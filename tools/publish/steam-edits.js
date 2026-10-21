// Edits for the Steam guides (tools/publish/steam.js). They take out what a player does not need
// in a guide: tool names, commands and how a number was measured (the GitHub version keeps
// them). `files`: per chapter file, [from, to] pairs applied first; each `from` must occur
// exactly once, and the export reports those that no longer do. `rules`: per language, [regex,
// replacement] pairs applied to every chapter after that (the English is wrapped, so words
// are matched across line breaks).
module.exports = {
  rules: {
    en: [
      // The introduction's list of sources.
      [/\s*Numbers\s+come\s+from\s[^]*?\.(?=\s+[A-Z(]|\s*\n\n|\s*$)/, ''],
      // Source tags: data is the game's prototype data.
      [/\s*\(data\)/g, ''],
      [/\(data;\s+/g, '('],
      [/;\s+data\)/g, ')'],
      [/\s*\(`tools\/[^`]*`[^()]*\)/g, ''],
      [/\s(?:with|by|using)\s+`tools\/[^`]*`/g, ''],
      [/;\s+`tools\/bp-sync\.js\s+pull`\s+reports\s+/g, '; against the earlier export there are '],
      // The companion mod's recorder: the author's game, logged every minute.
      [/10-minute\s+windows\s+from\s+the\s+recorder/g, '10-minute averages in the author\'s game'],
      [/10-minute\s+averages\s+from\s+the\s+recorder/g, '10-minute averages in the author\'s game'],
      [/\blast\s+recorder\s+window\b/g, 'last 10-minute window'],
      [/\s*\((?:data;\s+)?recorder\)/g, ''],
      [/\(recorder;\s+/g, '('],
      [/;\s+recorder\)/g, ')'],
      [/\b([Tt])he\s+recorder\b/g, '$1he game\'s log'],
      // Measurements in copies of the save.
      [/\s*\(probe\)/g, ''],
      [/Measured\s+with\s+a\s+probe:/g, 'Measured:'],
      [/\bin\s+the\s+probe\b/g, 'in the test'],
      [/\b([Tt])he\s+probe\b/g, '$1he test run'],
      // The blueprint bench: a blueprint alone on an empty map, its inputs unlimited.
      [/\b([Oo])n\s+the\s+bench\b/g, '$1n a test map'],
      [/\bthe\s+bench's\b/g, 'the test map\'s'],
      [/\b([Tt])he\s+bench\b/g, '$1he test map'],
      [/\(bench\)/g, '(test map)'],
      [/\bBench([,:])/g, 'Test map$1'],
    ],
    zh: [
      [/数字来自[^。]*。/, ''],
      [/（数据）/g, ''],
      [/（数据；/g, '（'],
      [/；数据）/g, '）'],
      [/（`tools\/[^`]*`[^（）]*）/g, ''],
      [/用 `tools\/[^`]*` ?/g, ''],
      [/；`tools\/bp-sync\.js pull` 报告/g, '；与上次导出相比有'],
      [/记录器(?:中选取的 |每 |的 )10 分钟(?:的)?(?:统计|平均值|窗口)/g, (m) => (m.includes('选取') ? '作者游戏里选取的 10 分钟平均值' : '作者游戏里每 10 分钟的平均值')],
      [/（(?:数据；)?记录器）/g, ''],
      [/（记录器；/g, '（'],
      [/；记录器）/g, '）'],
      [/记录器/g, '游戏记录'],
      [/（探针）/g, ''],
      [/探针/g, '测试'],
      [/测试台/g, '测试地图'],
    ],
  },
  files: {
    '01-landing-to-red-science.md': [
      ['Times like "0:35" are game time in that run, read from the companion mod\'s recorder;\nnumbers about machines come from the game\'s data or from engine measurements, and every mechanic\nis also listed, with its source, in [Techniques and mechanics](../research/techniques.md).',
        'Times like "0:35" are game time in that run. Every mechanic used here is also listed in\n[Techniques and mechanics](../research/techniques.md).'],
      ['(The recorder does not log machine states,', '(Machine states were not recorded,'],
      [';\n  `tools/inspect-save.ps1` reports the amount under every drill and collector)', ')'],
    ],
    '01-landing-to-red-science.zh-CN.md': [
      ['；`tools/inspect-save.ps1` 会报告每台采矿机和采集器下方的剩余量）', '）'],
      ['文中"0:35"这样的时间都是那局的游戏时间，读自助手模组的记录器；关于机器的数字来自游戏数据或引擎实测，每一条机制也连同来源一起列在[技巧与机制](../research/techniques.zh-CN.md)里。',
        '文中"0:35"这样的时间都是那局的游戏时间。用到的每一条机制也都列在[技巧与机制](../research/techniques.zh-CN.md)里。'],
      ['（记录器不记录机器状态，', '（当时没有记录机器状态，'],
    ],
    '04-aluminium-glass-logs.md': [
      ['(`tools/inserter-rate-probe`: one inserter per case, 10 minutes each, every drop timed to the\ntick; Iron plates', '(Iron plates'],
    ],
    '04-aluminium-glass-logs.zh-CN.md': [
      ['（`tools/inserter-rate-probe`：每个场景一个机械臂，各测 10 分钟，每次放下都精确到 tick；铁板', '（铁板'],
    ],
    '08-vrauks.md': [
      ['(`tools/belt-lab`: a Splitter', '(a Splitter'],
    ],
    '08-vrauks.zh-CN.md': [
      ['（`tools/belt-lab`：分流器会', '（分流器会'],
    ],
    '09-py-science-pack-1.md': [
      ['(`planner-summary.js --factory pY`: 6 packs', '(6 packs'],
    ],
    '09-py-science-pack-1.zh-CN.md': [
      ['（`planner-summary.js --factory pY`：每分钟 6 包', '（每分钟 6 包'],
    ],
    '10-crushed-coal-power.md': [
      ['(19 Steam engines, poles, water; `tools/power-probe`, research notes, Steam power)', '(19 Steam engines, poles, water)'],
    ],
    '10-crushed-coal-power.zh-CN.md': [
      ['（19 台蒸汽机、电线杆、水；`tools/power-probe`，见技巧笔记的“蒸汽发电”）', '（19 台蒸汽机、电线杆、水）'],
    ],
  },
};
