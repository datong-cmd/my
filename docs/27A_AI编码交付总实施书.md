# 27A AI 编码交付总实施书

> 这是后续 AI 生成 Mod 代码时的唯一入口。源码事实按需从 `01—10` 反查，不得凌驾于施工版 `22—30G`。

## 1. 最终产品定义

产品是《变身大明》的硬依赖兼容扩展，两者同时启动。本模组仅为 `h_greatming` 明制增加轻量政治模拟：皇权—内阁政策、官僚执行、既有朋党输入、监察案件、八项全国力量、五档历史阶段、重大危机、改革、抽象再工业化、商业政治力量及革命/反革命。

不支持其他国家，不提供独立运行，不做财政、生产、市场、人口和地区模拟。

## 2. 阅读优先级

1. 强制边界：`22、22A、24、25A、27A`；
2. 机制施工：`23、23A、23B、23C、25、26、26A、26B`；
3. 美术/测试：`27`；
4. 事件链与转盘：`29、29A、30、30A—30G`；
5. 源码事实：`01、02、02A、03、05—10、21`，仅按需读取。

冲突时以前一层为准。财政、区域生产、市场、人口、跨政权、通用框架、新兵种和新政体的早期文档已经删除，不得从 Git 历史恢复为实现要求。

## 3. MVP 文件清单

```text
descriptor.mod
common/on_action/minghm_on_actions.txt
common/scripted_triggers/minghm_core_triggers.txt
common/scripted_triggers/minghm_politics_triggers.txt
common/script_values/minghm_values.txt
common/scripted_effects/minghm_core_effects.txt
common/scripted_effects/minghm_politics_effects.txt
common/decisions/minghm_decisions.txt
common/character_interactions/minghm_interactions.txt
common/modifiers/minghm_modifiers.txt
events/minghm_core_events.txt
events/minghm_policy_events.txt
events/minghm_crisis_events.txt
events/minghm_outlook_events.txt
gui/event_window_widgets/event_window_widget_minghm_outlook.gui
localization/simp_chinese/minghm_l_simp_chinese.yml
```

除 `29` 规定的独立事件 widget 外，MVP 不创建 GUI；不创建 trait、building、government、culture、faith、faction、MAA 或美术文件。后续革命战争仅新增独立 `common/casus_belli_types/minghm_revolution_cb.txt`。该 widget 不覆盖 HUD、公共 GUI 或 DLC 原转盘窗口。

## 4. 数据字典冻结

### 长期 title 状态

- 八项 `0..100`：`state_capacity`、`reform_momentum`、`conservative_power`、`popular_mobilization`、`elite_cohesion`、`military_autonomy`、`commercial_influence`、`crisis_pressure`，均加 `minghm_` 前缀；
- `minghm_historical_stage = 0..4`；
- `minghm_industrial_stage = 0..4`；
- 初始化版本 `minghm_schema_version`。

### 单活动槽

政策、案件、危机字段严格按 `23/23C/26`，并与大型事件链共用 `minghm_foreground_content_active`。同一时间只推进一种复杂内容；大型链内部需要案件/政策数值时使用链字段，不另开槽。所有人物 saved scopes 和临时 flags/modifiers 按 `25A` 清理。

### 上游只读/适配

`h_greatming`、`huang_quan_value`、`HQ_change`、原模组官位/品级/朋党/厂卫/军功。除皇权适配器的明确消费外，本模组不写上游变量。

## 5. 编码批次与验收门

