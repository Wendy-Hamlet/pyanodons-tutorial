// Steam guide export: turns the chapters into paste-ready Steam guide sections (BBCode).
//
//   node tools/publish/steam.js [--lang en|zh|both] [--out DIR] [--limit N] [--bytes] [chapter ...]
//
// Steam guides have no upload API, so this writes what the guide editor takes, field by field:
// DIR/<lang>/guide.html (the chapters asked for, each field with a copy button and its length, the
// images to upload per section) and DIR/<lang>/NN.txt (the same as text). Default DIR is
// C:/tmp/pt-steam, default --limit 7500 (Steam allows 8,000 characters a section, tags
// included); chapters are numbers (default all). --bytes counts UTF-8 bytes instead of
// characters, in case Steam turns out to count Chinese text that way.
//
// The guides keep the tutorial only. Left out: the "How these facts were checked" section, tool
// names, commands and the other method notes, by the edits and rules in steam-edits.js and
// clean() below. Every guide starts with a section saying who wrote it and linking its full
// version on GitHub. The script then lists every line that still names a tool or a method
// (fix those in steam-edits.js) and every edit that no longer matches its chapter.
//
// Links: blueprints and research notes go to GitHub; links to other chapters go to their Steam
// guides once steam-guides.json (beside this file) maps them, {"en": {"2": "<url>"}, "zh": {...}},
// otherwise to GitHub. Images cannot be linked: each one becomes a marker line ">>> IMAGE
// name <<<" with its caption below; upload the image in that section and put it there.

const fs = require('fs');
const path = require('path');
const edits = require('./steam-edits');

const root = path.join(__dirname, '..', '..');
const repo = 'https://github.com/Wendy-Hamlet/pyanodons-tutorial';
const blob = `${repo}/blob/master/`;

const args = process.argv.slice(2);
const opt = (name, def) => {
  const i = args.indexOf(name);
  if (i < 0) return def;
  const v = args[i + 1];
  args.splice(i, 2);
  return v;
};
const langArg = opt('--lang', 'both');
const outDir = opt('--out', 'C:/tmp/pt-steam');
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

const T = {
  en: {
    series: 'Pyanodons, step by step',
    about: 'About this guide',
    cont: '(continued)',
    written: 'This guide was written by Claude, Anthropic\'s AI, from my saves and my game\'s logs, which it read with tools; "the author" in the text is me. I have read all of it, but I cannot promise it is free of mistakes.',
    full: (url) => `The full version, with the source of every number, the tools and how each fact was checked, is on GitHub: [url=${url}]this chapter[/url]. All the blueprints: [url=${blob}blueprints/README.md]blueprints[/url].`,
    nav: (prev, next) => [prev && `Previous: ${prev}`, next && `Next: ${next}`].filter(Boolean).join(' · '),
    short: 'Written by Claude (AI) from my saves; I have read it all, but it may still contain mistakes.',
    image: (name) => `>>> IMAGE ${name} <<<`,
    terms: '"Measured" means run in a copy of my save; "on a test map" means the blueprint built alone on an empty map with unlimited inputs.',
  },
  zh: {
    series: 'Pyanodons 循序渐进',
    about: '关于本指南',
    cont: '（续）',
    written: '本指南由 Claude（Anthropic 的人工智能）用工具读取我的存档和游戏记录后撰写，文中的“作者”就是我。我通读过全部内容，但仍不能保证没有错误。',
    full: (url) => `完整版（每个数字的来源、所用工具和核实方法）在 GitHub：[url=${url}]本章[/url]。全部蓝图：[url=${blob}blueprints/README.zh-CN.md]蓝图[/url]。`,
    nav: (prev, next) => [prev && `上一章：${prev}`, next && `下一章：${next}`].filter(Boolean).join(' · '),
    short: '由 Claude（人工智能）读取我的存档后撰写；我已通读，但仍可能有错误。',
    image: (name) => `>>> 图片 ${name} <<<`,
    terms: '文中“实测”指在我存档的副本里运行；“测试地图”指把蓝图单独建在空地图上、输入不限量地运行。',
  },
};

