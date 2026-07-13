# 实机证据

本目录只保存由锁定版本 Godot 实际运行产生的截图、录屏与测试证据。确定性合成预览和概念图不得放入此处冒充实机。

## 第一轮五房间实机截图

文件：

- `runtime/bedroom_first_playable.png`
- `runtime/first_loop_hallway.png`
- `runtime/first_loop_kitchen.png`
- `runtime/first_loop_child_room.png`
- `runtime/first_loop_living_room.png`

- 引擎：Godot `4.6.3.stable.official` Standard；
- 渲染：macOS Compatibility，Apple M4，OpenGL API 4.1 Metal；
- 输出：640×360，若开发窗口为 2×，只在 Godot 内使用最近邻还原逻辑画布尺寸；
- 运行内容：按锁定坐标连通的卧室、走廊、厨房、儿童房与客厅，V2 环境和道具图集、32×48 四方向角色、20×12 脚部碰撞、96 px/s 移动、房间相机和 HUD 房间标签；
- 状态：第一轮五房间开发证据，资产仍为 `REVIEW`；这些截图不代表第二轮、惩罚态、角色动画或最终发布评审完成。

复现命令：

```sh
GODOT="$HOME/Applications/Godot-4.6.3-stable.app/Contents/MacOS/Godot"
"$GODOT" --path . --resolution 1280x720 -- \
  --capture-room=bedroom \
  --capture-screenshot=res://docs/evidence/runtime/bedroom_first_playable.png
```

将 `--capture-room` 换成 `hallway`、`kitchen`、`child_room` 或 `living_room`，并同步修改输出文件名，即可复现其余截图。截图必须使用实际图形后端；`--headless` 的 dummy 渲染器没有可读取的帧缓冲。

## V3 第一轮五房间实机截图

- `runtime/v3_first_loop_bedroom.png`
- `runtime/v3_first_loop_hallway.png`
- `runtime/v3_first_loop_kitchen.png`
- `runtime/v3_first_loop_child_room.png`
- `runtime/v3_first_loop_living_room.png`

这组截图使用与上方相同的引擎、渲染器和 640×360 输出流程。玩家可见环境已替换为生成式 V3 运行时背景，秦峥使用 V3 四方向精灵；V2 TileMap 与道具图集仅作为隐藏的碰撞、房间坐标和开发回退层。儿童房截图使用左侧门洞校正版，并把交互点对齐床下纸角。状态为 `REVIEW`，尚不代表第二轮覆盖层、惩罚态或移动碰撞观感已经批准。

## V3 厨房两轮对照

- 第一轮：`runtime/v3_first_loop_kitchen.png`
- 第二轮：`runtime/v3_loop2_kitchen.png`

第二轮截图通过合法状态链 `loop_1 → punishment_1 → loop_2` 进入，不是手工替换截图。运行时根据 `GameState.cycle_index` 自动选择房间纹理；未拥有第二轮变体的房间安全回退到第一轮背景。厨房第二轮固定变化为地面水渍消失、单杯变成两只干净杯子，HUD 同步显示“第二轮”。

复现第二轮厨房：

```sh
GODOT="$HOME/Applications/Godot-4.6.3-stable.app/Contents/MacOS/Godot"
"$GODOT" --path . --resolution 1280x720 -- \
  --capture-room=kitchen \
  --capture-phase=loop_2 \
  --capture-screenshot=res://docs/evidence/runtime/v3_loop2_kitchen.png
```

## V3 儿童房两轮对照

- 第一轮：`runtime/v3_first_loop_child_room.png`
- 第二轮：`runtime/v3_loop2_child_room.png`

第二轮中，床下纸角消失，同一张儿童画移到床右侧并正面朝外；黄色房屋的门变为红色，最高人形进入屋内，门外无人。`child_drawing` 交互点从 `(35, 19)` 同步移动到 `(37, 19)`，避免画面与调查位置脱节。

复现第二轮儿童房：

```sh
GODOT="$HOME/Applications/Godot-4.6.3-stable.app/Contents/MacOS/Godot"
"$GODOT" --path . --resolution 1280x720 -- \
  --capture-room=child_room \
  --capture-phase=loop_2 \
  --capture-screenshot=res://docs/evidence/runtime/v3_loop2_child_room.png
```
