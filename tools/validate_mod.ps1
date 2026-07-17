param(
    [string]$ModRoot = (Join-Path $PSScriptRoot "..\\mod\\minghm_companion")
)

$ErrorActionPreference = 'Stop'
$required = @(
    'descriptor.mod',
    'common\\on_action\\minghm_on_actions.txt',
    'common\\scripted_triggers\\minghm_core_triggers.txt',
    'common\\script_values\\minghm_values.txt',
    'common\\script_values\\minghm_outlook_values.txt',
    'common\\scripted_effects\\minghm_core_effects.txt',
    'common\\scripted_effects\\minghm_outlook_effects.txt',
    'events\\minghm_core_events.txt',
    'events\\minghm_outlook_events.txt'
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
if ($allText -match '(?m)^\s*(?!#).*\bchange_government\s*=') { throw 'This mod must not alter government.' }
if ($allText -match '(?m)^\s*(?!#).*\bcreate_character\s*=') { throw 'This phase must not create characters.' }

$localization = Join-Path $ModRoot 'localization\simp_chinese\minghm_policy_l_simp_chinese.yml'
if (Test-Path -LiteralPath $localization) {
    $locText = Get-Content -Raw -Encoding utf8 $localization
    foreach ($key in @('minghm_policy.1000.t', 'minghm_policy.1001.t', 'minghm_policy.1002.t')) {
        if ($locText -notmatch [regex]::Escape($key)) { throw "Missing localization key: $key" }
    }
}

Write-Host 'Static mod structure and guard-rail checks passed.'