// The chapter files, by number and language.
const chapterDir = path.join(root, 'chapters');
const chapters = {};
for (const f of fs.readdirSync(chapterDir).sort()) {
  const m = /^(\d\d)-.*?(\.zh-CN)?\.md$/.exec(f);
  if (!m) continue;
  const n = Number(m[1]);
  (chapters[n] = chapters[n] || {})[m[2] ? 'zh' : 'en'] = f;
}

const isCJK = (c) => /[\u3000-\u303f\u3400-\u9fff\uff00-\uffef]/.test(c || '');
const tagNames = 'b|i|u|s|h1|h2|h3|url|list|olist|\\*|table|tr|th|td|code|quote|hr|spoiler|strike|noparse|img|previewimg';
const tagLike = new RegExp(`\\[\\/?(${tagNames})(=[^\\]]*)?\\]`, 'i');

// ---------- cleaning: what the guides leave out ----------

const toolToken = /`(?:tools\/[^`]*|[\w.-]+\.(?:js|ps1)\b[^`]*)`/g;

function clean(text) {
  // A parenthesis that only names tools goes; tool names inside a longer one go.
  text = text.replace(/\(([^()]*)\)/g, (all, inner) => {
    if (!toolToken.test(inner)) return all;
    toolToken.lastIndex = 0;
    let rest = inner.replace(toolToken, '').replace(/\s*,\s*(,|$)/g, '$1').replace(/^\s*[,;]\s*/, '')
      .replace(/\s*[,;]\s*$/, '').replace(/,\s*,/g, ',').trim();
    rest = rest.replace(/^(?:and|with|in|by)\s+/, '');
    return rest ? `(${rest})` : '';
  });
  toolToken.lastIndex = 0;
  text = text.replace(/（([^（）]*)）/g, (all, inner) => {
    if (!toolToken.test(inner)) return all;
    toolToken.lastIndex = 0;
    const rest = inner.replace(toolToken, '').replace(/^[\s，、；,]+|[\s，、；,]+$/g, '').replace(/[，、]\s*[，、]/g, '，').trim();
    return rest ? `（${rest}）` : '';
  });
  toolToken.lastIndex = 0;
  return text.replace(/ +([,.;:])/g, '$1').replace(/ {2,}/g, ' ').replace(/ +([，。；：）])/g, '$1');
}

// Words that show a method note survived the cleaning.
const lintWords = /tools\/|\.js\b|\.ps1\b|probe|recorder|companion|bench|design lab|belt-lab|data\.raw|save-env|探针|记录器|助手模组|伴侣模组|伴生模组|测试台|实验台/i;

// ---------- Markdown to blocks ----------

function parse(md) {
  const lines = md.replace(/\r/g, '').split('\n');
  const blocks = [];
  let i = 0;
  const listRe = /^( *)([-*]|\d+\.) +(.*)$/;
  while (i < lines.length) {
    const line = lines[i];
    if (!line.trim()) { i++; continue; }
    let m;
    if ((m = /^(#{1,6}) +(.*)$/.exec(line))) {
      blocks.push({ type: 'h', level: m[1].length, text: m[2].trim() });
      i++;
    } else if (/^ *```/.test(line)) {
      const body = [];
      for (i++; i < lines.length && !/^ *```/.test(lines[i]); i++) body.push(lines[i]);
      i++;
      blocks.push({ type: 'code', text: body.join('\n') });
    } else if (/^\|/.test(line) && /^\|[\s:|-]+\|?\s*$/.test(lines[i + 1] || '')) {
      const rows = [];
      for (; i < lines.length && /^\|/.test(lines[i]); i++) rows.push(lines[i]);
      const cells = rows.map(splitRow);
      blocks.push({ type: 'table', head: cells[0], rows: cells.slice(2) });
    } else if (listRe.test(line)) {
      const items = [];
      while (i < lines.length) {
        const l = lines[i];
        if (!l.trim()) {
          const next = lines.slice(i).find((x) => x.trim());
          if (next && listRe.test(next)) { i++; continue; }
          break;
        }
        const lm = listRe.exec(l);
        if (lm) {
          items.push({ indent: lm[1].length, ordered: /\d/.test(lm[2]), text: lm[3] });
        } else if (/^ +\S/.test(l) && items.length) {
          items[items.length - 1].text += joiner(items[items.length - 1].text, l.trim()) + l.trim();
        } else break;
        i++;
      }
      blocks.push({ type: 'list', tree: nest(items) });
    } else if (/^!\[[^\]]*\]\([^)]*\)\s*$/.test(line)) {
      const im = /^!\[([^\]]*)\]\(([^)]*)\)/.exec(line);
      blocks.push({ type: 'image', alt: im[1], src: im[2] });
      i++;
    } else {
      let text = line.trim();
      for (i++; i < lines.length && lines[i].trim() && !/^(#{1,6} |\||!\[| *```)/.test(lines[i]) && !listRe.test(lines[i]); i++) {
        text += joiner(text, lines[i].trim()) + lines[i].trim();
      }
      blocks.push({ type: 'p', text });
    }
  }
  return blocks;
}

