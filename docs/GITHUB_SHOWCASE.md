# GitHub 展示配置

状态：**README 与资产已完成**<br>
最后更新：2026-07-13

本文记录不存储在 Git 历史中的仓库页面设置，确保更换维护者后仍能复现展示效果。

## About

建议仓库描述：

> A 2D pixel psychological horror game about memory, guilt, and an inescapable home. 记忆越清晰，惩罚越接近。

Homepage：垂直切片发布前留空；发布后填写正式 itch.io 页面，不使用临时网盘或本地演示地址。

## Topics

```text
godot
godot-engine
gdscript
pixel-art
psychological-horror
horror-game
indie-game
narrative-game
game-development
open-source-game
```

Topics 使用小写和连字符，不加入与当前范围不符的 `procedural-generation`、`roguelike`、`rpg-maker` 或尚未支持的平台。

## Social Preview

文件：[`../assets/branding/github-social-preview.jpg`](../assets/branding/github-social-preview.jpg)

- 尺寸：1280×640；
- 格式：JPEG；
- 文件大小：低于 1 MB；
- 固体深色背景，兼容浅色/深色分享界面；
- 无文字，避免社交平台裁切和多语言冲突；
- 明确属于概念视觉，不冒充实机截图。

上传路径：仓库 `Settings` → `General` → `Social preview` → `Edit` → `Upload an image`。

GitHub 没有把 Social Preview 作为仓库文件自动读取；仅提交图片不会替代设置页上传。上传后用仓库链接在一个支持 Open Graph 预览的平台验证裁切。

## README 视觉规则

- 首屏只出现主视觉、标题、核心句、状态徽章和短导航。
- 公开文本不得泄露主角完整犯罪身份。
- 概念图必须标注不是实机截图；有实机画面后另建 `screenshots/`，不静默替换概念图含义。
- 徽章最多五个，优先表达里程碑、设计成熟度、引擎、平台和许可。
- 不使用访问量计数器、自动播放 GIF、贡献贪吃蛇或与游戏气质不一致的动态组件。
- Mermaid 只承担核心循环，不把完整技术架构塞进首页。

## 发布后更新

垂直切片完成后：

1. 在主视觉下加入一张真实游戏截图并明确标注 build 版本；
2. 把里程碑徽章改为 `playable vertical slice`；
3. 添加 itch.io 链接和 Windows 下载入口；
4. 将开发清单替换为实际构建、测试人数和已知限制；
5. 保留设计规格入口，避免 README 变成只有宣传没有可信度的页面。
