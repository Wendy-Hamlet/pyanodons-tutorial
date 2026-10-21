// Run in the Bilibili article editor page (member.bilibili.com/platform/upload/text/new-edit), from
// the browser console or a browser-automation tool, after tools/publish/bilibili.js has written a
// chapter. It adds a file input (#pt-upload) to the page:
// - given article.md, it imports it with the editor's own Markdown import (replacing the content);
// - given images, it puts each in place of its marker paragraph "【图片 name】caption" through
//   the editor's own image upload (the one used for dropped files), one after another, waiting
//   until Bilibili has stored each, and writes the caption into the image's caption field.
// ptBili.title(text) sets the title; await ptBili.settings() sets the publish settings (see there);
// await ptBili.cover() opens the cover upload and leaves its file input as #pt-cover (give it
// cover.jpg), ptBili.confirmCover() accepts the crop dialog; ptBili.state(), ptBili.log() and
// ptBili.markers() report; ptBili.relink(urls, n) fixes a published chapter's links to later ones.
// Nothing is saved or published by this script (the editor saves its draft by itself; 发布 or
// 提交文章 is clicked by hand or by the automation, after checking state()).
(() => {
  const frame = () => [...document.querySelectorAll('iframe')].find((f) => f.src.includes('read-editor'));
  const editor = () => frame().contentDocument.querySelector('.ProseMirror').editor;
  const wait = (ms) => new Promise((r) => setTimeout(r, ms));
  const log = [];
  const markerRe = /^【图片 ([^\s】]+)】(.*)$/;

  function markers() {
    const out = [];
    editor().state.doc.descendants((node, pos) => {
      const m = node.type.name === 'paragraph' && markerRe.exec(node.textContent.trim());
      if (m) out.push({ name: m[1], caption: m[2].trim(), pos });
    });
    return out;
  }

  function pending() {
    let n = 0;
    editor().state.doc.descendants((node) => {
      if (node.type.name === 'enhancedImage' && !node.attrs['data-url']) n++;
    });
    return n;
  }

  async function place(file) {
    const ed = editor();
    const at = markers().find((m) => m.name === file.name);
    if (!at) { log.push(`${file.name}: no marker`); return; }
    ed.chain().deleteRange({ from: at.pos, to: at.pos + ed.state.doc.nodeAt(at.pos).nodeSize }).run();
    const w = frame().contentWindow;
    const handler = ed.extensionManager.extensions.find((e) => e.name === 'fileHandler');
    handler.options.onDrop(ed, [new w.File([file], file.name, { type: file.type })], at.pos);
    for (let k = 0; k < 120 && (k < 2 || pending()); k++) await wait(500);
    const node = ed.state.doc.nodeAt(at.pos);
    if (at.caption && node && node.type.name === 'enhancedImage') {
      ed.view.dispatch(ed.state.tr.setNodeMarkup(at.pos, null, { ...node.attrs, caption: at.caption }));
    }
    log.push(`${file.name}: ${pending() ? 'still uploading' : 'uploaded'}${at.caption ? (node && node.type.name === 'enhancedImage' ? ', caption set' : ', caption NOT set') : ''}`);
  }

  async function take(files) {
    const list = [...files];
    for (const f of list.filter((x) => x.name.endsWith('.md'))) {
      const ok = editor().commands.importMarkdown({ content: await f.text() });
      await wait(1000);
      log.push(`${f.name}: ${ok ? 'imported' : 'import failed'}, ${markers().length} markers`);
    }
    // Images in the order of their markers, so each upload lands before the next is placed.
    const order = markers().map((m) => m.name);
    const images = list.filter((x) => !x.name.endsWith('.md')).sort((a, b) => order.indexOf(a.name) - order.indexOf(b.name));
    for (const f of images) await place(f);
    if (images.length) tidy();
  }

  // The upload leaves an empty paragraph after each image: remove those.
  function tidy() {
    const ed = editor();
    const ranges = [];
    let prev = null;
    ed.state.doc.forEach((node, offset) => {
      if (node.type.name === 'paragraph' && !node.textContent && prev === 'enhancedImage') ranges.push([offset, offset + node.nodeSize]);
      prev = node.type.name;
    });
    let tr = ed.state.tr;
    for (const [a, b] of ranges.reverse()) tr = tr.delete(a, b);
    ed.view.dispatch(tr);
    log.push(`removed ${ranges.length} empty paragraphs after images`);
  }

  let input = document.getElementById('pt-upload');
  if (!input) {
    input = document.createElement('input');
    input.type = 'file';
    input.multiple = true;
    input.id = 'pt-upload';
    input.setAttribute('aria-label', 'pt-upload file input');
    input.style.cssText = 'position:fixed;left:0;top:0;width:1px;height:1px;opacity:0';
    document.body.appendChild(input);
  }
  input.onchange = async () => {
    await take(input.files);
    input.value = '';
  };

  // The cover: the "本地上传" choice opens a file picker through a new file input's click(). That
  // click is caught and the input moved here as #pt-cover, to be given cover.jpg; then
  // confirmCover() accepts the crop dialog (cover.jpg is already 16:9).
  async function cover() {
    const w = frame().contentWindow;
    const d = frame().contentDocument;
    if (!w.ptCaught) {
      const click = w.HTMLInputElement.prototype.click;
      w.HTMLInputElement.prototype.click = function () {
        if (this.type !== 'file') return click.call(this);
        const old = document.getElementById('pt-cover');
        if (old) old.remove();
        this.id = 'pt-cover';
        this.setAttribute('aria-label', 'pt-cover file input');
        this.style.cssText = 'position:fixed;left:0;top:0;width:1px;height:1px;opacity:0';
        document.body.appendChild(this);
        return undefined;
      };
      w.ptCaught = true;
    }
    const button = [...d.querySelectorAll('.upload-text')].find((e) => e.textContent.trim() === '添加封面');
    if (!button) return 'no 添加封面 button (a cover is set already?)';
    button.parentElement.click();
    await wait(500);
    const local = [...d.querySelectorAll('.select-option')].find((e) => e.textContent.trim() === '本地上传');
    local.click();
    await wait(500);
    return document.getElementById('pt-cover') ? 'give #pt-cover the cover' : 'no file input caught';
  }

  function confirmCover() {
    const ok = [...frame().contentDocument.querySelectorAll('button, .vui_button')].filter((b) => b.offsetParent && b.textContent.trim() === '确定');
    if (ok.length !== 1) return `found ${ok.length} 确定 buttons`;
    ok[0].click();
    return 'cover confirmed';
  }

  function title(text) {
    const box = frame().contentDocument.querySelector('.title-input__inner');
    const setter = Object.getOwnPropertyDescriptor(frame().contentWindow.HTMLTextAreaElement.prototype, 'value').set;
    setter.call(box, text);
    box.dispatchEvent(new Event('input', { bubbles: true }));
    return box.value;
  }

  // The publish settings the author chose for every chapter: visible to all, custom cover on,
  // comments on, original declared, the AI declaration NOT ticked, and the series collection.
  // Run it before cover() (the cover button only shows with the custom cover on).
  const item = (label) => [...frame().contentDocument.querySelectorAll('.form-item-label')].find((l) => l.textContent.trim() === label).parentElement;
  const switchOf = (label) => item(label).querySelector('.vui_switch--switch');
  const boxOf = (text) => [...item('创作声明').querySelectorAll('.vui_checkbox')].find((b) => b.textContent.includes(text));
  const visibleToAll = () => [...item('可见范围').querySelectorAll('.vui_radio')].find((r) => r.textContent.includes('所有人可见'));

  async function settings(collection = 'Pyanodons 循序渐进') {
    const d = frame().contentDocument;
    if (!visibleToAll().classList.contains('vui_radio--checked')) visibleToAll().click();
    for (const [label, on] of [['自定义封面', true], ['评论开关', true]]) {
      if (switchOf(label).classList.contains('is-checked') !== on) switchOf(label).click();
    }
    for (const [text, on] of [['声明此文章为原创', true], ['AI辅助创作声明', false]]) {
      if (boxOf(text).querySelector('input').checked !== on) boxOf(text).querySelector('input').click();
    }
    if (!item('文集').textContent.includes(collection)) {
      d.querySelector('.collection-button').click();
      await wait(800);
      const dialog = d.querySelector('.collection-dialog');
      const choice = [...dialog.querySelectorAll('.collection-item')].find((c) => c.textContent.trim() === collection);
      if (!choice) return `no collection "${collection}"`;
      choice.click();
      await wait(300);
      [...dialog.querySelectorAll('.collection-action button')].find((b) => b.textContent.trim() === '确定').click();
      await wait(500);
    }
    return state();
  }

  // What the settings are now, to check before publishing.
  function state() {
    return {
      visibleToAll: visibleToAll().classList.contains('vui_radio--checked'),
      customCover: switchOf('自定义封面').classList.contains('is-checked'),
      coverSet: !item('自定义封面').textContent.includes('添加封面'),
      comments: switchOf('评论开关').classList.contains('is-checked'),
      scheduled: switchOf('定时发布').classList.contains('is-checked'),
      original: boxOf('声明此文章为原创').querySelector('input').checked,
      aiDeclared: boxOf('AI辅助创作声明').querySelector('input').checked,
      collection: item('文集').textContent.trim(),
      title: frame().contentDocument.querySelector('.title-input__inner').value,
      markersLeft: markers().length,
      uploading: pending(),
    };
  }

  // In a published chapter opened for editing (new-edit?aid=<rid>&type=3): point its links to
  // other chapters on GitHub at their Bilibili copies. urls is bilibili-articles.json's "zh"
  // ({"2": "https://www.bilibili.com/opus/..."}), own the chapter's number (its "本章" link to the
  // full version stays). Bilibili allows 3 edits per article, so do it once, after every chapter
  // it links to is out.
  function relink(urls, own) {
    const ed = editor();
    let tr = ed.state.tr;
    const changed = [];
    ed.state.doc.descendants((node, pos) => {
      if (node.type.name !== 'link') return;
      const m = /\/chapters\/(\d\d)-[^/#]*\.md(#.*)?$/.exec(node.attrs.href || '');
      const n = m && Number(m[1]);
      if (!m || n === own || !urls[n]) return;
      tr = tr.setNodeMarkup(pos, null, { ...node.attrs, href: urls[n] });
      changed.push(`${node.attrs.text} -> ${n}`);
    });
    ed.view.dispatch(tr);
    return changed;
  }

  window.ptBili = { log: () => log.slice(), markers, pending, title, cover, confirmCover, settings, state, relink };
  return 'ptBili ready';
})();