function joiner(a, b) {
  return isCJK(a.slice(-1)) && isCJK(b[0]) ? '' : ' ';
}

function splitRow(row) {
  const cells = [];
  let cur = '';
  let code = false;
  const s = row.trim().replace(/^\|/, '').replace(/\|$/, '');
  for (let k = 0; k < s.length; k++) {
    const c = s[k];
    if (c === '\\' && s[k + 1] === '|') { cur += '|'; k++; continue; }
    if (c === '`') code = !code;
    if (c === '|' && !code) { cells.push(cur.trim()); cur = ''; continue; }
    cur += c;
  }
  cells.push(cur.trim());
  return cells;
}

function nest(items) {
  const top = { children: [] };
  const stack = [{ indent: -1, node: top }];
  for (const it of items) {
    while (stack.length > 1 && it.indent <= stack[stack.length - 1].indent) stack.pop();
    const node = { text: it.text, ordered: it.ordered, children: [] };
    stack[stack.length - 1].node.children.push(node);
    stack.push({ indent: it.indent, node });
  }
  return top.children;
}

// ---------- inline Markdown to BBCode ----------

function linkTarget(href, ctx) {
  if (/^https?:/.test(href)) return href;
  const [file, anchor] = href.split('#');
  const hash = anchor ? `#${anchor}` : '';
  const ch = /^(\d\d)-[^/]*\.md$/.exec(file);
  if (ch) {
    const lang = /\.zh-CN\.md$/.test(file) ? 'zh' : 'en';
    const steam = (steamIds[lang] || {})[String(Number(ch[1]))];
    return steam || `${blob}chapters/${file}${hash}`;
  }
  if (!file) return `${blob}chapters/${ctx.file}${hash}`;
  const rel = path.posix.normalize(path.posix.join('chapters', file));
  if (rel === 'README.md' || rel === 'README.zh-CN.md') return rel === 'README.md' ? repo : `${blob}${rel}`;
  return `${blob}${rel}${hash}`;
}

