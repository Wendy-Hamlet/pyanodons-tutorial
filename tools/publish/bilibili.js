// Bilibili article export: each chapter as Markdown for the Bilibili article editor (专栏), with
// every table rendered to a PNG, since the editor has no tables.
//
//   node tools/publish/bilibili.js [--lang zh|en] [--out DIR] [chapter ...]
//
// Writes DIR/<lang>/NN/: article.md, title.txt, and images/ with the chapter's pictures and one
// PNG per table (chNN-table-K.png). Default DIR tools/publish/out/bilibili (not committed),
// default --lang zh, chapters are numbers (default all). In the article each picture and table
// is a marker paragraph "【图片 name】caption". bilibili-page.js, run in the editor page,
// imports article.md and puts each image in place of its marker through the editor's own
// upload, so the images end up on Bilibili's server, with the caption in the image's own
// caption field (at most 100 characters; longer ones are shortened in edits.js).
//
// The text is the tutorial only, as for Steam (edits.js, common.js; the run lists any line still
// naming a tool), and opens with a note that Claude wrote it from the author's saves, linking the
// full chapter on GitHub. Links to other chapters go to their Bilibili articles once
// bilibili-articles.json (beside this file) maps them, {"zh": {"2": "<url>"}}, otherwise to
// GitHub. Tables are drawn by the installed Edge (or the browser in PT_BROWSER) through
// puppeteer-core: run `npm install` in this folder once.

const fs = require('fs');
const path = require('path');
const { root, blob, chapters, T, clean, lint, linkTarget, chapter } = require('./common');
const { captions } = require('./edits');

const args = process.argv.slice(2);
const opt = (name, def) => {
  const i = args.indexOf(name);
  if (i < 0) return def;
  const v = args[i + 1];
  args.splice(i, 2);
  return v;
};
const lang = opt('--lang', 'zh');
const outDir = opt('--out', path.join(__dirname, 'out', 'bilibili'));
const wanted = args.map(Number);
const browserPath = process.env.PT_BROWSER || 'C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe';

let ids = {};
const idFile = path.join(__dirname, 'bilibili-articles.json');
if (fs.existsSync(idFile)) ids = JSON.parse(fs.readFileSync(idFile, 'utf8'));

const marker = (name, caption = '') => `【图片 ${name}】${caption}`;
// Bilibili's suggested longest title, and its longest image caption.
const titleLimit = 30;
const captionLimit = 100;

// ---------- inline Markdown, rewritten for the editor's importer ----------

const escHtml = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

// The editor has no inline code: code spans become plain text, escaped so the importer reads
// them literally. Links become absolute; `<` is escaped because the importer reads HTML.
function mdInline(text, file) {
  const held = [];
  const hold = (s) => `\u0000${held.push(s) - 1}\u0000`;
  text = text.replace(/`([^`]+)`/g, (all, code) => hold(escHtml(code).replace(/[\\*_[\]~]/g, '\\$&')));
  text = text.replace(/\[([^\]]+)\]\(([^)\s]+)\)/g, (all, label, href) => hold(`[${label.replace(/`/g, '')}](${linkTarget(href, file, ids)})`));
  text = text.replace(/</g, '&lt;');
  while (/\u0000\d+\u0000/.test(text)) text = text.replace(/\u0000(\d+)\u0000/g, (all, k) => held[k]);
  return text;
}

