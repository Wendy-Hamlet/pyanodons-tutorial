// Layout helper: builds ghost lists for `node a.js ghost @file.json` from short descriptions.
//
//   const L = require('./layout');
//   const g = new L.Layout();
//   g.path(21.5, 4.5, 'S5 W2');            // belts: 5 tiles south, then 2 west (each tile faces
//                                         // the way items leave it)
//   g.add('burner-inserter', 20.5, 4.5, 'W'); // inserter `dir` = the side it picks from
//   g.add('assembling-machine-1', 20.5, 12.5, 'N', 'empty-planter-box');
//   g.write('C:/tmp/cf-agent/x.json');     // {"list": [...]} for the ghost op
const fs = require('fs');

const STEP = { N: [0, -1], E: [1, 0], S: [0, 1], W: [-1, 0] };

class Layout {
  constructor() { this.list = []; this.taken = new Map(); }

  add(name, x, y, dir, recipe, extra) {
    const e = { name, x, y };
    if (dir) e.dir = dir;
    if (recipe) e.recipe = recipe;
    Object.assign(e, extra || {});
    this.list.push(e);
    return this;
  }

  // Belts along moves like "S5 W2": the first tile is (x, y); every tile faces the direction of
  // the move that leaves it; the last tile faces the last move.
  path(x, y, moves, name = 'transport-belt') {
    const steps = moves.trim().split(/\s+/).flatMap((m) => Array(Number(m.slice(1) || 1)).fill(m[0]));
    let cx = x, cy = y;
    steps.forEach((d) => {
      this.add(name, cx, cy, d);
      cx += STEP[d][0]; cy += STEP[d][1];
    });
    return { x: cx, y: cy }; // the tile after the last belt
  }

  // A pair of underground belts: entrance at (x, y) going `dir`, exit `len` tiles further.
  underground(x, y, dir, len) {
    this.add('underground-belt', x, y, dir, null, { ug: 'input' });
    this.add('underground-belt', x + STEP[dir][0] * len, y + STEP[dir][1] * len, dir, null, { ug: 'output' });
  }

  write(file) {
    fs.writeFileSync(file, JSON.stringify({ list: this.list }));
    const count = {};
    for (const e of this.list) count[e.name] = (count[e.name] || 0) + 1;
    return count;
  }
}

module.exports = { Layout, STEP };

// Entities of a blueprint string as layout entries, moved so the blueprint's top-left tile is
// at (left, top). Keeps directions, recipes, underground types and inserter filters.
Layout.prototype.blueprint = function (str, left, top) {
  const zlib = require('zlib');
  const bp = JSON.parse(zlib.inflateSync(Buffer.from(str.trim().slice(1), 'base64')).toString()).blueprint;
  const D = { 0: 'N', 4: 'E', 8: 'S', 12: 'W' };
  const x0 = Math.min(...bp.entities.map((e) => e.position.x - (e.name.includes('drill') ? 1 : 0.5)));
  const y0 = Math.min(...bp.entities.map((e) => e.position.y - (e.name.includes('drill') ? 1 : 0.5)));
  for (const e of bp.entities) {
    const extra = {};
    if (e.type) extra.ug = e.type;
    if (e.filters) { extra.filters = e.filters.map((f) => f.name); if (e.filter_mode) extra.filter_mode = e.filter_mode; }
    this.add(e.name, e.position.x - x0 + left, e.position.y - y0 + top, D[e.direction || 0], e.recipe, extra);
  }
  return this;
};
