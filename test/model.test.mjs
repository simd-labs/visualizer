import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { buildModel, tokenPositionsAt, TimelineMappingError } from '../src/model.js';

const load = (name) => JSON.parse(readFileSync(`test/fixtures/${name}.json`, 'utf8'));
const text = (name) => readFileSync(`test/fixtures/${name}.txt`, 'utf8');

// Timeline rows of the text view. Each row is "[iter,instr]" padded to column 10,
// the bar, then 3 spaces and the instruction, so the bar is cut from the known text.
function textTimelineRows(t, asm) {
  const lines = t.split('\n');
  const start = lines.findIndex((l) => l.startsWith('[0,'));
  assert.notEqual(start, -1, 'no timeline rows in text');
  const rows = [];
  for (let i = start; lines[i]?.startsWith('['); i++) {
    const m = lines[i].match(/^\[(\d+),(\d+)\]/);
    const instr = asm[+m[2]];
    assert.ok(lines[i].endsWith(`   ${instr}`), `row ${i} does not end with its instruction`);
    const bar = lines[i].slice(10, lines[i].length - instr.length - 3).replace(/[.\s]+$/, '');
    rows.push({ iter: +m[1], instr: +m[2], bar });
  }
  return rows;
}

function assertRowMatchesText(row, bar) {
  // Text legend: D at dispatch, '=' while queued (dispatch+1..issue-1),
  // 'e' while executing (issued..executed-1), E at executed cycle,
  // '-' until retire, R at retired.
  assert.equal(bar.indexOf('D'), row.dispatched);
  assert.equal(bar.indexOf('R'), row.retired);
  assert.equal(bar.indexOf('e'), row.issued);
  assert.equal(bar.indexOf('E'), row.executed);
  assert.equal((bar.match(/=/g) || []).length, row.issued - row.dispatched - 1);
  assert.equal((bar.match(/-/g) || []).length, row.retired - row.executed - 1);
  // CycleReady has no glyph in the bar; the wait table checks it.
  assert.ok(row.ready >= row.dispatched && row.ready <= row.issued, 'ready outside [dispatched, issued]');
}

// Column values are spaced to start together with their "[r]" header cell,
// so each token's column index follows from its char offset.
function textResourceTable(t, title) {
  const lines = t.split('\n');
  const start = lines.findIndex((l) => l.trim() === title);
  assert.notEqual(start, -1, `no "${title}" table`);
  const starts = [...lines[start + 1].matchAll(/\[[^\]]+\]/g)].map((m) => m.index);
  const table = [];
  for (let i = start + 2; lines[i] && lines[i].trim(); i++) {
    const row = new Array(starts.length).fill(0);
    for (const m of lines[i].matchAll(/(\d+\.\d+|-)/g)) {
      const c = starts.findIndex((s) => Math.abs(m.index - s) <= 2);
      assert.notEqual(c, -1, `token ${m[0]} at ${m.index} matches no column`);
      row[c] = m[0] === '-' ? 0 : parseFloat(m[0]);
    }
    table.push(row);
  }
  return table;
}

// Text prints "[12.0] - Zn4FP45"; the JSON name is "Zn4FP45.\x00", so the suffix goes.
function textResourceNames(t) {
  const lines = t.split('\n');
  const start = lines.findIndex((l) => l === 'Resources:');
  assert.notEqual(start, -1, 'no Resources block');
  const names = [];
  for (let i = start + 1; /^\[[\d.]+\]\s+- /.test(lines[i] ?? ''); i++) names.push(lines[i].replace(/^.*?- /, ''));
  return names;
}
const baseName = (r) => r.replace(/\.[\u0000-\u001f]$/, '');
const near = (a, b) => assert.ok(Math.abs(a - b) <= 0.05 + 1e-9, `${a} is not within 0.05 of ${b}`);

// Average waits from the text wait table: [1] scheduler queue, [2] queue while ready, [3] WB until retire.
function textWaitTable(t) {
  const lines = t.split('\n');
  const start = lines.findIndex((l) => l.startsWith('Average Wait times'));
  assert.notEqual(start, -1, 'no wait table');
  const rows = [];
  for (let i = start; i < lines.length; i++) {
    const m = lines[i].match(/^(\d+)\.\s+(\d+)\s+([\d.]+)\s+([\d.]+)\s+([\d.]+)/);
    if (m) rows.push({ instr: +m[1], execs: +m[2], queue: +m[3], ready: +m[4], retire: +m[5] });
  }
  return rows;
}

