# 实机证据

本目录只保存由锁定版本 Godot 实际运行产生的截图、录屏与测试证据。确定性合成预览和概念图不得放入此处冒充实机。

## 第一轮卧室首张可玩截图

文件：`runtime/bedroom_first_playable.png`

- 引擎：Godot `4.6.3.stable.official` Standard；
- 渲染：macOS Compatibility，Apple M4，OpenGL API 4.1 Metal；
- 输出：640×360，若开发窗口为 2×，只在 Godot 内使用最近邻还原逻辑画布尺寸；
- 运行内容：`TileMapLayer` 卧室、V2 环境和道具图集、32×48 四方向角色、20×12 脚部碰撞、96 px/s 移动、48 px 调查选择和 HUD 提示；
- 状态：第一轮卧室开发证据，资产仍为 `REVIEW`，不代表五房间或三状态评审完成。

复现命令：

```sh
GODOT="$HOME/Applications/Godot-4.6.3-stable.app/Contents/MacOS/Godot"
"$GODOT" --path . -- --capture-screenshot=res://docs/evidence/runtime/bedroom_first_playable.png
```
