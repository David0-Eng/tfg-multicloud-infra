# Times a deployment from nothing until the service actually answers.
# Needs an active provider session (aws login / az login).

param(
    [string]$Env = "azure-dev",
    [int]$Port = 3000,
    [string]$UrlOutput = "",
    [switch]$Clean,
    [switch]$Destroy,
    [int]$TimeoutMinutes = 20
)

# PowerShell 5.1 turns stderr from a native command into a terminating error and
# terraform writes its warnings there, so exit codes are checked by hand instead.
$ErrorActionPreference = "Continue"
$envDir = Join-Path $PSScriptRoot "..\envs\$Env"
$log = Join-Path $PSScriptRoot "..\measure-$Env.log"

function Say($msg) {
    $line = "[{0}] {1}" -f (Get-Date -Format 'HH:mm:ss'), $msg
    Write-Host $line
    Add-Content -Path $log -Value $line -Encoding utf8
}

if (-not (Test-Path $envDir)) { throw "Environment not found: $envDir" }
Say "=== MEASURING $Env ==="

if ($Clean) {
    Say "Destroying any existing resources first..."
    terraform "-chdir=$envDir" destroy -auto-approve | Out-Null
    Say "Clean slate ready."
}

Say "Running plan..."
$planOut = terraform "-chdir=$envDir" plan -no-color | Out-String
if ($LASTEXITCODE -ne 0) {
    Say "terraform plan failed. Check the session with 'aws login' or 'az login' and retry."
    exit 1
}
$planned = 0
if ($planOut -match 'Plan:\s+(\d+)\s+to add') { $planned = [int]$Matches[1] }
Say "Plan proposes $planned resources to add."

Say "Applying..."
$sw = [System.Diagnostics.Stopwatch]::StartNew()
terraform "-chdir=$envDir" apply -auto-approve | Out-Null
if ($LASTEXITCODE -ne 0) { throw "terraform apply failed" }
$applyTime = $sw.Elapsed
Say ("Infrastructure ready in {0}." -f $applyTime.ToString('mm\:ss'))

# Each environment names its address output differently
if (-not $UrlOutput) {
    foreach ($cand in @("vm_public_ip", "instance_public_ip", "public_ip")) {
        $v = terraform "-chdir=$envDir" output -raw $cand
        if ($LASTEXITCODE -eq 0 -and $v) { $UrlOutput = $cand; break }
    }
}
if (-not $UrlOutput) { throw "No usable output found. Pass -UrlOutput explicitly." }

$val = terraform "-chdir=$envDir" output -raw $UrlOutput
if ($val -match '^https?://') { $baseUrl = $val } else { $baseUrl = "http://${val}:$Port" }
Say "Polling $baseUrl every 10s until it answers..."

# The apply time on its own is misleading, cloud-init is still working
$up = $false
while (-not $up -and $sw.Elapsed.TotalMinutes -lt $TimeoutMinutes) {
    try {
        $r = Invoke-WebRequest -Uri $baseUrl -TimeoutSec 5 -UseBasicParsing
        if ($r.StatusCode -ge 200 -and $r.StatusCode -lt 400) { $up = $true }
    } catch {
        Start-Sleep -Seconds 10
    }
}
$sw.Stop()

if (-not $up) {
    Say "Service did NOT answer within $TimeoutMinutes minutes. Check cloud-init on the VM."
    exit 1
}

$bootstrap = $sw.Elapsed - $applyTime
Say ""
Say "=== RESULTS ==="
Say ("Resources created      : {0}" -f $planned)
Say ("Infrastructure ready   : {0}" -f $applyTime.ToString('mm\:ss'))
Say ("Bootstrap (cloud-init) : {0}" -f $bootstrap.ToString('mm\:ss'))
Say ("Service reachable in   : {0}" -f $sw.Elapsed.ToString('mm\:ss'))
Say ("Service URL            : {0}" -f $baseUrl)
Say ("Log saved to           : {0}" -f $log)

if ($Destroy) {
    Say "Destroying..."
    terraform "-chdir=$envDir" destroy -auto-approve | Out-Null
    Say "Environment destroyed."
} else {
    Say "Environment left running. Destroy it when you are done taking screenshots."
}
