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

$script:ProjectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\..\.."))
$script:MaxUploadBytes = [int64](100 * 1024 * 1024)

function Quote-Arg {
    param([string]$Value)
    if ($null -eq $Value) {
        return '""'
    }
    return '"' + ($Value -replace '"', '\"') + '"'
}

function Format-ByteSize {
    param([int64]$Bytes)
    if ($Bytes -ge 1GB) {
        return ("{0:N1} GB" -f ($Bytes / 1GB))
    }
    if ($Bytes -ge 1MB) {
        return ("{0:N1} MB" -f ($Bytes / 1MB))
    }
    if ($Bytes -ge 1KB) {
        return ("{0:N1} KB" -f ($Bytes / 1KB))
    }
    return "$Bytes bytes"
}

function Get-RelativePathCompat {
    param(
        [string]$BasePath,
        [string]$TargetPath
    )

    $baseFull = [System.IO.Path]::GetFullPath($BasePath)
    if (-not $baseFull.EndsWith([System.IO.Path]::DirectorySeparatorChar)) {
        $baseFull += [System.IO.Path]::DirectorySeparatorChar
    }

    $targetFull = [System.IO.Path]::GetFullPath($TargetPath)
    $baseUri = [System.Uri]$baseFull
    $targetUri = [System.Uri]$targetFull
    if ($baseUri.Scheme -ne $targetUri.Scheme) {
        return $null
    }

    return ([System.Uri]::UnescapeDataString($baseUri.MakeRelativeUri($targetUri).ToString()) -replace '/', '\')
}

function Test-PathInsideProject {
    param([string]$Path)

    $relative = Get-RelativePathCompat -BasePath $script:ProjectRoot -TargetPath $Path
    if ([string]::IsNullOrWhiteSpace($relative)) {
        return $false
    }
    return (-not $relative.StartsWith("..\") -and -not [System.IO.Path]::IsPathRooted($relative))
}

function ConvertTo-ArchiveRelativePath {
    param([string]$Path)

    $fullPath = [System.IO.Path]::GetFullPath($Path)
    if (Test-PathInsideProject -Path $fullPath) {
        return Get-RelativePathCompat -BasePath $script:ProjectRoot -TargetPath $fullPath
    }

    $root = [System.IO.Path]::GetPathRoot($fullPath)
    $driveName = if ([string]::IsNullOrWhiteSpace($root)) { "external" } else { ($root -replace '[:\\\/]', '') }
    $tail = $fullPath.Substring($root.Length).TrimStart('\', '/')
    return (Join-Path (Join-Path "external" $driveName) $tail)
}

function Resolve-ProUploadFiles {
    param([string[]]$Entries)

    $includes = New-Object System.Collections.Generic.List[string]
    $excludes = New-Object System.Collections.Generic.List[string]

    foreach ($entry in $Entries) {
        if ([string]::IsNullOrWhiteSpace($entry)) {
            continue
        }
        $trimmed = $entry.Trim()
        if ($trimmed.StartsWith("!")) {
            $excludes.Add($trimmed.Substring(1))
        } else {
            $includes.Add($trimmed)
        }
    }

    $files = New-Object System.Collections.Generic.List[object]
    $seen = @{}

    foreach ($entry in $includes) {
        $candidate = if ([System.IO.Path]::IsPathRooted($entry)) {
            $entry
        } else {
            Join-Path $script:ProjectRoot $entry
        }

        $matches = @()
        if (Test-Path -LiteralPath $candidate) {
            $item = Get-Item -LiteralPath $candidate -Force
            if ($item.PSIsContainer) {
                $matches = @(Get-ChildItem -LiteralPath $item.FullName -Recurse -Force | Where-Object { -not $_.PSIsContainer })
            } else {
                $matches = @($item)
            }
        } else {
            $matches = @(Get-ChildItem -Path $candidate -Recurse -Force -ErrorAction SilentlyContinue | Where-Object { -not $_.PSIsContainer })
        }

        if ($matches.Count -eq 0) {
            throw "No files matched '$entry' for /pro upload."
        }

        foreach ($match in $matches) {
            $fullName = [System.IO.Path]::GetFullPath($match.FullName)
            if (-not $seen.ContainsKey($fullName)) {
                $seen[$fullName] = $true
                $files.Add($match)
            }
        }
    }

    if ($files.Count -eq 0) {
        throw "No files were selected for /pro upload."
    }

    if ($excludes.Count -gt 0) {
        $filtered = New-Object System.Collections.Generic.List[object]
        foreach ($file in $files) {
            $fullName = [System.IO.Path]::GetFullPath($file.FullName)
            $relative = Get-RelativePathCompat -BasePath $script:ProjectRoot -TargetPath $fullName
            $normalizedFull = $fullName -replace '/', '\'
            $normalizedRelative = if ($relative) { $relative -replace '/', '\' } else { "" }
            $isExcluded = $false

            foreach ($exclude in $excludes) {
                $excludePath = if ([System.IO.Path]::IsPathRooted($exclude)) {
                    $exclude
                } else {
                    Join-Path $script:ProjectRoot $exclude
                }
                $normalizedExclude = ([System.IO.Path]::GetFullPath($excludePath) -replace '/', '\')
                $normalizedExcludeRelative = (Get-RelativePathCompat -BasePath $script:ProjectRoot -TargetPath $normalizedExclude) -replace '/', '\'

                if ($normalizedFull -like $normalizedExclude -or $normalizedRelative -like $normalizedExcludeRelative) {
                    $isExcluded = $true
                    break
                }
            }

            if (-not $isExcluded) {
                $filtered.Add($file)
            }
        }
        $files = $filtered
    }

    if ($files.Count -eq 0) {
        throw "All selected /pro upload files were excluded."
    }

    return $files.ToArray()
}

function New-ProUploadZip {
    param([object[]]$Files)

    Add-Type -AssemblyName System.IO.Compression.FileSystem

    $uploadDir = Join-Path $script:ProjectRoot "output\pro_uploads"
    New-Item -ItemType Directory -Path $uploadDir -Force | Out-Null

    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $stageDir = Join-Path $uploadDir "staging-$stamp-$PID"
    $zipPath = Join-Path $uploadDir "pro-upload-$stamp-$PID.zip"

    if (Test-Path -LiteralPath $zipPath) {
        Remove-Item -LiteralPath $zipPath -Force
    }

    New-Item -ItemType Directory -Path $stageDir -Force | Out-Null
    $archivePaths = @{}

    try {
        foreach ($file in $Files) {
            $sourcePath = [System.IO.Path]::GetFullPath($file.FullName)
            $archivePath = ConvertTo-ArchiveRelativePath -Path $sourcePath
            if ($archivePaths.ContainsKey($archivePath)) {
                $extension = [System.IO.Path]::GetExtension($archivePath)
                $withoutExtension = $archivePath.Substring(0, $archivePath.Length - $extension.Length)
                $index = 2
                do {
                    $candidateArchivePath = "$withoutExtension-$index$extension"
                    $index++
                } while ($archivePaths.ContainsKey($candidateArchivePath))
                $archivePath = $candidateArchivePath
            }
            $archivePaths[$archivePath] = $true

            $destinationPath = Join-Path $stageDir $archivePath
            $destinationDir = Split-Path -Parent $destinationPath
            if (-not (Test-Path -LiteralPath $destinationDir)) {
                New-Item -ItemType Directory -Path $destinationDir -Force | Out-Null
            }
            Copy-Item -LiteralPath $sourcePath -Destination $destinationPath -Force
        }

        [System.IO.Compression.ZipFile]::CreateFromDirectory(
            $stageDir,
            $zipPath,
            [System.IO.Compression.CompressionLevel]::Optimal,
            $false
        )
    } finally {
        if (Test-Path -LiteralPath $stageDir) {
            Remove-Item -LiteralPath $stageDir -Recurse -Force -ErrorAction SilentlyContinue
        }
    }

    $zipItem = Get-Item -LiteralPath $zipPath
    if ($zipItem.Length -gt $script:MaxUploadBytes) {
        $actualSize = Format-ByteSize -Bytes $zipItem.Length
        $limitSize = Format-ByteSize -Bytes $script:MaxUploadBytes
        Remove-Item -LiteralPath $zipPath -Force -ErrorAction SilentlyContinue
        throw "Prepared /pro upload ZIP is $actualSize, above the browser upload limit of $limitSize. Reduce the file set before retrying."
    }

    Write-Host ("[pro] Bundled {0} file(s) into {1} ({2})." -f $Files.Count, $zipPath, (Format-ByteSize -Bytes $zipItem.Length))
    return $zipPath
}

function Find-Npx {
    $projectNodeDir = Join-Path $script:ProjectRoot ".tools\node-v24.15.0-win-x64"
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

function Ensure-LocalOracleZipUploadSupport {
    $localOracleRoot = Join-Path $script:ProjectRoot ".tools\oracle-local"
    $localOracleCli = Join-Path $localOracleRoot "node_modules\@steipete\oracle\dist\bin\oracle-cli.js"
    $promptJs = Join-Path $localOracleRoot "node_modules\@steipete\oracle\dist\src\browser\prompt.js"

    if (-not (Test-Path -LiteralPath $localOracleCli)) {
        $npmPath = $null
        if ($script:ProjectNodeDir) {
            $candidateNpm = Join-Path $script:ProjectNodeDir "npm.cmd"
            if (Test-Path -LiteralPath $candidateNpm) {
                $npmPath = $candidateNpm
            }
        }
        if (-not $npmPath) {
            $npmCommand = Get-Command "npm.cmd" -ErrorAction SilentlyContinue
            if (-not $npmCommand) {
                $npmCommand = Get-Command "npm" -ErrorAction SilentlyContinue
            }
            if (-not $npmCommand) {
                throw "npm was not found. Project-local Oracle is required for ZIP browser uploads."
            }
            $npmPath = $npmCommand.Source
        }

        Write-Host "[pro] Installing project-local Oracle for ZIP browser uploads..."
        & $npmPath install --prefix $localOracleRoot "@steipete/oracle@0.11.0"
        if ($LASTEXITCODE -ne 0) {
            throw "npm install @steipete/oracle failed with exit code $LASTEXITCODE."
        }
    }

    if (-not (Test-Path -LiteralPath $promptJs)) {
        throw "Project-local Oracle is missing browser prompt support at $promptJs."
    }

    $promptText = Get-Content -LiteralPath $promptJs -Raw
    if ($promptText -notmatch '"\.zip"') {
        $patchedText = $promptText -replace '("\.pdf",)', "`$1`r`n    `".zip`",`r`n    `".7z`",`r`n    `".tar`",`r`n    `".gz`",`r`n    `".tgz`","
        if ($patchedText -eq $promptText) {
            throw "Could not patch project-local Oracle to upload ZIP files through the browser picker."
        }
        Set-Content -LiteralPath $promptJs -Value $patchedText -Encoding UTF8
        Write-Host "[pro] Patched project-local Oracle to treat ZIP archives as browser uploads."
    }

    return $localOracleCli
}

function Find-OracleInvocation {
    param(
        [string]$NpxPath,
        [switch]$RequireLocalZipUpload
    )

    $localOracleCli = Join-Path $script:ProjectRoot ".tools\oracle-local\node_modules\@steipete\oracle\dist\bin\oracle-cli.js"
    if ($RequireLocalZipUpload) {
        $localOracleCli = Ensure-LocalOracleZipUploadSupport
    }
    if (Test-Path -LiteralPath $localOracleCli) {
        $nodePath = $null
        if ($script:ProjectNodeDir) {
            $candidateNode = Join-Path $script:ProjectNodeDir "node.exe"
            if (Test-Path -LiteralPath $candidateNode) {
                $nodePath = $candidateNode
            }
        }
        if (-not $nodePath) {
            $nodeCommand = Get-Command "node" -ErrorAction SilentlyContinue
            if (-not $nodeCommand) {
                throw "node was not found while preparing local Oracle CLI."
            }
            $nodePath = $nodeCommand.Source
        }
        return [pscustomobject]@{
            Command = $nodePath
            Args = @($localOracleCli)
        }
    }

    return [pscustomobject]@{
        Command = $NpxPath
        Args = @("-y", "@steipete/oracle")
    }
}

if ($FirstLogin -and [string]::IsNullOrWhiteSpace($Prompt)) {
    $Prompt = "HI"
}

if (-not $FirstLogin -and [string]::IsNullOrWhiteSpace($Prompt)) {
    throw "Prompt is required. Example: .\invoke-pro.ps1 -Prompt `"Review this plan.`""
}

if ($CopyOnly) {
    throw "-CopyOnly is disabled for this project. /pro file context must use the single-ZIP browser upload path."
}

$requestedFiles = @($File | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
if ($FirstLogin -and $requestedFiles.Count -gt 0) {
    throw "Do not attach files while running -FirstLogin. Log in first, then run /pro with -File."
}

$npxPath = Find-Npx
if ($script:ProjectNodeDir) {
    $env:Path = "$script:ProjectNodeDir;$env:Path"
}

$uploadZipPath = $null
if ($requestedFiles.Count -gt 0) {
    $resolvedUploadFiles = Resolve-ProUploadFiles -Entries $requestedFiles
    $uploadZipPath = New-ProUploadZip -Files $resolvedUploadFiles
}

$oracleInvocation = Find-OracleInvocation -NpxPath $npxPath -RequireLocalZipUpload:($null -ne $uploadZipPath)
$oracleArgs = @($oracleInvocation.Args)

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

if ($uploadZipPath) {
    $oracleArgs += @("--browser-attachments", "always")
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

if ($uploadZipPath) {
    $oracleArgs += @("--file", $uploadZipPath)
}

$oracleArgs += @("-p", $Prompt)

if ($PrintCommand) {
    $printable = @((Quote-Arg $oracleInvocation.Command)) + ($oracleArgs | ForEach-Object { Quote-Arg $_ })
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
    & $oracleInvocation.Command @oracleArgs 2>&1 | Tee-Object -FilePath $capturePath
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