const complete = ['znver4', 'skylake', 'neoverse-v2'];
for (const f of complete) {
  test(`${f}: every timeline row and all five cycles match the text`, () => {
    const json = load(f);
    const model = buildModel(json);
    const t = text(f);
    const n = model.instructions.length;
    assert.equal(model.iters, 3);
    assert.equal(model.complete, true);
    assert.deepEqual(model.instructions, json.CodeRegions[0].Instructions);
    assert.equal(model.rows.length, n * 3);

    const textRows = textTimelineRows(t, model.instructions);
    assert.equal(textRows.length, model.rows.length);
    model.rows.forEach((r, i) => {
      assert.equal(r.iter, textRows[i].iter);
      assert.equal(r.instr, textRows[i].instr);
      assertRowMatchesText(r, textRows[i].bar);
    });

    // Ready is the one cycle the bar does not show, so check it through the wait table:
    // per instruction, the average of issued-dispatched, issued-ready and retired-executed-1.
    const wait = textWaitTable(t);
    assert.equal(wait.length, n);
    for (let k = 0; k < n; k++) {
      const mine = model.rows.filter((r) => r.instr === k);
      const avg = (fn) => mine.reduce((s, r) => s + fn(r), 0) / mine.length;
      const w = wait[k];
      assert.equal(w.execs, mine.length);
      near(avg((r) => r.issued - r.dispatched), w.queue);
      near(avg((r) => r.issued - r.ready), w.ready);
      near(avg((r) => r.retired - r.executed - 1), w.retire);
    }
  });

  test(`${f}: resource names and every matrix cell match the text`, () => {
    const json = load(f);
    const model = buildModel(json);
    const t = text(f);
    assert.deepEqual(model.resources, json.TargetInfo.Resources);
    assert.deepEqual(textResourceNames(t), model.resources.map(baseName));
    // Matrix rows: per instruction, then the per-iteration totals row. Text prints 2 decimals and '-' for zero.
    const byInstr = textResourceTable(t, 'Resource pressure by instruction:');
    const perIter = textResourceTable(t, 'Resource pressure per iteration:')[0];
    const nd = (x) => Math.round(x * 100) / 100;
    assert.deepEqual(model.matrix.map((row) => row.map(nd)), [...byInstr, perIter]);
  });
}

test('znver4-i100: the 10 iterations that ran match the text, notice names the iteration cap', () => {
  const json = load('znver4-i100');
  const model = buildModel(json);
  const t = text('znver4-i100');
  assert.equal(model.iters, 10);
  assert.equal(model.total, 100);
  assert.equal(model.complete, false);
  assert.equal(model.cycleCut, false);
  assert.equal(model.rows.length, 40);
  const textRows = textTimelineRows(t, model.instructions);
  assert.equal(textRows.length, 40);
  model.rows.forEach((r, i) => {
    assert.equal(r.iter, textRows[i].iter);
    assert.equal(r.instr, textRows[i].instr);
    assertRowMatchesText(r, textRows[i].bar);
  });
  const byInstr = textResourceTable(t, 'Resource pressure by instruction:');
  const perIter = textResourceTable(t, 'Resource pressure per iteration:')[0];
  const nd = (x) => Math.round(x * 100) / 100;
  assert.deepEqual(model.matrix.map((row) => row.map(nd)), [...byInstr, perIter]);
});

test('znver4-cap18: the cycle cap leaves a whole-row prefix that matches the text', () => {
  const json = load('znver4-cap18');
  const model = buildModel(json);
  const t = text('znver4-cap18');
  assert.equal(model.rows.length, 17);
  assert.equal(model.iters, 4);
  assert.equal(model.total, 10);
  assert.equal(model.complete, false);
  assert.equal(model.cycleCut, true);
  const textRows = textTimelineRows(t, model.instructions);
  assert.equal(textRows.length, 17);
  model.rows.forEach((r, i) => {
    assert.equal(r.iter, textRows[i].iter);
    assert.equal(r.instr, textRows[i].instr);
    assertRowMatchesText(r, textRows[i].bar);
  });
  assert.match(t, /Truncated display due to cycle limit/);
});

