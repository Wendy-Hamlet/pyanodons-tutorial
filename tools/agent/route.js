// Route a belt or pipe through the live game: reads the occupied tiles of an area over RCON, finds the
// cheapest path with breadth-first search (plain tiles cost 1, an underground pair costs its length + 4)
// and writes a ghost list for `node a.js ghost @file.json`.
//
//   node route.js belt|pipe x1 y1 x2 y2 [--out file.json] [--margin 12] [--last N|E|S|W] [--avoid x,y;x,y]
//                 [--touch x,y;x,y]  (pipes: existing pipes the ends may join, e.g. the source pipe)
//
// (x1,y1) is the first tile of the new line, (x2,y2) its last; --last gives the direction the last tile
// faces (belts: where items leave it; default: the direction of the last move). Belts never take a tile
// that an existing belt or inserter drops onto or an inserter picks from, and an underground pair (max distance 5 for belts, 10 for
// pipes) needs free entrance and exit tiles. A pipe tile must also not touch any other pipe or fluid box
// (it would join that network); a pipe never sits on another machine port's connection tile.
const fs = require('fs');
const { execFileSync } = require('child_process');

const args = process.argv.slice(2);
const kind = args[0];
const [x1, y1, x2, y2] = args.slice(1, 5).map(Number);
const opt = (k, d) => (args.includes(k) ? args[args.indexOf(k) + 1] : d);
const margin = Number(opt('--margin', 12));
const out = opt('--out', `C:/tmp/cf-agent/route-${kind}.json`);
const lastDir = opt('--last', null);
const avoid = new Set((opt('--avoid', '') || '').split(';').filter(Boolean).map((s) => s.trim()));
const MAXU = kind === 'pipe' ? 10 : 5;
const DIRS = { N: [0, -1], E: [1, 0], S: [0, 1], W: [-1, 0] };

const bx = [Math.floor(Math.min(x1, x2)) - margin, Math.floor(Math.min(y1, y2)) - margin,
  Math.ceil(Math.max(x1, x2)) + margin, Math.ceil(Math.max(y1, y2)) + margin];

// Lua: every entity's tiles; belt/inserter drop targets; fluid boxes' tiles (for pipes).
const lua = `local a={{${bx[0]},${bx[1]}},{${bx[2]},${bx[3]}}} local occ,drop,fl,pt,ugt={}, {}, {}, {}, {}
for _,e in pairs(s.find_entities_filtered{area=a}) do
  if e.type~='character' and e.type~='item-entity' and e.type~='resource' and e.type~='tile-ghost' then
    local b=e.bounding_box
    for x=math.floor(b.left_top.x+0.01),math.ceil(b.right_bottom.x-0.01)-1 do for y=math.floor(b.left_top.y+0.01),math.ceil(b.right_bottom.y-0.01)-1 do occ[#occ+1]=x..','..y end end
    if e.type=='pipe-to-ground' or e.type=='underground-belt' then ugt[#ugt+1]=math.floor(e.position.x)..','..math.floor(e.position.y) end
    if e.type=='transport-belt' or e.type=='underground-belt' or e.type=='splitter' then
      local o=e.belt_neighbours and e.belt_neighbours.outputs
      local d=e.direction local v=({[0]={0,-1},[4]={1,0},[8]={0,1},[12]={-1,0}})[d]
      if v then drop[#drop+1]=math.floor(e.position.x+v[1])..','..math.floor(e.position.y+v[2]) end
    elseif e.type=='inserter' then local p=e.drop_position drop[#drop+1]=math.floor(p.x)..','..math.floor(p.y) local q=e.pickup_position drop[#drop+1]=math.floor(q.x)..','..math.floor(q.y)
    end
    if e.fluids_count and e.fluids_count>0 then for i=1,e.fluids_count do for _,c in pairs(e.get_fluid_box_pipe_connections(i)) do pt[#pt+1]=math.floor(c.target_position.x)..','..math.floor(c.target_position.y) end end
      if e.type=='pipe' or e.type=='pipe-to-ground' or e.type=='storage-tank' or e.type=='pump' or e.type=='offshore-pump' or e.type=='valve' or e.name:find('valve') then local b2=e.bounding_box for x=math.floor(b2.left_top.x+0.01),math.ceil(b2.right_bottom.x-0.01)-1 do for y=math.floor(b2.left_top.y+0.01),math.ceil(b2.right_bottom.y-0.01)-1 do fl[#fl+1]=x..','..y end end end end
  end
end
return table.concat(occ,';')..'|'..table.concat(drop,';')..'|'..table.concat(fl,';')..'|'..table.concat(pt,';')..'|'..table.concat(ugt,';')`;

