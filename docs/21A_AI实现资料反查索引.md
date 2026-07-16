# AI 实现资料反查索引

> 这是实现阶段的首要查找入口。收到一个代码任务时，先在本表找到任务行，再按“设计→参考模组→本体/DLC→数据接口→性能测试”顺序读取。

## 1. 通用读取顺序

每个实现任务固定读取：

1. [18_AI编码总规范](18_AI编码总规范.md)：前缀、号段、模块所有权和禁止项；
2. [18A_变量状态与接口数据字典](18A_变量状态与接口数据字典.md)：唯一状态与公共接口；
3. [18B_事件触发效果与本地化模板](18B_事件触发效果与本地化模板.md)：脚本结构、事件登记和测试模板；
4. 本表对应的机制设计文档；
5. [01](01_参考模组源码文件索引.md)/[02](02_参考模组脚本ID定位索引.md)/[02A](02A_参考模组全事件触发与调用索引.md)：定位本地参考实现；
6. [13](13_CK3本体与溥天之下技术映射.md)/[13A](13A_兼容覆盖与资产复用清单.md)：本体接口与兼容；
7. [17A](17A_性能缓存存档与测试预算.md)/[19B](19B_测试发布与风险清单.md)：频率、上限和验收。

不要把整套文档一次塞给代码 AI。按任务行选取最小充分上下文，但 `18/18A/18B` 的相关契约不可省略。

## 2. 基础架构任务

| 实现任务 | 设计/规范 | 参考模组定位 | 本体/DLC 重点 | 状态/接口 | 性能与测试 |
|---|---|---|---|---|---|
| Mod 脚手架与前缀 | `18 §3—7`、`19 M0` | `01` 各 common 目录；`06` 架构 | launcher 版本、DLC feature | schema、initialized、adapter | T0 前缀/覆盖；M0 加载 |
| 适用国家与主头衔 | `13`、`18A §3/14` | 政体、landed_titles、on_action，查 `01/02` | 天朝/行政政体、主头衔 | `minghm_is_applicable_state_trigger` | 新局、继承、灭国/恢复 |
| DLC/版本 adapter | `13`、`13A`、`18 §10` | 参考模组 descriptor/原生调用 | `all_under_heaven` feature | `minghm_has_required_dlc_trigger` | 缺 DLC、版本变化、日志 |
| 单一调度器 | `06`、`17A`、`18 §9` | `common/on_action/GM_*` | 已确认原生 on_action 合并方式 | month/quarter/year markers | 重复入口、错峰、100 年 |
| 存档 schema/迁移 | `17A`、`18A §15` | 不直接复制；参考人物/变量持久性 | 变量和 saved scope | migrate/initialize/recover | 旧档、重复迁移、中断 |
| Debug/诊断 | `17A`、`18B §18` | debug interactions/decisions | debug game rule/日志 | dump/validate/repair | 极端值、幽灵槽、无奖励 |

## 3. 区域、阶级与阶段

| 实现任务 | 设计 | 参考模组定位 | 本体/DLC 重点 | 状态/接口 | 性能与测试 |
|---|---|---|---|---|---|
| 8 区域锚点 | [14A](14A_区域经济与社会结构.md)、`19A §4` | map/history/titles 查 `01` | landed title、发展/控制/建筑只作基线 | region index/scopes、8 axes | 标准 8/硬 12；不同开局映射 |
| 区域八轴 | `14A §2/6/9/10` | 土地/建筑/殖民组件 | title variables | change axis、settle region | 年度一次、clamp、dirty |
| 冲击传播 | `14A §8` | 灾害/贸易/战争事件由 `02A` 查调用 | 相邻/功能区 scope | propagate region shock | 最多 8/12，不扫地图 |
| C1—C8 初始化 | [14](14_阶级力量与生产方式模型.md)、`18A §2/4` | 朋党/流官/军功/私产状态样板 | title/character/modifier | 56 源状态 | 新局基线、非守恒、无人物膨胀 |
| 阶级力量/动员缓存 | `14 §5/11/12` | `pengdang_effects`、皇权/军功 values | scripted values | recalculate class power | 8 槽、季度/年度、UI 只读 |
| 六政治联盟 | `14 §6`、[17](17_AI平衡与长期博弈.md) | 朋党关系/党魁 GUI | situation groups/人物代理 | A1—A6 state、leader scopes | ≤6+危机临时；路线惯性 |
| P0—P9 阶段 | [15](15_历史阶段与转型路径.md) | 本体王朝周期、参考政体事件 | dynastic cycle/situation | drivers、candidate/ticks | 季度审核、最短停留、非线性 |
| 四层制度 | `15 §2` | government/laws/culture | 原生政体/法律只在需要时映射 | production/state/mobilization/ideology enum | 不用一个 modifier 包办 |

