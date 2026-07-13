# 开发环境与基础命令

状态：**F-01 Mac 开发基线**<br>
最后更新：2026-07-13

本项目在 Apple Silicon Mac 上开发，使用 Godot `4.6.3-stable` Standard（非 .NET）版本和 GDScript。首发与发布验收平台仍是 Windows x86_64；Mac 本地运行不扩大产品平台范围。

## 本机工具

用户级 Godot 应用：

```text
~/Applications/Godot-4.6.3-stable.app
```

命令行可执行文件：

```text
~/Applications/Godot-4.6.3-stable.app/Contents/MacOS/Godot
```

标准导出模板安装在 Godot 用户数据目录的 `export_templates/4.6.3.stable/`。不得使用 .NET 模板或其他 Godot 版本覆盖该目录。

## 初始化与验证

首次克隆或修改项目输入/显示基线后执行：

```sh
GODOT="$HOME/Applications/Godot-4.6.3-stable.app/Contents/MacOS/Godot"
"$GODOT" --headless --path . --script tools/godot/configure_project.gd
"$GODOT" --headless --path . --script tests/smoke/project_boot_smoke.gd
"$GODOT" --headless --path . --script tests/smoke/settings_smoke.gd
"$GODOT" --headless --path . --script tests/smoke/game_state_smoke.gd
"$GODOT" --headless --path . --script tests/smoke/dialogue_smoke.gd
"$GODOT" --headless --path . --script tests/smoke/playable_bedroom_smoke.gd
"$GODOT" --headless --path . --script tests/smoke/house_layout_smoke.gd
```

测试分别覆盖项目契约、设置损坏恢复与重载、六种碎片顺序和状态不变量、中文两页文本的快进/输入保护，以及卧室移动—调查—文本—恢复控制闭环。

本地打开编辑器：

```sh
"$GODOT" --editor --path .
```

生成 Windows x86_64 开发构建：

```sh
mkdir -p build/windows
"$GODOT" --headless --path . --export-debug "Windows Desktop" build/windows/HellCycle.exe
```

成功生成 `.exe` 只证明导出链有效；P-06 仍必须在真实 Windows 环境运行并完成干净环境验收。

导出预设只打包主场景的可达依赖，不得把 `tests/`、`tools/`、文档或可编辑美术源塞入游戏包。`build/` 是本地验证产物，不提交仓库。

## 像素显示契约

- 基础视口：640×360；
- `canvas_items` 伸缩，`keep` 纵横比，`integer` 倍率；
- 默认最近邻采样，不使用 Mipmaps；
- 世界节点和相机位置保持整数像素；
- 32×32 环境瓦片、32×48 主角；
- 当前地图实现使用 `TileMapLayer`，不使用旧式单体 `TileMap`。
