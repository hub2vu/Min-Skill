param(
    [string]$Prompt,
    [string[]]$File = @(),
    [string]$Model = "gpt-5.5-pro",
    [ValidateSet("light", "standard", "extended", "heavy")]
    [string]$ThinkingTime = "heavy",
    [switch]$FirstLogin,
    [switch]$DryRun,
    [switch]$CopyOnly,
    [switch]$KeepBrowser,
    [switch]$PrintCommand,
    [switch]$SkipEnvironmentCheck,
    [int]$InputTimeoutMs = 120000,
    [string]$AutoReattachDelay = "5s",
    [string]$AutoReattachInterval = "3s",
    [string]$AutoReattachTimeout = "60s",
    [int]$HeartbeatSeconds = 30
)

$ErrorActionPreference = "Stop"

function Quote-Arg {
    param([string]$Value)
    if ($null -eq $Value) {
        return '""'
    }
    return '"' + ($Value -replace '"', '\"') + '"'
}

function Find-Npx {
    if (-not $SkipEnvironmentCheck) {
        $node = Get-Command "node" -ErrorAction SilentlyContinue
        if (-not $node) {
            throw "node was not found. Install Node.js 24+ and restart PowerShell."
        }

        $nodeVersionText = (& $node.Source --version).Trim()
        if ($nodeVersionText -notmatch '^v?(\d+)\.') {
            throw "Could not determine Node.js version from '$nodeVersionText'. Oracle requires Node.js 24+."
        }
        $nodeMajor = [int]$Matches[1]
        if ($nodeMajor -lt 24) {
            throw "Oracle requires Node.js 24+. Current Node.js is $nodeVersionText at $($node.Source)."
        }
    }

    $npx = Get-Command "npx.cmd" -ErrorAction SilentlyContinue
    if (-not $npx) {
        $npx = Get-Command "npx" -ErrorAction SilentlyContinue
    }
    if (-not $npx) {
        throw "npx was not found. Install Node.js 24+ and restart PowerShell."
    }
    return $npx.Source
}

if ($FirstLogin -and [string]::IsNullOrWhiteSpace($Prompt)) {
    $Prompt = "HI"
}

if (-not $FirstLogin -and [string]::IsNullOrWhiteSpace($Prompt)) {
    throw "Prompt is required. Example: .\invoke-pro.ps1 -Prompt `"Review this plan.`""
}

$npxPath = Find-Npx
$oracleArgs = @(
    "-y",
    "@steipete/oracle"
)

if ($CopyOnly) {
    $oracleArgs += @("--render", "--copy")
} else {
    $oracleArgs += @(
        "--engine", "browser",
        "--model", $Model,
        "--browser-manual-login",
        "--browser-thinking-time", $ThinkingTime
    )
}

if ($FirstLogin) {
    $oracleArgs += @(
        "--browser-keep-browser",
        "--browser-input-timeout", [string]$InputTimeoutMs
    )
} elseif (-not $CopyOnly) {
    $oracleArgs += @(
        "--browser-auto-reattach-delay", $AutoReattachDelay,
        "--browser-auto-reattach-interval", $AutoReattachInterval,
        "--browser-auto-reattach-timeout", $AutoReattachTimeout,
        "--heartbeat", [string]$HeartbeatSeconds
    )
}

if ($KeepBrowser -and -not $CopyOnly -and -not $FirstLogin) {
    $oracleArgs += "--browser-keep-browser"
}

if ($DryRun) {
    $oracleArgs += @("--dry-run", "summary")
}

foreach ($entry in $File) {
    if (-not [string]::IsNullOrWhiteSpace($entry)) {
        $oracleArgs += @("--file", $entry)
    }
}

$oracleArgs += @("-p", $Prompt)

if ($PrintCommand) {
    $printable = @((Quote-Arg $npxPath)) + ($oracleArgs | ForEach-Object { Quote-Arg $_ })
    Write-Output ($printable -join " ")
    exit 0
}

& $npxPath @oracleArgs
exit $LASTEXITCODE
