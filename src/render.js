import { buildModel, tokenPositionsAt, instanceLabel, attachSourceLines, schedulerSlots, unitGroup } from './model.js';
import { initMca, runMca } from './mca.js';
import { lookup } from './unit-names.js';
import { EXAMPLES, exampleFor } from './examples.js';

const file = document.getElementById('file');
const err = document.getElementById('error');
const out = document.getElementById('out');
const notice = document.getElementById('notice');
const noticeMore = document.getElementById('notice-more');
const asm = document.getElementById('asm');
const gutter = document.getElementById('asm-gutter');
const asmCaption = document.getElementById('asm-caption');

// Line numbers left of the editor: one number per line, scrolling with the
// textarea. wrap is off, so line k of the numbers sits on line k of the text.
function refreshGutter() {
  const n = asm.value.split('\n').length;
  const cur = gutter.childElementCount;
  if (cur !== n) {
    gutter.textContent = '';
    for (let i = 1; i <= n; i++) {
      const d = document.createElement('div');
      d.textContent = i;
      d.dataset.line = i;
      gutter.appendChild(d);
    }
  }
  gutter.scrollTop = asm.scrollTop;
}
function highlightLine(line) {
  for (const el of gutter.querySelectorAll('.hl')) el.classList.remove('hl');
  if (line != null) gutter.children[line - 1]?.classList.add('hl');
}
asm.addEventListener('input', refreshGutter);
asm.addEventListener('scroll', () => (gutter.scrollTop = asm.scrollTop));
const cpu = document.getElementById('cpu');
const iterations = document.getElementById('iterations');
const runBtn = document.getElementById('run');
const empty = document.getElementById('empty');
const emptyLabel = document.getElementById('empty-label');
const themeBtn = document.getElementById('theme-toggle');
let shownModel = null;
let noticeBase = ''; // the timeline note's fixed part; renderTimeline appends the visible range
// the default CPU is znver4, so the box starts with the x86 example; the user presses Run
asm.value = EXAMPLES.x86_64;
refreshGutter();

// The caption names the example while the box holds one, unedited. A file
// load is the user's own asm, so only direct edits and file loads hide it.
function refreshAsmCaption() {
  const isExample = Object.values(EXAMPLES).includes(asm.value);
  asmCaption.hidden = !isExample;
  if (isExample) asmCaption.textContent = `Example loop for ${cpu.value || 'the selected CPU'}. Edit it or paste your own.`;
}

// Every load/run claims the generation counter synchronously, before its
// first await; every result, error and finally does nothing when stale.
let loadGen = 0;
let runBusy = false;
let mcaReady = false;
let mcaFailed = false;
let cpusReady = false;
let pendingAsmRun = false;

function showError(e) {
  let text = String(e);
  if (/invalid region end directive/.test(text)) {
    // clang copies '# LLVM-MCA-END' into every return path, so the asm has several
    text += "\nCause: clang copied the '# LLVM-MCA-END' marker into each return path. Keep one END marker, or remove the markers.";
  }
  err.textContent = text;
  err.hidden = false;
  out.hidden = true;
}

// One label per state, so the button and the "press Run" hint always agree:
// Loading llvm-mca... (with progress), Run, Running..., llvm-mca failed to load.
let loadProgress = 'Loading llvm-mca...';
function refreshRunBtn() {
  // Run stays disabled until the WASM module, the CPU list and a selection
  // all exist, and while a run is in flight.
  runBtn.disabled = runBusy || !mcaReady || !cpusReady || !cpu.selectedOptions[0] || mcaFailed;
  if (mcaFailed) runBtn.textContent = 'llvm-mca failed to load';
  else if (runBusy) runBtn.textContent = 'Running...';
  else if (!mcaReady) runBtn.textContent = loadProgress;
  else runBtn.textContent = 'Run';
  // the card mirrors the button: no "press Run" while Run is disabled
  if (mcaFailed) emptyLabel.textContent = 'llvm-mca failed to load. Drop a .s or llvm-mca JSON file on the page instead.';
  else if (!mcaReady) emptyLabel.textContent = 'Paste an assembly loop or drop a .s file; Run starts once llvm-mca is ready.';
  else emptyLabel.textContent = 'Paste an assembly loop and press Run, or drop a .s or llvm-mca JSON file on the page.';
}
refreshRunBtn(); // the loading state must be right before the first progress tick

// A .s file arrived (drop, pick, or Run click): fill the box and run it,
// queueing the run while the WASM module is still loading. A newer file or
// edit replaces the queued run.
function requestAsm() {
  if (mcaReady) runAsm();
  else if (!mcaFailed) pendingAsmRun = true;
}

// The model plus the vendor-style name of each resource, for the CPU in the file.
// `source` is the asm text a run came from; a JSON drop passes nothing, so
// its labels stay iteration:mnemonic.
function modelOf(json, source) {
  const model = buildModel(json);
  model.units = model.resources.map((r) => lookup(json.TargetInfo.CPUName, r));
  attachSourceLines(model, source);
  return model;
}

async function loadText(text) {
  const gen = ++loadGen;
  pendingAsmRun = false;
  try {
    const model = modelOf(JSON.parse(text));
    if (gen !== loadGen) return;
    show(model);
  } catch (e) {
    if (gen !== loadGen) return;
    showError(e);
  }
}

function show(model) {
  notice.hidden = model.complete;
  noticeMore.hidden = model.complete;
  if (!model.complete) {
    const cap = model.cycleCut
      ? "llvm-mca's cycle cap (default 80) cut the timeline. The page always asks llvm-mca for every iteration and cycle; a cut like this comes from a JSON file produced with lower limits."
      : "llvm-mca's iteration cap (default 10) or cycle cap (default 80) cut the timeline. The file does not say which. The page always asks for every iteration and cycle; a cut like this comes from a JSON file produced with lower limits.";
    const range = model.iters === 0 ? 'no iterations' : `iterations 0-${model.iters - 1}`;
    noticeBase = `Showing ${range} of ${model.total}. Rows past the box: scroll it.`;
    notice.textContent = noticeBase;
    // the cap details sit collapsed so the chart stays near its heading; a
    // scrollbar-covered chart box keeps the rest of the iteration:mnemonic:line rows reachable
    noticeMore.replaceChildren(
      noticeMore.firstElementChild,
      cap + " The rest are not in the data. Rows past the box's height are still reachable: the chart box has a scrollbar, scroll it for the later iteration:mnemonic:line rows."
    );
  }
  err.hidden = true;
  empty.hidden = true;
  out.hidden = false;
  shownModel = model;
  readPalette();
  // draw after unhiding: the timeline sizes its columns from the box's laid-out width
  renderTimeline(model, document.getElementById('timeline'));
  renderHeatmap(model, document.getElementById('heatmap'));
  renderFlow(model);
  renderTables(model);
}

