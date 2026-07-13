# 生成式 V3 美术记录

状态：**生产中**  
生成方式：OpenAI 内置图像生成工具  
项目指导：David Luo  
开始日期：2026-07-13

V3 将生成式位图作为玩家可见美术的主要来源。旧的确定性 SVG/PNG 图集保留为碰撞、定位和回退参考，不再代表最终视觉目标。

## 风格母版

| 文件 | 用途 | SHA-256 |
|---|---|---|
| `rooms/living_room_master.png` | 全项目房间材质、光照、细节密度和俯视透视母版 | `d332030a8f27a4cce76dafe4191ab3faf15598437bcbfef004f5d7f88c2a30b1` |
| `rooms/bedroom_master.png` | 第一轮卧室母版；单枕、冷被褥、空置痕迹和安全负空间 | `aade0166babe294971e3c6089c7da1f57cc826006ae9444e2b82fbe0652500f8` |
| `rooms/kitchen_master.png` | 第一轮厨房母版；冷硬瓷砖、家庭使用痕迹、低位收据与碎玻璃 | `60f105800de48020d02e909fc591c63350b7a65bacff94337203afd1a21310aa` |
| `rooms/child_room_master.png` | 第一轮儿童房母版；生活痕迹、床侧画纸、身高线和褪色暖色 | `e9440c08687624a7f3e22e786c6d2bcdef65b7c047475928085382ff9df76c3c` |
| `rooms/child_room_loop1_background_v2.png` | 儿童房精确编辑版；左墙加入与中央走廊相连的双瓦片宽门洞，其余构图锁定 | `c3a12bc36fa85e4860ff38cfb4eaefec389a27bcb40f20084fa98a7ee0e77cc7` |
| `rooms/hallway_master.png` | 第一轮中央走廊母版；五向门洞、出口区分、灯具节奏和克制生活痕迹 | `f8751d0008ec08f767ce7a09db5265ab6edc0b2af31ee065dc679a76f17c5049` |
| `rooms/living_room_loop1_background.png` | 移除母版人物后的第一轮客厅纯背景 | `1b2e154e7e535131c03ca808de32262ae128a0daa6edde017c67249b32196fe6` |
| `rooms/bedroom_loop1_background.png` | 移除母版人物后的第一轮卧室纯背景 | `ed5c16b8e87f97a6ea79f4c0a4f597351e6b74bd0050f4a1f71a7a81ea26966c` |
| `characters/qin_zheng_sheet_chroma.png` | 秦峥四方向四步态生成母版，品红键控背景 | `fb721e29831d26c9e8eddd9319ab9817384d06cf2b2769dddb900976768fa3f4` |
| `characters/qin_zheng_sheet_alpha.png` | 使用内置技能键控工具生成的透明母版 | `998d6bf3a056e10744a5e1a7412f1a70eef7172f9da8732639a03ffd26c188f4` |
| `characters/qin_zheng_spritesheet.png` | 最大连通主体清理、统一缩放后的 128×192 Godot 精灵表 | `1f1d01e19e9ac01632c85930a3396f0762be40f5c9dfdc812b931286e155b3bd` |
| `runtime/rooms/bedroom_loop1.png` | 第一轮卧室 640×360 最近邻运行时背景 | `0a544d15de14895b0b6817df8cbfee1a2c95af7e7fd90fd2bf94ff3e1f9d5595` |
| `runtime/rooms/hallway_loop1.png` | 第一轮走廊 640×360 最近邻运行时背景 | `a4dbf720d8ef6f52347c62e41317e0b5f7ad866830ad2665a18a63362a721670` |
| `runtime/rooms/kitchen_loop1.png` | 第一轮厨房 640×360 最近邻运行时背景 | `6eb3b71c18da845bada17057708dbea5e0fe8cab2b103da1c2e98d224f50eab6` |
| `runtime/rooms/child_room_loop1.png` | 第一轮儿童房门洞校正版 640×360 最近邻运行时背景 | `3606c92e60684cf6709c744d8f2b6b71ded4fa5c583e9a0602aeb38045bc10a7` |
| `runtime/rooms/living_room_loop1.png` | 第一轮客厅 640×360 最近邻运行时背景 | `813c11c33a36ca5271917a3aad0ec1f9d78652a5989e2d374a2b8a4be5beff69` |

母版提示的核心约束：高完成度正交俯视像素美术；可信的三口之家客厅；入口、家庭桌、照片形成主视线，时钟位于独立视线；冷暗环境与克制暖灯；无怪物、血液、宗教符号、文字和水印。

儿童房门洞精确编辑提示：以 `child_room_master.png` 为编辑目标，只在左墙中段加入约两块 32px 运行时瓦片宽的开放门洞与木门框；锁定房间轮廓、床、床侧纸角、书桌、书架、窗、身高线、玩具、地毯、灯具、家具位置、光照和色板；右墙保持封闭；无角色、文字、符号、水印、怪物、血液或透视漂移。使用 OpenAI 内置图像生成工具的 `precise-object-edit` 工作流。

## 生产规则

- 后续房间必须引用客厅母版，保持透视、材质和光照一致；
- 第一轮先建立可信日常空间，第二轮只编辑锁定变化；
- 关键交互物保留独立覆盖层，背景不承担状态逻辑；
- 每张最终资产进入项目后记录提示摘要、SHA-256、裁切与缩放方式；
- Godot 运行截图是最终验收依据，生成原图本身不等于 `APPROVED`。

秦峥处理命令：

```sh
python3 "$HOME/.codex/skills/.system/imagegen/scripts/remove_chroma_key.py" \
  --input assets/game/generated_v3/characters/qin_zheng_sheet_chroma.png \
  --out assets/game/generated_v3/characters/qin_zheng_sheet_alpha.png \
  --auto-key border --soft-matte --transparent-threshold 12 \
  --opaque-threshold 220 --despill
python3 tools/process_generated_character.py
```

房间运行时处理命令：

```sh
"$HOME/Applications/Godot-4.6.3-stable.app/Contents/MacOS/Godot" \
  --headless --path . --script tools/godot/process_v3_rooms.gd
```

处理器固定输出 640×360 PNG 并使用最近邻缩放；儿童房使用精确编辑母版直接对齐左侧门洞，不再水平翻转。生成背景只负责可见画面，Godot 中的 V2 TileMap 与道具节点保持隐藏，并继续提供稳定的房间网格、门洞、碰撞与交互坐标。
