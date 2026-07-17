# 27A AI 编码交付总实施书

> 这是后续 AI 生成 Mod 代码时的唯一入口。旧文档用于设计来源和反查，不得凌驾于施工版 `22–27`。

## 1. 最终产品定义

产品是《变身大明》的硬依赖兼容扩展，两者同时启动。本模组仅为 `h_greatming` 明制增加轻量政治模拟：皇权—内阁政策、官僚执行、既有朋党输入、监察案件、八项全国力量、五档历史阶段、重大危机、改革、抽象再工业化、商业政治力量及革命/反革命。

不支持其他国家，不提供独立运行，不做财政、生产、市场、人口和地区模拟。

## 2. 阅读优先级

1. 强制边界：`22、22A、24、25A、27A`；
2. 机制施工：`23、23A、23B、23C、25、26、26A、26B`；
3. 美术/测试：`27`；
4. 代码格式与旧索引：`18、18A、18B、21A`；
5. `01–21` 其余文档仅为研究资料。

冲突时以前一层为准。尤其 `11/11A/11B/11C/14A` 不得实现，`15A` 只保留 26A 的组织政治抽象。

## 3. MVP 文件清单

```text
descriptor.mod
common/on_action/minghm_on_actions.txt
common/scripted_triggers/minghm_core_triggers.txt
common/scripted_triggers/minghm_politics_triggers.txt
common/scripted_values/minghm_values.txt
common/scripted_effects/minghm_core_effects.txt
common/scripted_effects/minghm_politics_effects.txt
common/decisions/minghm_decisions.txt
common/character_interactions/minghm_interactions.txt
common/modifiers/minghm_modifiers.txt
events/minghm_core_events.txt
events/minghm_policy_events.txt
events/minghm_crisis_events.txt
localization/simp_chinese/minghm_l_simp_chinese.yml
```

MVP 不创建 GUI、trait、building、government、culture、faith、faction、MAA 或美术文件。后续革命战争仅新增独立 `common/casus_belli_types/minghm_revolution_cb.txt`。

## 4. 数据字典冻结

### 长期 title 状态

- 八项 `0..100`：`state_capacity`、`reform_momentum`、`conservative_power`、`popular_mobilization`、`elite_cohesion`、`military_autonomy`、`commercial_influence`、`crisis_pressure`，均加 `minghm_` 前缀；
- `minghm_historical_stage = 0..4`；
- `minghm_industrial_stage = 0..4`；
- 初始化版本 `minghm_schema_version`。

### 单活动槽

政策、案件、危机字段严格按 `23/23C/26`；同类同时一个。所有人物 saved scopes 和临时 flags/modifiers 按 `25A` 清理。

### 上游只读/适配

`h_greatming`、`huang_quan_value`、`HQ_change`、原模组官位/品级/朋党/厂卫/军功。除皇权适配器的明确消费外，本模组不写上游变量。

## 5. 编码批次与验收门

| 批次 | 产物 | 必须证明 |
|---|---|---|
| M0 | descriptor、namespace、日志开关 | 四件套加载，无重复键 |
| M1 | Ming trigger、初始化、休眠/恢复、统一清理 | 新局/旧档/继承/复国安全 |
| M2 | 八项值、统一修改 effect、年度阶段判定 | 范围钳制、阶段防抖、非明零运行 |
| M3 | 一个“官僚考成重整”政策垂直切片 | 完整数字对抗与反馈清理 |
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