| 批次 | 产物 | 必须证明 |
|---|---|---|
| M0 | descriptor、namespace、日志开关 | 四件套加载，无重复键 |
| M1 | Ming trigger、初始化、休眠/恢复、统一清理 | 新局/旧档/继承/复国安全 |
| M2 | 八项值、统一修改 effect、年度阶段判定 | 范围钳制、阶段防抖、非明零运行 |
| M3 | 一个“官僚考成重整”政策垂直切片 | 完整数字对抗与反馈清理 |
| M3A | 三司制王朝局势转盘 | 五阶段与三分数正确显示，零天朝耦合，缓存可清理 |
| M4 | 皇权、官位、朋党适配器 | 探针失败能降级，不写上游数据 |
| M5 | 改革专员与改革案件 | 复用人物、无身份复制、无悬挂作用域 |
| M6 | 六项改革与六类危机 | 模板共享状态机，无重复脚本爆炸 |
| M7 | 再工业化四阶段和三种正当化模式 | 无经济沙盘、无逐人物意识形态 |
| M8 | 事件版革命/反革命 | 双方可玩、可妥协、非一边倒 |
| M9 可选 | 独立革命 CB | T8 四出口通过才默认启用 |
| M10 | AI、平衡、100 年长跑与发布包 | 性能红线、资产红线全部通过 |

每批次单独提交；上一门未通过不得展开下一批次的大量内容。

## 6. 第一个垂直切片的精确流程

1. 明帝通过 `minghm_launch_bureaucratic_reform_decision` 发起；
2. title 保存 policy type/stage，抓取至多 8 名已有官员；
3. 计算推动力与阻力并在事件中展示前三修正；
4. 玩家选择妥协、协调、耗皇权强推或撤回；
5. 选择现有官员为改革专员，不生成角色；
6. 两年内每季度只对活动槽加一次固定/条件修正；
7. 按差值四档结算，改变八项值中的 1–3 项；
8. 调用统一清理 effect，验证人物临时状态和 title 活动槽归零。

完成这条链即可验证绝大多数基础架构，禁止先批量写几十个事件。

## 7. AI 生成代码的硬规则

- 所有键、namespace、文件名使用 `minghm_`；
- 任何上游键先在索引和实机文件确认，不凭名称猜测；
- trigger/value/effect 分层，事件不散写长期变量；
- 选项展示数值原因，随机修正最多 10；
- 先找现有人物，普通集团无人物化；
- 不使用 `any_living_character` 或全地图循环；
- 不覆盖公共文件和 GUI；
- 不复制美术；
- 王朝转盘只按 `29/29A` 复用 DLC 静态轮盘资产，不创建或覆盖原 `dynastic_cycle` situation；
- 每个状态机同时写取消、死亡、失效、继承和清理路径；
- 注释标出上游耦合点及版本探针。

## 8. 完成定义

实现计划转为代码后的“完成”不是文件齐全，而是：

- 在指定四件套上实机运行；
- 仅明制生效；
- 政策、危机、阶段、革命形成长期可逆数字博弈；
- 皇权、官僚、朋党、厂卫身份真实来自前置；
- 性能和对象上限通过 100 年长跑；
- 无已弃用经济系统、人物膨胀或资产复制；
- T0–T7 全通过，T8 失败时革命战争桥安全关闭。

## 9. 大型事件链增补交付规则

大型事件链必须先读 `30/30A—30G`。权威状态放在 `h_greatming`，`story_cycle` 只作玩家进度展示；全国同时最多一条，AI 不创建可见 story。

```text
common/story_cycles/minghm_major_chain_story.txt
events/minghm_succession_chain_events.txt
events/minghm_reform_chain_events.txt
events/minghm_military_chain_events.txt
events/minghm_technical_chain_events.txt
events/minghm_case_chain_events.txt
events/minghm_revolution_chain_events.txt
```

| 批次 | 产物 | 必须证明 |
|---|---|---|
| M6A | 统一容器与“新君临朝”垂直切片 | 单链锁、继承重建、角色死亡降级、间隔与清理通过 |
| M6B | 其余五条大型事件链 | 严格按固定骨架，不扩展经济、地图参与者或上游职位写入 |

每条链先完成 6—10 个固定事件，再考虑最多四个条件插曲；不得先批量生成几十个事件。
