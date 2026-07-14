# GitHub 展示配置

状态：**README V3 展示重构完成；品牌概念、实机证据、核心机制和开发入口已形成清晰层级**<br>
最后更新：2026-07-14

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

- 阅读顺序固定为：品牌承诺 → 实机证明 → 轮回差异 → 当前状态 → 运行与制作入口。
- 首屏只出现主视觉、标题、核心句、状态徽章和短导航；首个正文视口必须尽快出现真实运行画面。
- 公开文本不得泄露主角完整犯罪身份。
- 概念图必须标注不是实机截图；实机画面使用 `docs/evidence/runtime/v3_*.png`，不静默替换概念图含义。
- 第一轮与第二轮使用同机位对照，优先证明“房子会记得”，而不是堆叠无上下文截图。
- 旧版 V2 资产可以保留作制作档案，但不得与 V3 并列展示成当前运行时品质。
- 徽章最多五个，优先表达真实里程碑、引擎版本、目标平台、语言和许可。
- 不使用访问量计数器、自动播放 GIF、贡献贪吃蛇或与游戏气质不一致的动态组件。
- 当前进度使用“已可验证 / 正在制作 / 发布前仍需完成”三列，避免把内部任务清单直接倾倒给访客。
- 制作文档只保留高价值路由，不在首页复述整套规格。

## 发布后更新

垂直切片完成后：

1. 把里程碑徽章改为 `playable vertical slice`；
2. 在实机主图旁明确标注发布 build 版本；
3. 添加 itch.io 链接和 Windows 下载入口；
4. 将开发状态表替换为实际构建、测试人数和已知限制；
5. 保留设计规格入口，避免 README 变成只有宣传没有可信度的页面。