// A table cell as HTML for the rendered image: links keep their label only.
function cellHtml(text) {
  const held = [];
  const hold = (s) => `\u0000${held.push(s) - 1}\u0000`;
  text = text.replace(/`([^`]+)`/g, (all, code) => hold(escHtml(code)));
  text = text.replace(/\[([^\]]+)\]\(([^)\s]+)\)/g, (all, label) => hold(escHtml(label.replace(/`/g, ''))));
  text = escHtml(text).replace(/\\([\\`*_{}\[\]()#+\-.!|])/g, '$1');
  text = text.replace(/\*\*(.+?)\*\*/g, '<b>$1</b>').replace(/(^|[^*\w])\*(?!\s)([^*]+?)\*(?!\w)/g, '$1<i>$2</i>')
    .replace(/~~(.+?)~~/g, '<s>$1</s>');
  while (/\u0000\d+\u0000/.test(text)) text = text.replace(/\u0000(\d+)\u0000/g, (all, k) => held[k]);
  return text;
}

// ---------- blocks to Markdown ----------

function listMd(nodes, file, indent = '') {
  return nodes.map((n, k) => {
    const mark = n.ordered ? `${k + 1}. ` : '- ';
    const sub = n.children.length ? `\n${listMd(n.children, file, indent + ' '.repeat(mark.length))}` : '';
    return `${indent}${mark}${mdInline(clean(n.text), file)}${sub}`;
  }).join('\n');
}

function article(n) {
  const c = chapter(n, lang);
  const t = T[lang];
  const tag = `ch${String(n).padStart(2, '0')}`;
  const parts = [];
  const tables = [];
  const pictures = [];

  // The note every chapter opens with.
  const sep = lang === 'zh' ? '' : ' ';
  const end = lang === 'zh' ? '。' : '.';
  const written = lang === 'zh' ? t.written.replace('本指南', '本文') : t.written.replace('This guide', 'This article');
  const prev = chapters[n - 1] && chapters[n - 1][lang];
  const next = chapters[n + 1] && chapters[n + 1][lang];
  const nav = [prev && `${t.prev}${sep}[${t.chapter(n - 1)}](${linkTarget(prev, c.file, ids)})`,
    next && `${t.next}${sep}[${t.chapter(n + 1)}](${linkTarget(next, c.file, ids)})`].filter(Boolean).join(' · ');
  parts.push([`**${written}**`,
    `${t.full}${sep}[${t.thisChapter}](${blob}chapters/${c.file})${end}${lang === 'zh' ? '' : ' '}${t.blueprints}${sep}[${t.blueprintsLink}](${blob}${t.blueprintsFile})${end}`,
    t.terms, nav].filter(Boolean).map((p) => `> ${p}`).join('\n>\n'), '---');

  for (const b of c.blocks) {
    switch (b.type) {
      case 'h': parts.push(`${'#'.repeat(Math.min(b.level - 1, 3))} ${mdInline(clean(b.text), c.file)}`); break;
      case 'p': parts.push(mdInline(clean(b.text), c.file)); break;
      case 'code': parts.push(`\`\`\`\n${b.text}\n\`\`\``); break;
      case 'list': parts.push(listMd(b.tree, c.file)); break;
      case 'image': {
        const name = path.posix.basename(b.src);
        pictures.push(name);
        // The caption field takes plain text.
        const caption = (captions[lang] || {})[name] || clean(b.alt).replace(/\[([^\]]+)\]\([^)]*\)/g, '$1')
          .replace(/\\([\\`*_{}\[\]()#+\-.!|])/g, '$1').replace(/\*\*|`/g, '');
        if (caption.length > captionLimit) report.push(`caption of ${name} is ${caption.length} characters (at most ${captionLimit}): shorten it in edits.js`);
        parts.push(marker(name, caption.replace(/[\\*_[\]<~]/g, (x) => (x === '<' ? '&lt;' : `\\${x}`))));
        break;
      }
      case 'table': {
        const name = `${tag}-table-${String(tables.length + 1).padStart(2, '0')}.png`;
        tables.push({ name, head: b.head.map((x) => cellHtml(clean(x))), rows: b.rows.map((r) => r.map((x) => cellHtml(clean(x)))) });
        parts.push(marker(name));
        break;
      }
      default: throw new Error(`unknown block ${b.type}`);
    }
  }

  const md = `${parts.join('\n\n')}\n`;
  const report = [...c.report];
  lint(md, tag, report);
  // About Bilibili's suggested 30 at most: "Pyanodons 循序渐进 04｜铝矿开采、玻璃制造、原木生产和红瓶生产" (35).
  const title = lang === 'zh'
    ? `${t.series} ${String(n).padStart(2, '0')}｜${c.title.replace(/^第[一二三四五六七八九十]+章\s*(?:——|：)?\s*/, '')}`
    : `${t.series} · ${c.title}`;
  return { n, tag, file: c.file, title, md, tables, pictures, report };
}

