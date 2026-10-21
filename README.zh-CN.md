# Pyanodons 循序渐进

面向 Factorio 2.1 + Pyanodons 全套的教程，边玩边写。
[English](README.md)

这里的每个数字都来自游戏自身的原型数据或引擎实测，而不是 wiki 或记忆。每章末尾都会说明哪些是实测、哪些是从数据推算的，并附上所用脚本，方便你用自己的 mod 版本复核。

## 章节

1. [开局到红瓶](chapters/01-landing-to-red-science.zh-CN.md)
2. [焦炭、钢材与碎矿炼铁](chapters/02-coke-steel-crushed-iron.zh-CN.md)
3. [灰烬分离与原煤发电](chapters/03-ash-separation-raw-coal-power.zh-CN.md)
4. [铝矿开采、玻璃制造、原木生产和红瓶生产](chapters/04-aluminium-glass-logs.zh-CN.md)
5. [锡矿、锌矿、铅矿冶炼](chapters/05-tin-zinc-smelting.zh-CN.md)
6. [简易电路板](chapters/06-simple-circuit-boards.zh-CN.md)
7. [铜筛选、钛矿冶炼和硬铝生产](chapters/07-copper-screening-titanium-duralumin.zh-CN.md)
8. [钳尾刀虫](chapters/08-vrauks.zh-CN.md)
9. [pY科技包1型](chapters/09-py-science-pack-1.zh-CN.md)
10. [碎煤发电](chapters/10-crushed-coal-power.zh-CN.md)
11. [铅矿、钛矿和锡矿冶炼改良](chapters/11-lead-titanium-tin-smelting.zh-CN.md)

参考：[技巧与机制](research/techniques.zh-CN.md)（所有经过验证的机制、数字和设计原则汇总在一处）· [焦炭、炼钢、碎矿与灰烬分离](research/coke-and-steel.zh-CN.md)（第二章背后的配方、产率和副产物，以及灰烬分离）· [红瓶 + pY1 工厂](research/red-py1-factory.zh-CN.md)（总线、区块、简易电路板和火车前的关键中间体）· [作者的第一个存档](research/first-save-review.zh-CN.md)（哪些靠手搬，以及取代它们的总线）· [Py 下的铁路](research/py-railway.md)（英文）· [地图设置](research/map-settings.zh-CN.md)（Py 推荐预设、作者的改动及其对地图的影响）· [T.U.R.D. 选择](research/turd-choices.zh-CN.md)（作者已做的选择、尚未决定的，以及全部升级）· [蓝图](blueprints/README.zh-CN.md)（实测过的设计，可直接导入）。

## 编写时使用的环境

- Factorio 2.1.21（第一章那局）。未启用太空时代与品质；启用了高架铁路。
- Pyanodons 3.1.x：pyalienlife 3.1.8、pyalternativeenergy 3.2.9、pycoalprocessing 3.1.7、pyfusionenergy 3.1.5、pyhightech 3.1.5、pyindustry 3.1.6、pypetroleumhandling 3.1.3、pypostprocessing 3.1.6、pyrawores 3.1.4。
- 更早的部分：第一章里先上传送带的路线（第 7 节）、引擎实测和各篇研究笔记，是在 Factorio 2.1.20 上做的，当时是 pyalienlife 3.1.7、pyalternativeenergy 3.2.8、pycoalprocessing 3.1.5、pyfusionenergy 3.1.4、pyhightech 3.1.4、pyindustry 3.1.5、pypostprocessing 3.1.5。第一章用到的配方和建筑在两者中完全相同。
- 会影响前期的非 Py mod，在相关处会单独说明：
  - `py_quick_start`：给一套开局物资（建设机器人和能量装甲）。
  - `pump-anywhere-fork`：抽取泵可以放在陆地上。
  - `DoingThingsByHand`：手搓越多越快（本教程不涉及）。
- 作者的地图（Py-Exploration，种子 2652821414；见[地图设置](research/map-settings.zh-CN.md)）：起始区域 400%，矿物频率 33%、丰度 400%，无悬崖、无虫巢、无湖泊（所以需要 `pump-anywhere-fork`）。你的地图上矿的位置会不同，但速率和配方不变。

## 约定

- 英文版使用游戏内英文名；中文版使用 `aotixzhcn` / `aotixpy` 汉化 mod 的译名。
- 除非另有说明，速率按机器以制造/采矿速度 1 持续运转计算。
- "实测"指在引擎中观察到；"数据推算"指由原型数值计算得出。

## 工具（`tools/`）