async function runAsm() {
  const gen = ++loadGen;
  runBusy = true;
  refreshRunBtn();
  try {
    if (asm.value.trim() === '') throw new Error('Paste assembly or drop a .s file first');
    const sel = cpu.selectedOptions[0];
    if (!sel) throw new Error('Pick a CPU first');
    const iters = Math.round(Number(iterations.value));
    const min = +iterations.min;
    const max = +iterations.max;
    if (!Number.isInteger(iters) || iters < min || iters > max) {
      throw new Error(`Iterations must be an integer between ${min} and ${max}`);
    }
    const args = [
      '-mtriple=' + sel.dataset.triple,
      '-mcpu=' + sel.value,
      '-iterations=' + iters,
      '-timeline',
      '-json',
      '-issue-events',
    ];
    out.hidden = true;
    const r = await runMca(asm.value, args);
    if (gen !== loadGen) return;
    if (r.exit !== 0 || r.stdout === '') throw new Error(r.stderr.trim() || `llvm-mca exited with ${r.exit}`);
    show(modelOf(JSON.parse(r.stdout), asm.value));
  } catch (e) {
    if (gen !== loadGen) return;
    showError(e);
  } finally {
    // only the run still owning the busy state may clear it
    if (gen === loadGen) {
      runBusy = false;
      refreshRunBtn();
    }
  }
}

// Route a file by its full text: a trimmed document starting with '{' is
// llvm-mca -json output (leading whitespace or a BOM is fine), everything
// else is assembly.
async function loadSource(f) {
  const gen = ++loadGen;
  const text = await f.text();
  if (gen !== loadGen) return; // a newer input claimed the generation while we read
  if (text.replace(/^\ufeff/, '').trimStart().startsWith('{')) {
    loadText(text);
    return;
  }
  asm.value = text;
  refreshGutter();
  refreshAsmCaption();
  requestAsm();
}

file.addEventListener('change', () => file.files[0] && loadSource(file.files[0]));
// a file dropped anywhere on the page loads; text drags (e.g. inside the editor) keep their default
const hasFiles = (e) => e.dataTransfer?.types.includes('Files');
document.addEventListener('dragover', (e) => hasFiles(e) && e.preventDefault());
document.addEventListener('drop', (e) => {
  if (!hasFiles(e)) return;
  e.preventDefault();
  e.dataTransfer.files[0] && loadSource(e.dataTransfer.files[0]);
});
runBtn.addEventListener('click', () => requestAsm());
// the selected CPU's example; before cpus.json loads, the default znver4's
const selectedExample = () => exampleFor(cpu.selectedOptions[0]?.dataset.triple ?? 'x86_64');
document.getElementById('example').addEventListener('click', () => {
  asm.value = selectedExample();
  refreshGutter();
  refreshAsmCaption();
  requestAsm();
});
// A CPU change swaps in its architecture's example, unless the box holds the user's own asm.
cpu.addEventListener('change', () => {
  if (asm.value.trim() === '' || Object.values(EXAMPLES).includes(asm.value)) asm.value = selectedExample();
  refreshGutter();
  refreshAsmCaption();
});
asm.addEventListener('input', () => {
  // an edit replaces any queued run of a file dropped while loading
  pendingAsmRun = false;
  refreshAsmCaption();
});

// The CPU list is static: cpus.json is regenerated by wasm/cpus.mjs from
// llvm-mca's scheduling models.
fetch('cpus.json')
  .then((r) => {
    if (!r.ok) throw new Error(`HTTP ${r.status} fetching cpus.json`);
    return r.json();
  })
  .then((cpus) => {
    for (const [triple, names] of Object.entries(cpus)) {
      const group = document.createElement('optgroup');
      group.label = triple.split('-')[0]; // the architecture: x86_64, aarch64, riscv64
      for (const name of names) {
        const opt = document.createElement('option');
        opt.value = name;
        opt.textContent = name;
        opt.dataset.triple = triple;
        group.append(opt);
      }
      cpu.append(group);
    }
    cpu.value = 'znver4';
  })
  .catch((e) => showError(e))
  .finally(() => {
    cpusReady = true;
    refreshRunBtn();
    refreshAsmCaption();
  });

initMca({
  onProgress(got, total) {
    const mb = (n) => (n / (1 << 20)).toFixed(1) + ' MB';
    const p = total ? `Loading llvm-mca... ${mb(got)} of ${mb(total)}` : `Loading llvm-mca... ${mb(got)}`;
    loadProgress = p;
    if (!runBusy && !mcaReady) runBtn.textContent = p;
  },
  onReady() {
    mcaReady = true;
    refreshRunBtn();
    if (pendingAsmRun) {
      pendingAsmRun = false;
      runAsm();
    }
  },
  onLoadError(message) {
    mcaFailed = true;
    pendingAsmRun = false;
    refreshRunBtn();
    showError(message);
  },
});

const CELL = 14; // timeline cycle width and row height: holds a 13px label and a 13px bar
// Shrinking a cycle column below the 12px label is unreadable, so the fit
// floors at 12px; a run wider than the box at 12px scrolls inside the box.
const CELL_MIN = 12;
let timelineCell = CELL; // the drawn run's horizontal px per cycle (renderTimeline)
const CELL_H = 13; // heatmap row height: a cell holds its 11px value below the 90px head
const HCELL = 32; // heatmap cell: wide enough to print the pressure value inside
const VGAP = 1; // heatmap vertical gap; horizontal cells are joined
const LEFT = 200; // timeline gutter for the iteration:mnemonic:line row labels
const TOP = 16; // timeline space for cycle labels
const HEAD = 90; // heatmap space for rotated resource names
const FONT = 13; // timeline and heatmap label size
const UNIT_COL = 100; // heatmap gutter for the instr N and total/iter row labels
const SCALE_ROW = 12; // heatmap space above the columns for the pressure scale

// Chart colors live in style.css as custom properties, one set per theme.
// Stage pairs are >= 3:1 except wait-exec and ready-done, which also differ by
// fill pattern (stripes painted with the panel color; page.spec.mjs measures
// the rendered rects in both themes).
const STAGES = { wait: '', ready: '', exec: '', done: '' };
const FLOW_COLORS = {};
const FLOW_VARS = {
  text: '--text', surface: '--surface', block: '--code-bg', edge: '--chart-edge', heat: '--heat',
  token: '--token', tokenEdge: '--token-edge', tokenText: '--token-text', hollow: '--token-hollow',
  cursor: '--cursor', halo: '--cursor-halo', muted: '--text-secondary',
  int: '--unit-int', branch: '--unit-branch', slow: '--unit-slow', vec: '--unit-vec', mem: '--unit-mem',
};
function readPalette() {
  const s = getComputedStyle(document.documentElement);
  for (const k in STAGES) STAGES[k] = s.getPropertyValue(`--stage-${k}`).trim();
  for (const [k, v] of Object.entries(FLOW_VARS)) FLOW_COLORS[k] = s.getPropertyValue(v).trim();
}

const legend = document.getElementById('legend');
for (const stage of Object.keys(STAGES)) {
  const swatch = document.createElement('i');
  swatch.className = `swatch-${stage}`; // style.css: color per theme, plus the timeline's hatch on wait and done
  const item = document.createElement('span');
  item.append(swatch, stage);
  legend.append(item);
}
{
  // row labels carry the same format the flow legend defines
  const item = document.createElement('span');
  item.textContent = 'rows: iteration:mnemonic:line (iteration 0 is the first pass through the loop, line is 1-based in the editor)';
  legend.append(item);
}