function inline(text, ctx) {
  // Code spans and links are set aside first, so bold and italics can span them.
  const held = [];
  const hold = (s) => `\u0000${held.push(s) - 1}\u0000`;
  text = text.replace(/`([^`]+)`/g, (all, code) => hold(literal(code)));
  text = text.replace(/\[([^\]]+)\]\(([^)\s]+)\)/g, (all, label, href) => hold(`[url=${linkTarget(href, ctx)}]${emph(label)}[/url]`));
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
      ctx.image(name);
      return [`[b]${T[ctx.lang].image(name)}[/b]\n[i]${inline(clean(b.alt), ctx)}[/i]`];
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
  const file = chapters[n][lang];
  const t = T[lang];
  let md = fs.readFileSync(path.join(chapterDir, file), 'utf8').replace(/\r/g, '');
  const report = [];

  for (const [from, to] of (edits.files[file] || [])) {
    const count = md.split(from).length - 1;
    if (count !== 1) report.push(`edit matches ${count} times: ${from.slice(0, 80)}`);
    else md = md.replace(from, () => to);
  }
  for (const [re, to] of edits.rules[lang]) md = md.replace(re, to);

  const blocks = parse(md);
  const title = blocks[0].text.replace(/^Chapter \d+ — /, (x) => x.replace(' — ', ': '));
  const sections = [];
  let current = null;
  let images = null;
  const ctx = { file, lang, image: (name) => images.push(name) };
  const open = (name) => {
    images = [];
    current = { title: name, parts: [], images };
    sections.push(current);
  };

  // The first section: who wrote it, the full version, the chapter's own introduction.
  open(t.about);
  const prev = chapters[n - 1] && chapters[n - 1][lang];
  const next = chapters[n + 1] && chapters[n + 1][lang];
  const chName = (k) => `[url=${linkTarget(chapters[k][lang], ctx)}]${lang === 'zh' ? `第 ${k} 章` : `chapter ${k}`}[/url]`;
  current.parts.push(`[b]${t.written}[/b]`, t.full(`${blob}chapters/${file}`), t.terms);
  const nav = t.nav(prev && chName(n - 1), next && chName(n + 1));
  if (nav) current.parts.push(nav);
  current.parts.push('[hr][/hr]');

  let skipping = false;
  for (const b of blocks.slice(1)) {
    if (b.type === 'p' && /^\[(中文版|English)\]\(/.test(b.text)) continue;
    if (b.type === 'h' && b.level === 2) {
      skipping = /How these facts were checked|这些(结论|事实)(是)?(怎么|怎样|如何)(核实|核对)/.test(b.text);
      if (!skipping) open(clean(b.text).replace(/\*\*/g, ''));
      continue;
    }
    if (skipping) continue;
    current.parts.push(...blockCode(b, ctx));
  }

  // Each section's parts into Steam sections of at most `limit` characters.
  const out = [];
  for (const s of sections) {
    let body = [];
    let k = 0;
    const flush = () => {
      out.push({ title: k ? `${s.title} ${t.cont}` : s.title, body: body.join('\n\n'), images: s.images });
      body = [];
      k++;
    };
    for (const p of s.parts) {
      if (body.length && size([...body, p].join('\n\n')) > limit) flush();
      body.push(p);
    }
    if (body.length) flush();
  }
  // Images go with the Steam section their marker landed in.
  for (const s of out) s.images = s.images.filter((name) => s.body.includes(T[lang].image(name)));

  for (const s of out) {
    if (size(s.body) > limit) report.push(`section "${s.title}" is ${size(s.body)} ${unit}`);
    s.body.split('\n').forEach((line) => {
      const hit = lintWords.exec(line.replace(/\[url=[^\]]*\]/g, ''));
      if (hit) {
        const at = hit.index;
        report.push(`[${s.title}] ${hit[0]}: …${line.slice(Math.max(0, at - 70), at + 50)}…`);
      }
    });
  }

  const intro = blocks.slice(1).find((b) => b.type === 'p' && !/^\[(中文版|English)\]/.test(b.text));
  let desc = intro ? clean(intro.text).replace(/\[([^\]]+)\]\([^)]*\)/g, '$1').replace(/[*`]/g, '') : '';
  // Whole sentences of the introduction, enough to say what the chapter covers.
  const sentences = lang === 'zh' ? desc.match(/[^。]+。?/g) || [] : desc.split(/(?<=\.)\s+(?=[A-Z])/);
  desc = '';
  for (const s of sentences) {
    if (desc.length >= (lang === 'zh' ? 60 : 150)) break;
    desc += (desc && lang === 'en' ? ' ' : '') + s;
  }
  return {
    n, file, report,
    title: `${t.series} · ${title}`,
    description: `${desc}${lang === 'en' ? ' ' : ''}${t.short}`.trim(),
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
