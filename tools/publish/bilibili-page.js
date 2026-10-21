// Run in the Bilibili article editor page (member.bilibili.com/platform/upload/text/new-edit), from
// the browser console or a browser-automation tool, after tools/publish/bilibili.js has written a
// chapter. It adds a file input (#pt-upload) to the page:
// - given article.md, it imports it with the editor's own Markdown import (replacing the content);
// - given images, it puts each in place of its marker paragraph "【图片 name】" through the
//   editor's own image upload (the one used for dropped files), one after another, waiting until
//   Bilibili has stored each.
// ptBili.title(text) sets the title; ptBili.log() and ptBili.markers() report. Nothing is saved
// or published by this script (the editor saves its draft by itself).
(() => {
  const frame = () => [...document.querySelectorAll('iframe')].find((f) => f.src.includes('read-editor'));
  const editor = () => frame().contentDocument.querySelector('.ProseMirror').editor;
  const wait = (ms) => new Promise((r) => setTimeout(r, ms));
  const log = [];
  const markerRe = /^【图片 (\S+)】$/;

  function markers() {
    const out = [];
    editor().state.doc.descendants((node, pos) => {
      const m = node.type.name === 'paragraph' && markerRe.exec(node.textContent.trim());
      if (m) out.push({ name: m[1], pos });
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
    log.push(`${file.name}: ${pending() ? 'still uploading' : 'uploaded'}`);
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

  function title(text) {
    const box = frame().contentDocument.querySelector('.title-input__inner');
    const setter = Object.getOwnPropertyDescriptor(frame().contentWindow.HTMLTextAreaElement.prototype, 'value').set;
    setter.call(box, text);
    box.dispatchEvent(new Event('input', { bubbles: true }));
    return box.value;
  }

  window.ptBili = { log: () => log.slice(), markers, pending, title };
  return 'ptBili ready';
})();
