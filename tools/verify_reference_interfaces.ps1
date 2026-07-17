param(
    [string]$ReferenceModRoot = 'D:\steam\steamapps\workshop\content\1158310\2713348525',
    [string]$GameRoot = 'D:\steam\steamapps\common\Crusader Kings III\game'
)

$ErrorActionPreference = 'Stop'

function Require-Text {
    param([string]$Path, [string]$Pattern, [string]$Label)
    if (-not (Test-Path -LiteralPath $Path)) { throw "Missing source for $Label`: $Path" }
    $content = Get-Content -LiteralPath $Path -Raw -Encoding utf8
    if ($content -notmatch $Pattern) { throw "Reference interface mismatch: $Label" }
}

$yanTrigger = Join-Path $ReferenceModRoot 'common\scripted_triggers\99_yan_triggers.txt'
$hqEffect = Join-Path $ReferenceModRoot 'common\scripted_effects\liuguan_effects.txt'
$partyValue = Join-Path $ReferenceModRoot 'common\script_values\liuguan_values.txt'
$yanOnAction = Join-Path $ReferenceModRoot 'common\on_action\yan_on_action.txt'
$regencyOnAction = Join-Path $ReferenceModRoot 'common\on_action\yan_shezheng_on_action.txt'
$gameTitleActions = Join-Path $GameRoot 'common\on_action\title_on_actions.txt'
$gameYearlyActions = Join-Path $GameRoot 'common\on_action\yearly_on_actions.txt'
$gameDynasticCycle = Join-Path $GameRoot 'common\situation\situations\tgp_dynastic_cycle.txt'
$gameDynasticCycleGui = Join-Path $GameRoot 'gui\window_tgp_dynastic_cycle.gui'

Require-Text $yanTrigger '(?ms)^is_GM_emperor\s*=\s*\{.*?has_title\s*=\s*title:h_greatming\s*\}' 'is_GM_emperor -> h_greatming'
Require-Text $hqEffect '(?ms)^HQ_change\s*=\s*\{.*?\$CHECK\$\s*=\s*202301102000.*?\$CHECK\$\s*=\s*437639088' 'HQ_change accepted checks'
Require-Text $hqEffect '(?ms)^HQ_change\s*=\s*\{.*?name\s*=\s*huang_quan_value.*?var:huang_quan_value\s*>\s*2000.*?var:huang_quan_value\s*<\s*-500' 'HQ_change variable and clamp'
Require-Text $partyValue '(?m)^pengdang_yingxiang_score\s*=\s*\{' 'pengdang_yingxiang_score'
Require-Text (Join-Path $ReferenceModRoot 'common\\court_positions\\types\\99_yan_court_positions.txt') '(?m)^court_dalisiqing_position\s*=\s*\{' 'Dali court position'
Require-Text (Join-Path $ReferenceModRoot 'common\\court_positions\\types\\99_yan_court_positions.txt') '(?m)^court_jinyiwei_position\s*=\s*\{' 'Jinyiwei court position'
Require-Text $yanOnAction '(?ms)^on_title_gain\s*=\s*\{.*?on_actions\s*=\s*\{.*?on_title_gain_GreatMing' 'reference on_title_gain merge'
Require-Text $yanOnAction '(?ms)^yearly_global_pulse\s*=\s*\{.*?on_actions\s*=\s*\{' 'reference yearly_global_pulse merge'
Require-Text $regencyOnAction '(?ms)any_relation\s*=\s*\{\s*count\s*>\s*0\s*type\s*=\s*diange_daxueshi\s*has_trait\s*=\s*zhongjidian_daxueshi' 'Zhongjidian grand secretary relation'
Require-Text (Join-Path $ReferenceModRoot 'common\character_interactions\99_yan_qita.txt') 'has_relation_diange_daxueshi\s*=\s*scope:actor' 'generic grand secretary relation trigger'
Require-Text $gameTitleActions '(?m)^on_title_gain\s*=\s*\{' 'base on_title_gain'
Require-Text $gameYearlyActions '(?m)^quarterly_playable_pulse\s*=\s*\{' 'base quarterly_playable_pulse'
Require-Text $gameYearlyActions '(?m)^yearly_global_pulse\s*=\s*\{' 'base yearly_global_pulse'
Require-Text $gameDynasticCycle '(?ms)^dynastic_cycle\s*=\s*\{.*?is_unique\s*=\s*yes.*?add_manual_participant' 'DLC dynastic-cycle situation/manual participant interface'
Require-Text $gameDynasticCycleGui 'dynastic_cycle_wheel_border\.dds' 'DLC dynastic-cycle wheel-border texture'

Write-Host 'Reference interface verification passed.'
