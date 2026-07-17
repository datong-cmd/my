param(
    [string]$ModRoot = (Join-Path $PSScriptRoot "..\\mod\\minghm_companion")
)

$ErrorActionPreference = 'Stop'
$required = @(
    'descriptor.mod',
    'common\\on_action\\minghm_on_actions.txt',
    'common\\scripted_triggers\\minghm_core_triggers.txt',
    'common\\script_values\\minghm_values.txt',
    'common\\scripted_effects\\minghm_core_effects.txt',
    'events\\minghm_core_events.txt'
)

foreach ($relative in $required) {
    $path = Join-Path $ModRoot $relative
    if (-not (Test-Path -LiteralPath $path)) { throw "Missing required file: $relative" }
}

$scriptFiles = Get-ChildItem -LiteralPath $ModRoot -Recurse -File |
    Where-Object { $_.Extension -in '.txt', '.mod' }
$allText = ($scriptFiles | ForEach-Object { Get-Content -Raw -Encoding utf8 $_.FullName }) -join "`n"
foreach ($forbidden in @('any_living_character', 'every_title', 'every_county')) {
    if ($allText -match [regex]::Escape($forbidden)) { throw "Forbidden performance pattern found: $forbidden" }
}

if ($allText -notmatch 'title:h_greatming') { throw 'The Ming title gate is missing.' }
if ($allText -match '(?m)^\s*(?!#).*\bhuang_quan_value\s*=') { throw 'This mod must not write the upstream huang_quan_value.' }

Write-Host 'Static mod structure and guard-rail checks passed.'
