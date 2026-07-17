# 29A DLC 王朝兴衰取舍与接口反查表

> 状态更新：早期“只借视觉、不创建 situation”的取舍已被后续需求替换。当前实现为独立的 `minghm_dynastic_cycle`，仅服务 `h_greatming`，并保留本文所列的性能禁区。准确实现见 [34](34_大明专用王朝局势实现说明.md)。

| DLC 组件 | 原用途 | 三司制适配 | 结论 |
|---|---|---|---|
| 五个 phase | 表示治世、危世、乱世 | 映射为五档明制历史阶段 | 采用框架 |
| takeover points | 催化因素累计到换阶段 | 用八项全国值年度判定和两年防抖 | 改写数值 |
| catalysts | 战争、灾害、合法性等推动阶段 | 已有政策/危机结算修改全国值 | 采用思想，不建对象 |
| `situation:dynastic_cycle` | 管理区域、历史、参与者和 phase | 不创建，避免天朝耦合和常态开销 | 不采用 |
| `title:h_china` | 天朝霸权及 de jure 核心 | 唯一载体为 `title:h_greatming` | 替换边界 |
| 天命/合法性 | 统治资格和阶段推动 | 皇权只作提示，主要用整合/改革/解体三分数 | 不采用原值 |
| movement groups | 官员、诸侯与外部统治者运动 | 读取原模组朋党/官位作为事件修正 | 不建第二套集团 |
| 朝贡、丝路、国库 | 天朝外交经济耦合 | 项目已弃用财政/市场且只做明内政 | 删除 |
| 原专用 window | 完整 situation/运动/行动 UI | 新建小型 event widget | 不覆盖 |
| 轮盘与阶段图标 | 五阶段视觉 | 直接路径引用 | 采用资产 |
| C++ 旋转接口 | 根据 phase 动态旋转 | 固定轮盘 + 当前图标高亮 | 不采用 |
| 月度/年度 situation pulse | 更新参与者、灾害、运动、考试 | 仅沿用 Ming 年度判定 | 大幅简化 |

## 核验路径

- 阶段、participant、`h_china` 耦合：`common/situation/situations/tgp_dynastic_cycle.txt`
- 原具体数值：`common/script_values/10_tgp_dynastic_cycle_values.txt`
- 年度天朝更新：`common/on_action/dynastic_cycle_on_actions.txt`
- 原转盘硬编码：`gui/window_tgp_dynastic_cycle.gui`
- 事件 widget 方式：`events/dlc/tgp/tgp_dynastic_cycle_events.txt`
- 玩家变量 GUI 读取范式：`gui/event_window_widgets/child_examination_success_chance.gui`
- 中文阶段含义：`localization/simp_chinese/dlc/tgp/dlc_tgp_situation_parameters_l_simp_chinese.yml`

## 编码前探针

| 编号 | 探针 | 通过标准 | 失败降级 |
|---|---|---|---|
| W01 | event custom widget 注册 | 事件能显示自定义容器 | 改为普通事件文本+五阶段图标 |
| W02 | `GetPlayer.MakeScope.Var` | 三条分数与阶段值正确显示 | 通过本地化 scripted value 显示 |
| W03 | DLC 轮盘资产跨 GUI 引用 | 纹理无缺失/拉伸 | 只用五个 phase icons |
| W04 | 当前阶段可见条件 | 五图标恰好一个高亮 | 中央文本显示阶段，取消高亮 |
| W05 | 缓存清理 | 关闭事件后变量全部删除 | 下次打开先清理并覆盖；日志警告 |
