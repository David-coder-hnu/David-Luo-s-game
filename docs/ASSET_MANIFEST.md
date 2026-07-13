# 垂直切片资产清单

状态：**制作清单已锁定，资产尚未生产**<br>
适用版本：Vertical Slice 0.1<br>
最后更新：2026-07-13

本文定义垂直切片允许进入制作队列的资产。未列出的正式资产默认不属于当前范围；新增前必须说明替代或新增原因。

状态枚举：`PLANNED`、`BLOCKOUT`、`REVIEW`、`APPROVED`。

## 1. 环境瓦片

| ID | 文件建议 | 尺寸/形式 | 变体 | 状态 | 验收重点 |
|---|---|---|---|---|---|
| ENV-001 | `tiles_wall_base.png` | 16×16 图集 | 冷墙、墙角、焦边 | PLANNED | 无纯黑统一描边 |
| ENV-002 | `tiles_floor_wood.png` | 16×16 图集 | 4 个低对比变化 | PLANNED | 重复纹理不抢注意力 |
| ENV-003 | `tiles_floor_kitchen.png` | 16×16 图集 | 瓷砖、边缘、破损 | PLANNED | 与木地板清楚区分 |
| ENV-004 | `tiles_door_frames.png` | 16×16 图集 | 卧室、出口、开放门洞 | PLANNED | 出口与卧室门不混淆 |
| ENV-005 | `tiles_front_occluders.png` | 16×16 图集 | 高墙、柜顶 | PLANNED | 角色遮挡层正确 |
| ENV-006 | `tiles_scorch_edge.png` | 16×16 图集 | V1/V3 | PLANNED | 只使用核心色板 |

## 2. 房间道具

| ID | 对象 ID | 资产 | 建议包围尺寸 | 第二轮变体 | 状态 |
|---|---|---|---|---|---|
| PROP-001 | `bed` | 单人床、被褥 | 48×32 | 轻微床沿压痕 | PLANNED |
| PROP-002 | `bedside_table` | 空床头柜 | 16×16 | 无 | PLANNED |
| PROP-003 | `wardrobe` | 空衣柜 | 32×32 | 柜门偏开 | PLANNED |
| PROP-004 | `kitchen_counter` | 水槽与橱柜组 | 模块化图集 | 冰箱声停止，无视觉替换 | PLANNED |
| PROP-005 | `kitchen_glass` | 单杯/双杯 | 16×16 | 单杯替换双杯 | PLANNED |
| PROP-006 | `kitchen_stain` | 低对比污迹 | 32×16 | 第二轮隐藏 | PLANNED |
| PROP-007 | `kitchen_receipt` | 焦边收据 | 16×16 + 特写 | 文本变体 | PLANNED |
| PROP-008 | `child_bed` | 儿童床 | 48×32 | 床面更整齐 | PLANNED |
| PROP-009 | `height_marks` | 身高刻度 | 16×32 | 无 | PLANNED |
| PROP-010 | `music_box` | 音乐盒 | 16×16 | 第二轮声音启用 | PLANNED |
| PROP-011 | `child_drawing` | 床下/朝外儿童画 | 16×16 + 两张特写 | 画面与位置替换 | PLANNED |
| PROP-012 | `sofa` | 客厅沙发 | 48×32 | 无 | PLANNED |
| PROP-013 | `family_table` | 餐桌与三把椅子 | 48×48 | 一把椅子角度变化 | PLANNED |
| PROP-014 | `wedding_photo` | 相框与特写 | 16×16 + 两张特写 | 男性轮廓恢复 | PLANNED |
| PROP-015 | `living_clock` | 墙钟与数字 UI | 16×32 | 第二轮可调整 | PLANNED |
| PROP-016 | `memory_compartment` | 暗格闭合/开启 | 32×32 | 解谜后开启 | PLANNED |
| PROP-017 | `memory_tape` | 录音带 | 16×16 + 特写 | 仅第二轮出现 | PLANNED |
| PROP-018 | `hall_lights` | 五盏灯状态 | 16×16 | 亮/暗/V3 | PLANNED |
| PROP-019 | `exit_door` | 封闭出口门 | 32×32 | 惩罚交互文本 | PLANNED |

特写图不直接使用生成概念图；必须按 UI 尺寸重绘并使用同一色板。

## 3. 角色

| ID | 资产 | 尺寸 | 帧 | 状态 | 验收重点 |
|---|---|---:|---:|---|---|
| CHAR-001 | 秦峥 idle | 16×24 | 4 方向×1 | PLANNED | 轮廓与照片男性一致 |
| CHAR-002 | 秦峥 walk | 16×24 | 4 方向×4 | PLANNED | 8–10 FPS、脚步事件对齐 |
| CHAR-003 | 秦峥惩罚减速 | 复用 walk | 无新增 | PLANNED | 不新增受伤动画 |

切片不制作苏岚、秦禾或执行者的场景角色精灵。

## 4. UI 与品牌