## 4. 官僚与中枢权力

| 实现任务 | 设计 | 参考模组定位 | 本体/DLC 重点 | 状态/接口 | 性能与测试 |
|---|---|---|---|---|---|
| 科举候选池 | [07](07_流官科举授官与考成.md) | `keju_events`、`guozijian_events`、pool selectors | 功绩/任命/考试/活动可选 | 有界 candidate scopes | 空池、AI、人物上限 |
| 授官与任期 | `07` | `liuguan_effects/triggers`、`shouguan_events` | celestial appointment、governorship | character role + state access | 死亡/离任/继承/重复任命 |
| 考成与升降 | `07` | `KaoKe_events`、流官记忆 | merit/position | experience、评价、公共 change effects | 年/任期事件，不扫所有人物 |
| 内阁议程/票拟封还 | [08](08_皇权内阁与诏令.md) | 内阁职位/事件、九卿/内廷 GUI | council/court position/situation action | politics agenda、commitment | 玩家/AI/无候选/继承 |
| 皇权直接干预 | `08`、[08A](08A_皇权数值调用与门槛专项索引.md) | `GM_core_value`、204 增减/162 门槛定位 | legitimacy、treasury、appointments | 不建单一万能皇权；调用能力/控制接口 | 成本、反制、继承断裂 |
| 朋党→六联盟 | [09](09_朋党组织与政治影响力.md) | `pengdang_effects`、`GM_Pengdang_events`、党魁 GUI | relation/situation group | A1—A6 公共 effects | 分裂/合并/领袖死亡/AI |
| 弹劾与重大案件 | [09A](09A_监察弹劾与司法流程.md) | `GM_Tanhe`、`xingbushenban`、罪名 events | imprisonment/crime/position | case stages、evidence scopes | 事件驱动、关键人物有限 |
| 非常监察/锦衣卫 | [09B](09B_锦衣卫与非常监察.md) | `Jinyiwei_interaction`、`yanjinyiwei_events`、zhaoyu GUI | schemes/imprisonment/information | information/coercion/private capture | 诬告、机构自主、scope 失效 |

## 5. 财政、土地、市场与项目

