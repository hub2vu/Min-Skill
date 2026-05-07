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
    [switch]$ForceThinkingTime,
    [ValidateSet("auto", "select", "current", "ignore")]
    [string]$BrowserModelStrategy = "auto",
    [switch]$PrintCommand,
    [switch]$SkipEnvironmentCheck,
    [int]$InputTimeoutMs = 120000,
    [string]$AutoReattachDelay = "5s",
    [string]$AutoReattachInterval = "3s",
    [string]$AutoReattachTimeout = "60s",
    [int]$HeartbeatSeconds = 30,
    [int]$BrowserPort = 0,
    [switch]$NoBrowserLock,
    [switch]$SkipBrowserModelPreselect,
    [int]$BrowserLockTimeoutSeconds = 7200
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
    $projectNodeDir = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\..\..\.tools\node-v24.15.0-win-x64"))
    $projectNode = Join-Path $projectNodeDir "node.exe"
    $projectNpx = Join-Path $projectNodeDir "npx.cmd"
    if ((Test-Path -LiteralPath $projectNode) -and (Test-Path -LiteralPath $projectNpx)) {
        if (-not $SkipEnvironmentCheck) {
            $nodeVersionText = (& $projectNode --version).Trim()
            if ($nodeVersionText -notmatch '^v?(\d+)\.') {
                throw "Could not determine project Node.js version from '$nodeVersionText'. Oracle requires Node.js 24+."
            }
            $nodeMajor = [int]$Matches[1]
            if ($nodeMajor -lt 24) {
                throw "Oracle requires Node.js 24+. Project Node.js is $nodeVersionText at $projectNode."
            }
        }
        $script:ProjectNodeDir = $projectNodeDir
        return $projectNpx
    }

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

function Acquire-BrowserLock {
    param([int]$TimeoutSeconds)

    $lockPath = Join-Path ([System.IO.Path]::GetTempPath()) "codex-pro-browser.lock"
    $deadline = (Get-Date).AddSeconds([Math]::Max(1, $TimeoutSeconds))
    $announced = $false

    while ($true) {
        try {
            $stream = [System.IO.File]::Open(
                $lockPath,
                [System.IO.FileMode]::OpenOrCreate,
                [System.IO.FileAccess]::ReadWrite,
                [System.IO.FileShare]::None
            )
            $stream.SetLength(0)
            $content = "pid=$PID`nstarted=$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss K')`n"
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($content)
            $stream.Write($bytes, 0, $bytes.Length)
            $stream.Flush()
            return $stream
        } catch [System.IO.IOException] {
            if ((Get-Date) -ge $deadline) {
                throw "Timed out waiting for /pro browser lock at $lockPath. Another browser-mode Pro run may still be active."
            }
            if (-not $announced) {
                Write-Host "[pro] Waiting for active browser-mode Pro run to finish..."
                $announced = $true
            }
            Start-Sleep -Seconds 5
        }
    }
}

function Ensure-ProBrowserModel {
    if ($SkipBrowserModelPreselect) {
        return
    }

    if ($FirstLogin -or $CopyOnly -or $DryRun) {
        return
    }

    if ($Model -notmatch '(?i)\bpro\b') {
        return
    }

    $projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\..\.."))
    $ensureScript = Join-Path $PSScriptRoot "ensure-pro-browser-model.js"
    if (-not (Test-Path -LiteralPath $ensureScript)) {
        throw "Missing Pro browser preselect script at $ensureScript."
    }

    $nodePath = $null
    $npmPath = $null
    if ($script:ProjectNodeDir) {
        $candidateNode = Join-Path $script:ProjectNodeDir "node.exe"
        $candidateNpm = Join-Path $script:ProjectNodeDir "npm.cmd"
        if (Test-Path -LiteralPath $candidateNode) {
            $nodePath = $candidateNode
        }
        if (Test-Path -LiteralPath $candidateNpm) {
            $npmPath = $candidateNpm
        }
    }

    if (-not $nodePath) {
        $nodeCommand = Get-Command "node" -ErrorAction SilentlyContinue
        if (-not $nodeCommand) {
            throw "node was not found while preparing ChatGPT Pro selection."
        }
        $nodePath = $nodeCommand.Source
    }

    if (-not $npmPath) {
        $npmCommand = Get-Command "npm.cmd" -ErrorAction SilentlyContinue
        if (-not $npmCommand) {
            $npmCommand = Get-Command "npm" -ErrorAction SilentlyContinue
        }
        if (-not $npmCommand) {
            throw "npm was not found while preparing Playwright for ChatGPT Pro selection."
        }
        $npmPath = $npmCommand.Source
    }

    $playwrightPrefix = Join-Path $projectRoot ".tools\playwright-check"
    $playwrightModule = Join-Path $playwrightPrefix "node_modules\playwright"
    if (-not (Test-Path -LiteralPath $playwrightModule)) {
        Write-Host "[pro] Installing Playwright package for ChatGPT Pro UI verification..."
        $previousSkipDownload = $env:PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD
        try {
            $env:PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = "1"
            & $npmPath install --prefix $playwrightPrefix playwright
            if ($LASTEXITCODE -ne 0) {
                throw "npm install playwright failed with exit code $LASTEXITCODE."
            }
        } finally {
            $env:PLAYWRIGHT_SKIP_BROWSER_DOWNLOAD = $previousSkipDownload
        }
    }

    $previousNodePath = $env:NODE_PATH
    try {
        $env:NODE_PATH = (Join-Path $playwrightPrefix "node_modules")
        Write-Host "[pro] Ensuring ChatGPT UI is set to Pro..."
        & $nodePath $ensureScript
        if ($LASTEXITCODE -ne 0) {
            throw "Could not verify/select ChatGPT Pro in the browser UI."
        }
    } finally {
        $env:NODE_PATH = $previousNodePath
    }
}