| ID | 资产 | 形式 | 状态 | 发布用途 |
|---|---|---|---|---|
| UI-001 | 游戏中文字标 | SVG/高分辨率 PNG | PLANNED | 标题页、商店页 |
| UI-002 | 文本框九宫格 | PNG | PLANNED | 游戏 UI |
| UI-003 | `E` / `Enter` / `Esc` 键帽 | PNG 或矢量源 | PLANNED | 提示 |
| UI-004 | 按住确认细环 | 程序绘制优先 | PLANNED | 面对/回避 |
| UI-005 | 时钟数字与选择框 | 程序文本 + PNG 边框 | PLANNED | 时钟谜题 |
| UI-006 | 菜单焦点菱形 | 8×8 PNG | PLANNED | 标题/暂停 |
| UI-007 | 内容提示图标 | 16×16 PNG | PLANNED | 安全提示 |
| BRAND-001 | GitHub 主视觉 | 1774×887 PNG | APPROVED | 概念展示，不作实机截图 |
| BRAND-002 | 视觉语言板 | SVG | APPROVED | README / 美术圣经 |
| BRAND-003 | 房屋灰盒图 | SVG | APPROVED | README / 关卡文档 |
| BRAND-004 | GitHub Social Preview | 1280×640 JPG | APPROVED | 仓库 Settings 上传；不在游戏内使用 |

## 5. 后处理

| ID | 资产/资源 | 形式 | 状态 | 验收重点 |
|---|---|---|---|---|
| FX-001 | 饱和度控制 | CanvasItem shader | PLANNED | 100%→55%，无色阶断裂 |
| FX-002 | 惩罚暗角 | shader/纹理 | PLANNED | 不遮挡脚下与最近出口 |
| FX-003 | 焦红边缘 | shader + 低频噪声 | PLANNED | 无快速闪烁，安全模式静态 |
| FX-004 | 淡入淡出 | UI ColorRect/动画 | PLANNED | 黑屏与音频同步 |

## 6. 音频资产

| ID | 文件建议 | 类型 | 循环 | 状态 |
|---|---|---|---|---|
| AUD-001 | `amb_bedroom_house_loop.ogg` | 房屋低频 | 是 | PLANNED |
| AUD-002 | `amb_bedroom_pipe_sequence.ogg` | 水管序列 | 是 | PLANNED |
| AUD-003 | `amb_kitchen_fridge_loop.ogg` | 冰箱 | 是 | PLANNED |
| AUD-004 | `foley_step_wood_01-04.wav` | 木脚步 | 否 | PLANNED |
| AUD-005 | `foley_step_tile_01-04.wav` | 瓷砖脚步 | 否 | PLANNED |
| AUD-006 | `mem_kitchen_cabinet.wav` | 橱柜记忆 | 否 | PLANNED |
| AUD-007 | `mem_child_counting_keys.wav` | 数数与钥匙 | 否 | PLANNED |
| AUD-008 | `mem_living_table_silence.wav` | 餐具与静默 | 否 | PLANNED |
| AUD-009 | `evt_lights_off_01-05.wav` | 灯灭 | 否 | PLANNED |
| AUD-010 | `evt_door_handle_turn.wav` | 门把 | 否 | PLANNED |
| AUD-011 | `evt_floor_pressure.wav` | 木板受压 | 否 | PLANNED |
| AUD-012 | `evt_heartbeat_loop.ogg` | 心跳 | 是 | PLANNED |
| AUD-013 | `evt_breath_close.wav` | 近距离呼吸 | 否 | PLANNED |
| AUD-014 | `foley_clock_wrong.wav` | 齿轮回转 | 否 | PLANNED |
| AUD-015 | `foley_compartment_open.wav` | 暗格 | 否 | PLANNED |
| AUD-016 | `mem_tape_face.ogg` | 面对结尾磁带 | 否 | PLANNED |
| AUD-017 | `mem_child_hum_avoid.wav` | 回避三音 | 否 | PLANNED |
| AUD-018 | `ui_confirm_cancel_hold.wav` | UI 反馈组 | 否 | PLANNED |

详细混音和时序以 `AUDIO_DIRECTION.md` 为准。

## 7. 非关键调查物预算

最多从下列候选选择 12 个，不要求全部制作：儿童身高刻度、转学表、购物清单、修补衣袖、单只儿童袜、空药盒、三人餐具、坏掉的门链、未寄出的信封、停用电话、空相册页、被擦除的日历。

每增加一个候选，必须删除另一个，保持调查密度和文本预算。

## 8. 资产验收流程

1. `BLOCKOUT`：轮廓和尺寸在实机场景可用；
2. `REVIEW`：符合色板、网格、叙事与许可要求；
3. 在第一轮、第二轮、惩罚三种状态截图；
4. 通过 100% / 200% / 全屏整数缩放检查；
5. 更新本表为 `APPROVED` 并登记 `ASSET_CREDITS.md`。

未经 `APPROVED` 的资产可以进入开发构建，不能进入发布候选。
