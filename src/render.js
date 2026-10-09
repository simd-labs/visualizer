import { buildModel } from './model.js';

const drop = document.getElementById('drop');
const file = document.getElementById('file');
const err = document.getElementById('error');
const out = document.getElementById('out');
const notice = document.getElementById('notice');

let loadGen = 0;

async function load(f) {
  const gen = ++loadGen;
  try {
    const model = buildModel(JSON.parse(await f.text()));
    if (gen !== loadGen) return; // a newer load is in flight; discard this one
    notice.hidden = model.complete;
    if (!model.complete) {
      const cap = model.cycleCut
        ? "llvm-mca's cycle cap (-timeline-max-cycles, default 80) cut the timeline. Rerun with a higher value, or 0 for no cycle limit."
        : "llvm-mca's iteration cap (-timeline-max-iterations, default 10) or cycle cap (-timeline-max-cycles, default 80) cut the timeline. The file does not say which. Rerun with higher values, or 0 for no cycle limit.";
      notice.textContent = `Showing ${model.iters} of ${model.total} iterations. ${cap}`;
    }
    err.hidden = true;
    out.hidden = false;
    renderTimeline(model, document.getElementById('timeline'));
    renderHeatmap(model, document.getElementById('heatmap'));
    renderTables(model);
  } catch (e) {
    if (gen !== loadGen) return;
    err.textContent = String(e);
    err.hidden = false;
    out.hidden = true;
  }
}

file.addEventListener('change', () => file.files[0] && load(file.files[0]));
drop.addEventListener('dragover', (e) => e.preventDefault());
drop.addEventListener('drop', (e) => {
  e.preventDefault();
  e.dataTransfer.files[0] && load(e.dataTransfer.files[0]);
});

const CELL = 10;
const LEFT = 200; // timeline gutter for the [iter,instr] labels
const TOP = 16; // timeline space for cycle labels
const HEAD = 60; // heatmap space for rotated resource names
// Adjacent stages touch. Each neighbour pair and each stage against white is >= 3:1 (page.spec.mjs measures the rendered rects).
const STAGES = { wait: '#b45309', ready: '#1e1b4b', exec: '#15803d', done: '#0f172a' };

const legend = document.getElementById('legend');
for (const [stage, color] of Object.entries(STAGES)) {
  const swatch = document.createElement('i');
  swatch.style.background = color;
  const item = document.createElement('span');
  item.append(swatch, stage);
  legend.append(item);
}

function svg(tag, attrs) {
  const el = document.createElementNS('http://www.w3.org/2000/svg', tag);
  for (const [k, v] of Object.entries(attrs)) el.setAttribute(k, v);
  return el;
}

// llvm-mca's "Zn4FP45.\x00" names print as "Zn4FP45.0", the text output's form
const label = (name) => name.replace(/[\u0000-\u001f]/g, (c) => c.charCodeAt(0));
const rowName = (model, i) => (i === model.instructions.length ? 'total/iter' : model.instructions[i]);

function renderTimeline(model, host) {
  host.textContent = '';
  if (model.rows.length === 0) {
    host.textContent = 'No instruction retired within the cycle cap, so there is no timeline to draw. Raise -timeline-max-cycles.';
    return;
  }
  const maxCycle = Math.max(...model.rows.map((r) => r.retired));
  const w = (maxCycle + 1) * CELL;
  const h = model.rows.length * CELL;
  const root = svg('svg', { width: LEFT + w + 20, height: TOP + h + 4, 'aria-hidden': 'true' });

  for (let c = 0; c <= maxCycle; c += 5) {
    const x = LEFT + c * CELL;
    root.appendChild(svg('line', { class: 'grid', x1: x, x2: x, y1: TOP, y2: TOP + h, stroke: '#cbd5e1' }));
    const t = svg('text', { class: 'axis', x: x + 2, y: 11, 'font-size': 9 });
    t.textContent = c;
    root.appendChild(t);
  }

  for (const r of model.rows) {
    const y = TOP + (r.iter * model.instructions.length + r.instr) * CELL;
    const spans = [
      [r.dispatched, r.ready, 'wait'],
      [r.ready, r.issued, 'ready'],
      [r.issued, r.executed, 'exec'],
      [r.executed, r.retired, 'done'],
    ];
    for (const [a, b, stage] of spans) {
      if (b <= a) continue;
      const rect = svg('rect', { x: LEFT + a * CELL, y, width: (b - a) * CELL, height: CELL - 1, fill: STAGES[stage] });
      rect.appendChild(svg('title', {})).textContent =
        `${model.instructions[r.instr]}\niter ${r.iter}, ${stage}: cycles ${a}-${b}`;
      root.appendChild(rect);
    }
    const text = svg('text', { class: 'row', x: 4, y: y + CELL - 2, 'font-size': 9 });
    text.textContent = `[${r.iter},${r.instr}]`;
    root.appendChild(text);
  }
  host.appendChild(root);
}

