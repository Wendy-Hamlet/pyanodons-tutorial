// Output folders of the isolated setups, shared by the node tools.
module.exports = {
  // Fixed snapshot of the player's mods for measurements: data dump, locale names, lab runs
  // (tools/dump-data.ps1).
  dump: 'C:/tmp/cf-dump/data/script-output',
  // Latest save snapshot (tools/inspect-save.ps1, run in tools/save-env.ps1's setup).
  save: 'C:/tmp/cf-save/data/script-output/cellforge',
};
