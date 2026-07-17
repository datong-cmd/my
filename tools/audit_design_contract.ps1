param(
    [string]$RepositoryRoot = (Join-Path $PSScriptRoot "..")
)

$ErrorActionPreference = 'Stop'
$modRoot = Join-Path $RepositoryRoot 'mod\minghm_companion'
if (-not (Test-Path -LiteralPath $modRoot)) { throw "Missing mod root: $modRoot" }

$scriptFiles = Get-ChildItem -LiteralPath $modRoot -Recurse -File |
    Where-Object { $_.Extension -in '.txt', '.mod' }
$allTextParts = @()
foreach ($scriptFile in $scriptFiles) {
    $allTextParts += Get-Content -Raw -Encoding utf8 -LiteralPath $scriptFile.FullName
}
$allText = $allTextParts -join "`n"
$forbidden = @(
    'any_living_character', 'every_title', 'every_county', 'every_vassal', 'every_sub_realm_title',
    'create_character', 'create_faction', 'add_building', 'add_maa', 'create_maa',
    'spawn_army', 'create_war', 'change_government', 'create_situation'
)
foreach ($token in $forbidden) {
    if ($allText -match [regex]::Escape($token)) { throw "Design-contract violation: forbidden token '$token'" }
}

$decisionDir = Join-Path $modRoot 'common\decisions'
$decisionFiles = Get-ChildItem -LiteralPath $decisionDir -Filter '*.txt' -File
$decisionDefinitions = 0
$mingOnlyShows = 0
foreach ($file in $decisionFiles) {
    $text = Get-Content -Raw -Encoding utf8 $file.FullName
    $decisionDefinitions += ([regex]::Matches($text, '(?m)^minghm_[A-Za-z0-9_]+_decision\s*=\s*\{')).Count
    $mingOnlyShows += ([regex]::Matches($text, '(?m)^\s*is_shown\s*=\s*\{\s*minghm_is_ming_emperor_trigger\s*=\s*yes\s*\}')).Count
}
if ($decisionDefinitions -lt 12) { throw "Expected at least 12 Ming decisions, found $decisionDefinitions" }
if ($mingOnlyShows -ne $decisionDefinitions) { throw "Every decision must have a Ming-only is_shown gate. Decisions=$decisionDefinitions gates=$mingOnlyShows" }

$outerDescriptor = Get-Content -Raw -Encoding utf8 (Join-Path -Path $RepositoryRoot -ChildPath 'minghm_companion.mod')
$innerDescriptor = Get-Content -Raw -Encoding utf8 (Join-Path -Path $modRoot -ChildPath 'descriptor.mod')
$dependencyName = -join [char[]](0x53D8, 0x8EAB, 0x5927, 0x660E)
$dependencyPattern = 'dependencies\s*=\s*\{\s*"' + [regex]::Escape($dependencyName) + '"\s*\}'
if ($outerDescriptor -notmatch $dependencyPattern) { throw 'Missing upstream dependency in outer descriptor' }
if ($innerDescriptor -notmatch $dependencyPattern) { throw 'Missing upstream dependency in inner descriptor' }

foreach ($folder in @('gfx', 'gui', 'common\buildings', 'common\men_at_arms_types', 'common\factions')) {
    $path = Join-Path $modRoot $folder
    if (Test-Path -LiteralPath $path) { throw "Design-contract violation: forbidden content folder '$folder' exists" }
}

Write-Host "Design contract audit passed: $decisionDefinitions Ming-only decisions, no prohibited systems or assets."
