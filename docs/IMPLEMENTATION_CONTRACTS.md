# 实现数据与事件契约

状态：**垂直切片接口基线已锁定**<br>
适用版本：Vertical Slice 0.1<br>
最后更新：2026-07-13

本文固定跨模块名称、数据字段和事件语义，避免并行开发时各自发明接口。示例是契约而非必须逐字采用的代码实现；字段语义和稳定 ID 不得自行改变。

## 1. 稳定 ID

### 阶段

`title`、`loop_1`、`punishment_1`、`loop_2`、`ending_face`、`ending_avoid`

### 房间

`bedroom`、`hallway`、`kitchen`、`child_room`、`living_room`

### 碎片

`kitchen_receipt`、`child_drawing`、`wedding_photo`

### 场景对象

关键交互：`bed`、`exit_door`、`living_clock`、`memory_compartment`、`memory_tape`

主要碎片及变化目标：`kitchen_receipt`、`kitchen_stain`、`kitchen_glass`、`child_drawing`、`music_box`、`wedding_photo`

灯具：`light_kitchen`、`light_child`、`light_living`、`light_hall_south`、`light_hall_north`、`light_bedroom`

装饰目标：`bedroom_rug`、`bedroom_lamp`、`bedroom_window`

同一对象的两轮形态共享一个 `object_id`，由变化记录替换纹理、可见性或属性；不得把 `*_loop1`、`*_loop2` 资产区域名当成场景对象 ID。

ID 写入代码、数据、测试和调试工具后不可改名。玩家可见名称来自文本键，不使用 ID 直接展示。

## 2. GameState API

只允许通过方法修改状态，外部节点不得直接写字段。

```text
start_new_game() -> void
reset_progress() -> void
request_phase(next_phase) -> Result
record_room_entry(room_id) -> bool
complete_fragment(fragment_id) -> FragmentCompletionResult
register_clock_attempt(hour, minute) -> ClockResult
open_final_memory() -> Result
commit_ending(ending_id) -> Result
snapshot_for_debug() -> Dictionary
```

### 返回语义

- `Result.ok`: 合法状态变化已发生；
- `Result.noop`: 请求合法但状态已存在，保证幂等；
- `Result.rejected`: 前置条件不满足，不改变任何字段；
- 开发构建记录拒绝原因，发布构建不崩溃。

### FragmentCompletionResult

```text
status: ok | noop | rejected
completed_count: 0..3
is_last_fragment: bool
should_start_punishment: bool
```

只有从 2 个完成变为 3 个完成的首次调用返回 `should_start_punishment=true`。

### ClockResult

```text
status: correct | incorrect | already_solved | rejected
attempt_count: int
hint_upgraded: bool
```

第三次错误首次发生时 `hint_upgraded=true`；正确后任何调用返回 `already_solved`。

## 3. 全局信号

| 信号 | 参数 | 发出者 | 消费者 |
|---|---|---|---|
| `phase_changed` | `from, to` | GameState | EventDirector、UI、DevTools |
| `fragment_completed` | `fragment_id, count` | GameState | AudioDirector、UI |
| `all_fragments_completed` | 无 | GameState | EventDirector |
| `first_room_recorded` | `room_id` | GameState | DevTools、第二轮回应 |
| `clock_attempted` | `result` | GameState | ClockUI、DialogueController |
| `final_memory_opened` | 无 | GameState | HouseMutationController |
| `ending_committed` | `ending_id` | GameState | EventDirector、InputController |
| `settings_changed` | `key, value` | Settings | Audio、Display、PostProcess |

信号表示已经发生的事实，不用“请求”式信号绕过状态验证。请求调用明确方法。

## 4. FragmentDefinition

```text
id: StringName
room_id: StringName
interaction_id: StringName
dialogue_first: Array[StringName]
dialogue_repeat_loop_1: Array[StringName]
dialogue_repeat_loop_2: Array[StringName]
memory_cue_id: StringName
completion_audio_id: StringName | empty
```

验证规则：

- `id` 必须属于三个稳定碎片 ID；
- `room_id` 和 `interaction_id` 必须存在；
- first 文本至少一页，repeat 每轮至少一页；
- 完成音默认为空，避免获得物品提示音；
- 定义不包含计数、阶段跳转或直接场景路径。

## 5. Dialogue 数据

```text
dialogue_id: StringName
pages:
  - text_key: StringName
    speaker: narration | qin_zheng | su_lan | child | unknown
    presentation: box | subtitle | center_black
    min_display_ms: int
    skippable: bool
    cue_before: StringName | empty
    cue_after: StringName | empty
```

