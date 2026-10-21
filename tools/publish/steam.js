// Steam guide export: turns the chapters into paste-ready Steam guide sections (BBCode).
//
//   node tools/publish/steam.js [--lang en|zh|both] [--out DIR] [--limit N] [--bytes] [chapter ...]
//
// Steam guides have no upload API, so this writes what the guide editor takes, field by field:
// DIR/<lang>/guide.html (the chapters asked for, each field with a copy button and its length, the
// images to upload per section) and DIR/<lang>/NN.txt (the same as text). Default DIR is
// tools/publish/out/steam (not committed), default --limit 7500 (Steam allows 8,000 characters
// a section, tags included); chapters are numbers (default all). --bytes counts UTF-8 bytes
// instead of characters, in case Steam turns out to count Chinese text that way.
//
// The guides keep the tutorial only. Left out: the "How these facts were checked" section, tool
// names, commands and the other method notes, by the edits and rules in edits.js and clean() in
// common.js. Every guide starts with a section saying who wrote it and linking its full version
// on GitHub. The script then lists every line that still names a tool or a method (fix those in
// edits.js) and every edit that no longer matches its chapter.
//
// Links: blueprints and research notes go to GitHub; links to other chapters go to their Steam
// guides once steam-guides.json (beside this file) maps them, {"en": {"2": "<url>"}, "zh": {...}},
// otherwise to GitHub. Images cannot be linked: each one becomes a marker line ">>> IMAGE
// name <<<" with its caption below; upload the image in that section and put it there.

const fs = require('fs');
const path = require('path');
const { root, blob, chapters, T, clean, lint, linkTarget, chapter } = require('./common');

const args = process.argv.slice(2);
const opt = (name, def) => {
  const i = args.indexOf(name);
  if (i < 0) return def;
  const v = args[i + 1];
  args.splice(i, 2);
  return v;
};
const langArg = opt('--lang', 'both');
const outDir = opt('--out', path.join(__dirname, 'out', 'steam'));
const limit = Number(opt('--limit', '7500'));
const bytes = args.includes('--bytes');
if (bytes) args.splice(args.indexOf('--bytes'), 1);
const size = (s) => (bytes ? Buffer.byteLength(s) : s.length);
const unit = bytes ? 'bytes' : 'characters';
const wanted = args.map(Number);
const langs = langArg === 'both' ? ['en', 'zh'] : [langArg];

let steamIds = {};
const idFile = path.join(__dirname, 'steam-guides.json');
if (fs.existsSync(idFile)) steamIds = JSON.parse(fs.readFileSync(idFile, 'utf8'));

const S = {
  en: { about: 'About this guide', cont: '(continued)', image: (name) => `>>> IMAGE ${name} <<<` },
  zh: { about: '关于本指南', cont: '（续）', image: (name) => `>>> 图片 ${name} <<<` },
};

const tagNames = 'b|i|u|s|h1|h2|h3|url|list|olist|\\*|table|tr|th|td|code|quote|hr|spoiler|strike|noparse|img|previewimg';
const tagLike = new RegExp(`\\[\\/?(${tagNames})(=[^\\]]*)?\\]`, 'i');

// ---------- inline Markdown to BBCode ----------

function inline(text, ctx) {
  // Code spans and links are set aside first, so bold and italics can span them.
  const held = [];
  const hold = (s) => `\u0000${held.push(s) - 1}\u0000`;
  text = text.replace(/`([^`]+)`/g, (all, code) => hold(literal(code)));
  text = text.replace(/\[([^\]]+)\]\(([^)\s]+)\)/g, (all, label, href) => hold(`[url=${linkTarget(href, ctx.file, steamIds)}]${emph(label)}[/url]`));
  text = emph(text);
  while (/\u0000\d+\u0000/.test(text)) text = text.replace(/\u0000(\d+)\u0000/g, (all, k) => held[k]);
  return text;
}

function literal(s) {
  return tagLike.test(s) ? `[noparse]${s}[/noparse]` : s;
}

function emph(s) {
  s = s.replace(/\\([\\`*_{}\[\]()#+\-.!|])/g, '$1');
  s = s.replace(/\[[^\]]*\]/g, (b) => literal(b));
  s = s.replace(/\*\*(.+?)\*\*/g, '[b]$1[/b]');
  s = s.replace(/(^|[^*\w])\*(?!\s)([^*]+?)\*(?!\w)/g, '$1[i]$2[/i]');
  s = s.replace(/(^|[^\w])_(?!\s)([^_]+?)_(?!\w)/g, '$1[i]$2[/i]');
  s = s.replace(/~~(.+?)~~/g, '[strike]$1[/strike]');
  return s;
}

// ---------- blocks to BBCode ----------

