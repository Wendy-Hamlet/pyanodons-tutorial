// Shared logistics reading of a save snapshot (entities.json from tools/inspect-save.ps1): which
// tile holds which entity, belt lines (followed through underground belts, ending where they join
// or side-load another line) with what they carry, and who puts items where: inserters, drills and
// machines with an output port. Used by trace-layout.js and manual-links.js.

const VEC = { north: [0, -1], east: [1, 0], south: [0, 1], west: [-1, 0] };
const key = (x, y) => `${Math.floor(x)},${Math.floor(y)}`;

// `list`: snapshot entries (ghosts are left out here).
function analyse(entries) {
  const list = entries.filter((e) => e.type !== 'entity-ghost');
  const at = new Map();
  for (const e of list) {
    for (let x = Math.floor(e.x1 + 0.01); x < Math.ceil(e.x2 - 0.01); x++) {
      for (let y = Math.floor(e.y1 + 0.01); y < Math.ceil(e.y2 - 0.01); y++) at.set(`${x},${y}`, e);
    }
  }

  // ---- belts ----
  const belts = list.filter((e) => e.type === 'transport-belt' || e.type === 'underground-belt');
  const next = new Map();
  for (const b of belts) {
    const v = VEC[b.dir] || [0, 0];
    if (b.type === 'underground-belt' && b.ug === 'input') {
      for (let d = 1; d <= 10; d++) {
        const o = at.get(key(b.x + v[0] * d, b.y + v[1] * d));
        if (o && o.type === 'underground-belt' && o.ug === 'output' && o.dir === b.dir) { next.set(b, o); break; }
      }
    } else {
      const o = at.get(key(b.x + v[0], b.y + v[1]));
      const ov = o && VEC[o.dir];
      if (o && (o.type === 'transport-belt' || o.type === 'underground-belt') && !(ov[0] === -v[0] && ov[1] === -v[1])) next.set(b, o);
    }
  }
  const incoming = new Map();
  for (const [a, b] of next) {
    // A straight feed (same direction) continues a line; a perpendicular one side-loads into it.
    if (a.dir === b.dir || b.type === 'underground-belt') incoming.set(b, a);
  }
  const lineOf = new Map();
  const lines = [];
  const starts = belts.filter((b) => !incoming.has(b));
  const rest = belts.filter((b) => incoming.has(b));
  for (const s of [...starts, ...rest]) {
    if (lineOf.has(s)) continue;
    const line = { id: lines.length + 1, tiles: [], items: {}, joins: null };
    let b = s;
    while (b && !lineOf.has(b)) {
      lineOf.set(b, line);
      line.tiles.push(b);
      for (const [n, c] of Object.entries(b.items || {})) line.items[n] = (line.items[n] || 0) + c;
      const n = next.get(b);
      if (n && n.dir !== b.dir && n.type === 'transport-belt' && incoming.get(n) !== b) { line.sideloads = n; break; }
      b = n;
    }
    if (b && lineOf.has(b) && lineOf.get(b) !== line) line.joins = b;
    lines.push(line);
  }
  // What a line carries: its own items plus everything fed into it upstream (joins and
  // side-loads), since a snapshot shows only what happened to be on it.
  const feeders = new Map();
  for (const l of lines) {
    const target = l.joins ? lineOf.get(l.joins) : l.sideloads ? lineOf.get(l.sideloads) : null;
    if (target && target !== l) { if (!feeders.has(target)) feeders.set(target, []); feeders.get(target).push(l); }
  }
  const carriesCache = new Map();
  const carries = (l, seen = new Set()) => {
    if (carriesCache.has(l)) return carriesCache.get(l);
    if (seen.has(l)) return new Set(Object.keys(l.items));
    seen.add(l);
    const out = new Set(Object.keys(l.items));
    for (const f of feeders.get(l) || []) for (const i of carries(f, seen)) out.add(i);
    carriesCache.set(l, out);
    return out;
  };
  const tileLine = new Map();
  for (const l of lines) for (const t of l.tiles) tileLine.set(key(t.x, t.y), l);

  // ---- who puts what where ----
  const loads = new Map(); // entity -> [{ via, from, filter, mode }]
  const unloads = new Map(); // entity -> [{ via, to, filter, mode }]
  const add = (map, k, v) => { if (!k) return; if (!map.has(k)) map.set(k, []); map.get(k).push(v); };
  for (const i of list.filter((e) => e.type === 'inserter' && e.pickup && e.drop)) {
    const from = at.get(key(i.pickup.x, i.pickup.y));
    const to = at.get(key(i.drop.x, i.drop.y));
    const s = { via: i, from, to, filter: i.filter, mode: i.filter_mode };
    add(loads, to, s);
    add(unloads, from, s);
  }
  // Drills and machines with an output port drop their products themselves (no inserter).
  for (const d of list.filter((e) => e.drop && (e.type === 'mining-drill' || e.type === 'assembling-machine' || e.type === 'furnace'))) {
    const to = at.get(key(d.drop.x, d.drop.y));
    const s = { via: d, from: d, to, port: true };
    add(loads, to, s);
    if (d.type !== 'mining-drill') add(unloads, d, s);
  }
  return { list, at, lines, lineOf, tileLine, loads, unloads, carries, key, VEC };
}

module.exports = { analyse, key, VEC };
