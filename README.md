# Game First Tetris

一个以“适合新手学习正规游戏开发流程”为核心目标的 Godot 4 俄罗斯方块项目。

当前阶段只做一件事：先把一个干净、稳定、规则标准的俄罗斯方块做扎实。  
Rogue 元素会作为未来方向保留，但不会在本阶段提前实现。

## 当前状态

- 已完成项目初始化
- 已建立 Git 仓库并绑定 GitHub 远程
- 已创建最小 Godot 4 项目骨架
- 已补充基础文档与任务看板
- 第一阶段最小可玩版已完成
- 第二阶段现代标准增强主线已完成
- 第二阶段结构整理支线已完成第一轮最小落地
- 当前已支持：开局生成活动方块、最小可用的 7-bag 方块生成、最小可用的 Next Queue、最小可用的 Hold、Next / Hold 图形化预览、与静态格子的基础碰撞、左右移动、自动下落、等级与下落速度成长、软降、Hard Drop、基础旋转合法性判断、触底锁定、写回棋盘、继续生成下一个活动方块、出生位置校验失败后的游戏结束、最小可用的重新开始、基础消行，以及按清除行数累计的基础计分
- 当前项目已经具备一个可运行、可验证、可循环游玩的标准俄罗斯方块基础闭环
- 当前项目已显式定义输入动作：`hard_drop` 默认绑定 `Space`，`hold` 默认绑定 `C`
- 当前等级采用最小规则：累计消除 5 行升 1 级，等级提升后自动下落速度加快
- 第二阶段当前已达到可收口状态
- 当前更合理的后续方向是：进入下一阶段，按需要继续做更深一层的结构整理或表现层完善
- 当前已完成一轮低风险结构整理：方块来源接口、规则参数入口、运行结果数据出口都已有最小可用边界

## 开发环境

- 项目目录：`D:\workspace4Codex\game-first-tetris`
- Godot 目录：`D:\Development\Godot`
- 已验证版本：`4.6.1.stable.official`

## 第二阶段目标

1. 在第一阶段最小可玩版基础上，补强现代标准体验
2. 只做少量、低侵入的结构整理，为未来扩展预留接口
3. 继续保持小步提交、可验证、可回退

## 建议工作流

1. 先看 [`docs/setup.md`](docs/setup.md)，确认本地启动方式
2. 再看 [`docs/roadmap.md`](docs/roadmap.md)，理解阶段划分
3. 再看 [`docs/stage-1-rules.md`](docs/stage-1-rules.md)，确认第一阶段规则边界与拆分
4. 再看 [`docs/stage-1-architecture.md`](docs/stage-1-architecture.md)，确认节点结构与模块职责
5. 再看 [`docs/stage-1-data-model.md`](docs/stage-1-data-model.md)，确认棋盘与方块的数据结构
6. 再看 [`docs/test-checklist.md`](docs/test-checklist.md)，按当前能力做最小验证
7. 按 [`docs/task-board.md`](docs/task-board.md) 逐步推进任务
8. 每完成一个小目标就验证并提交

## 运行项目

可以直接使用本机 Godot 控制台启动：

```powershell
D:\Development\Godot\godot.cmd --path D:\workspace4Codex\game-first-tetris
```