| 实现任务 | 设计 | 参考模组定位 | 本体/DLC 重点 | 状态/接口 | 性能与测试 |
|---|---|---|---|---|---|
| 公共国库 adapter | [11](11_国家财政库存与预算.md)、`13` | 九卿/工程/数值调用 | 原生 state treasury | get/add treasury | 不足、重复扣费、缺 DLC |
| 内帑与公私财政 | `11`、`14` | 皇权/内廷/私产组件 | estate/character gold/treasury | state_private_capture、承诺 | 继承、公私转移、无双国库 |
| 预算与拖欠 | `11` | great projects、军饷/财政事件 | treasury、modifiers | commitment slots、credit memory | 季度期限、default、AI 履约 |
| 土地清丈 MVP | [19A](19A_MVP垂直切片.md) | 地契/土地/流官/监察相关 ID 由 `02` 查 | treasury、appointment、situation | reform slot、region axes、C2/C3/C7 | MVP-01..15、20 年观察 |
| 赋役与税基 | [11A](11A_县域赋役土地矿产与基础设施.md) | 建筑/法律/决议/事件 | title development/control 只作信号 | fiscal capacity、extraction | 年度区域结算、转嫁 |
| 土地兼并/债务失地 | [11B](11B_私产地产行商与市场.md)、`14A` | artifacts 地契、私产互动 | title/character effects | land concentration、C2/C5/C7/C8 | 不生成大量宝物/人物 |
| 市场/商帮/信用 | `11B` | `99_yan_maoyi`、贸易 events/modifiers | gold、contracts、activities 可选 | credit depth、C5/C6、default memory | 区域/年度、无价格全模拟 |
| 聚合人口/迁徙 | [11C](11C_人口控制与社会人口抽象.md)、`14A §7` | PopulationControl 只借鉴风险 | 不生成模拟人口 | pressure/urbanization/C7→C8 delta | 100/200 年对象稳定 |
| 矿冶/基础设施项目 | `11A`、[15A](15A_改革再工业化与资本形成.md) | buildings/great_projects | great projects、development、transport assets | project slots p1—p3 | ≤3；供给/维护/关闭清理 |
| 再工业化七环 | `15A` | 军器/制造局/工程等分散样板 | gunpowder capacity、projects、MAA | industrial capacity、supply、ownership | 年度、去工业化、非永久增长 |
| 资本形成与所有制 | `14/14A/15A` | 私产、行商、工程 | treasury/gold/contracts | C5/C6/C8、capture/labor conflict | 资本外逃/投地/破产/寡头化 |

## 6. 军事与战争政治

| 实现任务 | 设计 | 参考模组定位 | 本体/DLC 重点 | 状态/接口 | 性能与测试 |
|---|---|---|---|---|---|
| 军功生成/核验 | [10](10_军功卫所与战争政治.md) | `GM_liuguan_on_action`、`GM_war_effects` | battle/siege/war on_actions、merit | C4/character bounded merit | 战争事件驱动、重复战斗防刷 |
| 军功兑现 | `10` | `99_yan_fengjue`、gongchen traits/gui | titles/positions/gold/estate | commitment/privilege memory | 排队、预算、AI 选择 |
| 卫所/军户/募兵 | `10`、`14A` | government/traits/land | men-at-arms、tax/levy modifiers | labor coercion、land、C4/C7 | 年度聚合、逃役/衰变 |
| 军饷与兵变 | `10`、`11`、`16` | 军功/战争/财政事件 | treasury/army/war | crisis type military_pay | K0—K6、欠饷期限、复员 |
| 军工与火器 | [10A](10A_兵种军器与军事现代化.md)、`15A` | MAA/buildings/projects | gunpowder capacity、MAA、great project | project ownership/supply | 原生平衡对照、≤3 项目 |
| 军头化/政变 | `10`、[15B](15B_革命反革命与复辟.md) | 权臣/军功/CB 样板 | faction/war/diarchy 可选 | C4 coercion/organization、memory coup | 胜败后可继续、无固定人物 |

## 7. 藩属与边疆

| 实现任务 | 设计 | 参考模组定位 | 本体/DLC 重点 | 状态/接口 | 性能与测试 |
|---|---|---|---|---|---|
| 朝贡/属国多维关系 | [12](12_藩属朝贡与跨政权外交.md) | subject contracts、FanShuGuo interaction/gui | tributary contracts、diplomacy | relationship memory/commitment | 不遍历所有外交对象高频 |
| 贡赐与军役谈判 | `12`、`16` | 上贡/召集/调停互动 | treasury、war obligations | crisis/commitment | 赤字、拒绝、干预、AI |
| 土司继承请封 | [12A](12A_土司羁縻殖民与边疆治理.md) | 属国/流官/边疆组件 | appointment/contract | frontier relation + key actor | 继承、无候选、地方知识 |
| 可逆归流 | `12A` | zhimin/government/laws 样板 | government/appointment | state control、local autonomy memory | 试点/回撤/反抗/区域差异 |
| 移民殖民与财富输送 | `12A` | zhimin interactions/decisions/laws | migration abstraction/title effects | land/labor/capture/region | 不生成人口；长期反制 |
| 征服军事共同体 | [12B](12B_八旗与征服型军事共同体.md) | qing/baqi contracts/value/gui | subject/army/government | supply/service/status/reform | 供养危机、身份分裂、改革 |