function listCode(nodes, ctx) {
  const tag = nodes[0] && nodes[0].ordered ? 'olist' : 'list';
  const items = nodes.map((n) => `[*]${inline(clean(n.text), ctx)}${n.children.length ? `\n${listCode(n.children, ctx)}` : ''}`);
  return `[${tag}]\n${items.join('\n')}\n[/${tag}]`;
}

function tableCode(head, rows, ctx) {
  const row = (cells, t) => `[tr]${cells.map((c) => `[${t}]${inline(clean(c), ctx)}[/${t}]`).join('')}[/tr]`;
  return `[table]\n${row(head, 'th')}\n${rows.map((r) => row(r, 'td')).join('\n')}\n[/table]`;
}

// A block as one or more BBCode pieces, each at most `limit` long where it can be split.
function blockCode(b, ctx) {
  switch (b.type) {
    case 'h': return [`[h${Math.min(b.level - 1, 3)}]${inline(clean(b.text), ctx)}[/h${Math.min(b.level - 1, 3)}]`];
    case 'p': return [inline(clean(b.text), ctx)];
    case 'code': return [`[code]${b.text}[/code]`];
    case 'image': {
      const name = path.posix.basename(b.src);
      return [`[b]${S[ctx.lang].image(name)}[/b]\n[i]${inline(clean(b.alt), ctx)}[/i]`];
    }
    case 'list': {
      const whole = listCode(b.tree, ctx);
      if (size(whole) <= limit) return [whole];
      return packs(b.tree, (part) => listCode(part, ctx));
    }
    case 'table': {
      const whole = tableCode(b.head, b.rows, ctx);
      if (size(whole) <= limit) return [whole];
      return packs(b.rows, (part) => tableCode(b.head, part, ctx));
    }
    default: throw new Error(`unknown block ${b.type}`);
  }
}

// Splits items into the fewest runs whose code fits the limit.
function packs(items, code) {
  const out = [];
  let run = [];
  for (const it of items) {
    if (run.length && size(code([...run, it])) > limit) {
      out.push(code(run));
      run = [];
    }
    run.push(it);
  }
  if (run.length) out.push(code(run));
  return out;
}

// ---------- one chapter to a guide ----------

function guide(n, lang) {
  const c = chapter(n, lang);
  const t = T[lang];
  const s = S[lang];
  const ctx = { file: c.file, lang };
  const sections = [];
  let current = null;
  const open = (name) => {
    current = { title: name, parts: [] };
    sections.push(current);
  };

  // The first section: who wrote it, the full version, the chapter's own introduction.
  open(s.about);
  const prev = chapters[n - 1] && chapters[n - 1][lang];
  const next = chapters[n + 1] && chapters[n + 1][lang];
  const chName = (k) => `[url=${linkTarget(chapters[k][lang], c.file, steamIds)}]${t.chapter(k)}[/url]`;
  const sep = lang === 'zh' ? '' : ' ';
  current.parts.push(`[b]${t.written}[/b]`,
    `${t.full}${sep}[url=${blob}chapters/${c.file}]${t.thisChapter}[/url]${lang === 'zh' ? '。' : '.'} ${t.blueprints}${sep}[url=${blob}${t.blueprintsFile}]${t.blueprintsLink}[/url]${lang === 'zh' ? '。' : '.'}`.replace(/。 /, '。'),
    t.terms);
  const nav = [prev && `${t.prev}${sep}${chName(n - 1)}`, next && `${t.next}${sep}${chName(n + 1)}`].filter(Boolean).join(' · ');
  if (nav) current.parts.push(nav);
  current.parts.push('[hr][/hr]');

  for (const b of c.blocks) {
    if (b.type === 'h' && b.level === 2) open(clean(b.text).replace(/\*\*/g, ''));
    else current.parts.push(...blockCode(b, ctx));
  }

  // Each section's parts into Steam sections of at most `limit` characters.
  const out = [];
  for (const sec of sections) {
    let body = [];
    let k = 0;
    const flush = () => {
      const text = body.join('\n\n');
      const images = [...text.matchAll(/>>> (?:IMAGE|图片) (\S+) <<</g)].map((m) => m[1]);
      out.push({ title: k ? `${sec.title} ${s.cont}` : sec.title, body: text, images });
      body = [];
      k++;
    };
    for (const p of sec.parts) {
      if (body.length && size([...body, p].join('\n\n')) > limit) flush();
      body.push(p);
    }
    if (body.length) flush();
  }

  const report = [...c.report];
  for (const sec of out) {
    if (size(sec.body) > limit) report.push(`section "${sec.title}" is ${size(sec.body)} ${unit}`);
    lint(sec.body, sec.title, report);
  }
  return {
    n, file: c.file, report,
    title: `${t.series} · ${c.title}`,
    description: `${c.description}${lang === 'en' ? ' ' : ''}${t.short}`.trim(),
    sections: out,
  };
}

// ---------- output ----------

const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;');

