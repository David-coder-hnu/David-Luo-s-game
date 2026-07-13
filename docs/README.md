# 制作文档索引

本目录是《地狱轮回》的制作依据。除明确标记为“历史归档”的文件外，所有实现、测试和内容评审都必须以本页列出的权威文档为准。

## 权威顺序

当文档出现冲突时，按以下顺序处理：

1. [`DECISIONS.md`](DECISIONS.md) — 已接受的决定优先级最高；修改决定必须新增修订记录。
2. [`VERTICAL_SLICE.md`](VERTICAL_SLICE.md) — 当前里程碑的范围、流程与完成定义。
3. [`NARRATIVE_BEATS.md`](NARRATIVE_BEATS.md) — 叙事事实、逐拍文本和呈现边界。
4. 专项制作规格 — [`ART_BIBLE.md`](ART_BIBLE.md)、[`ART_REVIEW.md`](ART_REVIEW.md)、[`LEVEL_BLOCKOUT.md`](LEVEL_BLOCKOUT.md)、[`UI_UX_SPEC.md`](UI_UX_SPEC.md)、[`AUDIO_DIRECTION.md`](AUDIO_DIRECTION.md)。专项内的具体规则优先于通用技术默认值。
5. [`TECHNICAL_DESIGN.md`](TECHNICAL_DESIGN.md) 与 [`IMPLEMENTATION_CONTRACTS.md`](IMPLEMENTATION_CONTRACTS.md) — 系统结构、稳定 ID、数据和事件接口。
6. [`ASSET_MANIFEST.md`](ASSET_MANIFEST.md) — 当前版本允许生产的完整资产范围。
7. [`PLAYTEST.md`](PLAYTEST.md) — 如何判断实现正确、体验假设是否成立。
8. [`AI_BUILD_PROTOCOL.md`](AI_BUILD_PROTOCOL.md) — 如何把规格拆成可执行、可验收的 AI 任务。
9. [`GAME_VISION.md`](GAME_VISION.md) — 长期产品方向和设计原则。
10. [`ROADMAP.md`](ROADMAP.md) — 当前阶段通过后才生效的后续计划。

GitHub 仓库页的非代码设置与更新规则记录在 [`GITHUB_SHOWCASE.md`](GITHUB_SHOWCASE.md)，它不改变游戏需求优先级。

Mac 开发环境、Godot 路径和基础验证命令记录在 [`DEVELOPMENT.md`](DEVELOPMENT.md)；它执行技术基线，不改变产品需求优先级。

如果较低优先级文档与较高优先级文档冲突，应先修正文档，不得自行选择实现。

## 文档职责

| 文档 | 回答的问题 | 不负责 |
|---|---|---|
| `GAME_VISION` | 为什么做、玩家应感受什么 | 当前迭代的任务细节 |
| `DECISIONS` | 哪些关键取舍已经锁定 | 论证所有历史备选方案 |
| `VERTICAL_SLICE` | 本轮具体做什么、何时算完成 | 完整版全部内容 |
| `NARRATIVE_BEATS` | 玩家看到、听到和理解什么 | 节点结构和代码接口 |
| `ART_BIBLE` | 色板、像素、构图和变化强度 | 改写叙事事实 |
| `ART_REVIEW` | 当前美术质量、拒绝原因和批准证据 | 用静态脚本检查替代实机评审 |
| `LEVEL_BLOCKOUT` | 坐标、门洞、碰撞和视线 | 最终美术细节 |
| `UI_UX_SPEC` | 屏幕、输入反馈和舒适性 | 状态规则和剧情内容 |
| `AUDIO_DIRECTION` | 声景、混音、逐拍声音 | 新增剧情事件 |
| `TECHNICAL_DESIGN` | 系统怎样协作 | 改写剧情或扩大范围 |
| `IMPLEMENTATION_CONTRACTS` | ID、字段、信号和错误语义 | 产品方向选择 |
| `DEVELOPMENT` | Mac 开发环境、Godot 命令和导出验证 | 改变首发平台或游戏范围 |
| `ASSET_MANIFEST` | 当前要生产哪些资产 | 未经决策扩大范围 |
| `PLAYTEST` | 怎样验收和收集证据 | 用主观偏好替代测试观察 |
| `AI_BUILD_PROTOCOL` | 怎样拆分、委派和评审任务 | 替代专项设计规格 |
| `ROADMAP` | 通过阶段门后做什么 | 承诺未经验证的发布日期 |

## 剧透边界

- 根目录 `README.md`、商店页和公开宣传材料必须无核心身份剧透。
- 本目录除本页和 `ASSET_CREDITS.md` 外，默认允许完整剧透。
- 测试人员在体验结束前不得阅读 `NARRATIVE_BEATS.md`。

## 历史归档

`docs/design/` 中带时间戳的文件是立项期间的自动生成稿，仅用于追溯思路。它们可能包含互相冲突或已经被推翻的规格，不得作为实现和验收依据。

## 变更规则

- 需求变化先更新 `DECISIONS.md`，再同步受影响文档，最后修改实现。
- 任何新增功能必须同时拥有明确的体验目的和验收方式。
- 影响叙事事实的改动必须同时检查切片流程、文本、测试问题和公开剧透边界。
- 文档中的“必须”表示发布阻断项；“应该”允许在评审后例外；“可以”表示非承诺选项。
