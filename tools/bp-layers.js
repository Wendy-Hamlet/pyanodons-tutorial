// Cuts the single-platform station blueprints: rail-<kind>-N-(N-1) is the difference of the 1-N and
// 1-(N-1) stations, platform N alone at its absolute place (snap 240), without the main-line piece
// that only 1-1 holds. Pasted one after another, of any kind, they make a station whose platforms
// do different jobs: an outpost taking a fluid in and sending an item and a fluid out.
//   node tools/bp-layers.js [--options <file>]
// Each cut keeps the settings of 1-N and the parameter table of 1-1 (the formula reads p0_s, so the
// one parameter must be parameter-0, whichever platform it is). Run it again after the 1-N stations
// change, then `bp-sync.js push`.
const fs = require('fs');
const path = require('path');
const zlib = require('zlib');

const dir = path.join(__dirname, '..', 'blueprints');
const load = (name) => JSON.parse(zlib.inflateSync(Buffer.from(fs.readFileSync(path.join(dir, `${name}.txt`), 'utf8').trim().slice(1), 'base64'))).blueprint;
const save = (name, blueprint) => fs.writeFileSync(path.join(dir, `${name}.txt`),
  `0${zlib.deflateSync(Buffer.from(JSON.stringify({ blueprint }), 'utf8'), { level: 9 }).toString('base64')}\n`);
const key = (e) => `${e.name}@${e.position.x},${e.position.y}d${e.direction || 0}`;

const kinds = [
  { file: 'rail-requester', label: '物品卸货站', en: 'item requester', zh: '物品卸货站', params: 'item, slots of a train (40)', zhParams: '物品、单列火车格数（40）' },
  { file: 'rail-provider', label: '物品供货站', en: 'item provider', zh: '物品供货站', params: 'item', zhParams: '物品' },
  { file: 'rail-fluid-requester', label: '流体卸货站', en: 'fluid requester', zh: '流体卸货站', params: 'fluid, amount', zhParams: '流体、需求量' },
  { file: 'rail-fluid-provider', label: '流体供货站', en: 'fluid provider', zh: '流体供货站', params: 'fluid', zhParams: '流体' },
];

const description = (k, n) => `Platform ${n} alone of the 1-4 ${k.en}, same absolute place (snap 240), no main-line piece. `
  + `Paste over the platforms below it, of any kind; an item platform cannot stand right above a fluid one. Parameters: ${k.params}.\n`
  + `1-4 ${k.zh}的第 ${n} 道，绝对位置不变（240 对齐），不含干线。叠在下面几道上，各道种类可以不同，但物品站台不能紧贴在流体站台上方。参数：${k.zhParams}。`;

const names = [];
for (const k of kinds) {
  const first = load(`${k.file}-1`);
  for (let n = 2; n <= 4; n += 1) {
    const whole = load(`${k.file}-${n}`);
    const below = new Set(load(`${k.file}-${n - 1}`).entities.map(key));
    const kept = whole.entities.filter((e) => !below.has(key(e)));
    if (whole.entities.length - kept.length !== below.size) throw new Error(`${k.file}-${n - 1} is not a subset of ${k.file}-${n}`);

    const number = new Map(kept.map((e, i) => [e.entity_number, i + 1]));
    const parameter = `parameter-${n - 1}`;
    const entities = kept.map((e) => {
      const copy = JSON.parse(JSON.stringify(e).split(parameter).join('parameter-0'));
      copy.entity_number = number.get(e.entity_number);
      // The item requester tells its platforms apart by placeholder amounts 0, -1, -2, -3; 1-1 has 0.
      for (const section of copy.control_behavior?.sections?.sections || []) {
        for (const filter of section.filters) {
          if (filter.name === 'parameter-0' && filter.count === 1 - n) filter.count = 0;
        }
      }
      return copy;
    });
    if (/parameter-[1-9]/.test(JSON.stringify(entities))) throw new Error(`${k.file}-${n}: another parameter left`);
    const wires = whole.wires.filter((w) => number.has(w[0]) && number.has(w[2]))
      .map((w) => [number.get(w[0]), w[1], number.get(w[2]), w[3]]);
    const parameters = first.parameters.map((p) => (p.name ? { ...p, name: p.name.replace(/0$/, '') } : p));
    const [, kind, arrow] = first.icons.map((i) => i.signal);
    const digit = (d) => ({ type: 'virtual', name: `signal-${d}` });
    const icons = [kind, arrow, digit(n), digit(n - 1)].map((signal, i) => ({ signal, index: i + 1 }));

    const name = `${k.file}-${n}-${n - 1}`;
    const text = description(k, n);
    if (Buffer.byteLength(text) > 500) throw new Error(`${name}: description of ${Buffer.byteLength(text)} bytes`);
    save(name, { ...first, label: `${k.label}-${n}-${n - 1}`, description: text, icons, entities, wires, parameters });
    names.push(name);
    console.log(`${name}: ${entities.length} entities, ${wires.length} wires, ${whole.wires.length - wires.length} left to 1-${n - 1}`);
  }
}

// --options <file>: the options of junction-bench mode "layers".
const at = process.argv.indexOf('--options');
if (at > 0) {
  const text = (name) => fs.readFileSync(path.join(dir, `${name}.txt`), 'utf8').trim();
  const options = { kinds: {} };
  for (const k of kinds) {
    options.kinds[k.file] = {
      full: text(`${k.file}-4`),
      layers: [text(`${k.file}-1`), text(`${k.file}-2-1`), text(`${k.file}-3-2`), text(`${k.file}-4-3`)],
    };
  }
  fs.writeFileSync(process.argv[at + 1], JSON.stringify(options));
}

// Book order: each kind's cuts right after its 1-4.
const manifestFile = path.join(dir, 'book.json');
const manifest = JSON.parse(fs.readFileSync(manifestFile, 'utf8'));
manifest.blueprints = manifest.blueprints.filter((n) => !names.includes(n));
for (const k of kinds) {
  const after = manifest.blueprints.indexOf(`${k.file}-4`);
  if (after < 0) throw new Error(`${k.file}-4 not in book.json`);
  manifest.blueprints.splice(after + 1, 0, `${k.file}-2-1`, `${k.file}-3-2`, `${k.file}-4-3`);
}
fs.writeFileSync(manifestFile, `${JSON.stringify(manifest, null, 2)}\n`);
console.log(`${names.length} blueprints, book of ${manifest.blueprints.length}`);
