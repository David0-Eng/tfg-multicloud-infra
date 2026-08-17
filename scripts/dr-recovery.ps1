# Rebuilds the service on Azure after losing the primary and measures the RTO.
# Use -Destroy to tear the recovery environment down again.
# Needs az login and terraform.tfvars in envs/azure-dev.

param(
    [switch]$Destroy
)

# PowerShell 5.1 turns stderr from a native command into a terminating error and
# terraform writes its warnings there.
$ErrorActionPreference = "Continue"
$envDir = Join-Path $PSScriptRoot "..\envs\azure-dev"
$log = Join-Path $PSScriptRoot "..\dr-recovery.log"

function Say($msg) {
    Write-Host $msg
    Add-Content -Path $log -Value $msg -Encoding utf8
}

if ($Destroy) {
    Write-Host "Destroying the recovery environment..."
    terraform "-chdir=$envDir" destroy -auto-approve
    exit $LASTEXITCODE
}

Say "=== DR RECOVERY START: $(Get-Date -Format 'HH:mm:ss') ==="
$sw = [System.Diagnostics.Stopwatch]::StartNew()

terraform "-chdir=$envDir" apply -auto-approve
if ($LASTEXITCODE -ne 0) {
    Say "terraform apply failed. Check the session with 'az login' and retry."
    exit 1
}
$applyTime = $sw.Elapsed

$ip = terraform "-chdir=$envDir" output -raw vm_public_ip
if (-not $ip) {
    Say "Could not read vm_public_ip from the state. Recovery cannot be verified."
    exit 1
}
$healthUrl = "http://${ip}:8000/health"
Say ("[{0}] Infrastructure ready in {1}. Polling {2}" -f (Get-Date -Format 'HH:mm:ss'), $applyTime.ToString('mm\:ss'), $healthUrl)

# Infrastructure being ready is not recovery, cloud-init still has to install
# Docker and start the stack
$recovered = $false
while (-not $recovered -and $sw.Elapsed.TotalMinutes -lt 20) {
    $state = "no answer yet"
    try {
        $r = Invoke-WebRequest -Uri $healthUrl -TimeoutSec 5 -UseBasicParsing
        if ($r.StatusCode -eq 200) { $recovered = $true } else { $state = "HTTP $($r.StatusCode)" }
    } catch {
    }
    if (-not $recovered) {
        Say ("[{0}] {1} ({2} elapsed)" -f (Get-Date -Format 'HH:mm:ss'), $state, $sw.Elapsed.ToString('mm\:ss'))
        Start-Sleep -Seconds 10
    }
}

$sw.Stop()
if ($recovered) {
    Say ""
    Say "=== SERVICE RECOVERED ==="
    Say ("Infrastructure ready : {0}" -f $applyTime.ToString('mm\:ss'))
    Say ("RTO (total)          : {0}" -f $sw.Elapsed.ToString('mm\:ss'))
    Say ("Service URL          : http://{0}:8000" -f $ip)
    Say ("Log saved to         : {0}" -f $log)
} else {
    Say "Recovery did NOT complete within 20 minutes. Check cloud-init logs on the VM."
    exit 1
}