// A new panel width (window resize, a scrollbar showing up) redraws the flow at the current cycle.
new ResizeObserver(() => {
  const host = document.getElementById('flow');
  if (!currentFlowModel || !host.clientWidth || Math.max(FLOW.W, host.clientWidth - 1) === flowLayout.W) return;
  drawFlowBlocks(currentFlowModel);
  setFlowCycle(currentFlowModel, +document.getElementById('flow-cycle').value);
}).observe(document.getElementById('flow'));

// Redraw the charts in the new theme's colors, keeping the current cycle.
function repaint() {
  readPalette();
  renderTimeline(shownModel, document.getElementById('timeline'));
  renderHeatmap(shownModel, document.getElementById('heatmap'));
  if (currentFlowModel) {
    drawFlowBlocks(currentFlowModel);
    setFlowCycle(currentFlowModel, +document.getElementById('flow-cycle').value);
  }
}

// Theme: the stored choice, else the system setting. The inline script in
// index.html applies the same rule before first paint.
const THEME_KEY = 'simd-labs-theme';
const darkQuery = matchMedia('(prefers-color-scheme: dark)');
function storedTheme() {
  try {
    const t = localStorage.getItem(THEME_KEY);
    return t === 'dark' || t === 'light' ? t : null;
  } catch {
    return null; // storage blocked
  }
}
function applyTheme(theme) {
  document.documentElement.setAttribute('data-theme', theme);
  themeBtn.setAttribute('aria-pressed', String(theme === 'dark'));
  const next = theme === 'dark' ? 'light' : 'dark';
  themeBtn.setAttribute('aria-label', `Switch to ${next} mode`);
  themeBtn.setAttribute('title', `Switch to ${next} mode`);
  if (shownModel) repaint();
}
const systemTheme = () => (darkQuery.matches ? 'dark' : 'light');
themeBtn.addEventListener('click', () => {
  const next = document.documentElement.getAttribute('data-theme') === 'dark' ? 'light' : 'dark';
  try {
    localStorage.setItem(THEME_KEY, next);
  } catch {
    /* storage blocked: the choice lasts for this page only */
  }
  applyTheme(next);
});
darkQuery.addEventListener('change', () => storedTheme() || applyTheme(systemTheme()));
applyTheme(storedTheme() || systemTheme());

function svg(tag, attrs) {
  const el = document.createElementNS('http://www.w3.org/2000/svg', tag);
  for (const [k, v] of Object.entries(attrs)) el.setAttribute(k, v);
  return el;
}

// llvm-mca's "Zn4FP45.\x00" names print as "Zn4FP45.0", the text output's form
const label = (name) => name.replace(/[\u0000-\u001f]/g, (c) => c.charCodeAt(0));
// a unit's vendor-style name, and the same with llvm-mca's name for tooltips and tables
const withLabel = (model, iter, instr, rest) => `${model.instructions[instr]} (${instanceLabel(model, iter, instr)})\n${rest}`;
const unitName = (model, u) => model.units[u].name;
const unitRef = (model, u) => `${model.units[u].name} (${label(model.resources[u])})`;
const rowName = (model, i) => (i === model.instructions.length ? 'total/iter' : model.instructions[i]);

function renderTimeline(model, host) {
  host.textContent = '';
  if (model.rows.length === 0) {
    host.textContent = 'No instruction retired within the cycle cap, so there is no timeline to draw. Raise the cycle limit when producing the JSON.';
    return;
  }
  const maxCycle = Math.max(...model.rows.map((r) => r.retired));
  // the last axis tick covers the last cycle (the next tick would pass maxCycle)
  const lastTick = Math.ceil(maxCycle / 5) * 5;
  // Fit the run to the box; cell stays between the 12px label's floor and the
  // full 14px column. A run that cannot fit even at the floor keeps a wider
  // slab, so its box gets real overflow to scroll (its old behavior).
  const avail = host.clientWidth > 0 ? host.clientWidth : host.closest('.panel').clientWidth - 34; // panel: 16px padding and 1px border each side; reads 0 while the panel is unshown
  const fit = avail > 0 ? Math.floor((avail - LEFT - 30) / (lastTick + 2)) : CELL;
  let cell = Math.max(CELL_MIN, Math.min(CELL, fit));
  if (fit > CELL_MIN && cell * (lastTick + 2) + LEFT + 30 > avail - 2) cell -= 1; // exact fits leave the right edge flush across scrollbars and platforms
  if (fit < CELL_MIN) cell = CELL + 2; // a slab wider than any box: the run needs real overflow to scroll
  // Rows fit the box the CSS cap actually yields (the same min() the
  // stylesheet applies): 760px side by side holds the znver4 run's 60 rows
  // at the 12px floor (740px), and the svg stays under the classic vertical
  // scrollbar's trigger; stacked keeps the 520px cap and scrolls with the cue.
  const cap = matchMedia('(min-width: 1400px)').matches ? Math.min(757, innerHeight - 140) : 520;
  const cellH = Math.max(CELL_MIN, Math.min(CELL, Math.floor((cap - TOP - 4) / model.rows.length)));
  const w = lastTick * cell;
  const h = model.rows.length * cellH;
  // one cell past the last tick: a bar retiring at the cap ends its cell there
  const root = svg('svg', { width: LEFT + w + 2 * cell, height: TOP + h + 4, 'aria-hidden': 'true' });
  // wait-exec and ready-done cannot each reach 3:1 of luminance on one surface;
  // they also differ by fill pattern: stripes on wait and done, solid fills on
  // ready and exec, with the stripe painted in the panel's surface color. The
  // defs live in the timeline itself so a JSON drop without issue events (no
  // flow SVG) still shows the cue; the tests scope to the svg's direct rects.
  const defs = svg('defs', {});
  for (const stage of ['wait', 'done']) {
    const p = svg('pattern', { id: `hatch-${stage}`, width: 8, height: 8, patternUnits: 'userSpaceOnUse' });
    p.appendChild(svg('rect', { width: 8, height: 8, fill: STAGES[stage] }));
    p.appendChild(svg('line', { x1: 0, y1: 0, x2: 8, y2: 8, stroke: FLOW_COLORS.surface, 'stroke-width': 2 }));
    defs.appendChild(p);
  }
  root.prepend(defs);

  // the axis's last tick is the ceil of the last retire to a 5, so it cannot
  // fall short of the last bar; the svg is a cell wider still, so nothing
  // touches the box's right edge
  const ticks = [...new Set([...Array(Math.floor(maxCycle / 5) + 1).keys()].map((k) => k * 5).concat(lastTick))].sort((a, b) => a - b);
  for (const c of ticks) {
    const x = LEFT + c * cell;
    root.appendChild(svg('line', { class: 'grid', x1: x, x2: x, y1: TOP, y2: TOP + h, stroke: FLOW_COLORS.edge, 'stroke-opacity': 0.5 }));
    const t = svg('text', { class: 'axis', x, y: 14, 'font-size': 13, 'text-anchor': 'middle' });
    t.textContent = c;
    root.appendChild(t);
  }

  for (const r of model.rows) {
    const y = TOP + (r.iter * model.instructions.length + r.instr) * cellH;
    const spans = [
      [r.dispatched, r.ready, 'wait'],
      [r.ready, r.issued, 'ready'],
      [r.issued, r.executed, 'exec'],
      [r.executed, r.retired, 'done'],
    ];
    for (const [a, b, stage] of spans) {
      if (b <= a) continue;
      const fill = stage === 'wait' || stage === 'done' ? `url(#hatch-${stage})` : STAGES[stage];
      const rect = svg('rect', { x: LEFT + a * cell, y: +y.toFixed(3), width: (b - a) * cell, height: cellH - 1, fill });
      rect.appendChild(svg('title', {})).textContent =
        withLabel(model, r.iter, r.instr, `${stage}: cycles ${a}-${b}`);
      root.appendChild(rect);
    }
    const text = svg('text', { class: 'row', x: 4, y: y + cellH - 2, 'font-size': Math.min(FONT, cellH) });
    text.textContent = instanceLabel(model, r.iter, r.instr);
    // hover the row: its source line in the editor's gutter
    text.style.pointerEvents = 'all';
    text.addEventListener('mouseenter', () => highlightLine(model.lines?.[r.instr]));
    text.addEventListener('mouseleave', () => highlightLine(null));
    root.appendChild(text);
  }
  timelineCell = cell;
  host.appendChild(root);
  updateScrollCue(host);
  // rows past the box's height need a scroll; the note names the range in view
  if (host.scrollHeight > host.clientHeight + 1 && model.rows.length) {
    const r = host.getBoundingClientRect();
    const instrs = model.instructions.length;
    const ys = [...host.querySelectorAll('svg text.row')].map((t) => t.getBoundingClientRect());
    const firstIdx = ys.findIndex((b) => b.bottom > r.top);
    let lastIdx = ys.length - 1;
    while (lastIdx >= 0 && ys[lastIdx].bottom > r.bottom + 0.5) lastIdx--;
    if (firstIdx >= 0 && lastIdx >= firstIdx) {
      notice.textContent = noticeBase + ` Box shows ${Math.floor(firstIdx / instrs)}-${Math.floor(lastIdx / instrs)}.`;
    }
  }
}

