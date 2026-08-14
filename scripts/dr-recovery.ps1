# Disaster-recovery runbook: recover the service on Azure (secondary cloud)
# and measure the RTO (time from decision to service responding).
#
# Usage:
#   .\dr-recovery.ps1              # recover on Azure and measure RTO
#   .\dr-recovery.ps1 -Destroy     # tear the recovery environment down
#
# Requires: az login done, terraform.tfvars present in envs/azure-dev
# (including stack_repo_url so the stack deploys unattended).

param(
    [switch]$Destroy
)

$ErrorActionPreference = "Stop"
$envDir = Join-Path $PSScriptRoot "..\envs\azure-dev"

if ($Destroy) {
    Write-Host "Destroying the recovery environment..."
    terraform "-chdir=$envDir" destroy -auto-approve
    exit $LASTEXITCODE
}

Write-Host "=== DR RECOVERY START: $(Get-Date -Format 'HH:mm:ss') ==="
$sw = [System.Diagnostics.Stopwatch]::StartNew()

# 1. Recreate the whole secondary environment from code
terraform "-chdir=$envDir" apply -auto-approve
if ($LASTEXITCODE -ne 0) { throw "terraform apply failed" }
$applyTime = $sw.Elapsed

# 2. Wait until the application actually answers (real service recovery,
#    not just infrastructure created): cloud-init still has to install
#    Docker and start the stack.
$ip = terraform "-chdir=$envDir" output -raw vm_public_ip
$healthUrl = "http://${ip}:8000/health"
Write-Host "Infrastructure up in $($applyTime.ToString('mm\:ss')). Polling $healthUrl ..."

$recovered = $false
while (-not $recovered -and $sw.Elapsed.TotalMinutes -lt 20) {
    try {
        $r = Invoke-WebRequest -Uri $healthUrl -TimeoutSec 5 -UseBasicParsing
        if ($r.StatusCode -eq 200) { $recovered = $true }
    } catch {
        Start-Sleep -Seconds 10
    }
}

$sw.Stop()
if ($recovered) {
    Write-Host ""
    Write-Host "=== SERVICE RECOVERED ==="
    Write-Host "Infrastructure ready : $($applyTime.ToString('mm\:ss'))"
    Write-Host "RTO (total)          : $($sw.Elapsed.ToString('mm\:ss'))"
    Write-Host "Service URL          : http://${ip}:8000"
} else {
    Write-Host "Recovery did NOT complete within 20 minutes. Check cloud-init logs on the VM."
    exit 1
}
