import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { buildModel } from '../src/model.js';
import {
  mcaInfo,
  coreKeyFor,
  refRowFor,
  columnCell,
  buildAnnotations,
  archOf,
  mnemonicOfKey,
} from '../src/simdref.js';

const load = (name) => JSON.parse(readFileSync(`test/fixtures/${name}.json`, 'utf8'));
const json = load('d34-mca');
const records = load('d34-chunk');
const cores = load('d34-cores');
const model = buildModel(json);
// The fixture loop's catalog keys, as the identity worker reports them.
// The branch line resolves to no key, so it shows "unknown".
const keys = [
  'x86:vpermd (ymm, ymm, ymm)',
  'x86:vbroadcastss (ymm, xmm)',
  'x86:movbe (r32, m32)',
  'x86:adcx (r64, r64)',
  null,
];

const near = (got, want) => assert.ok(Math.abs(got - want) < 1e-9, `${got} != ${want}`);

test('mcaInfo reads InstructionInfoView per instruction', () => {
  const info = mcaInfo(json);
  assert.equal(info.length, 5);
  assert.deepEqual(info[0], { latency: 4, rthroughput: 1, uops: 1 });
  assert.equal(info[2].rthroughput, 0.3333333333333333);
  assert.deepEqual(mcaInfo({}), []);
});

test('coreKeyFor maps an llvm -mcpu name and never guesses a tie', () => {
  assert.equal(coreKeyFor(cores, 'znver4'), 'ZEN4');
  assert.equal(coreKeyFor(cores, 'neoverse-v2'), 'neoverse-v2');
  assert.equal(coreKeyFor(cores, 'skymont'), 'ARL-E');
  assert.equal(coreKeyFor(cores, 'sifive-x280'), 'sifive-x280');
  // znver1 maps to two cores, ZEN+ and ZEN1
  assert.equal(coreKeyFor(cores, 'znver1'), null);
  assert.equal(coreKeyFor(cores, 'no-such-cpu'), null);
});

test('columnCell shows the row and "unknown" when none resolves', () => {
  assert.equal(columnCell(null), 'unknown');
  assert.equal(columnCell(refRowFor(records['x86:adcx (r64, r64)'], 'ZEN4')), '1c 0.38tp 1u uops.info measured');
  assert.equal(refRowFor(records['x86:adcx (r64, r64)'], 'ICX'), null);
  assert.equal(columnCell(refRowFor(records['x86:vpermd (ymm, ymm, ymm)'], 'ICX')), '3c 1tp intel-guide modeled');
});

test('the ZEN4 column values, differences and summary', () => {
  const ann = buildAnnotations(model, json, keys, records, 'ZEN4');
  assert.deepEqual(ann.cells, [
    '4c 0.50tp 1u 1*FP12 uops.info measured',
    '1c 0.50tp 1u 1*FP12 uops.info measured',
    '7c 0.33tp 1u uops.info measured',
    '1c 0.38tp 1u uops.info measured',
    'unknown',
  ]);
  // differences are llvm-mca minus simdref
  near(ann.rows[0].diff.latency, 0);
  near(ann.rows[0].diff.rthroughput, 0.5);
  near(ann.rows[0].diff.uops, 0);
  near(ann.rows[1].diff.latency, 1);
  near(ann.rows[2].diff.latency, -2);
  near(ann.rows[2].diff.rthroughput, 0.0033333333333333);
  near(ann.rows[3].diff.rthroughput, 0.62);
  assert.deepEqual(ann.rows[4].diff, { latency: null, rthroughput: null, uops: null });
  assert.equal(ann.rows[4].ref, null);
  assert.equal(ann.rows[0].ref.kind, 'measured');
  // 3 measured rows within 1 cycle; the branch has no measured row
  assert.deepEqual(ann.summary, { within1: 3, noMeasured: 1, total: 5 });
});

test('modeled rows are labeled modeled and count as no measured row', () => {
  const ann = buildAnnotations(model, json, keys, records, 'ICX');
  assert.deepEqual(ann.cells, [
    '3c 1tp intel-guide modeled',
    '6c 0.54tp intel-guide modeled',
    '6c 0.57tp intel-guide modeled',
    'unknown',
    'unknown',
  ]);
  assert.equal(ann.rows[0].ref.kind, 'modeled');
  near(ann.rows[0].diff.latency, 1);
  assert.equal(ann.rows[0].diff.uops, null);
  near(ann.rows[1].diff.latency, -4);
  assert.deepEqual(ann.summary, { within1: 0, noMeasured: 5, total: 5 });
});

test('archOf maps the llvm triple to the identity worker key', () => {
  assert.equal(archOf('x86_64-unknown-linux-gnu'), 'x86');
  assert.equal(archOf('aarch64-unknown-linux-gnu'), 'aarch64');
  assert.equal(archOf('riscv64-unknown-linux-gnu'), 'riscv64');
});

test('mnemonicOfKey reads the catalog mnemonic out of a db_key', () => {
  // jne spells its catalog row jnz; the chunk is JNZ.json
  assert.equal(mnemonicOfKey('x86:jnz (rel32)'), 'jnz');
  assert.equal(mnemonicOfKey('x86:add (r32, r32)'), 'add');
  assert.equal(mnemonicOfKey('arm:add (<wdorwzr>, <wnorwzr__3>, <wmorwzr__2>#0)'), 'add');
  assert.equal(mnemonicOfKey('riscv:addi'), 'addi');
  assert.equal(mnemonicOfKey(''), '');
});
