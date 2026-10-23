// Shared by the publishing scripts (steam.js, bilibili.js): the chapter files, the edits that keep
// the tutorial only (edits.js), a small Markdown block parser for the subset the chapters use,
// links resolved to GitHub, and the note every published version opens with.

const fs = require('fs');
const path = require('path');
const edits = require('./edits');

const root = path.join(__dirname, '..', '..');
const repo = 'https://github.com/Wendy-Hamlet/pyanodons-tutorial';
const blob = `${repo}/blob/master/`;

// The chapter files, by number and language.
const chapterDir = path.join(root, 'chapters');
const chapters = {};
for (const f of fs.readdirSync(chapterDir).sort()) {
  const m = /^(\d\d)-.*?(\.zh-CN)?\.md$/.exec(f);
  if (!m) continue;
  const n = Number(m[1]);
  (chapters[n] = chapters[n] || {})[m[2] ? 'zh' : 'en'] = f;
}

// What every published version says about itself (body text, no markup).
const T = {
  en: {
    series: 'Pyanodons, step by step',
    written: 'This guide was written by Claude, Anthropic\'s AI, from my saves and my game\'s logs, which it read with tools; "the author" in the text is me. I have read all of it, but I cannot promise it is free of mistakes.',
    full: 'The full version, with the source of every number, the tools and how each fact was checked, is on GitHub:',
    thisChapter: 'this chapter',
    blueprints: 'All the blueprints:',
    blueprintsLink: 'blueprints',
    blueprintsFile: 'blueprints/README.md',
    terms: '"Measured" means run in a copy of my save; "on a test map" means the blueprint built alone on an empty map with unlimited inputs.',
    short: 'Written by Claude (AI) from my saves; I have read it all, but it may still contain mistakes.',
    chapter: (k) => `chapter ${k}`,
    prev: 'Previous:',
    next: 'Next:',
  },
  zh: {
    series: 'Pyanodons 循序渐进',
    written: '本指南由 Claude（Anthropic 的人工智能）用工具读取我的存档和游戏记录后撰写，文中的“作者”就是我。我通读过全部内容，但仍不能保证没有错误。',
    full: '完整版（每个数字的来源、所用工具和核实方法）在 GitHub：',
    thisChapter: '本章',
    blueprints: '全部蓝图：',
    blueprintsLink: '蓝图',
    blueprintsFile: 'blueprints/README.zh-CN.md',
    terms: '文中“实测”指在我存档的副本里运行；“测试地图”指把蓝图单独建在空地图上、输入不限量地运行。',
    short: '由 Claude（人工智能）读取我的存档后撰写；我已通读，但仍可能有错误。',
    chapter: (k) => `第 ${k} 章`,
    prev: '上一章：',
    next: '下一章：',
  },
};

const isCJK = (c) => /[　-〿㐀-鿿＀-￯]/.test(c || '');

// ---------- cleaning: what the published versions leave out ----------

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

function lint(text, where, report) {
  text.split('\n').forEach((line) => {
    const hit = lintWords.exec(line.replace(/\[url=[^\]]*\]|\]\([^)]*\)/g, ''));
    if (hit) report.push(`[${where}] ${hit[0]}: …${line.slice(Math.max(0, hit.index - 70), hit.index + 50)}…`);
  });
}

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
      let inner = null;
      while (i < lines.length) {
        const l = lines[i];
        if (!l.trim()) {
          const k = lines.findIndex((x, at) => at > i && x.trim());
          const next = k < 0 ? null : lines[k];
          if (next && listRe.test(next)) { i++; continue; }
          // An indented block after a blank line (a table or a paragraph inside the last item):
          // the list ends here and the block follows it, out of the list (neither site nests
          // tables in list items).
          if (next && /^ {2,}\S/.test(next)) {
            let j = k;
            while (j < lines.length && (!lines[j].trim() || /^ {2,}\S/.test(lines[j]))) j++;
            inner = parse(lines.slice(k, j).map((x) => x.replace(/^ {2,}/, '')).join('\n'));
            i = j;
          }
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
      if (inner) blocks.push(...inner);
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

// Two wrapped lines join without a space between Chinese characters, or next to Chinese
// (full-width) punctuation; otherwise with one.
const isCJKPunct = (c) => /[　-〿＀-￯“”‘’]/.test(c || '');
function joiner(a, b) {
  const x = a.slice(-1), y = b[0];
  return (isCJK(x) && isCJK(y)) || isCJKPunct(x) || isCJKPunct(y) ? '' : ' ';
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

// ---------- links ----------

// A chapter's relative link as an absolute one. `ids` maps chapters to their published copies,
// {"en": {"2": "<url>"}, "zh": {...}}; chapters not in it link to GitHub.
function linkTarget(href, file, ids = {}) {
  if (/^https?:/.test(href)) return href;
  const [target, anchor] = href.split('#');
  const hash = anchor ? `#${anchor}` : '';
  const ch = /^(\d\d)-[^/]*\.md$/.exec(target);
  if (ch) {
    const lang = /\.zh-CN\.md$/.test(target) ? 'zh' : 'en';
    return (ids[lang] || {})[String(Number(ch[1]))] || `${blob}chapters/${target}${hash}`;
  }
  if (!target) return `${blob}chapters/${file}${hash}`;
  const rel = path.posix.normalize(path.posix.join('chapters', target));
  if (rel === 'README.md') return repo;
  return `${blob}${rel}${hash}`;
}

// ---------- one chapter ----------

const isNav = (b) => b.type === 'p' && /^\[(中文版|English)\]\(/.test(b.text);
const isChecked = (text) => /How these facts were checked|这些(结论|事实)(是)?(怎么|怎样|如何)(核实|核对)/.test(text);

// The chapter with the edits applied, as blocks: { file, title, blocks (without the title, the
// navigation line and the "How these facts were checked" section), description, report }.
function chapter(n, lang) {
  const file = chapters[n][lang];
  let md = fs.readFileSync(path.join(chapterDir, file), 'utf8').replace(/\r/g, '');
  const report = [];
  for (const [from, to] of (edits.files[file] || [])) {
    const count = md.split(from).length - 1;
    if (count !== 1) report.push(`edit matches ${count} times: ${from.slice(0, 80)}`);
    else md = md.replace(from, () => to);
  }
  for (const [re, to] of edits.rules[lang]) md = md.replace(re, to);

  const all = parse(md);
  const title = all[0].text.replace(/^Chapter \d+ — /, (x) => x.replace(' — ', ': '));
  const blocks = [];
  let skipping = false;
  for (const b of all.slice(1)) {
    if (isNav(b)) continue;
    if (b.type === 'h' && b.level === 2) skipping = isChecked(b.text);
    if (!skipping) blocks.push(b);
  }

  // Whole sentences of the introduction, enough to say what the chapter covers.
  const intro = blocks.find((b) => b.type === 'p');
  const text = intro ? clean(intro.text).replace(/\[([^\]]+)\]\([^)]*\)/g, '$1').replace(/[*`]/g, '') : '';
  const sentences = lang === 'zh' ? text.match(/[^。]+。?/g) || [] : text.split(/(?<=\.)\s+(?=[A-Z])/);
  let description = '';
  for (const s of sentences) {
    if (description.length >= (lang === 'zh' ? 60 : 150)) break;
    description += (description && lang === 'en' ? ' ' : '') + s;
  }
  return { n, file, lang, title, blocks, description, report };
}

module.exports = { root, repo, blob, chapters, T, isCJK, clean, lint, parse, linkTarget, chapter };