const L = {
  en: { head: 'Steam guide export', help: 'Paste each field into the Steam guide editor. Replace every image marker line with the image uploaded in that section.', title: 'Title', desc: 'Description', section: 'Section', stitle: 'Section title', stext: 'Section text', upload: 'Upload in this section:', copy: 'Copy', copied: 'Copied', chars: 'characters', bytes: 'bytes' },
  zh: { head: 'Steam 指南导出', help: '把每一栏粘贴到 Steam 指南编辑器。每个图片标记行换成在该小节上传的图片。', title: '标题', desc: '简介', section: '小节', stitle: '小节标题', stext: '小节正文', upload: '本小节要上传的图片：', copy: '复制', copied: '已复制', chars: '字符', bytes: '字节' },
};

function html(lang, guides) {
  const l = L[lang];
  const imgDir = path.join(root, 'images').replace(/\\/g, '/');
  const field = (label, value) => `<div class="f"><div class="h"><b>${esc(label)}</b><span>${size(value)} ${bytes ? l.bytes : l.chars}</span><button>${l.copy}</button></div><textarea rows="${Math.min(14, value.split('\n').length + 1)}" readonly>${esc(value)}</textarea></div>`;
  const body = guides.map((g) => `<section><h2>${esc(g.title)}</h2>
${field(l.title, g.title)}${field(l.desc, g.description)}
${g.sections.map((s, k) => `<h3>${l.section} ${k + 1}</h3>${field(l.stitle, s.title)}${field(l.stext, s.body)}${s.images.length ? `<div class="imgs">${l.upload} ${s.images.map((im) => `<figure><img src="file:///${imgDir}/${im}" loading="lazy"><figcaption>${esc(im)}</figcaption></figure>`).join('')}</div>` : ''}`).join('\n')}
</section>`).join('\n');
  return `<!doctype html><html lang="${lang === 'zh' ? 'zh-CN' : 'en'}"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width, initial-scale=1"><title>${l.head}</title>
<style>:root{--bg:#fff;--fg:#1b1b1b;--mut:#666;--line:#ccc;--box:#f6f6f6}
@media (prefers-color-scheme: dark){:root{--bg:#16181c;--fg:#e8e8e8;--mut:#9a9a9a;--line:#3a3d44;--box:#1f2228}}
body{background:var(--bg);color:var(--fg);font:15px/1.5 system-ui,sans-serif;max-width:980px;margin:0 auto;padding:16px}
section{border-top:2px solid var(--line);margin-top:28px}.f{margin:8px 0}.h{display:flex;gap:12px;align-items:center}
.h span{color:var(--mut);font-size:13px;flex:1}textarea{width:100%;box-sizing:border-box;background:var(--box);color:var(--fg);border:1px solid var(--line);font:13px/1.4 ui-monospace,monospace}
button{cursor:pointer}.imgs{display:flex;flex-wrap:wrap;gap:8px;align-items:flex-start;color:var(--mut)}figure{margin:0}img{width:180px;display:block}figcaption{font-size:12px}</style></head><body>
<h1>${l.head}</h1><p>${l.help}</p>
${body}
<script>document.addEventListener('click',async(e)=>{if(e.target.tagName!=='BUTTON')return;const t=e.target.closest('.f').querySelector('textarea');try{await navigator.clipboard.writeText(t.value)}catch(_){t.select();document.execCommand('copy')}e.target.textContent='${l.copied}';setTimeout(()=>e.target.textContent='${l.copy}',1200)});</script>
</body></html>`;
}

let problems = 0;
for (const lang of langs) {
  const nums = Object.keys(chapters).map(Number).filter((k) => chapters[k][lang] && (!wanted.length || wanted.includes(k)));
  const guides = nums.map((k) => guide(k, lang));
  const dir = path.join(outDir, lang);
  fs.mkdirSync(dir, { recursive: true });
  for (const g of guides) {
    const txt = [`TITLE: ${g.title}`, `DESCRIPTION: ${g.description}`,
      ...g.sections.map((s, k) => `===== SECTION ${k + 1}: ${s.title} (${size(s.body)} ${unit}${s.images.length ? `; images: ${s.images.join(', ')}` : ''})\n${s.body}`)].join('\n\n');
    fs.writeFileSync(path.join(dir, `${String(g.n).padStart(2, '0')}.txt`), `${txt}\n`);
    console.log(`${lang} ${g.file}: ${g.sections.length} sections, ${g.sections.reduce((a, s) => a + s.images.length, 0)} images`);
    for (const r of g.report) console.log(`  ${r}`);
    problems += g.report.length;
  }
  fs.writeFileSync(path.join(dir, 'guide.html'), html(lang, guides));
  console.log(`wrote ${path.join(dir, 'guide.html').replace(/\\/g, '/')}`);
}
console.log(problems ? `${problems} lines to look at` : 'clean');
