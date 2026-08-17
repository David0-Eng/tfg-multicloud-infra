# Polls the load balancer once a second while watching target health, so the log
# shows whether stopping an instance was visible to users. Stop one instance from
# the console, press ENTER to mark that moment, then Ctrl+C for the summary.

param(
    [string]$Env = "aws-ha",
    [string]$Region = "eu-south-2",
    [string]$TargetGroupName = "tfg-ha-tg",
    [int]$TimeoutSec = 3
)

# PowerShell 5.1 turns stderr from a native command into a terminating error and
# both terraform and aws write there.
$ErrorActionPreference = "Continue"
$envDir = Join-Path $PSScriptRoot "..\envs\$Env"
$log = Join-Path $PSScriptRoot "..\failover-$Env.log"

function Say($msg) {
    Write-Host $msg
    Add-Content -Path $log -Value $msg -Encoding utf8
}

$url = terraform "-chdir=$envDir" output -raw alb_url
if (-not $url) { throw "Could not read alb_url from $Env" }
$tgArn = aws elbv2 describe-target-groups --region $Region --names $TargetGroupName `
         --query "TargetGroups[0].TargetGroupArn" --output text
if (-not $tgArn -or $tgArn -eq "None") { throw "Target group $TargetGroupName not found" }

Say "=== FAILOVER TEST ==="
Say "URL          : $url"
Say "Target group : $TargetGroupName"
Say "Press ENTER right after stopping the instance in the console."
Say ""

$total = 0; $failed = 0
$t0 = $null
$detected = $null
$firstFail = $null
$prevHealth = ""

try {
    while ($true) {
        $stamp = Get-Date

        if (-not $t0 -and [Console]::KeyAvailable) {
            if ([Console]::ReadKey($true).Key -eq "Enter") {
                $t0 = $stamp
                Say ("[{0}] >>> FAILURE INJECTED <<<" -f $stamp.ToString('HH:mm:ss'))
            }
        }

        $total++
        $code = "FAIL"
        try {
            $r = Invoke-WebRequest -Uri $url -TimeoutSec $TimeoutSec -UseBasicParsing
            $code = $r.StatusCode
        } catch {
            $failed++
            if (-not $firstFail) { $firstFail = $stamp }
        }

        # --output text can come back as several lines, which PowerShell turns
        # into an array, so join it before treating it as a string
        $raw = aws elbv2 describe-target-health --region $Region --target-group-arn $tgArn `
               --query "TargetHealthDescriptions[].TargetHealth.State" --output text
        $health = ((@($raw) -join " ") -replace "\s+", " ").Trim()

        if ($health -ne $prevHealth) {
            Say ("[{0}] targets -> {1}" -f $stamp.ToString('HH:mm:ss'), $health)
            if (-not $detected -and $health -match "unhealthy") {
                $detected = $stamp
                Say ("[{0}] >>> UNHEALTHY TARGET DETECTED <<<" -f $stamp.ToString('HH:mm:ss'))
            }
            $prevHealth = $health
        }

        Say ("[{0}] HTTP {1}  targets: {2}" -f $stamp.ToString('HH:mm:ss'), $code, $health)
        Start-Sleep -Seconds 1
    }
}
finally {
    Say ""
    Say "=== SUMMARY ==="
    Say ("Requests sent        : {0}" -f $total)
    Say ("Requests failed      : {0}" -f $failed)
    if ($total -gt 0) {
        Say ("Availability         : {0:N2} %" -f (100 * ($total - $failed) / $total))
    }
    if ($t0 -and $detected) {
        Say ("Detection time       : {0:N0} s" -f ($detected - $t0).TotalSeconds)
    } elseif ($detected) {
        Say "Detection time       : marker not set, see timestamps above"
    }
    if ($firstFail) {
        Say ("First failed request : {0}" -f $firstFail.ToString('HH:mm:ss'))
    } else {
        Say "First failed request : none, the outage was transparent"
    }
    Say ("Log saved to         : {0}" -f $log)
}
