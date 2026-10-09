import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { buildModel, TimelineMappingError } from '../src/model.js';

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