- 最终文本只存在于本地化表，不复制进资源或脚本。
- `skippable=false` 只用于关键选择说明和结尾责任表达，不能滥用。
- `speaker=unknown` 不在 UI 显示名字。
- 页面完成后由 DialogueController 发出一次 `dialogue_finished(dialogue_id)`。

## 6. MutationDefinition

```text
mutation_id: StringName
target_object_id: StringName
cycle: 0 | 1
condition_key: StringName | empty
operation: show | hide | texture | transform | dialogue_set | audio_state | material_param
value: Variant
design_intent: String
```

- `design_intent` 是开发可见说明，不进入游戏。
- 同一变化集内同一对象/属性只能有一个最终写入者。
- 应用必须幂等；重复调用结果完全一致。
- 变化不得修改 WorldSolid 碰撞，除非新决策明确批准。

## 7. EventTimelineCue

```text
time_ms: int
channel: input | audio | lighting | postprocess | dialogue | transition
action: StringName
target_id: StringName | empty
parameters: Dictionary
accessibility_variant: Dictionary | empty
```

惩罚时间线要求：

- cue 按 `time_ms` 稳定排序；同时间按原始声明顺序执行；
- 暂停使用统一时间源，不允许子系统继续自身 Tween；
- `accessibility_variant` 只替换表现参数，不改变时间和叙事动作；
- 最终 cue 必须请求合法的 `loop_2` 阶段迁移。

## 8. Interaction contract

```text
get_interaction_id() -> StringName
get_priority(player_position, facing) -> InteractionScore
can_interact(game_snapshot) -> bool
get_prompt_key(game_snapshot) -> StringName
interact(context) -> void
```

`InteractionScore` 由正前方、距离、稳定 ID 组成。选择顺序固定，不能依赖节点树遍历。

交互开始后对象进入 busy；只有收到文本完成、取消或场景退出事件才解除。重复按键被忽略，不排队。

## 9. Input actions

| Action | 默认绑定 | 用途 |
|---|---|---|
| `move_up` | W / Up | 移动、菜单上 |
| `move_down` | S / Down | 移动、菜单下 |
| `move_left` | A / Left | 移动、菜单左 |
| `move_right` | D / Right | 移动、菜单右 |
| `interact` | E / Enter | 调查、确认、文本 |
| `cancel` | Esc | 暂停、返回、取消 |
| `step_large` | Shift | 时钟十分钟步进修饰键 |
| `dev_panel` | F10 | 仅开发构建 |

游戏逻辑只读取 action，不读取硬编码键值。

## 10. Settings 数据

允许持久化：

```text
schema_version: 1
master_volume: 0.0..1.0
fullscreen: bool
reduce_flashes: bool
```

禁止持久化：阶段、轮回、碎片、第一房间、时钟、结尾选择。

设置文件缺失、字段损坏或版本未知时使用默认值并安全重写，不阻止启动。默认：音量 `0.7`、窗口模式、降低闪烁关闭。

## 11. 文本键命名

格式：`domain.subject.state.page`。

示例：

- `fragment.kitchen.first.01`
- `fragment.kitchen.repeat_loop2.01`
- `echo.first_room.kitchen.01`
- `clock.wrong.default.01`
- `clock.wrong.hint.01`
- `ending.face.tape.01`
- `ui.hold.release_to_cancel`

删除文本键前必须搜索代码、数据和测试引用。改文案不改键；只有语义角色变化时才新建键。

## 12. 调试快照

`snapshot_for_debug()` 至少返回：

```text
phase
cycle_index
completed_fragments_sorted
first_room_loop_1
behavior_echo_played
clock_attempts
clock_solved
final_memory_opened
ending_committed
```

快照只读，不暴露可写状态引用。测试失败时输出该快照和最后十次合法/拒绝迁移。

## 13. 错误与恢复

- 缺失非关键文本：开发构建显示键名并报错；发布构建显示安全占位，不崩溃。
- 缺失关键阶段数据：阻止发布验收；运行时返回标题并记录错误，不能进入半完成结尾。
- 找不到变化目标：跳过该变化并报 P1，不创建临时节点猜测。
- 音频缺失：允许批准的静默占位，但必须在开发面板列出。
- 非法状态迁移：拒绝且保留原状态。

## 14. 契约测试

至少覆盖：

- 所有稳定 ID 唯一且引用存在；
- 六种碎片顺序只触发一次 `all_fragments_completed`；
- 重复提交碎片、时钟和结尾幂等；
- 所有非法阶段迁移被拒绝；
- 第二轮变化目标全部存在；
- 本地化键完整且无未使用关键键；
- 设置损坏时恢复默认，进度从不被序列化；
- 发布构建不注册 `dev_panel` 行为或调试入口。