if ($FirstLogin -and [string]::IsNullOrWhiteSpace($Prompt)) {
    $Prompt = "HI"
}

if (-not $FirstLogin -and [string]::IsNullOrWhiteSpace($Prompt)) {
    throw "Prompt is required. Example: .\invoke-pro.ps1 -Prompt `"Review this plan.`""
}

$npxPath = Find-Npx
if ($script:ProjectNodeDir) {
    $env:Path = "$script:ProjectNodeDir;$env:Path"
}
$oracleArgs = @(
    "-y",
    "@steipete/oracle"
)

if ($CopyOnly) {
    $oracleArgs += @("--render", "--copy")
} else {
    $resolvedBrowserModelStrategy = $BrowserModelStrategy
    if ($resolvedBrowserModelStrategy -eq "auto") {
        $resolvedBrowserModelStrategy = "select"
        if ($Model -match '(?i)\bpro\b') {
            $resolvedBrowserModelStrategy = "ignore"
        }
    }
    $oracleArgs += @(
        "--engine", "browser",
        "--model", $Model,
        "--browser-manual-login",
        "--browser-model-strategy", $resolvedBrowserModelStrategy
    )

    $shouldPassThinkingTime = -not [string]::IsNullOrWhiteSpace($ThinkingTime)
    if ($Model -match '(?i)\bpro\b' -and -not $ForceThinkingTime) {
        $shouldPassThinkingTime = $false
    }
    if ($shouldPassThinkingTime) {
        $oracleArgs += @("--browser-thinking-time", $ThinkingTime)
    }
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

if ($BrowserPort -gt 0 -and -not $CopyOnly) {
    $oracleArgs += @("--browser-port", [string]$BrowserPort)
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

$browserLock = $null
$capturePath = $null
$finalExitCode = 0

try {
    if (-not $CopyOnly -and -not $DryRun -and -not $NoBrowserLock) {
        $browserLock = Acquire-BrowserLock -TimeoutSeconds $BrowserLockTimeoutSeconds
    }

    Ensure-ProBrowserModel

    $capturePath = [System.IO.Path]::GetTempFileName()
    & $npxPath @oracleArgs 2>&1 | Tee-Object -FilePath $capturePath
    $oracleExitCode = if ($null -eq $LASTEXITCODE) { 0 } else { [int]$LASTEXITCODE }

    $oracleText = ""
    if (Test-Path -LiteralPath $capturePath) {
        $oracleText = Get-Content -LiteralPath $capturePath -Raw -ErrorAction SilentlyContinue
    }

    if ($oracleText -match "ERROR:\s*Chrome window closed before oracle finished|Chrome disconnected before completion") {
        $oracleExitCode = 1
    }

    $finalExitCode = $oracleExitCode
} finally {
    if ($capturePath -and (Test-Path -LiteralPath $capturePath)) {
        Remove-Item -LiteralPath $capturePath -Force -ErrorAction SilentlyContinue
    }
    if ($browserLock) {
        if ($browserLock -is [System.Array]) {
            foreach ($item in $browserLock) {
                if ($item -is [System.IDisposable]) {
                    $item.Dispose()
                }
            }
        } elseif ($browserLock -is [System.IDisposable]) {
            $browserLock.Dispose()
        }
    }
}

exit $finalExitCode