// Overlay-scroll systems (Linux/Breeze, macOS) paint no scrollbar thumb at
// rest, so a box wider than its content gets an edge fade and a "scroll"
// hint on its clipped edge. The cue hides at the edge and when nothing
// overflows.
function updateScrollCue(box) {
  const wrap = box.closest('.scroll-wrap');
  if (!wrap) return;
  const refresh = () => {
    const overX = box.scrollWidth > box.clientWidth + 1;
    const overY = box.scrollHeight > box.clientHeight + 1;
    // 16px of slack: with scrollbar-gutter plus a classic 15px bar (Linux),
    // Chromium's max scrollLeft stops that far short of scrollWidth - clientWidth
    wrap.classList.toggle('cue-right', overX && box.scrollLeft + box.clientWidth < box.scrollWidth - 16);
    wrap.classList.toggle('cue-down', overY && box.scrollTop + box.clientHeight < box.scrollHeight - 17);
  };
  if (!box.dataset.cue) {
    box.dataset.cue = '1';
    box.addEventListener('scroll', refresh);
    new ResizeObserver(refresh).observe(box);
  }
  refresh();
}

function renderHeatmap(model, host) {
  host.textContent = '';
  const fmt = (v) => +v.toFixed(2);
  const max = Math.max(...model.matrix.flat());
  const names = model.units.map((n) => n.name);
  // every glyph keeps its set font size; a 0.62em monospace advance sizes the gutters
  const tw = (s) => s.length * 0.62 * 13;
  // the header gutter and the row-label gutter share one rotated-text width
  const head = Math.max(HEAD, ...names.map((n) => tw(n) + 8));
  // a cell prints the pressure value at 12px in a full 32px cell, 11px when
  // narrower boxes shrink cells down to 26px; below that the box scrolls
  // inside itself, never the page (800px, 23 columns).
  const hostW = host.clientWidth || 940;
  const hcell = Math.max(26, Math.min(HCELL, Math.floor((hostW - UNIT_COL - 100) / names.length)));
  const VALFONT = hcell >= HCELL ? 12 : 11;
  const root = svg('svg', {
    width: names.length * hcell + UNIT_COL + 100,
    height: model.matrix.length * CELL + head + SCALE_ROW + FONT + 12, // the last FONT+12 holds the scale line under the grid
    'aria-hidden': 'true',
  });
  const labelRow = head + SCALE_ROW;
  model.matrix.forEach((row, i) => {
    row.forEach((v, j) => {
      if (v === 0) return;
      // floor of 0.7 opacity keeps the palest cell at 3:1 against white
      const opacity = 0.7 + 0.3 * (v / max);
      const rect = svg('rect', {
        x: UNIT_COL + j * hcell,
        y: labelRow + i * CELL,
        width: hcell,
        height: CELL - VGAP,
        fill: FLOW_COLORS.heat,
        opacity,
        'data-cy': `${i},${j}`,
      });
      rect.appendChild(svg('title', {})).textContent = `${rowName(model, i)}, ${unitRef(model, j)}: ${v.toFixed(2)}`;
      root.appendChild(rect);
    });
    const rowText = i === model.instructions.length ? 'total/iter' : `instr ${i}`;
    const rowLabel = svg('text', { class: 'rowlabel', x: UNIT_COL - 4, y: labelRow + i * CELL + CELL - 1, 'font-size': FONT, 'text-anchor': 'end' });
    rowLabel.textContent = rowText;
    root.appendChild(rowLabel);
  });
  names.forEach((name, j) => {
    // a central baseline puts the rotated glyphs' middle on the column centre
    const x = UNIT_COL + j * hcell + hcell / 2;
    const c = svg('text', { class: 'col', x, y: labelRow - 4, 'font-size': FONT, 'dominant-baseline': 'central', transform: `rotate(-90 ${x} ${labelRow - 4})` });
    c.textContent = name;
    c.appendChild(svg('title', {})).textContent = unitRef(model, j);
    root.appendChild(c);
  });
  // the pressure scale: a labelled horizontal line under the row labels,
  // below their depth, clear of the grid and of the "total/iter" label
  const rowLabelW = Math.max('total/iter'.length * 0.62 * FONT, 56);
  const scale = svg('text', { class: 'heat-scale', x: rowLabelW + 8, y: labelRow + model.matrix.length * CELL + 14, 'font-size': FONT, fill: FLOW_COLORS.muted });
  scale.textContent = `pressure per iteration: 0 to ${fmt(max)}`;
  root.appendChild(scale);
  // a cell prints its value: fmt rounds to 2 decimals, and a value still too
  // wide drops a decimal (the text table under the SVG keeps full precision)
  const px = (s) => Math.ceil(s.length * 0.62 * VALFONT) + 6;
  const numFill = () =>
    document.documentElement.getAttribute('data-theme') === 'dark'
      ? getComputedStyle(document.documentElement).getPropertyValue('--bg').trim()
      : '#fff';
  model.matrix.forEach((row, i) => {
    row.forEach((v, j) => {
      if (v === 0) return;
      let s = String(fmt(v));
      for (let d = 1; px(s) > hcell && d <= 2; d++) s = String(+v.toFixed(2 - d));
      const t = svg('text', {
        class: 'heat-val',
        x: UNIT_COL + j * hcell + hcell / 2,
        y: labelRow + i * CELL + (CELL - VGAP) / 2,
        'font-size': VALFONT,
        'text-anchor': 'middle',
        'dominant-baseline': 'central',
        fill: numFill(),
      });
      t.textContent = s;
      root.appendChild(t);
    });
  });
  host.appendChild(root);
  updateScrollCue(host);
}

