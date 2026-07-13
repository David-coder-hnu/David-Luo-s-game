# 资产来源与许可登记

最后更新：2026-07-13

根目录 MIT License 适用于项目代码、文档和下表明确标记为 MIT 的项目原创视觉资产。第三方或工具生成资产不得仅因位于本仓库就被假定为 MIT；必须逐项声明来源和实际许可。

## 当前资产

| 路径 | 类型 | 作者/来源 | 许可 | 修改与说明 | 获取日期 |
|---|---|---|---|---|---|
| `assets/branding/hell-cycle-hero.png` | GitHub 概念主视觉 | David Luo 项目指导；OpenAI 内置图像生成工具生成 | 由项目所有者按 MIT 分发；同时受生成服务适用条款约束 | 原始生成结果，未冒充实机截图；提示见同目录 `.prompt.md` | 2026-07-13 |
| `assets/branding/github-social-preview.jpg` | GitHub 分享预览 | 由 `hell-cycle-hero.png` 等比缩放与 JPEG 编码 | 同主视觉 | 1280×640、低于 1 MB；用于仓库 Settings | 2026-07-13 |
| `assets/branding/visual-language.svg` | 视觉语言与色板板 | 项目原创 | MIT | 代码原生 SVG | 2026-07-13 |
| `assets/diagrams/house-blockout.svg` | 五房间灰盒图 | 项目原创 | MIT | 代码原生 SVG；坐标依据 `LEVEL_BLOCKOUT.md` | 2026-07-13 |
| `assets/game/source/*.svg`、`assets/game/atlases/*.png`、`assets/game/characters/*.png`、`assets/game/ui/ui_atlas.png`、`assets/game/ui/wordmark.png`、`assets/game/fx/*.png` | 瓦片、道具、角色、UI、FX | 项目确定性生成脚本 | MIT | 由 `tools/build_visual_assets.mjs` 生成；使用美术圣经登记的核心语义色与材料过渡色；V2 为 32px 视觉基线 | 2026-07-13 |
| `assets/game/previews/bedroom_benchmark.png` | 640×360 构图标杆 | 项目确定性合成脚本 | MIT | 由实际运行时图集通过 `tools/build_art_preview.mjs` 合成；不是 Godot 实机截图 | 2026-07-13 |
| `docs/evidence/runtime/bedroom_first_playable.png`、`docs/evidence/runtime/first_loop_*.png` | 640×360 Godot 实机证据 | 项目原创场景与 V2 运行时图集；Godot 4.6.3 macOS Compatibility 渲染 | MIT | 第一轮五房间、可操控角色、TileMapLayer、碰撞、房间相机和 HUD 的运行时截图；不是概念图 | 2026-07-13 |
| `assets/game/ui/title_background.png` | 游戏标题背景 | 由项目主视觉受控裁切 | 同主视觉 | 640×360；概念视觉用于标题，不宣称实机场景 | 2026-07-13 |
| `assets/game/source/generated/*_source.png` | 叙事特写高分辨率母版 | David Luo 项目指导；OpenAI 内置图像生成工具生成 | 由项目所有者按 MIT 分发；同时受生成服务适用条款约束 | 提示与 SHA-256 见同目录 `GENERATION_RECORD.md`；不得直接导入游戏 | 2026-07-13 |
| `assets/game/closeups/*.png` | 叙事特写运行时图像 | 由上述母版经确定性处理生成 | 同母版 | 320×180、最近邻、有限色、无抖动；处理脚本可复现 | 2026-07-13 |
| `assets/game/generated_v3/**` | V3 房间母版、纯背景与角色资产 | David Luo 项目指导；OpenAI 内置图像生成工具生成；确定性脚本处理 | 由项目所有者按 MIT 分发；同时受生成服务适用条款约束 | 提示摘要、SHA-256、去背与处理流程见 `assets/game/generated_v3/GENERATION_RECORD.md`；接入前状态为生产中 | 2026-07-13 |

## 合入规则

每个外部或原创资产在合入前必须记录：

- 仓库内路径；
- 资产类型；
- 名称或简要描述；
- 作者/权利人；
- 原始来源链接或原创说明；
- 精确许可名称与版本；
- 是否允许修改和商业分发；
- 本项目做过的修改；
- 必需的署名文本；
- 获取日期。

禁止合入以下资产：

- 来源只有搜索引擎、社交媒体转发或无法定位原作者；
- 许可仅写“free”“可商用”而没有具体条款；
- 禁止再分发，但必须随游戏打包；
- 与项目 MIT 标识容易造成误解且无法单独声明；
- 使用生成式工具制作但无法满足所用工具条款或无法说明来源。

字体必须额外确认嵌入、子集化和随游戏分发权限。音效包必须确认能否以导入后形式随开源项目公开。

## 发布前审计

- [ ] 发布包中每个非代码文件都能映射到本表或明确的项目原创资产声明。
- [ ] 所有署名文本已加入游戏内 Credits 和发行页面。
- [ ] 仓库许可徽章没有把第三方资产错误描述为 MIT。
- [ ] 删除未使用资产，避免分发不必要的授权内容。
- [ ] 保留许可原文要求随附的文件。
