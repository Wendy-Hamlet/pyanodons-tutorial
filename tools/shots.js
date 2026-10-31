// Screenshots from the author's real game, taken by the companion mod (/pt-shots).
//
//   node tools/shots.js plan name[@surface]:x1,y1,x2,y2[,zoom] ...
//     Writes tools/companion/shots.lua: the areas to shoot, in tile coordinates as
//     tools/render-area.js prints them. In game, /pt-shots reloads the mod scripts (single
//     player) and takes each area with entity info (alt view), as JPGs. @surface shoots another
//     surface than nauvis, such as a Blueprint Sandboxes lab (trains-probe lists them).
//
//   node tools/shots.js pull
//     Copies the JPGs from %APPDATA%\Factorio\script-output\py-tutorial-companion\shots into
//     images/.

const fs = require('fs');
const path = require('path');

const luaFile = path.join(__dirname, 'companion', 'shots.lua');
const shotDir = path.join(process.env.APPDATA || '', 'Factorio', 'script-output', 'py-tutorial-companion', 'shots');
const images = path.join(__dirname, '..', 'images');

const [command, ...rest] = process.argv.slice(2);
if (command === 'plan' && rest.length) {
  const entries = rest.map((arg) => {
    const [named, coords] = arg.split(':');
    const [name, surface] = named.split('@');
    const [x1, y1, x2, y2, zoom = 1] = coords.split(',').map(Number);
    if (!/^[a-z0-9-]+$/.test(name) || [x1, y1, x2, y2, zoom].some(Number.isNaN)) {
      throw new Error(`bad shot "${arg}" (want name[@surface]:x1,y1,x2,y2[,zoom])`);
    }
    const on = surface ? `, surface = ${JSON.stringify(surface)}` : '';
    return `  { name = ${JSON.stringify(name)}${on}, x1 = ${x1}, y1 = ${y1}, x2 = ${x2}, y2 = ${y2}, zoom = ${zoom} },`;
  });
  const stamp = new Date().toLocaleString('sv-SE').slice(0, 16);
  fs.writeFileSync(luaFile, `-- Written by tools/shots.js plan; do not edit by hand.\nreturn {\n  generated = ${JSON.stringify(stamp)},\n${entries.join('\n')}\n}\n`);
  console.log(`plan: ${entries.length} areas -> tools/companion/shots.lua; in game type /pt-shots`);
} else if (command === 'pull') {
  fs.mkdirSync(images, { recursive: true });
  const files = fs.readdirSync(shotDir).filter((f) => f.endsWith('.jpg'));
  for (const f of files) {
    fs.copyFileSync(path.join(shotDir, f), path.join(images, f));
    const st = fs.statSync(path.join(shotDir, f));
    console.log(`  ${f}  ${(st.size / 1024).toFixed(0)} KB  ${st.mtime.toLocaleString()}`);
  }
  console.log(`pull: ${files.length} screenshots -> images/`);
} else {
  console.log('usage: node tools/shots.js plan name:x1,y1,x2,y2[,zoom] ... | pull');
  process.exit(1);
}