// Flow diagram, laid out like a CPU block diagram (WikiChip, the vendor
// optimization guides): the dispatch and scheduler queues (and, when many
// columns would shrink the text past 11px at 800px, the retire queue) across
// the top, the execution ports side by side, retire at the bottom or top
// right. The diagram is drawn to the panel's width, at least W: wider panels
// get fewer unit rows and a shorter diagram, and the text stays at full size.
const FLOW = { W: 700, gap: 24, pad: 6, head: 20, name: 18, tokH: 18, tg: 3, font: 12, title: 14, small: 12, line: 13, band: 16 };
// unit kinds: the band word for units without a role line, and the legend's words
const KIND = { int: 'integer', branch: 'branch', slow: 'slow (divider)', vec: 'FP/vector', mem: 'memory' };
const CH = 0.62; // monospace advance per em; shortcut: estimates label widths, measure them if a font is wider
let flowCycleMax = 0;
let currentFlowModel = null;
// Maximum token pile and per-unit pile over the whole run, plus the
// scheduler slots: the boxes are sized from them once per run.
let flowShape = { pile: {}, byUnit: new Map(), tokW: 30, sched: null };
let flowLayout = null; // block and unit boxes from drawFlowBlocks, read by setFlowCycle

// Mirror of the status text setFlowCycle writes; walking the run with this
// finds the tallest line #flow-status must hold (see flowStatusHeight).
function statusText(model, cycle, tokens) {
  const counts = { dispatch: 0, waiting: 0, ready: 0, execute: 0, retire: 0 };
  const busy = {};
  const inFlight = {};
  for (const t of tokens) {
    counts[t.stage]++;
    for (const u of t.units) busy[u] = true;
    if (t.stage === 'execute' && t.units.length === 0 && t.lastUnits.length > 0) inFlight[t.lastUnits[0]] = true;
  }
  const busyNames = Object.keys(busy).map(Number).sort((a, b) => a - b).map((u) => unitName(model, u));
  const inFlightNames = Object.keys(inFlight).map(Number).sort((a, b) => a - b).map((u) => unitName(model, u));
  return (
    `Cycle ${cycle}. Dispatch ${counts.dispatch}, waiting ${counts.waiting}, ready ${counts.ready}, ` +
    `executing on ${busyNames.length ? busyNames.join(', ') : 'no units'}, retire ${counts.retire}.` +
    inFlightNames.map((u) => ` Executing (latency), last on ${u}.`).join('')
  );
}

// Wrapped height #flow-status needs at this width for the run's longest
// status, measured once so the cycle bar keeps a fixed height while stepping.
function flowStatusHeight(model, statusEl) {
  statusEl.style.minHeight = ''; // clear any previous run's pin so scrollHeight is live
  statusEl.textContent = '';
  const bar = statusEl.closest('.cycle-bar');
  let max = 0;
  for (let c = 0; c <= model.cycleIndex.maxCycle; c++) {
    statusEl.textContent = statusText(model, c, tokenPositionsAt(model, c));
    // pin the whole bar: fractional line-layout lets scrollHeight tick up by
    // 1px between cycles even when every child box stays the same
    max = Math.max(max, Math.ceil(bar.getBoundingClientRect().height));
  }
  statusEl.textContent = '';
  return max;
}

function maxOccupancy(model) {
  const pile = { dispatch: 1, waiting: 1, ready: 1, execute: 1, retire: 1, noUnit: 0 };
  const byUnit = new Map();
  const { maxCycle } = model.cycleIndex;
  const len = Math.max(...model.rows.map((r) => instanceLabel(model, r.iter, r.instr).length));
  const tokW = Math.ceil(len * CH * FLOW.font) + 8;
  for (let c = 0; c <= maxCycle; c++) {
    const counts = { dispatch: 0, waiting: 0, ready: 0, execute: 0, retire: 0, noUnit: 0 };
    const unitCounts = {};
    for (const t of tokenPositionsAt(model, c)) {
      counts[t.stage]++;
      // a token in the execute block parks somewhere: on every held unit,
      // or on its last unit when only latency remains
      const spots = t.units.length ? t.units : t.lastUnits;
      for (const u of spots) unitCounts[u] = (unitCounts[u] || 0) + 1;
      if (t.stage === 'execute' && spots.length === 0) counts.noUnit++;
    }
    for (const k in counts) pile[k] = Math.max(pile[k], counts[k]);
    for (const u in unitCounts) byUnit.set(+u, Math.max(byUnit.get(+u) || 1, unitCounts[u]));
  }
  return { pile, byUnit, tokW };
}

function renderFlow(model) {
  const slider = document.getElementById('flow-cycle');
  const sliderValue = document.getElementById('flow-cycle-value');
  const status = document.getElementById('flow-status');
  const notice = document.getElementById('flow-notice');
  const play = document.getElementById('flow-play');
  const step = document.getElementById('flow-step');
  stopFlow();
  // Tearing down an old diagram clears the model and every handler before
  // anything else can draw or fire.
  currentFlowModel = null;
  slider.oninput = null;
  play.onclick = null;
  step.onclick = null;
  document.getElementById('flow-list').textContent = '';
  if (model.events === null) {
    notice.hidden = false;
    notice.textContent =
      'This JSON has no issue events, so the flow diagram needs a run from assembly (our patched llvm-mca adds -issue-events).';
    document.getElementById('flow').textContent = '';
    slider.disabled = true;
    play.disabled = true;
    step.disabled = true;
    status.textContent = 'No issue events.';
    status.style.minHeight = '';
    status.closest('.cycle-bar').style.minHeight = '';
    sliderValue.textContent = '';
    return;
  }
  notice.hidden = true;
  slider.disabled = false;
  play.disabled = false;
  step.disabled = false;
  flowCycleMax = model.cycleIndex.maxCycle;
  slider.max = flowCycleMax;
  slider.value = 0;
  sliderValue.textContent = `cycle 0 of ${flowCycleMax}`;
  flowShape = { ...maxOccupancy(model), sched: schedulerSlots(model) };
  currentFlowModel = model;
  drawFlowBlocks(model);
  // Pin the cycle bar to the tallest status of the run, so status wraps in a
  // fixed height and the panels below never move while stepping.
  status.closest('.cycle-bar').style.minHeight = `${flowStatusHeight(model, status)}px`;
  slider.oninput = () => setFlowCycle(model, +slider.value); // assigned, not added: each run would stack a listener on the old model
  play.onclick = toggleFlowPlay;
  step.onclick = () => {
    stopFlow();
    setFlowCycle(model, Math.min(flowCycleMax, +slider.value + 1));
  };
  setFlowCycle(model, 0);
}