## 8. 改革、危机、革命与事件

| 实现任务 | 设计 | 参考模组定位 | 本体/DLC 重点 | 状态/接口 | 性能与测试 |
|---|---|---|---|---|---|
| 通用改革生命周期 | [15A](15A_改革再工业化与资本形成.md) | 工程/决议/事件链样板 | situation/story cycle/great project | reform r1/r2 | ≤2；季度；清理/回撤 |
| 通用危机 K0—K6 | [16](16_重大事件与危机博弈框架.md) | `02A` 查多段事件链；不要复制具体状态 | situation + participant groups | crisis fields/q1—q6 | 全国/区域槽、月截止/季审核 |
| 十三类明代事件族 | [16A](16A_重大事件族与明代情景模板.md)、[20](20_史料文学与机制参考摘要.md) | `events` 全索引 `02A` | event/situation/story cycle | 只调用公共 crisis/reform effects | 导演预算、冷却、历史人物替代 |
| AI 有限信息 | [17](17_AI平衡与长期博弈.md) | 参考 AI 权重只能作语法样板 | ai_chance/will_do、可见信息 | shared utility/route/memory | 季度议程、无隐藏真值 |
| 动员阶梯 | [15B](15B_革命反革命与复辟.md)、`14` | faction/war/党派/民变组件 | faction/situation/war | grievance+organization+coercion | 不满不自动革命 |
| 双重权力 | `15B`、`16` | 属国/政体/派系样板 | situation、title/war | alternative capacity/participants | 多中心上限、国家衔接 |
| 革命/反革命 | `15B` | CB/faction/政体仅语法借鉴 | faction/war/government | stage P8、coalitions、memory | AI 站队、非一边倒、可续玩 |
| 战后整合/复辟 | `15B`、`15` | 政体/合法性/任命 | dynastic cycle/government | fiscal/army/food/legitimacy | 每结局 20 年续玩 |
| 历史人物替代 | `16A`、`20` | history/pool selectors | character pool/traits | relevant actor scopes | 无人物也能运行、≤40 |

## 9. UI、文本与资产

| 实现任务 | 设计/规范 | 参考模组定位 | 本体/DLC 重点 | 边界 | 测试 |
|---|---|---|---|---|---|
| 国家结构概览 | `14 §13`、`18B §13/15` | 党魁/九卿/内廷 GUI 只借鉴信息架构 | 原生 situation/轻量 hub | UI 只读缓存 | 打开/关闭性能、可读性 |
| 改革面板 | `15A`、`19A §15` | great project/官署 GUI | situation action/project UI | 不直接写变量 | 成本/支持/反制完整 |
| 危机面板 | `16`、`18B §10` | 属国/八旗 hub + 事件 | situation | 六仪表、未知范围 | 信息不完全、槽清理 |
| 简中本地化 | `18B §14—17` | `localization` 用 `01/02` 查术语 | 本体 scope/icon 语法 | 不复制小说/史料段落 | 缺/重复 key、编码 |
| 本体/DLC 美术复用 | [03](03_参考模组资产索引.md)、[13A](13A_兼容覆盖与资产复用清单.md) | gfx/music/fonts 分类 | 本体与“溥天之下”资源 | 不上传原始资产 | 路径/版本/许可清单 |
| 参考模组资产 | `03/13A/21` | 本地路径索引 | 非运行依赖 | 只在许可明确时分发 | 发布包版权审计 |

