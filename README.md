# Game First Tetris

一个基于 Godot 4 的俄罗斯方块原型项目，当前同时保留两条线：
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

## 多端最小适配约定

### 当前断点

- 主菜单：
  - `>= 480px` 宽度时属于比较舒适的阅读区间
  - `360px - 479px` 仍可用，依赖文字换行和滚动访问
  - `< 360px` 暂不作为当前保证区间
- 游戏界面：
  - `>= 920px` 保持棋盘 + HUD 左右布局
  - `< 920px` 切换为上下堆叠，并进入紧凑 HUD
- HUD / Help：
  - `< 920px` 时进入更紧凑排列
  - 长说明不常驻主 HUD，统一进入 Help 面板

### 真实目标尺寸清单

- Web 小窗口：`360 x 640`
  - 当前：可用
  - 兜底：菜单滚动、游戏内上下堆叠、Help 面板承接长说明
  - 后续最需要补：更细的字体与间距断点
- 安卓竖屏：`393 x 852`、`412 x 915`
  - 当前：结构上可用
  - 兜底：上下堆叠 + 紧凑 HUD + Help 面板
  - 后续最需要补：触控区与更明确的竖屏优先布局
- Windows 常见窗口：`960 x 640`、`1024 x 768`、`1280 x 720`
  - 当前：可用，其中 `>= 920px` 会保持左右布局
  - 兜底：低于断点时切换到上下堆叠
  - 后续最需要补：更真实的桌面窗口压缩测试

## 文档入口

- `docs/task-board.md`：当前任务与阶段状态
- `docs/roadmap.md`：路线图与下一阶段建议
- `docs/test-checklist.md`：当前验证清单
- `docs/setup.md`：本地环境与启动说明