test('skylake-idivq: a cycle cap that cuts the first row maps zero rows', () => {
  const json = load('skylake-idivq');
  const model = buildModel(json);
  assert.equal(json.CodeRegions[0].TimelineView.TimelineInfo.length, 0);
  assert.equal(model.rows.length, 0);
  assert.equal(model.iters, 0);
  assert.equal(model.cycleCut, true);
  const t = text('skylake-idivq');
  assert.match(t, /Truncated display due to cycle limit/);
  assert.doesNotMatch(t, /^\[0,0\]/m);
});

test('every CycleReady is a non-negative integer (no cross-check against text)', () => {
  for (const f of [...complete, 'znver4-i100', 'znver4-cap18']) {
    for (const r of buildModel(load(f)).rows) {
      assert.ok(Number.isInteger(r.ready) && r.ready >= 0, `${f}: ready ${r.ready}`);
    }
  }
});

test('a missing, negative, or non-integer cycle field throws the named error', () => {
  const mutations = [
    (info) => delete info[0].CycleRetired,
    (info) => (info[1].CycleReady = -1),
    (info) => (info[2].CycleIssued = 'soon'),
    (info) => (info[0].CycleDispatched = 1.5),
  ];
  for (const mutate of mutations) {
    const json = load('znver4');
    mutate(json.CodeRegions[0].TimelineView.TimelineInfo);
    assert.throws(
      () => buildModel(json),
      (e) => e instanceof TimelineMappingError && e.name === 'TimelineMappingError'
    );
  }
});

test('more entries than instructions x iterations throw TimelineMappingError', () => {
  const json = load('znver4');
  const info = json.CodeRegions[0].TimelineView.TimelineInfo;
  info.push(...info.slice(0, 4)); // 16 entries for 4 instructions at Iterations=3
  assert.throws(
    () => buildModel(json),
    (e) => e instanceof TimelineMappingError && e.name === 'TimelineMappingError' && /16 entries/.test(e.message)
  );
});

test('wrong-schema JSON throws the named error', () => {
  const json = JSON.parse(readFileSync('test/fixtures/wrong-schema.json', 'utf8'));
  assert.throws(
    () => buildModel(json),
    (e) => e instanceof TimelineMappingError && e.name === 'TimelineMappingError'
  );
});

test('two code regions throw the named error', () => {
  const json = load('znver4');
  json.CodeRegions.push(json.CodeRegions[0]);
  assert.throws(
    () => buildModel(json),
    (e) => e.name === 'TimelineMappingError'
  );
});

test('malformed JSON fails at parse, before the model', () => {
  assert.throws(
    () => JSON.parse(readFileSync('test/fixtures/malformed.json', 'utf8')),
    (e) => e.name === 'SyntaxError'
  );
});

// Item 9: issue events from the -issue-events fixtures (WASM build output;
// native llvm-mca-23 has no patch).
const loadIssue = (name) => JSON.parse(readFileSync(`test/fixtures/${name}.issue.json`, 'utf8'));

test('issue events reproduce every heatmap cell for all three fixtures', () => {
  for (const f of complete) {
    const model = buildModel(loadIssue(f));
    assert.notEqual(model.events, null, `${f} has no issue events`);
    // Per instruction: sum each event's cycles per unit and divide by
    // iterations; compare cell by cell against the heatmap (which carries the
    // totals row at index n).
    const n = model.instructions.length;
    const sums = Array.from({ length: n + 1 }, () => new Array(model.resources.length).fill(0));
    for (const ev of model.events) {
      for (const { unit, hold } of ev.units) sums[ev.instr][unit] += hold;
    }
    for (let i = 0; i < n; i++) {
      for (let u = 0; u < model.resources.length; u++) {
        const got = sums[i][u] / model.iters;
        const want = model.matrix[i][u];
        assert.ok(Math.abs(got - want) < 0.01 + 1e-9, `${f} instr ${i} unit ${u}: events ${got} vs heatmap ${want}`);
      }
    }
    // totals row: sum the per-instruction event totals for the unit column
    for (let u = 0; u < model.resources.length; u++) {
      let col = 0;
      for (let i = 0; i < n; i++) col += sums[i][u];
      const got = col / model.iters;
      assert.ok(Math.abs(got - model.matrix[n][u]) < 0.01 + 1e-9, `${f} totals unit ${u}: events ${got} vs heatmap ${model.matrix[n][u]}`);
    }
  }
});