// The whole diagram except the tokens, drawn once per run (and on a theme
// change): every box is sized from the run's peaks, so nothing moves while
// the user steps. Top to bottom: dispatch and ready, the clusters (each
// scheduler group a fixed grid of slots above the units it feeds, then one
// box per unit), retire.
function drawFlowBlocks(model) {
  const host = document.getElementById('flow');
  host.textContent = '';
  // 1px under the width: the viewBox is W + 1 wide and must not downscale
  const W = Math.max(FLOW.W, host.clientWidth - 1);
  const { gap, pad, head, name: nameH, tokH, tg: tgap, font, title, small, line: lineH, band: bandH } = FLOW;
  const { pile, byUnit, tokW, sched } = flowShape;
  const step = tokW + tgap;
  const colsIn = (w) => Math.max(1, Math.floor((w - 2 * pad + tgap) / step));
  const stackH = (rows) => rows * tokH + (rows - 1) * tgap;
  const queueH = (n, w) => head + stackH(Math.ceil(Math.max(n, 1) / colsIn(w))) + pad;
  const box = (x, y, w, h) => ({ x, y, w, h, cols: colsIn(w) });

  const qW = (W - gap) / 2;
  const blocks = { dispatch: box(0, 0, qW, queueH(pile.dispatch, qW)), ready: box(qW + gap, 0, qW, queueH(pile.ready, qW)) };
  const h1 = Math.max(blocks.dispatch.h, blocks.ready.h);
  // execution ports, as in vendor block diagrams: one column per unit with its
  // name and role lines on top, grouped into int, vec and mem bands. Branch is
  // int's last column; dividers and other slow units fold into int as a row
  // of their own, tinted and dashed.
  const execY = h1 + gap;
  const ug = 6;
  const textW = (s, f) => Math.ceil(s.length * CH * f);
  const cols = model.units.map((n, u) => {
    const kind = n.cluster === 'other' || /div/i.test(n.name) ? 'slow' : n.cluster in KIND ? n.cluster : 'int';
    const lines = n.role ? n.role.split(' / ') : [KIND[kind]];
    const w = Math.min(W - 4 * pad, Math.max(textW(n.name, font), ...lines.map((l) => textW(l, small)), tokW) + 2 * pad);
    return { u, n, kind, lines, w, cols: colsIn(w), band: kind === 'vec' || kind === 'mem' ? kind : 'int' };
  });
  // each scheduler group sits in the band of the first unit it feeds
  const groupList = [...sched.slots].map(([g, n]) => {
    const fed = model.resources.flatMap((r, u) => (unitGroup(r) === g ? [u] : []));
    return { g, n, fed, band: fed.length ? cols[fed[0]].band : 'int', label: `${fed.length ? fed.map((u) => model.units[u].name).join(' ') : g} scheduler, ${n} slots` };
  });
  const slotCols = colsIn(W - 2 * pad);
  const badgeW = 30;
  const groups = new Map();
  const rank = { int: 0, vec: 0, mem: 0, branch: 1, slow: 2 };
  const units = [];
  const bands = [];
  let y = execY + head;
  for (const band of ['int', 'vec', 'mem']) {
    const list = cols
      .filter((c) => c.band === band)
      .sort((a, b) => rank[a.kind] - rank[b.kind] || (a.n.port != null && b.n.port != null ? a.n.port - b.n.port : 0) || a.n.name.localeCompare(b.n.name, 'en', { numeric: true }));
    const gs = groupList.filter((gr) => gr.band === band);
    if (!list.length && !gs.length) continue;
    bands.push({ band, y });
    y += bandH;
    gs.forEach((gr, i) => {
      // the band's first group shares the band's label line
      const top = i ? y : y - bandH;
      const slotY = top + bandH;
      groups.set(gr.g, { ...gr, x: 2 * pad, y: slotY, cols: slotCols, top, badge: { x: W - 2 * pad - badgeW, y: top + 1, w: badgeW, h: bandH - 2 } });
      y = slotY + stackH(Math.ceil(gr.n / slotCols)) + ug;
    });
    let row = [];
    const flush = () => {
      if (!row.length) return;
      const hdr = nameH + Math.max(...row.map((c) => c.lines.length)) * lineH;
      const rows = Math.max(...row.map((c) => Math.ceil((byUnit.get(c.u) || 1) / c.cols)));
      let x = 2 * pad;
      for (const c of row) {
        // the row shares its header line, each box fits its own pile over the run
        units[c.u] = { x, y, w: c.w, h: hdr + stackH(Math.ceil((byUnit.get(c.u) || 1) / c.cols)) + pad, hdr, c };
        x += c.w + ug;
      }
      y += hdr + stackH(rows) + pad + ug;
      row = [];
    };
    for (const c of list) {
      const used = row.reduce((s, r) => s + r.w + ug, 2 * pad);
      // a full row, or the first slow unit, starts a new row
      if (row.length && (used + c.w > W - 2 * pad || (c.kind === 'slow' && row.at(-1).kind !== 'slow'))) flush();
      row.push(c);
    }
    flush();
  }
  // tokens executing on no unit (no resource use) wait in a strip under the ports
  const noUnit = { x: pad, y, cols: colsIn(W) };
  if (pile.noUnit) y += stackH(Math.ceil(pile.noUnit / noUnit.cols)) + ug;
  blocks.execute = box(0, execY, W, y - ug + pad - execY);
  blocks.retire = box(0, execY + blocks.execute.h + gap, W, queueH(pile.retire, W));
  flowLayout = { W, blocks, units, noUnit, groups };
  // the legend names each kind's units, so the colors read without the SVG
  for (const el of document.querySelectorAll('#flow-legend .flow-kind')) el.remove();
  for (const kind of Object.keys(KIND)) {
    const names = cols.filter((c) => c.kind === kind).map((c) => c.n.name);
    if (!names.length) continue;
    const item = document.createElement('span');
    item.className = 'flow-kind';
    const sw = document.createElement('i');
    sw.className = `swatch-${kind}`;
    item.append(sw, `${KIND[kind]}: ${names.join(', ')}`);
    document.getElementById('flow-legend').append(item);
  }

  const height = blocks.retire.y + blocks.retire.h + 1;
  const root = svg('svg', { width: W + 1, height, viewBox: `-0.5 -0.5 ${W + 1} ${height}`, 'aria-hidden': 'true' });
  const defs = svg('defs', {});
  const marker = svg('marker', { id: 'flow-arrow', viewBox: '0 0 8 8', refX: 8, refY: 4, markerWidth: 8, markerHeight: 8, orient: 'auto' });
  marker.appendChild(svg('path', { d: 'M0,0 L8,4 L0,8 z', fill: FLOW_COLORS.edge }));
  defs.appendChild(marker);
  root.appendChild(defs);
  const arrow = (x1, y1, x2, y2) =>
    root.appendChild(svg('line', { x1, y1, x2, y2, stroke: FLOW_COLORS.edge, 'stroke-width': 1.5, 'marker-end': 'url(#flow-arrow)' }));
  for (const b of [blocks.dispatch, blocks.ready]) arrow(b.x + b.w / 2, b.h + 2, b.x + b.w / 2, execY - 2);
  arrow(W / 2, blocks.retire.y - gap + 2, W / 2, blocks.retire.y - 2);

  const names = { dispatch: 'Dispatch', ready: 'Scheduler (ready)', execute: 'Schedulers and execution units', retire: 'Retire' };
  for (const cls of ['dispatch', 'ready', 'execute', 'retire']) {
    const b = blocks[cls];
    const g = svg('g', { class: 'flow-block', 'data-block': cls });
    g.appendChild(svg('rect', { x: b.x, y: b.y, width: b.w, height: b.h, rx: 4, fill: FLOW_COLORS.block, stroke: FLOW_COLORS.edge }));
    const t = svg('text', { x: b.x + pad, y: b.y + 17, 'font-size': title, 'font-weight': 600 });
    t.textContent = names[cls];
    g.appendChild(t);
    if (cls === 'execute') {
      for (const bd of bands) {
        const t = svg('text', { class: 'flow-band', x: 2 * pad, y: bd.y + 13, 'font-size': small, 'font-weight': 600, fill: FLOW_COLORS[bd.band] });
        t.textContent = KIND[bd.band];
        g.appendChild(t);
      }
      for (const gr of groups.values()) {
        // empty slots stay drawn, so the queue reads as full or empty at a glance
        const gg = svg('g', { class: 'flow-group', 'data-group': gr.g });
        gg.appendChild(svg('text', { x: gr.badge.x - 6, y: gr.top + 13, 'font-size': small, 'text-anchor': 'end', fill: FLOW_COLORS.muted })).textContent = gr.label;
        gg.appendChild(svg('rect', { class: 'flow-badge-box', x: gr.badge.x, y: gr.badge.y, width: gr.badge.w, height: gr.badge.h, rx: gr.badge.h / 2, fill: FLOW_COLORS.token }));
        for (let k = 0; k < gr.n; k++) {
          const sx = gr.x + (k % gr.cols) * step;
          const sy = gr.y + Math.floor(k / gr.cols) * (tokH + tgap);
          gg.appendChild(svg('rect', { class: 'flow-slot', x: sx, y: sy, width: tokW, height: tokH, rx: 3, fill: 'none', stroke: FLOW_COLORS.muted, 'stroke-dasharray': '3 2' }));
        }
        g.appendChild(gg);
      }
      model.resources.forEach((name, u) => {
        const { x, y: uy, w, h, c } = units[u];
        const ugr = svg('g', { class: 'flow-unit', 'data-unit': u, 'data-kind': c.kind, transform: `translate(${x},${uy})` });
        const rect = { width: w, height: h, rx: 3, fill: FLOW_COLORS.surface, stroke: FLOW_COLORS[c.kind], 'stroke-width': 1.5 };
        if (c.kind === 'slow') rect['stroke-dasharray'] = '4 3';
        ugr.appendChild(svg('rect', rect));
        ugr.appendChild(svg('text', { x: pad, y: 15, 'font-size': font, 'font-weight': 600 })).textContent = c.n.name;
        c.lines.forEach((l, i) => {
          ugr.appendChild(svg('text', { class: 'role', x: pad, y: nameH + i * lineH + 9, 'font-size': small, fill: FLOW_COLORS.muted })).textContent = l;
        });
        ugr.appendChild(svg('title', {})).textContent = `${c.n.display}\n${label(name)}`;
        g.appendChild(ugr);
      });
    }
    root.appendChild(g);
  }
  const tg = svg('g', { class: 'flow-tokens' });
  root.appendChild(tg);
  host.appendChild(root);
}

