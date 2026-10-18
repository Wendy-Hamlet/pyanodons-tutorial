// Where an item can come from besides the recipes a technology unlocks, shared by the recipe tools
// so that they neither hide a source nor offer one that runs out:
// - Recipes that no technology unlocks (enabled = false, not hidden) are enabled by a mod script.
//   In Py that is either a T.U.R.D. upgrade the player picks (the recipe then replaces another
//   one), or a machine the script runs: every visible recipe of its crafting category is such a
//   recipe, standing in for the script (the Digosaurus dig site mining nexelit for meat, guts or
//   workers' food). That second kind comes with its machine: usable once the machine's own recipe is.
// - Items gathered from entities placed by map generation (fish in water, trees, rocks) are
//   finite: once taken they do not come back.
const arr = (x) => (Array.isArray(x) ? x : Object.values(x || {}));
const hidden = (p) => p && ((p.flags || []).includes('hidden') || p.hidden);
const categories = (r) => (arr(r.categories).length ? arr(r.categories) : ['crafting']);

module.exports = (raw) => {
  const unlockedBy = {};
  for (const [tn, t] of Object.entries(raw.technology)) {
    for (const e of arr(t.effects)) if (e.type === 'unlock-recipe') (unlockedBy[e.recipe] = unlockedBy[e.recipe] || []).push(tn);
  }
  const scripted = new Set(Object.entries(raw.recipe)
    .filter(([n, r]) => r.enabled === false && !hidden(r) && !unlockedBy[n]).map(([n]) => n));

  // Recipes that make each entity's item, to know when a machine itself becomes buildable.
  const placedBy = {};
  for (const [n, r] of Object.entries(raw.recipe)) {
    for (const p of arr(r.results)) {
      const it = raw.item[p.name];
      if (it && it.place_result) (placedBy[it.place_result] = placedBy[it.place_result] || []).push(n);
    }
  }
  const visible = {};
  for (const [n, r] of Object.entries(raw.recipe)) if (!hidden(r)) for (const c of categories(r)) (visible[c] = visible[c] || []).push(n);
  // Scripted recipe -> { machine, builds: recipes of the machine's item } for script-run machines.
  const scriptMachine = {};
  for (const type of ['assembling-machine', 'furnace']) {
    for (const [m, e] of Object.entries(raw[type] || {})) {
      if (hidden(e)) continue;
      for (const c of arr(e.crafting_categories)) {
        const list = visible[c] || [];
        if (!list.length || !list.every((r) => scripted.has(r))) continue;
        for (const r of list) scriptMachine[r] = { machine: m, builds: placedBy[m] || [] };
      }
    }
  }

  // Item -> map entities that give it when mined by hand (finite).
  const mapSources = {};
  for (const [type, verb] of [['fish', '手采水中的'], ['tree', '砍'], ['simple-entity', '开采']]) {
    for (const [n, e] of Object.entries(raw[type] || {})) {
      if (!e.autoplace || !e.minable) continue;
      const m = e.minable;
      for (const p of m.results ? arr(m.results) : m.result ? [{ name: m.result }] : []) {
        (mapSources[p.name] = mapSources[p.name] || []).push({ entity: n, type, verb });
      }
    }
  }

  return {
    unlockedBy,
    scripted,
    scriptMachine,
    mapSources,
    // Given a predicate for the recipes usable so far, the scripted recipes of script-run machines
    // that are buildable by then.
    machineRecipes(usable) {
      return Object.keys(scriptMachine).filter((r) => scriptMachine[r].builds.some(usable));
    },
    // The scripted recipes that make an item but belong to no script-run machine (T.U.R.D. and
    // the like): never used by the tools, only named so that a reader knows they exist.
    otherScripted(item) {
      return [...scripted].filter((r) => !scriptMachine[r] && arr(raw.recipe[r].results).some((p) => p.name === item));
    },
  };
};
