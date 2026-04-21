# Project Index

## 当前定位

- 项目：`game-first-tetris`
- 引擎：`Godot 4.6.1`
- 当前主线：经典模式稳定主线 + Rogue 低侵入实验线 + 移动端触控深化
- 当前状态：可试玩原型版，重点在移动端触控和多端可读性继续收口

## 推荐入口

- 运行项目：`project.godot`
- 默认主入口：`res://scenes/main_menu.tscn`
- 当前工作分支：`feature/mobile-touch-controls-next`

## 目录速览

- `docs/`
  当前路线图、任务板、规则、架构说明和测试清单。
- `scenes/`
  主菜单、游戏主场景、Help、触屏控件等场景资源。
- `scripts/`
  经典模式、Rogue 逻辑、输入桥接层和 UI 行为脚本。
- `assets/`
  美术、音频和字体资源。
- `artifacts/`
  本地截图回归、运行日志和临时验证产物，不进入版本库。

## 当前最该看的文档

- `docs/roadmap.md`
- `docs/task-board.md`
- `docs/test-checklist.md`
- `README.md`

## 当前阶段结论

- 经典模式已经稳定，可作为长期主线。
- Rogue 试验线已经形成低侵入验证层。
- 触屏输入桥接层和第一版正式触屏控件原型已经打通。
- 当前最需要继续推进的是 `360 x 640` 等超窄场景下的触控舒适度和多端阅读性。

## 下一步

- 继续打磨移动端触控可玩性。
- 明确当前里程碑的分支 / PR / 合并策略。
- 视需要补 Web 导出或更完整的录屏展示。