// A multi-resource instruction gets one token, drawn on its first held unit,
// with data-units naming every held unit; each other held unit gets a hollow
// marker with the same label. The text list below the diagram carries the
// same set (with names), so nothing is only in the SVG.
function setFlowCycle(model, cycle) {
  if (!currentFlowModel) return; // a no-events load tore the diagram down
  const slider = document.getElementById('flow-cycle');
  slider.value = cycle;
  document.getElementById('flow-cycle-value').textContent = `cycle ${cycle} of ${flowCycleMax}`;
  // highlight the same column in the timeline (a line, so the timeline's rect
  // count is unchanged)
  for (const el of document.querySelectorAll('#timeline line.flow-cur, #timeline line.flow-halo')) el.remove();
  const tl = document.querySelector('#timeline svg');
  if (tl?.lastChild) {
    const x = LEFT + cycle * timelineCell - timelineCell / 2;
    const y1 = TOP - 2;
    const y2 = +tl.lastChild.getAttribute('y') + CELL;
    // the cursor is close in luminance to some bars; the halo (page-contrast color) gives it an edge there
    tl.appendChild(svg('line', { class: 'flow-halo', x1: x, x2: x, y1, y2, stroke: FLOW_COLORS.halo, 'stroke-width': 4 }));
    tl.appendChild(svg('line', { class: 'flow-cur', x1: x, x2: x, y1, y2, stroke: FLOW_COLORS.cursor, 'stroke-width': 2 }));
    // every move keeps the cursor in view: center it in the chart box when it
    // would leave the visible span; stacked, also scroll the box so the sticky
    // cycle bar never covers the cursor row
    const box = tl.parentElement;
    const unstick = () => {
      const rowTop = tl.getBoundingClientRect().top;
      const barBottom = document.querySelector('.cycle-bar').getBoundingClientRect().bottom;
      // scrollTo of both axes is asynchronous: queue the cover fix so the
      // cursor's own scroll is not cancelled mid-animation
      if (rowTop < barBottom) box.scrollTop = Math.min(box.scrollTop + barBottom - rowTop, box.scrollHeight - box.clientHeight);
    };
    if (x < box.scrollLeft || x > box.scrollLeft + box.clientWidth) {
      box.scrollLeft = x - box.clientWidth / 2;
      requestAnimationFrame(unstick);
    } else unstick();
  }
  const tg = document.querySelector('#flow svg .flow-tokens');
  tg.textContent = ''; // only tokens change per cycle; the boxes stay as drawFlowBlocks placed them
  const { pad, head, tokH, tg: tgap, font } = FLOW;
  const tokW = flowShape.tokW;
  const step = tokW + tgap;
  const { blocks, units, noUnit, groups } = flowLayout;
  const waitingAt = flowShape.sched.waiting[cycle] ?? new Map();
  const inGroup = {};
  // each group's badge holds its waiting count; past the slot count the last
  // slot shows +N instead of a token, so the box keeps its size
  for (const [g, gr] of groups) {
    const m = waitingAt.get(g)?.length ?? 0;
    const b = svg('text', { class: 'flow-badge', 'data-group': g, x: gr.badge.x + gr.badge.w / 2, y: gr.badge.y + gr.badge.h / 2, 'font-size': font, 'font-weight': 600, 'text-anchor': 'middle', 'dominant-baseline': 'central', fill: FLOW_COLORS.tokenText });
    b.textContent = m;
    tg.appendChild(b);
    if (m <= gr.n) continue;
    const k = gr.n - 1;
    const o = svg('text', { class: 'flow-overflow', 'data-group': g, 'data-n': m - k, x: gr.x + (k % gr.cols) * step + tokW / 2, y: gr.y + Math.floor(k / gr.cols) * (tokH + tgap) + tokH / 2, 'font-size': font, 'font-weight': 600, 'text-anchor': 'middle', 'dominant-baseline': 'central', fill: FLOW_COLORS.text });
    o.textContent = `+${m - k}`;
    tg.appendChild(o);
  }
  // token slot k in a box of c columns: row-major, left to right, top to bottom
  const slot = (x0, y0, cols, k) => [x0 + (k % cols) * step, y0 + Math.floor(k / cols) * (tokH + tgap)];
  const unitSlot = (u, k) => slot(units[u].x + pad, units[u].y + units[u].hdr, units[u].c.cols, k);
  const tokens = tokenPositionsAt(model, cycle);
  const busy = {};
  const onUnitCount = {};
  const counts = { dispatch: 0, waiting: 0, ready: 0, execute: 0, retire: 0 };
  let noUnitCount = 0;
  const inFlight = {};
  for (const t of tokens) {
    const block = t.stage;
    // Its hold ended but not yet executed: executing latency. Keep it in the
    // execution block on the last unit it used, drawn dashed and dimmed.
    const inLatency = block === 'execute' && t.units.length === 0 && t.lastUnits.length > 0;
    const n = counts[block]++;
    for (const u of t.units) busy[u] = true;
    let x, y;
    if (block === 'execute') {
      const onUnit = inLatency ? t.lastUnits[0] : t.units[0];
      if (onUnit !== undefined) {
        const k = onUnitCount[onUnit] || 0;
        onUnitCount[onUnit] = k + 1;
        [x, y] = unitSlot(onUnit, k);
      } else {
        const k = noUnitCount++;
        x = noUnit.x + (k % noUnit.cols) * step;
        y = noUnit.y + Math.floor(k / noUnit.cols) * (tokH + tgap);
      }
    } else if (block === 'waiting') {
      const g = t.queue == null ? 'unassigned' : unitGroup(model.resources[t.queue]);
      const gr = groups.get(g);
      const k = (inGroup[g] = (inGroup[g] ?? -1) + 1);
      if (k >= gr.n - (waitingAt.get(g).length > gr.n ? 1 : 0)) continue; // counted in the +N slot
      x = gr.x + (k % gr.cols) * step;
      y = gr.y + Math.floor(k / gr.cols) * (tokH + tgap);
    } else {
      const b = blocks[block];
      x = b.x + pad + (n % b.cols) * step;
      y = b.y + head + Math.floor(n / b.cols) * (tokH + tgap);
    }
    if (t.units.length > 1) {
      // the solid token stays on units[0]; each other held unit gets a hollow
      // marker with the same label, so a shared hold never looks like an empty unit
      for (const u of t.units.slice(1)) {
        const k = onUnitCount[u] || 0;
        onUnitCount[u] = k + 1;
        const [mx, my] = unitSlot(u, k);
        const mg = svg('g', { class: 'flow-marker', 'data-instr': t.instr, 'data-iter': t.iter });
        mg.appendChild(svg('rect', { x: mx + 1, y: my + 1, width: tokW - 2, height: tokH - 2, rx: 3, fill: FLOW_COLORS.hollow, stroke: FLOW_COLORS.token, 'stroke-width': 2 }));
        const mt = svg('text', { x: mx + tokW / 2, y: my + tokH / 2, 'font-size': font, 'text-anchor': 'middle', 'dominant-baseline': 'central', fill: FLOW_COLORS.text });
        mt.textContent = instanceLabel(model, t.iter, t.instr);
        mg.appendChild(mt);
        mg.appendChild(svg('title', {})).textContent = withLabel(model, t.iter, t.instr, `on ${t.units.map((x) => unitRef(model, x)).join(', ')}`);
        tg.appendChild(mg);
      }
    }
    const g = svg('g', {
      class: 'flow-token',
      'data-instr': t.instr,
      'data-iter': t.iter,
      'data-block': block,
      'data-units': t.units.join(' '),
      ...(block === 'waiting' && { 'data-group': t.queue == null ? 'unassigned' : unitGroup(model.resources[t.queue]) }),
    });
    if (inLatency) {
      g.setAttribute('data-latency', '1');
      inFlight[t.lastUnits[0]] = true;
    }
    const rectAttrs = { x, y, width: tokW, height: tokH, rx: 3, fill: FLOW_COLORS.token, stroke: FLOW_COLORS.tokenEdge };
    // hollow and dashed, so it differs in shape from a solid active token; at 60% opacity the outline stays 3:1 on the unit box
    if (inLatency) Object.assign(rectAttrs, { fill: FLOW_COLORS.hollow, 'stroke-dasharray': '2 2', opacity: 0.6 });
    g.appendChild(svg('rect', rectAttrs));
    const lt = svg('text', { x: x + tokW / 2, y: y + tokH / 2, 'font-size': font, 'text-anchor': 'middle', 'dominant-baseline': 'central', fill: inLatency ? FLOW_COLORS.text : FLOW_COLORS.tokenText });
    lt.textContent = instanceLabel(model, t.iter, t.instr);
    g.appendChild(lt);
    const state = inLatency
      ? `executing (latency), last on ${unitRef(model, t.lastUnits[0])}`
      : t.units.length
        ? `${block}, on ${t.units.map((u) => unitRef(model, u)).join(', ')}`
        : `${block}`;
    g.appendChild(svg('title', {})).textContent = withLabel(model, t.iter, t.instr, state);
    // hover: the token's source line in the editor's gutter
    g.addEventListener('mouseenter', () => highlightLine(model.lines?.[t.instr]));
    g.addEventListener('mouseleave', () => highlightLine(null));
    tg.appendChild(g);
  }
  document.getElementById('flow-status').textContent = statusText(model, cycle, tokens);
  // the SVG is aria-hidden; this list is the text equivalent, one line per token
  const ul = document.createElement('ul');
  for (const t of tokens) {
    const li = document.createElement('li');
    const state =
      t.units.length > 0
        ? `executing on ${t.units.map((u) => unitRef(model, u)).join(', ')}`
        : t.lastUnits.length > 0
          ? `executing (latency), last on ${t.lastUnits.map((u) => unitRef(model, u)).join(', ')}`
          : t.stage;
    li.textContent = `${t.stage}: ${instanceLabel(model, t.iter, t.instr)} ${model.instructions[t.instr]} — ${state}`;
    ul.appendChild(li);
  }
  const host = document.getElementById('flow-list');
  host.textContent = '';
  host.appendChild(ul);
}