// ---------- tables to images ----------

const tableCss = `body{margin:0;background:#fff;color:#1f2328;font:15px/1.55 "Microsoft YaHei","PingFang SC","Segoe UI",sans-serif}
.t{display:inline-block;padding:12px;background:#fff;margin:0 0 24px}
table{border-collapse:collapse;max-width:760px}
th,td{border:1px solid #d0d7de;padding:6px 10px;vertical-align:top;text-align:left}
th{background:#eef1f5;font-weight:600}
tr:nth-child(even) td{background:#f8f9fb}
td.num{text-align:right;white-space:nowrap;font-variant-numeric:tabular-nums}`;

const isNum = (html) => /^[−\-+]?[\d.,]+\s*(%|×)?$/.test(html.replace(/<\/?b>/g, '').trim());

async function renderTables(jobs) {
  if (!jobs.length) return;
  let puppeteer;
  try {
    puppeteer = require('puppeteer-core');
  } catch (e) {
    throw new Error('puppeteer-core is missing: run `npm install` in tools/publish');
  }
  const html = `<!doctype html><html><head><meta charset="utf-8"><style>${tableCss}</style></head><body>${jobs.map((j, k) =>
    `<div class="t" id="t${k}"><table><tr>${j.head.map((h) => `<th>${h}</th>`).join('')}</tr>${j.rows.map((r) =>
      `<tr>${r.map((x) => `<td${isNum(x) ? ' class="num"' : ''}>${x}</td>`).join('')}</tr>`).join('')}</table></div><br>`).join('')}</body></html>`;
  // An ASCII profile folder: Edge fails silently under a non-ASCII user profile path.
  const browser = await puppeteer.launch({ executablePath: browserPath, headless: true, userDataDir: 'C:/tmp/pt-render-profile', args: ['--disable-gpu'] });
  try {
    const page = await browser.newPage();
    await page.setViewport({ width: 1000, height: 800, deviceScaleFactor: 2 });
    await page.setContent(html, { waitUntil: 'load' });
    for (let k = 0; k < jobs.length; k++) {
      const el = await page.$(`#t${k}`);
      await el.screenshot({ path: jobs[k].path });
    }
  } finally {
    await browser.close();
  }
}

// ---------- output ----------

(async () => {
  const nums = Object.keys(chapters).map(Number).filter((k) => chapters[k][lang] && (!wanted.length || wanted.includes(k)));
  const jobs = [];
  let problems = 0;
  for (const n of nums) {
    const a = article(n);
    const dir = path.join(outDir, lang, String(n).padStart(2, '0'));
    const imgDir = path.join(dir, 'images');
    fs.rmSync(dir, { recursive: true, force: true });
    fs.mkdirSync(imgDir, { recursive: true });
    fs.writeFileSync(path.join(dir, 'article.md'), a.md);
    fs.writeFileSync(path.join(dir, 'title.txt'), `${a.title}\n`);
    for (const p of a.pictures) fs.copyFileSync(path.join(root, 'images', p), path.join(imgDir, p));
    for (const tb of a.tables) jobs.push({ ...tb, path: path.join(imgDir, tb.name) });
    console.log(`${lang} ${a.file}: ${a.md.length} characters, ${a.pictures.length} pictures, ${a.tables.length} tables -> ${dir.replace(/\\/g, '/')}`);
    console.log(`  title (${a.title.length}${a.title.length > titleLimit ? `, Bilibili suggests at most ${titleLimit}` : ''}): ${a.title}`);
    for (const r of a.report) console.log(`  ${r}`);
    problems += a.report.length;
  }
  await renderTables(jobs);
  console.log(problems ? `${problems} lines to look at` : 'clean');
})().catch((e) => {
  console.error(e.message);
  process.exit(1);
});