所有工具都在独立的 Factorio 环境里运行（模组以硬链接或复制方式引用，配置和写入目录都是独立的），你自己的配置、模组和存档只会被读取或复制：`C:\tmp\cf-dump` 是你模组的固定快照，所有实测都在这里跑（只在刻意运行 `dump-data.ps1` 时重建）；`C:\tmp\cf-save` 则在每次读存档前按你当前的模组重新同步（`save-env.ps1`）。脚本中的路径是作者电脑上的（游戏装在 `E:\SteamLibrary`），请按你的环境调整参数。

- `dump-data.ps1` + `analyze-py.js`：导出当前模组组合的 `data.raw` 和本地化名称（中文、英文）并做摘要。模组更新后要重建，配方工具都读它。
- `q.js <名称>`：按内部名、英文名或中文名（全名或其中一段）一次查齐：物品、流体、建筑、配方、科技或资源的紧凑信息（生产它的每个配方及其机器、用时、解锁科技和科技费用，用到它的配方，建筑参数），最新存档快照里的情况（是否已研究、建了几座、背包里有多少、矿区位置），以及研究笔记和章节中提到它的每一段（`--data`、`--notes`、`--all`、`--zh`）。它为数据导出建了一个小索引（`q-index.json`），每次查询不到一秒。
- `recipe-tree.js <物品> --techs a,b`：只用某个时间点已解锁的配方展开生产树并汇总原料（中文名；`--techs save,a` 加上最新存档快照里已研究的全部科技）。能开采或抽取的物品，只有在采矿机此时能建时才算原料；来自地图实体的物品（鱼、树、岩石）标为有限，还没有配方的物品会列出能解锁配方的科技。不由科技解锁的配方会列出来，绝不悄悄略过：与 `rate-plan.js` 共用的 `sources.js` 区分由脚本运行的机器（挖矿兽的挖矿站：它的配方代表脚本的开采，随机器一起可用）和 T.U.R.D. 升级配方。原料汇总在每一步都沿列出的第一个配方；装桶、倒桶类配方排在最后。
- `rate-plan.js <计划.js> [--build]`：求解一份生产计划（每分钟目标，每种物品指定一个配方，所有速率联立求解，所以副产物和还回来的笼子都算在内）：机器、物品流量、原料、能耗、计划中各区块之间的物流（上总线还是直连），以及建造这些机器的材料；计划里写明燃料时，还会算出烧掉的燃料和留下的灰烬；`local: 'free'` 让只靠水就能做的物品在用它的区块里就地生产，`carry` 让物品以打包形式在区块间运输（石矿以石砖运输），每个区块还会列出需要缓存的副产物。计划文件放在 `research/plans/`。`products.js` 负责读取 2.1 的产物概率，供它和其他配方工具使用。
- `building-inputs.js <科技,...>`：某个阶段的建筑由哪些物品构成，按用到它的建筑配方数排序（找出超市要做的关键中间体）。
- `inspect-save.ps1 -Save <存档名|latest|文件.zip> [-Ticks 3700]` + `summarize-save.js` + `render-save-map.js`：先检查存档是否以游玩时完全相同的模组和启动设置载入（不一致就停止，除非加 `-AllowModChanges`），然后只读地读取存档（研究、背包、带朝向和过滤设置的建筑、每台机器的插件、速度和所在电网、产量、附近矿物），并画出基地地图；还会找出各个矿区，把每个矿区导出成蓝图字符串，加上 `-Ticks` 时再运行一分钟，实测真实开采速度和全基地每秒的产出与消耗。快照在载入一秒后拍：第一个刻里电力缓冲很小的机器会显示“电力不足”（见 `status-probe/`）。
- `render-area.js x1 y1 x2 y2 out.png`：把存档里的一块区域画成放大图并输出字符网格，便于逐格读懂结构。
- `trace-layout.js x1 y1 x2 y2`：一块区域的物流：每条带线运什么、谁往上放、谁从上取，流体网络（连通的管段及其流体），以及每台机器的进出。存档快照会记录传送带上的物品、流体和过滤模式。
- `manual-links.js [x1 y1 x2 y2]`：存档里还靠手搬的环节：只进不出的箱子（要手取）、只出不进的箱子（要手补）、手放原料的机器、手加燃料的热能设备，以及两头都靠手的物品（总线该替代的环节）。存档快照会记录箱子和机器里的物品；`logistics.js` 是它和 `trace-layout.js` 共用的传送带与机械臂解读。
- `extract-design.js <名称> x1 y1 x2 y2`（或 `<名称> --blueprint <文件>`）：把存档里的一块区域，或一整个蓝图文件，复制进实验场。
- `design-lab/`：实验场。把设计（自己的，或从存档复制来的）建在无限供料箱和计数终点旁边，测量产量、断料后残留的物品和采矿机状态，并导出蓝图。
- `companion/`：配合游玩的小模组（[说明](tools/companion/README.zh-CN.md)）：下面的蓝图书功能，以及游戏记录器（研究、聊天、建造活动、产量；日志自动轮转），由 `recorder-summary.js`（最新状态）和 `recorder-phases.js`（把整局按固定时长分段成时间线，用于根据真实游玩写章节）读取，由 `check-recorder.ps1` 检查；它还会写出 Factory Planner 里打开的工厂（`/pt-fp`），由 `planner-summary.js` 读取（目标、输入、副产物、耗电，以及每条产线的机器数和速率）。
- `bp-sync.js` + `companion/` + `check-companion.ps1`：把 `blueprints/` 作为一本蓝图书放进运行中的游戏，并把改过的蓝图导回，见[蓝图](blueprints/README.zh-CN.md#与运行中的游戏同步)。
- `take-screenshots.ps1`：用图形模式运行实验场来截取游戏内画面。Steam 版游戏会让 Steam 重新启动它，请在 Steam 关于启动参数的弹窗中点确认。实验场会关掉自由模式的坠毁现场和开场动画，否则残骸会压在设计上，开场还会让游戏停住直到按 Tab。
- `shots.js` + `/pt-shots`（助手模组）：从作者真实的游戏里截图。`shots.js plan` 列出要截的区域，游戏里输入 `/pt-shots` 截图，`shots.js pull` 把图片取回 `images/`。（用 `--benchmark-graphics` 载入真实存档会让游戏崩溃，所以改为在运行中的游戏里截。）
- `newgame-observer/` + `summarize-newgame.js`：观察新开一局有什么（包括出生点周围的资源、树木、岩石和地面，可用来比较地图设置）；用从存档读出的 `--map-gen-settings` 建图，可以复现同一个世界。
- `belt-lab/`、`ch1-probe/`、`drill-probe/`、`inserter-probe/`、`train-probe/`、`station-probe/`：各章节和研究笔记背后的引擎实测。`run-probe.ps1 <探针>` 运行其中一个（复制进固定环境、建图、运行、输出结果，再删掉；加 `-Work C:\tmp\cf-save` 则用当前的模组运行）。`inserter-rate-probe/`：工业机械臂的速度，精确到小数点后三位，每次放下都计时（`-Ticks 36700 -Work C:\tmp\cf-save`）。`valve-probe/`：一段管道能跨多远（320 格），以及管道泵和止回阀各起什么作用（`-Ticks 2500 -Work C:\tmp\cf-save`）。
- `save-probe.ps1 -Save <存档> -Probe <探针> [-Variant <版本>]`：在作者存档的副本里运行一个测量模组（读档环境，存档本身只复制），例如 `steel-probe/`：第二、三章炼钢区的实测（清空钢材箱和锅炉灰烬，按版本设置土壤挖掘机的电路条件，`ltN` 表示石灰石 < N，加 `,coke` 给铸造厂补焦炭；逐台记录铸造厂的产量、状态和缺料）；以及 `rate-probe/`：按存档原样测一段比检查器的一分钟更长的时间（版本写作 `预热秒数,测量秒数`，例如 `-Ticks 39700 -Variant 60,600`）：全基地每秒的产出和消耗，以及每秒采样一次的每台机器和采矿机的状态（锅炉和蒸汽机按所在的排分组），以及每个电网按发电和用电实体分的平均功率。版本写成 `预热,测量,分段,名称` 时还会输出时间线：每隔一个分段，列出每种指定物品或流体的产量和消耗、按位置指定的机器（`@x:y`）的状态和流体箱内容，以及常态发生变化的每组机器；最后一项写 `+实体@x:y[:朝向]` 时，读档时在那里按该朝向放下这个实体（假设测试，也是探针对基地唯一的改动）；写 `+sink@x:y` 则每刻清空那一格的传送带，`+empty@x:y` 每秒清空那里的箱子，并输出拿走了多少（用来测已经堵满的模块：把产出拿走再测）。`vrauk-probe/`：作者钳尾刀虫产线的启动过程（第八章）：每 5 分钟（或指定的分段）输出钳尾刀虫、虫茧和水桶的产量，繁育复合体、装了钳尾刀虫的围场和灌装机这段时间在做什么，以及水桶和虫茧都在哪里；版本 `fill` 每分钟把产线箱子里的钳尾刀虫装进空的插件槽，`prio` 给只有一个出口接了带子的分流器设输出优先级，`barrels:N` 加入水桶（`barrels:-N` 从带上拿掉）（例如 `-Ticks 864100 -Variant fill,prio,600`）。`power-probe/`：在原地测一座电站，作者还没建完的部分由脚本补齐（区域内的虚影复原；放置实体，电线杆不论距离直接连线，机械臂可设筛选；用无限管道供水，脚本保持输入带满载、清空输出带，开局往锅炉里放一次燃料，因为粉碎机靠本电站供电的模块无法自己启动），再接一个电力接口吃掉本电网剩下的电，让蒸汽机按蒸汽所能跑满：每个分段输出电网按实体分的发电和耗电、合成次数、进出的物品、带上和锅炉里的物品、积着灰烬的锅炉、按物品编号数出的指定传送带格每道的通过量、一次灌满流体燃料的储液罐每秒少多少（即烧流体的锅炉用了多少燃料），以及每组机器的状态（版本的各项写在它的 `control.lua` 开头）。把整个基地设为区域时，它就是负载测试：基地在现有用电之外还能多发多少电。作者已接进基地电网的电站，剪断它和外面的铜线（`isolate=1`）就能单独测量；`each=boiler` 逐台记录每台锅炉，`turn=` 和 `filter=` 用来试修法（转动一个实体、改一只机械臂的筛选），`stagger=种子:间隔:名称` 让这些机器按随机顺序逐台启动，检验一个设计是否在某些启动相位下会堵。
- `dig-probe/`（配合 `save-probe.ps1 -Variant 名称,数量,预热秒,测量秒`）：挖矿站的假设实验：在每个挖矿站里放指定种类和数量的挖矿兽，让食物槽一直装满内脏，统计跑了多少趟。
- `turd-probe/`（配合 `save-probe.ps1 -Ticks 10`）：通过 pyalienlife 自己的接口读出存档里已研究的 T.U.R.D. 升级和各自选中的选项，以及已生效的隐藏插件和建筑替换（`research/turd-choices.zh-CN.md`）。
- `status-probe/`（配合 `save-probe.ps1 -Variant 名称,刻数`）：存档载入后逐刻记录某种实体每一台的状态和电力缓冲、各状态所占比例，以及插件和信标给它的效果：用来区分基地真实的状态和某一刻的假象。
- `bp-bench.ps1 -Bench <名称> [-Variant <方案>]` + `bp-bench/`：蓝图测试台。把 `blueprints/` 里的一张蓝图放到空地图上（用游戏自己的蓝图建造，补齐插件请求），用电力接口给每个电网供电，用脚本保持输入带满载、清空输出带（以及作为流体出口的指定管道，全部清空或按设定速度取走），让研究中心一直研究，并报告每台机器完成的次数与它实际速度下配方允许的次数之比、状态采样、等待中的机器缺哪种原料，以及指定观察的实体。每个测试在 `bp-bench/benches/` 里有一个 JSON 文件（蓝图、输入、输出、流体出口、启动时预放的物品、科技、预热和测量时间、方案）。在读档环境里运行。
- `agent/`：让 Claude 在无界面服务器上自己玩 Py（远程控制客户端 `a.js`、带无玩家角色的 `pt-agent` 模组、额度监控 `quota.js`），见[它的说明](tools/agent/README.md)；游玩日志在 [research/agent-play](research/agent-play/journal.md)。
- `publish/`：把章节发到其他网站。两个版本都只保留教程本身（工具名、命令和“这些事实是怎么核实的”一节都去掉，由 `publish/edits.js` 里的修改完成），开头注明是 Claude 读取作者存档后撰写的，并链接到这里的完整章节。输出在 `publish/out/`（不提交）。
  - `steam.js [--lang en|zh] [章号 ...]`：Steam 指南。Steam 指南没有上传接口，所以它生成一个本地页面，列出每一栏（标题、简介、每个小节的 BBCode 正文，每节不超过 8000 字符）并附复制按钮，还列出每个小节要上传的图片。
  - `bilibili.js [--lang zh|en] [章号 ...]`：B站专栏。生成给编辑器自带导入功能用的 Markdown，每个表格渲染成一张 PNG（编辑器不支持表格；先在 `publish/` 里运行一次 `npm install` 装 puppeteer-core，它驱动本机的 Edge）。`bilibili-page.js` 在编辑器页面里运行，导入 Markdown，并通过编辑器自己的图片上传把每张图片和表格放到原位。
- 本地化名称：在配置里设 `locale=zh-CN`（或 `en`），运行 `factorio --dump-prototype-locale`，会在脚本输出目录生成 `*-locale.json`。

## 许可证

- **代码**（`tools/`、`research/plans/*.js`、`research/agent-play/scripts/`）：[MIT](LICENSE)。
- **其余内容**（章节、研究笔记、图片、蓝图）：[CC BY 4.0](LICENSE-CONTENT)，© 2026 Wendy-Hamlet。可以自由转载和改编，商用也可以；请署名"Wendy-Hamlet"，附上本仓库链接，并说明改动了什么。
- 截图里的游戏画面版权归 Wube Software（Factorio）和 Pyanodons 模组的作者所有。