test('shifting every event to the next unit breaks the cell check', () => {
  const json = loadIssue('znver4');
  const model = buildModel(json);
  const n = model.instructions.length;
  for (const ev of model.events) for (const u of ev.units) u.unit = (u.unit + 1) % model.resources.length;
  const sums = Array.from({ length: n + 1 }, () => new Array(model.resources.length).fill(0));
  for (const ev of model.events) for (const { unit, hold } of ev.units) sums[ev.instr][unit] += hold;
  let mismatches = 0;
  for (let i = 0; i < n; i++) {
    for (let u = 0; u < model.resources.length; u++) {
      if (Math.abs(sums[i][u] / model.iters - model.matrix[i][u]) >= 0.01 + 1e-9) mismatches++;
    }
  }
  assert.ok(mismatches > 0, 'shifted unit assignment still matched every cell');
});

// Hand-computed from znver4.issue.json's TimelineInfo and IssueEvents.
// Timeline rows (dispatched, ready, issued, executed, retired), instr 0..3 x iter 0..2:
//   it0: (0,0,1,9,10) (0,9,9,13,14) (0,0,1,2,14) (0,2,2,3,14)
//   it1: (0,2,2,10,14) (0,10,10,14,15) (1,2,2,3,15) (1,3,3,4,15)
//   it2: (1,3,3,11,15) (1,11,11,15,16) (1,3,3,4,16) (1,4,4,5,16)
// Issue events hold every unit for exactly 1 cycle (all cycles_den=1), so a
// token carries units only on the event's own cycle. znver4's dispatch cycle
// 0 is a real cycle (three instructions dispatch then), and a token whose
// wait span is empty (ready==issued) moves straight from dispatch to execute.
const Z4 = {
  0: [
    [0, 0, 'dispatch', []], [0, 1, 'dispatch', []], [1, 0, 'dispatch', []],
    [1, 1, 'dispatch', []], [2, 0, 'dispatch', []], [3, 0, 'dispatch', []],
  ],
  1: [
    [0, 0, 'execute', [13, 17, 20]], [0, 1, 'waiting', []], [0, 2, 'dispatch', []],
    [1, 0, 'waiting', []], [1, 1, 'waiting', []], [1, 2, 'dispatch', []],
    [2, 0, 'execute', [6]], [2, 1, 'dispatch', []], [2, 2, 'dispatch', []],
    [3, 0, 'waiting', []], [3, 1, 'dispatch', []], [3, 2, 'dispatch', []],
  ],
  2: [
    [0, 0, 'execute', []], [0, 1, 'execute', [12, 16, 19]], [0, 2, 'waiting', []],
    [1, 0, 'waiting', []], [1, 1, 'waiting', []], [1, 2, 'waiting', []],
    [2, 0, 'retire', []], [2, 1, 'execute', [5]], [2, 2, 'waiting', []],
    [3, 0, 'execute', [7]], [3, 1, 'waiting', []], [3, 2, 'waiting', []],
  ],
  3: [
    [0, 0, 'execute', []], [0, 1, 'execute', []], [0, 2, 'execute', [13, 15, 18]],
    [1, 0, 'waiting', []], [1, 1, 'waiting', []], [1, 2, 'waiting', []],
    [2, 0, 'retire', []], [2, 1, 'retire', []], [2, 2, 'execute', [4]],
    [3, 0, 'retire', []], [3, 1, 'execute', [3]], [3, 2, 'waiting', []],
  ],
  9: [
    [0, 0, 'retire', []], [0, 1, 'execute', []], [0, 2, 'execute', []],
    [1, 0, 'execute', [9]], [1, 1, 'waiting', []], [1, 2, 'waiting', []],
    [2, 0, 'retire', []], [2, 1, 'retire', []], [2, 2, 'retire', []],
    [3, 0, 'retire', []], [3, 1, 'retire', []], [3, 2, 'retire', []],
  ],
  15: [[1, 2, 'retire', []], [2, 2, 'retire', []], [3, 2, 'retire', []]],
  16: [],
};