function renderHeatmap(model, host) {
  host.textContent = '';
  const max = Math.max(...model.matrix.flat());
  const names = model.resources.map(label);
  const root = svg('svg', {
    width: names.length * CELL + 200,
    height: model.matrix.length * CELL + HEAD,
    'aria-hidden': 'true',
  });
  model.matrix.forEach((row, i) => {
    row.forEach((v, j) => {
      if (v === 0) return;
      // floor of 0.7 opacity keeps the palest cell at 3:1 against white
      const opacity = 0.7 + 0.3 * (v / max);
      const rect = svg('rect', {
        x: 100 + j * CELL,
        y: HEAD + i * CELL,
        width: CELL - 1,
        height: CELL - 1,
        fill: '#1d4ed8',
        opacity,
        'data-cy': `${i},${j}`,
      });
      rect.appendChild(svg('title', {})).textContent = `${rowName(model, i)}, ${names[j]}: ${v.toFixed(2)}`;
      root.appendChild(rect);
    });
    const rowLabel = svg('text', { class: 'rowlabel', x: 4, y: HEAD + i * CELL + CELL - 2, 'font-size': 9 });
    rowLabel.textContent = i === model.instructions.length ? 'total/iter' : `instr ${i}`;
    root.appendChild(rowLabel);
  });
  names.forEach((name, j) => {
    // rotated glyphs grow left of the baseline, so move the baseline right to centre them on the column
    const x = 100 + j * CELL + CELL - 2;
    const c = svg('text', { class: 'col', x, y: HEAD - 4, 'font-size': 9, transform: `rotate(-90 ${x} ${HEAD - 4})` });
    c.textContent = name;
    root.appendChild(c);
  });
  host.appendChild(root);
}

// The same numbers as text, for keyboard and screen reader users.
function table(host, head, body) {
  host.textContent = '';
  const t = document.createElement('table');
  const addRow = (cells, header, firstIsRowHeader) => {
    const tr = t.insertRow();
    cells.forEach((text, i) => {
      const cell = document.createElement(i === 0 && firstIsRowHeader ? 'th' : header);
      if (cell.tagName === 'TH') cell.scope = firstIsRowHeader && i === 0 ? 'row' : 'col';
      cell.textContent = text;
      tr.append(cell);
    });
  };
  addRow(head, 'th', false);
  body.forEach((cells) => addRow(cells, 'td', true));
  host.append(t);
}

function renderTables(model) {
  table(
    document.getElementById('timeline-table'),
    ['Iteration', 'Instr', 'Asm', 'Dispatched', 'Ready', 'Issued', 'Executed', 'Retired'],
    model.rows.map((r) => [r.iter, r.instr, model.instructions[r.instr], r.dispatched, r.ready, r.issued, r.executed, r.retired])
  );
  table(
    document.getElementById('heatmap-table'),
    ['Instruction', ...model.resources.map(label)],
    model.matrix.map((row, i) => [rowName(model, i), ...row.map((v) => v.toFixed(2))])
  );
}
