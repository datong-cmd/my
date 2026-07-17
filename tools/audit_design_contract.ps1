param(
    [string]$RepositoryRoot = (Join-Path $PSScriptRoot "..")
)

$ErrorActionPreference = 'Stop'
$modRoot = Join-Path $RepositoryRoot 'mod\minghm_companion'
if (-not (Test-Path -LiteralPath $modRoot)) { throw "Missing mod root: $modRoot" }
$modRoot = (Resolve-Path -LiteralPath $modRoot).Path

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

foreach ($folder in @('common\buildings', 'common\men_at_arms_types', 'common\factions')) {
    $path = Join-Path $modRoot $folder
    if (Test-Path -LiteralPath $path) { throw "Design-contract violation: forbidden content folder '$folder' exists" }
}

# A small, fixed text-icon set and one read-only event widget are permitted. Neither adds 3D assets.
$allowedGui = @(
    (Join-Path $modRoot 'gui\minghm_texticons.gui'),
    (Join-Path $modRoot 'gui\event_window_widgets\event_window_widget_minghm_dynastic_cycle.gui')
)
if (Test-Path -LiteralPath (Join-Path $modRoot 'gui')) {
    $guiFiles = @(Get-ChildItem -LiteralPath (Join-Path $modRoot 'gui') -Recurse -File)
    if ($guiFiles.Count -ne $allowedGui.Count -or @($guiFiles | Where-Object { $_.FullName -notin $allowedGui }).Count -ne 0) { throw 'Design-contract violation: only the approved text-icon GUI and read-only Ming situation widget are allowed' }
}

$situationRoot = Join-Path $modRoot 'common\situation\situations'
$allowedSituation = Join-Path $situationRoot 'minghm_dynastic_cycle.txt'
if (-not (Test-Path -LiteralPath $allowedSituation)) { throw 'Design-contract violation: missing Ming-only dynastic-cycle situation' }
$situationFiles = @(Get-ChildItem -LiteralPath $situationRoot -Filter '*.txt' -File)
if ($situationFiles.Count -ne 1 -or $situationFiles[0].FullName -ne $allowedSituation) { throw 'Design-contract violation: unexpected situation definitions' }
$situationText = Get-Content -Raw -Encoding utf8 -LiteralPath $allowedSituation
foreach ($forbiddenSituationToken in @('on_monthly', 'on_yearly', 'catalysts', 'add_character_realm_to_sub_region', 'auto_add_rulers = yes', 'auto_add_landless_rulers = yes')) {
    if ($situationText -match [regex]::Escape($forbiddenSituationToken)) { throw "Design-contract violation: prohibited Ming situation token '$forbiddenSituationToken'" }
}
foreach ($requiredSituationToken in @('is_unique = yes', 'keep_full_history = no', 'title:h_greatming', 'has_relation_diange_daxueshi', 'add_manual_participant')) {
    if ($situationText -notmatch [regex]::Escape($requiredSituationToken)) { throw "Design-contract violation: incomplete Ming situation token '$requiredSituationToken'" }
}

$allowedIcons = @('new_order.dds', 'stage_reform.dds', 'stage_rupture.dds', 'stage_stable.dds', 'stage_strained.dds', 'technical_organization.dds')
$iconRoot = Join-Path $modRoot 'gfx\interface\icons\minghm'
if (-not (Test-Path -LiteralPath $iconRoot)) { throw 'Design-contract violation: missing approved Ming text-icon directory' }
$iconFiles = @(Get-ChildItem -LiteralPath $iconRoot -File)
if ($iconFiles.Count -ne $allowedIcons.Count) { throw 'Design-contract violation: unexpected custom icon count' }
foreach ($iconFile in $iconFiles) {
    if ($iconFile.Extension -ne '.dds' -or $iconFile.Name -notin $allowedIcons -or $iconFile.Length -gt 32768) { throw "Design-contract violation: unapproved custom icon '$($iconFile.Name)'" }
}
$otherGfx = @(Get-ChildItem -LiteralPath (Join-Path $modRoot 'gfx') -Recurse -File | Where-Object { $_.DirectoryName -ne $iconRoot })
if ($otherGfx.Count -ne 0) { throw 'Design-contract violation: custom gfx outside the six approved text icons' }

Write-Host "Design contract audit passed: $decisionDefinitions Ming-only decisions, one bounded Ming situation, one read-only widget, and six approved text icons."