test('tokenPositionsAt matches the hand-computed positions on znver4', () => {
  const model = buildModel(loadIssue('znver4'));
  for (const [cycle, want] of Object.entries(Z4)) {
    const got = tokenPositionsAt(model, +cycle);
    assert.deepEqual(
      got.map((t) => [t.instr, t.iter, t.stage, t.units]),
      want,
      `cycle ${cycle}`
    );
  }
});

test('tokenPositionsAt: shifting each event to the next unit changes the units', () => {
  const json = loadIssue('znver4');
  const mutated = structuredClone(json);
  for (const ev of mutated.CodeRegions[0].IssueEventView.IssueEvents) {
    for (const u of ev.units) u.unit += 1;
  }
  const a = tokenPositionsAt(buildModel(json), 2);
  const b = tokenPositionsAt(buildModel(mutated), 2);
  assert.notDeepEqual(
    a.map((t) => t.units),
    b.map((t) => t.units)
  );
});

test('an execute token with no busy unit stays in the execution block on its last unit', () => {
  // znver4, instr 0 (vmovups load), issued cycle 1, units held 1 cycle,
  // executed cycle 9. Cycle 2 is after every hold (half-open [end, executed)),
  // so the instruction is still executing latency, not retiring.
  const model = buildModel(loadIssue('znver4'));
  const t = tokenPositionsAt(model, 2).find((x) => x.instr === 0 && x.iter === 0);
  assert.equal(t.stage, 'execute');
  assert.deepEqual(t.units, []);
  assert.deepEqual(t.lastUnits, [20]); // the holds tie on end; the event's last unit wins
});

// cortex-a55 is in-order: the first instruction dispatches and issues at
// cycle 0, and its load unit is already busy there. An out-of-order CPU's
// cycle-0 dispatch shows in znver4's table above; here the "not yet" value
// LLVM uses for unstarted timelines (-1 in the stock JSON) never appears, so
// 0 must render. Hand-computed from the fixture's TimelineInfo/IssueEvents:
// instr k issues at its event cycle and holds its unit for 1 cycle, then
// sits dimmed (latency) on that unit until its executed cycle.
const A55 = {
  0: [[0, 0, 'execute', [9], []]],
  1: [[0, 0, 'execute', [], [9]]],
  4: [[1, 0, 'execute', [8], []]],
  8: [[2, 0, 'execute', [5], []]],
  9: [
    [2, 0, 'execute', [], [5]],
    [3, 0, 'execute', [1], []],
  ],
};

test('tokenPositionsAt matches the hand-computed positions on in-order cortex-a55', () => {
  const model = buildModel(loadIssue('cortex-a55'));
  assert.notEqual(model.events, null);
  for (const [cycle, want] of Object.entries(A55)) {
    const got = tokenPositionsAt(model, +cycle);
    assert.deepEqual(
      got.map((t) => [t.instr, t.iter, t.stage, t.units, t.lastUnits]),
      want,
      `cycle ${cycle}`
    );
  }
});

test('the cycle index keeps tokenPositionsAt fast on a long run', () => {
  const n = 16;
  const iters = 1000;
  const info = [];
  for (let i = 0; i < n * iters; i++) {
    const base = 2 * i;
    info.push({
      CycleDispatched: base,
      CycleReady: base,
      CycleIssued: base + 1,
      CycleExecuted: base + 2,
      CycleRetired: base + 3,
    });
  }
  const events = [];
  for (let iter = 0; iter < iters; iter++) {
    for (let instr = 0; instr < n; instr++) {
      events.push({ cycle: 2 * (iter * n + instr) + 1, instruction: instr, iteration: iter, units: [{ cycles_den: 1, cycles_num: 1, unit: instr % 4 }] });
    }
  }
  const json = {
    CodeRegions: [{
      Instructions: Array.from({ length: n }, (_, i) => `instr ${i}`),
      SummaryView: { Iterations: iters },
      TimelineView: { TimelineInfo: info },
      ResourcePressureView: { ResourcePressureInfo: [] },
      IssueEventView: { IssueEvents: events },
    }],
    TargetInfo: { Resources: ['u0', 'u1', 'u2', 'u3'] },
  };
  const model = buildModel(json);
  const start = performance.now();
  let total = 0;
  for (let i = 0; i < 10000; i++) total += tokenPositionsAt(model, i % 100).length;
  const ms = (performance.now() - start) / 10000;
  assert.ok(total > 0);
  assert.ok(ms < 2, `${ms} ms per call`);
});
