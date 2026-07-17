param(
    [string]$ModRoot = (Join-Path $PSScriptRoot "..\mod\minghm_companion"),
    [string]$GameRoot = 'D:\steam\steamapps\common\Crusader Kings III\game',
    [string]$ReferenceModRoot = 'D:\steam\steamapps\workshop\content\1158310\2713348525'
)

$ErrorActionPreference = 'Stop'
if (-not (Test-Path -LiteralPath $ModRoot)) { throw "Missing mod root: $ModRoot" }
if (-not (Test-Path -LiteralPath $GameRoot)) { throw "Missing CK3 game root: $GameRoot" }

$scriptFiles = Get-ChildItem -LiteralPath $ModRoot -Recurse -Filter '*.txt' -File
$references = @()
foreach ($scriptFile in $scriptFiles) {
    $text = Get-Content -Raw -Encoding utf8 -LiteralPath $scriptFile.FullName
    foreach ($match in [regex]::Matches($text, 'reference\s*=\s*"([^"]+)"')) {
        $references += $match.Groups[1].Value
    }
}
$references = $references | Sort-Object -Unique
if ($references.Count -eq 0) { throw 'No visual references found.' }

$missing = @()
foreach ($reference in $references) {
    $gamePath = Join-Path -Path $GameRoot -ChildPath $reference
    $referenceModPath = Join-Path -Path $ReferenceModRoot -ChildPath $reference
    if (-not (Test-Path -LiteralPath $gamePath) -and -not (Test-Path -LiteralPath $referenceModPath)) {
        $missing += $reference
    }
}
if ($missing.Count -gt 0) { throw "Missing visual reference(s): $($missing -join ', ')" }

Write-Host "Asset reference verification passed: $($references.Count) existing upstream visual reference(s)."