Promise.resolve().then(() => {
  const tmp = 'C:/tmp/cf-agent/route-eval.json'; // ASCII path (the user profile path is not)
  fs.writeFileSync(tmp, JSON.stringify({ code: lua }));
  const ans = execFileSync("node", [`${__dirname}/a.js`, "eval", `@${tmp}`], { encoding: "utf8", maxBuffer: 64 << 20 });
  const m = ans.match(/value: "([^"]*)"/) || ans.match(/"value":"([^"]*)"/);
  const v = m && m[1];
  if (typeof v !== 'string') throw new Error(`eval failed: ${ans}`);
  const [occS, dropS, flS, ptS, ugS] = v.split('|');
  const ugT = new Set((ugS || '').split(';').filter(Boolean)); // existing undergrounds: a new pair may not jump over one (they pair with the nearest)
  const occ = new Set(occS.split(';').filter(Boolean));
  const dropT = new Set(dropS.split(';').filter(Boolean));
  const pipeT = new Set(flS.split(';').filter(Boolean));   // pipes, tanks, pumps, valves
  const portT = new Set((ptS || '').split(';').filter(Boolean)); // tiles a machine port connects to
  const touch = new Set((opt('--touch', '') || '').split(';').filter(Boolean).map((t) => t.split(',').map((n) => Math.floor(Number(n))).join(',')));
  const key = (x, y) => `${x},${y}`;
  const sx = Math.floor(x1), sy = Math.floor(y1), ex = Math.floor(x2), ey = Math.floor(y2);
  const inBox = (x, y) => x >= bx[0] && x < bx[2] && y >= bx[1] && y < bx[3];
  const free = (x, y) => {
    const k = key(x, y);
    if (!inBox(x, y) || occ.has(k) || avoid.has(`${x + 0.5},${y + 0.5}`)) return false;
    if (kind === 'pipe' && portT.has(k) && !((x === sx && y === sy) || (x === ex && y === ey))) return false; // a pipe on a port's tile joins that machine
    if (kind === 'belt' && dropT.has(k) && !((x === Math.floor(x1) && y === Math.floor(y1)) || (x === Math.floor(x2) && y === Math.floor(y2)))) return false; // the ends may meet inserters
    return true;
  };
  // No pipe tile (the ends included) may neighbour another network's pipe, tank, pump or valve: it would
  // join it. --touch lists the existing pipes the ends are meant to join (e.g. the source pipe).
  const pipeOk = (x, y) => {
    if (kind !== 'pipe') return true;
    return !Object.values(DIRS).some(([dx, dy]) => { const k = key(x + dx, y + dy); return pipeT.has(k) && !touch.has(k); });
  };
  if (!free(sx, sy)) throw new Error(`start tile ${x1},${y1} is taken`);
  if (!free(ex, ey)) throw new Error(`end tile ${x2},${y2} is taken`);
  // Dijkstra on small integer costs (bucket queue).
  // States are tile + arrival direction + "arrived by an underground": an underground pair goes
  // straight in and straight out (its entrance is entered from behind, its exit is left forward).
  const dist = new Map(), prev = new Map();
  const st = (x, y, d, u) => `${x},${y},${d},${u ? 1 : 0}`;
  const s0 = st(sx, sy, 'X', 0);
  const buckets = [[s0]]; dist.set(s0, 0);
  let goal = null;
  for (let c = 0; c < buckets.length && !goal; c++) {
    for (const k of buckets[c] || []) {
      if (dist.get(k) !== c) continue;
      const [xs, ys, ad, au] = k.split(',');
      const x = Number(xs), y = Number(ys), viaUg = au === '1';
      if (x === ex && y === ey) { goal = k; break; }
      for (const [d, [dx, dy]] of Object.entries(DIRS)) {
        if (viaUg && d !== ad) continue;                       // leave an exit forward
        const steps = [[x + dx, y + dy, 1, null]];
        const canUg = ad === d || (ad === 'X' && kind === 'belt');
        if (canUg) for (let n = 2; n <= MAXU; n++) steps.push([x + dx * n, y + dy * n, n + 4, n]);
        for (const [nx, ny, cost, ug] of steps) {
          if (!free(nx, ny) || !pipeOk(nx, ny)) continue;
          if (ug && !pipeOk(x, y)) continue;
          // pipes: the end tiles meet machine ports, so they must be plain pipes (no underground there)
          if (ug && kind === 'pipe' && ((x === sx && y === sy) || (nx === ex && ny === ey))) continue;
          if (ug && viaUg) continue;                            // an exit cannot be an entrance too
          if (ug) { let blocked = false; for (let m = 1; m < ug; m++) if (ugT.has(key(x + dx * m, y + dy * m))) blocked = true; if (blocked) continue; }
          const nk = st(nx, ny, d, ug), nc = c + cost;
          if (dist.has(nk) && dist.get(nk) <= nc) continue;
          dist.set(nk, nc); prev.set(nk, { from: k, d, ug });
          (buckets[nc] = buckets[nc] || []).push(nk);
        }
      }
    }
  }
  if (!goal) { console.log('no route'); process.exit(1); }
  // Walk back (states -> tiles).
  const steps = [];
  for (let k = goal; prev.has(k); k = prev.get(k).from) { const p = prev.get(k); steps.unshift({ to: k.split(',').slice(0, 2).join(','), d: p.d, ug: p.ug }); }
  const tilesUsed = new Set([key(sx, sy)]);
  for (const s of steps) {
    if (tilesUsed.has(s.to)) {
      // The route passes a tile twice (once under ground): forbid that tile and search again.
      const tries = Number(process.env.ROUTE_TRIES || 0);
      if (tries >= 8) { console.log('route crosses itself'); process.exit(1); }
      const [tx, ty] = s.to.split(',').map(Number);
      const a2 = args.slice(); const i = a2.indexOf('--avoid'); const add = `${tx + 0.5},${ty + 0.5}`;
      if (i >= 0) a2[i + 1] = a2[i + 1] + ';' + add; else a2.push('--avoid', add);
      execFileSync(process.execPath, [__filename, ...a2], { stdio: 'inherit', env: { ...process.env, ROUTE_TRIES: String(tries + 1) } });
      process.exit(0);
    }
    tilesUsed.add(s.to);
  }
  dist.set(key(ex, ey), dist.get(goal));
  const list = [];
  const at = (k) => k.split(',').map((n) => Number(n) + 0.5);
  let [cx, cy] = at(key(sx, sy));
  steps.forEach((s, i) => {
    const nextD = i + 1 < steps.length ? steps[i + 1].d : (lastDir || s.d);
    const [tx, ty] = at(s.to);
    if (s.ug) {
      // the current tile becomes an entrance facing d, the target an exit facing d
      if (kind === 'belt') {
        list.push({ name: 'underground-belt', x: cx, y: cy, dir: s.d, ug: 'input' });
        list.push({ name: 'underground-belt', x: tx, y: ty, dir: s.d, ug: 'output' });
      } else {
        const back = { N: 'S', S: 'N', E: 'W', W: 'E' };
        list.push({ name: 'pipe-to-ground', x: cx, y: cy, dir: back[s.d] });
        list.push({ name: 'pipe-to-ground', x: tx, y: ty, dir: s.d });
      }
    } else {
      if (!list.some((e) => e.x === cx && e.y === cy)) list.push(kind === 'belt' ? { name: 'transport-belt', x: cx, y: cy, dir: s.d } : { name: 'pipe', x: cx, y: cy });
      if (i === steps.length - 1) list.push(kind === 'belt' ? { name: 'transport-belt', x: tx, y: ty, dir: nextD } : { name: 'pipe', x: tx, y: ty });
    }
    if (s.ug && i === steps.length - 1 && kind === 'pipe') { /* exit already placed */ }
    [cx, cy] = [tx, ty];
  });
  // An underground exit followed by more steps keeps its tile; drop plain duplicates at ug tiles.
  const seen = new Set(); const final = [];
  for (const e of list) { const k = `${e.x},${e.y}`; if (seen.has(k)) continue; seen.add(k); final.push(e); }
  fs.writeFileSync(out, JSON.stringify({ list: final }));
  const count = {}; final.forEach((e) => { count[e.name] = (count[e.name] || 0) + 1; });
  console.log(`${out}: ${JSON.stringify(count)} cost ${dist.get(key(ex, ey))}`);
}).catch((e) => { console.error(e.message); process.exit(1); });