let flowTimer = null;
const speed = document.getElementById('flow-speed');
const speedOut = document.getElementById('flow-speed-value');
function stopFlow() {
  if (flowTimer) clearInterval(flowTimer);
  flowTimer = null;
  const b = document.getElementById('flow-play');
  if (b) b.textContent = 'Play';
}
function startFlowTimer() {
  flowTimer = setInterval(() => {
    const next = +document.getElementById('flow-cycle').value + 1;
    if (next > flowCycleMax) return stopFlow();
    setFlowCycle(currentFlowModel, next);
  }, 1000 / +speed.value);
}
function toggleFlowPlay() {
  const b = document.getElementById('flow-play');
  if (flowTimer) return stopFlow();
  b.textContent = 'Pause';
  const slider = document.getElementById('flow-cycle');
  if (+slider.value >= flowCycleMax) slider.value = 0;
  startFlowTimer();
}
speed.addEventListener('input', () => {
  speedOut.textContent = `${speed.value} cycles/s`;
  speed.setAttribute('aria-valuetext', `${speed.value} cycles per second`);
  if (flowTimer) {
    // a new rate applies now, not after the old interval's next tick
    clearInterval(flowTimer);
    startFlowTimer();
  }
});

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
    ['Instruction', ...model.resources.map((_r, u) => unitRef(model, u))],
    model.matrix.map((row, i) => [rowName(model, i), ...row.map((v) => v.toFixed(2))])
  );
}
