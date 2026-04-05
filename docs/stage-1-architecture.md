# 阶段 1：场景结构与模块设计

## 文档目标

这份文档只定义“第一阶段最小可玩的标准俄罗斯方块”所需的场景结构和模块边界。

- 先把节点关系定清楚
- 先把脚本职责拆清楚
- 先让后续玩法实现有稳定落点

本阶段不实现完整玩法逻辑，也不提前引入 Rogue 扩展。

## 推荐主场景结构

入口场景仍然使用 `res://scenes/main/main.tscn`，它只负责承载第一阶段主玩法场景。

主玩法场景建议为 `res://scenes/game/game_root.tscn`，结构如下：

```text
Main (Control)
└── GameRoot (Control)
    ├── Background (ColorRect)
    ├── Layout (HBoxContainer)
    │   ├── PlayfieldPanel (PanelContainer)
    │   │   └── PlayfieldMargin (MarginContainer)
    │   │       └── Playfield (Node2D)
    │   │           ├── Board (Node2D)
    │   │           └── ActivePiece (Node2D)
    │   └── SidebarPanel (PanelContainer)
    │       └── GameUI (VBoxContainer)
    └── GameManager (Node)
```

## 为什么这样拆

- `Main`：保留为项目统一入口，后续如果需要切换标题页或测试场景，不必直接改玩法场景
- `GameRoot`：承接第一阶段主玩法布局，是“这一局游戏”的根节点
- `Playfield`：只放棋盘空间相关节点，避免和 UI 混在一起
- `Board`：负责棋盘网格、边界、静态格子的显示与数据入口
- `ActivePiece`：只负责当前活动方块的显示与自身状态
- `GameUI`：只负责文字状态、提示和简单按钮，不碰棋盘逻辑
- `GameManager`：负责把各模块串起来，管理当前回合流程

## 核心模块职责

### 1. GameManager

职责：

- 持有当前局面的流程入口
- 协调 `Board`、`ActivePiece`、`GameUI`
- 负责启动、重开、结束状态切换
- 后续承接输入转发与玩法流程

当前阶段只做：

- 找到关键节点引用
- 初始化骨架显示
- 向 UI 同步当前是“结构骨架模式”

不在当前阶段做：

- 完整生成逻辑
- 回合循环
- 消行与结算

挂载节点：

- `GameRoot/GameManager`
- 脚本路径：`res://scripts/game/game_manager.gd`

### 2. Board

职责：

- 定义棋盘尺寸与单格尺寸
- 提供棋盘范围的可视化
- 后续承接静态格子数据和碰撞检测入口

当前阶段只做：

- 暴露 `10 x 20` 棋盘基础参数
- 绘制棋盘边界与网格占位
- 提供基础几何信息给其他模块使用

不在当前阶段做：

- 已锁定格子存储
- 消行判断
- 碰撞检测细节

挂载节点：

- `GameRoot/Layout/PlayfieldPanel/PlayfieldMargin/Playfield/Board`
- 脚本路径：`res://scripts/game/board.gd`

### 3. ActivePiece

职责：

- 表示当前活动方块
- 后续承接方块类型、旋转状态、位置状态
- 负责活动方块的独立显示

当前阶段只做：

- 显示一个占位用的示例方块
- 对齐棋盘单格尺寸
- 保留后续方块状态字段

不在当前阶段做：

- 真正的生成、移动、旋转、锁定逻辑
- 7 种方块完整切换

挂载节点：

- `GameRoot/Layout/PlayfieldPanel/PlayfieldMargin/Playfield/ActivePiece`
- 脚本路径：`res://scripts/game/piece.gd`

### 4. GameUI

职责：

- 展示当前阶段提示信息
- 后续承接暂停、结束提示、重开按钮等界面元素
- 与玩法逻辑保持弱耦合

当前阶段只做：

- 显示项目名、阶段名、当前骨架状态
- 放置一个预留的重开按钮

不在当前阶段做：

- 分数、等级、预览队列
- 完整 HUD

挂载节点：

- `GameRoot/Layout/SidebarPanel/GameUI`
- 脚本路径：`res://scripts/ui/game_ui.gd`

## 脚本与节点挂载清单

| 模块 | 节点路径 | 脚本 |
| --- | --- | --- |
| 主玩法骨架 | `Main/GameRoot` | 无单独脚本，先保持场景容器角色 |
| 流程协调 | `Main/GameRoot/GameManager` | `res://scripts/game/game_manager.gd` |
| 棋盘 | `Main/GameRoot/Layout/PlayfieldPanel/PlayfieldMargin/Playfield/Board` | `res://scripts/game/board.gd` |
| 当前方块 | `Main/GameRoot/Layout/PlayfieldPanel/PlayfieldMargin/Playfield/ActivePiece` | `res://scripts/game/piece.gd` |
| 侧边 UI | `Main/GameRoot/Layout/SidebarPanel/GameUI` | `res://scripts/ui/game_ui.gd` |

## 当前阶段必须保持的边界

- 允许创建最小场景骨架和脚本骨架
- 允许显示棋盘占位和活动方块占位
- 允许 `GameManager` 做最小初始化串联

当前不要做：

- 真实输入处理
- 方块下落与锁定
- 消行、结束判定、分数系统
- Next、Hold、Hard Drop、Wall Kick
- 任何 Rogue 扩展

## 验证目标

完成这一层后，项目应能达到以下状态：

- 打开项目能进入第一阶段主玩法骨架场景
- 左侧能看到 `10 x 20` 棋盘占位
- 棋盘中能看到一个示例活动方块占位
- 右侧能看到当前阶段说明与占位按钮
- 没有实现完整玩法，也没有把后续规则提前写进代码
