$ErrorActionPreference = "Stop"

$scriptPath = Join-Path $PSScriptRoot "..\scripts\invoke-pro.ps1"
$projectRoot = [System.IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\..\..\.."))
$rawFile = Join-Path $projectRoot "raw\1.webp"

if (-not (Test-Path -LiteralPath $rawFile)) {
    throw "Missing test fixture: $rawFile"
}

$output = & $scriptPath -Prompt "zip upload test" -File $rawFile -PrintCommand -SkipBrowserModelPreselect
if ($LASTEXITCODE -ne 0) {
    throw "invoke-pro.ps1 -PrintCommand exited with $LASTEXITCODE"
}

$fileArgCount = ([regex]::Matches($output, "--file")).Count
if ($fileArgCount -ne 1) {
    throw "Expected exactly one --file argument, got $fileArgCount. Output: $output"
}

if ($output -notmatch "\.zip`"") {
    throw "Expected the single --file argument to point to a ZIP. Output: $output"
}

if ($output -match [regex]::Escape("raw\1.webp")) {
    throw "Expected raw input file to be bundled, not passed directly. Output: $output"
}

Write-Output "PASS invoke-pro ZIP upload command generation"
