# Pyanodons 循序渐进

面向 Factorio 2.1 + Pyanodons 全套的教程，边玩边写。
[English](README.md)

这里的每个数字都来自游戏自身的原型数据或引擎实测，而不是 wiki 或记忆。每章末尾都会说明哪些是实测、哪些是从数据推算的，并附上所用脚本，方便你用自己的 mod 版本复核。

## 章节

1. [开局到红瓶](chapters/01-landing-to-red-science.zh-CN.md)

参考：[技巧与机制](research/techniques.zh-CN.md)（所有经过验证的机制、数字和设计原则汇总在一处）· [Py 下的铁路](research/py-railway.md)（英文）· [蓝图](blueprints/README.zh-CN.md)（实测过的设计，可直接导入）。

## 编写时使用的环境

- Factorio 2.1.20。未启用太空时代与品质；启用了高架铁路。
- Pyanodons 3.1.x：pyalienlife 3.1.7、pyalternativeenergy 3.2.8、pycoalprocessing 3.1.5、pyfusionenergy 3.1.4、pyhightech 3.1.4、pyindustry 3.1.5、pypetroleumhandling 3.1.3、pypostprocessing 3.1.5、pyrawores 3.1.4。
- 会影响前期的非 Py mod，在相关处会单独说明：
  - `py_quick_start`：给一套开局物资（建设机器人和能量装甲）。
  - `pump-anywhere-fork`：抽取泵可以放在陆地上。
  - `DoingThingsByHand`：手搓越多越快（本教程不涉及）。
- 作者的地图：起始区域 400%，矿物频率 33%、丰度 400%，无悬崖、无虫巢、无湖泊（所以需要 `pump-anywhere-fork`）。你的地图上矿的位置会不同，但速率和配方不变。

## 约定

- 英文版使用游戏内英文名；中文版使用 `aotixzhcn` / `aotixpy` 汉化 mod 的译名。
- 除非另有说明，速率按机器以制造/采矿速度 1 持续运转计算。
- "实测"指在引擎中观察到；"数据推算"指由原型数值计算得出。

## 工具（`tools/`）

所有工具都在独立的 Factorio 环境里运行（模组以硬链接或复制方式引用，配置和写入目录都是独立的），你自己的配置、模组和存档只会被读取或复制：`C:\tmp\cf-dump` 是你模组的固定快照，所有实测都在这里跑（只在刻意运行 `dump-data.ps1` 时重建）；`C:\tmp\cf-save` 则在每次读存档前按你当前的模组重新同步（`save-env.ps1`）。脚本中的路径是作者电脑上的（游戏装在 `E:\SteamLibrary`），请按你的环境调整参数。

- `dump-data.ps1` + `analyze-py.js`：导出当前模组组合的 `data.raw` 并做摘要。
- `recipe-tree.js <物品> --techs a,b`：只用某个时间点已解锁的配方展开生产树并汇总原料（中文名）。
- `inspect-save.ps1 -Save <存档名|latest|文件.zip> [-Ticks 3700]` + `summarize-save.js` + `render-save-map.js`：先检查存档是否以游玩时完全相同的模组和启动设置载入（不一致就停止，除非加 `-AllowModChanges`），然后只读地读取存档（研究、背包、带朝向和过滤设置的建筑、产量、附近矿物），并画出基地地图；还会找出各个矿区，把每个矿区导出成蓝图字符串，加上 `-Ticks` 时再实测一分钟内的真实开采速度。
- `render-area.js x1 y1 x2 y2 out.png`：把存档里的一块区域画成放大图并输出字符网格，便于逐格读懂结构。
- `extract-design.js <名称> x1 y1 x2 y2`（或 `<名称> --blueprint <文件>`）：把存档里的一块区域，或一整个蓝图文件，复制进实验场。
- `design-lab/`：实验场。把设计（自己的，或从存档复制来的）建在无限供料箱和计数终点旁边，测量产量、断料后残留的物品和采矿机状态，并导出蓝图。
- `companion/`：配合游玩的小模组（[说明](tools/companion/README.zh-CN.md)）：下面的蓝图书功能，以及游戏记录器（研究、聊天、建造活动、产量；日志自动轮转），由 `recorder-summary.js` 读取，由 `check-recorder.ps1` 检查。
- `bp-sync.js` + `companion/` + `check-companion.ps1`：把 `blueprints/` 作为一本蓝图书放进运行中的游戏，并把改过的蓝图导回，见[蓝图](blueprints/README.zh-CN.md#与运行中的游戏同步)。
- `take-screenshots.ps1`：用图形模式运行实验场来截取游戏内画面。Steam 版游戏会让 Steam 重新启动它，请在 Steam 关于启动参数的弹窗中点确认。
- `newgame-observer/` + `summarize-newgame.js`：观察新开一局有什么；用从存档读出的 `--map-gen-settings` 建图，可以复现同一个世界。
- `belt-lab/`、`ch1-probe/`、`train-probe/`、`station-probe/`：各章节和研究笔记背后的引擎实测。
- 本地化名称：在配置里设 `locale=zh-CN`（或 `en`），运行 `factorio --dump-prototype-locale`，会在脚本输出目录生成 `*-locale.json`。
