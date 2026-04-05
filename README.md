# Game First Tetris

一个基于 Godot 4 的俄罗斯方块项目，当前同时保留两条线：
- 稳定经典主线
- Rogue 原型实验线

当前工作分支是 `feature/rogue-prototype`，用于继续推进 Rogue 原型验证；`main` 应继续代表更稳定的经典主线。

## 当前状态

当前版本已经达到“可试玩原型版”状态，主要包含：
- 经典模式完整可玩闭环
- Rogue 模式三轮固定触发选择原型
- 最小局间承接壳层
- 暂停 / 中途重开 / 返回主菜单
- 最小声音反馈与消行闪烁
- HUD 收敛、Help 入口、响应式兜底

## 运行环境

- 项目目录：`D:\workspace4Codex\game-first-tetris`
- Godot 版本：`4.6.1.stable.official`
- 推荐使用本机 Godot 运行或编辑

## 运行项目

```powershell
D:\Development\Godot\godot.cmd --path D:\workspace4Codex\game-first-tetris
```

无头验证：

```powershell
D:\Development\Godot\Godot_v4.6.1-stable_win64_console.exe --headless --path D:\workspace4Codex\game-first-tetris --quit
```

## 当前控制方式

- `← / →`：左右移动
- `↑`：旋转
- `↓`：软降
- `Space`：Hard Drop
- `C`：Hold
- `Esc`：暂停 / 关闭 Help

## 模式说明

### 经典模式

- 保持标准俄罗斯方块主循环
- 不包含 Rogue 强化与局间带入

### Rogue 模式

当前是低侵入原型，已落地：
- 开局前第一次 `3 选 1`
- 局内第二次、第三次固定触发选择
- 三种最小强化：
  - Hard Drop 额外得分
  - 消行额外得分
  - 一次出生保护
- 最小局间带入：上一局最后一次获得的强化，可作为下一局额外起始奖励

## HUD 与界面约定

主 HUD 只保留高频信息：
- 模式摘要
- 当前状态
- 分数 / 等级
- Next / Hold
- Rogue 摘要（仅 Rogue 模式）

不适合常驻主界面的长说明，统一放到 `Help` 面板中。

当前已做的多端最小适配包括：
- 小窗口下主菜单支持滚动访问
- 游戏内主布局在窄宽度下会改为上下堆叠
- HUD 预览区和系统按钮组会切到更紧凑的排列

## 文档入口

- `docs/task-board.md`：当前任务与阶段收口记录
- `docs/roadmap.md`：阶段路线与方向说明
- `docs/test-checklist.md`：当前验证清单
- `docs/setup.md`：本地环境与启动说明
