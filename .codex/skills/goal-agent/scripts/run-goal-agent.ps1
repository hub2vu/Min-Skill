param(
    [Parameter(Mandatory = $true)]
    [string] $Goal,

    [string] $Workspace,

    [string] $OutputDir,

    [string] $RunName,

    [string] $Model,

    [switch] $Json,

    [switch] $BypassApprovals,

    [switch] $PersistSession
)

$ErrorActionPreference = "Stop"

function Get-FullPath([string] $Path) {
    return [System.IO.Path]::GetFullPath($Path)
}

if (-not $Workspace) {
    $Workspace = Join-Path $PSScriptRoot "..\..\..\.."
}

$Workspace = Get-FullPath $Workspace

if (-not (Test-Path -LiteralPath $Workspace -PathType Container)) {
    throw "Workspace does not exist: $Workspace"
}

if (-not $OutputDir) {
    $OutputDir = Join-Path $Workspace "docs\goal_agent_runs"
}

$OutputDir = Get-FullPath $OutputDir

if (-not $OutputDir.StartsWith($Workspace, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "OutputDir must stay inside Workspace. Workspace=$Workspace OutputDir=$OutputDir"
}

if (-not $RunName) {
    $stamp = Get-Date -Format "yyyyMMdd_HHmmss"
    $safe = ($Goal -replace "^/goal\s*", "" -replace "[^A-Za-z0-9._-]+", "_").Trim("_")
    if ($safe.Length -gt 48) {
        $safe = $safe.Substring(0, 48)
    }
    if (-not $safe) {
        $safe = "goal"
    }
    $RunName = "${stamp}_${safe}"
}

$RunDir = Get-FullPath (Join-Path $OutputDir $RunName)

if (-not $RunDir.StartsWith($OutputDir, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "RunDir must stay inside OutputDir. OutputDir=$OutputDir RunDir=$RunDir"
}

New-Item -ItemType Directory -Force -Path $RunDir | Out-Null

$trimmed = $Goal.Trim()
if ($trimmed.StartsWith("/goal", [System.StringComparison]::OrdinalIgnoreCase)) {
    $goalPrompt = $trimmed
} else {
    $goalPrompt = "/goal $trimmed"
}

$guard = @"
Work only under this workspace:
$Workspace

Save artifacts only inside that workspace unless the user explicitly provided another allowed path.
"@

$fullPrompt = "$guard`n`n$goalPrompt"
$lastMessage = Join-Path $RunDir "last_message.md"
$consoleLog = Join-Path $RunDir "console.log"
$metadataPath = Join-Path $RunDir "metadata.json"

$codex = Get-Command codex -ErrorAction SilentlyContinue
if (-not $codex) {
    throw "codex command was not found on PATH."
}

$args = @(
    "exec",
    "--enable", "goals",
    "--ephemeral",
    "--skip-git-repo-check",
    "-C", $Workspace,
    "-o", $lastMessage
)

if ($PersistSession) {
    $args = $args | Where-Object { $_ -ne "--ephemeral" }
}

if ($Model) {
    $args += @("-m", $Model)
}

if ($Json) {
    $args += "--json"
}

if ($BypassApprovals) {
    $args += "--dangerously-bypass-approvals-and-sandbox"
}

$args += $fullPrompt

$startedAt = (Get-Date).ToString("o")
$previousErrorActionPreference = $ErrorActionPreference
$previousNativePreference = $null
$hadNativePreference = Test-Path Variable:\PSNativeCommandUseErrorActionPreference
if ($hadNativePreference) {
    $previousNativePreference = $PSNativeCommandUseErrorActionPreference
    $PSNativeCommandUseErrorActionPreference = $false
}

try {
    $ErrorActionPreference = "Continue"
    $output = & $codex.Source @args 2>&1
    $exitCode = $LASTEXITCODE
} finally {
    $ErrorActionPreference = $previousErrorActionPreference
    if ($hadNativePreference) {
        $PSNativeCommandUseErrorActionPreference = $previousNativePreference
    }
}

$finishedAt = (Get-Date).ToString("o")

$output | Set-Content -LiteralPath $consoleLog -Encoding UTF8

$metadata = [ordered]@{
    started_at = $startedAt
    finished_at = $finishedAt
    exit_code = $exitCode
    workspace = $Workspace
    run_dir = $RunDir
    last_message = $lastMessage
    console_log = $consoleLog
    goal = $goalPrompt
    goals_feature = $true
    ephemeral = (-not $PersistSession)
}

$metadata | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath $metadataPath -Encoding UTF8

if ($exitCode -ne 0) {
    throw "codex exec failed with exit code $exitCode. See $consoleLog"
}

Write-Output $RunDir