## 10. 常见问题的最快查法

| 问题 | 先查 | 再查 |
|---|---|---|
| 某参考模组文件做什么 | `01` 文件行 | `05` 机制簇；对应 `07—12B` |
| 某 ID 定义在哪里 | `02` | 源文件上下文 |
| 某事件由谁触发 | `02A` | 所在专项机制文档的调用链 |
| 某皇权值在哪里增减/判断 | `08A` | `02`/源文件 |
| 是否覆盖本体 | `13A` | `01` 的“覆盖本体”列 |
| 本体/“溥天之下”有什么现成载体 | `13` | 本地游戏对应 common/events/gui 文件 |
| 应该存在哪个 scope | `18A` | `18` 的模块所有权 |
| effect/trigger/value 怎么命名 | `18` | `18A` 公共接口表 |
| 事件怎么写 | `18B` | 对应机制文档和 `02A` 语法样板 |
| 更新多久一次 | `17A` | `18A §13` 调用顺序 |
| AI 为什么选这个 | `17` | `18 §12`、具体 option profile |
| 如何验收 | `19B` | `19A` 或对应里程碑退出条件 |
| 历史依据够不够 | `20` | 只按具体机制补查材料 |

## 11. AI 任务包模板

向代码生成 AI 提交任务时使用：

```text
任务 ID：
所属里程碑：M0—M8
可玩验收场景：
允许修改文件：
禁止修改文件：

必读规范：18、18A 对应条目、18B 对应模板
机制设计：<本索引对应文档和章节>
参考模组语法样板：<01/02/02A 定位，不直接复制>
本体/DLC 接口：<13 对应项 + 本地已确认文件>
性能边界：<17A 对应频率、对象上限>
测试：<19B 层级 + 具体用例>

根 scope：
读取状态：
允许写入的公共 effects：
新增持久变量：默认不允许；若必要先修改数据字典/schema
事件号段：
AI 信息边界：
失败/清理/迁移行为：

交付必须包含：修改文件、定义调用链、变量审计、事件登记、本地化键、静态检查、实机步骤、未验证项。
```

## 12. 首批任务队列

按 `19` 路线，建议顺序：

| 顺序 | 任务 | 完成标志 |
|---:|---|---|
| 1 | M0 descriptor/namespace/game rule | 干净加载，前缀检查通过 |
| 2 | state title + schema + debug dump | 新局/重复初始化/读档通过 |
| 3 | DLC/版本/国库 adapter | 有 DLC、缺 DLC、边界探针通过 |
| 4 | situation 持久性探针 | 确认 situation 或固定槽方案 |
| 5 | 8 区域 anchor 与八轴基线 | 多开局映射、存读档通过 |
| 6 | C1—C8 与 A1—A6 基线 | 年度一次重算、UI debug 可读 |
| 7 | P0/P1 阶段审核 | 滞后、候选和重复审核通过 |
| 8 | 清丈 decision + reform slot | 只分配一槽、成本一次 |
| 9 | 试点区域与执行变形 | 官僚能力/地方反制分离 |
| 10 | 财政—地方危机 K0—K6 | 玩家与 AI 都能结算/回撤 |
| 11 | 承诺兑现/背叛和长期记忆 | q 槽清理、路线惯性有效 |
| 12 | MVP 20 年观察和迁移 | MVP-01..15、无阻断项 |

完成第 12 项后才进入全面官僚、军工、资本或革命代码生成。

## 13. 维护规则

- 新机制必须在本索引增加一行；
- 新公共接口先更新 `18A`；
- 新事件先登记号段、入口和测试；
- 参考模组或游戏更新后重建 `01/02/02A`，再做 `13A` 路径差异；
- 若专项文档与本表冲突，以 `18/18A/18B` 的冻结契约和最新版本说明为准；
- 已删除/弃用接口保留迁移记录，不悄悄复用旧键；
- 每个发布版本在本表记录支持的里程碑和 schema。

