// sourceLines answers one question: on which editor line is the k-th
// llvm-mca instruction, and can the answer be trusted at all.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, readdirSync, existsSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { sourceLines } from '../src/source-lines.js';
import { buildModel, attachSourceLines, instanceLabel } from '../src/model.js';

const here = dirname(fileURLToPath(import.meta.url));
const mnemonic = (s) => s.trim().split(/\s+/)[0].toLowerCase();

test('plain loop: one line per instruction, 1-based', () => {
  const src = 'movups (%rsi,%rax,4), %xmm0\nmulps %xmm1, %xmm0\njne loop';
  assert.deepEqual(sourceLines(src, ['movups\tx', 'mulps\tx', 'jne\tx']), [1, 2, 3]);
});

test('comments, labels and directives are not instructions', () => {
  const src = [
    '# a comment', // 1
    '.text', // 2
    '.globl loop', // 3
    'loop:', // 4
    '  ; semicolon comment', // 5
    '  movups (%rsi,%rax,4), %xmm0', // 6
    '  mulps %xmm1, %xmm0', // 7
    '// slash comment', // 8
    '  addq $4, %rax', // 9
    '  jne loop # trailing comment is fine', // 10
    '', // 11
  ].join('\n');
  assert.deepEqual(
    sourceLines(src, ['movups\ta', 'mulps\ta', 'addq\ta', 'jne\ta']),
    [6, 7, 9, 10]
  );
});

test('a file with code before # LLVM-MCA-BEGIN maps only the region', () => {
  const src = [
    'vmulps %ymm0, %ymm1, %ymm2', // 1: before the marker, not in the region
    '# LLVM-MCA-BEGIN loop', // 2
    'vmovups (%rsi,%rax,4), %ymm0', // 3
    'vfmadd231ps %ymm1, %ymm2, %ymm0', // 4
    'addq $8, %rax', // 5
    'jne .LBB0_1', // 6
    '# LLVM-MCA-END', // 7
    'retq', // 8
  ].join('\n');
  assert.deepEqual(
    sourceLines(src, ['vmovups\ta', 'vfmadd231ps\ta', 'addq\ta', 'jne\ta']),
    [3, 4, 5, 6]
  );
});

test('a mnemonic mismatch drops every line', () => {
  const src = 'movups a\nmulps b';
  assert.equal(sourceLines(src, ['movups\ta', 'addps\tb']), null);
});

test('no source (a JSON drop) has no lines; the label drops the line part', () => {
  const json = JSON.parse(readFileSync(join(here, 'fixtures/znver4.json'), 'utf8'));
  const model = buildModel(json);
  attachSourceLines(model, undefined);
  assert.equal(model.lines, null);
  assert.equal(instanceLabel(model, 0, 0), '0:vmovups');
  const src = readFileSync(join(here, 'fixtures/loop.s'), 'utf8');
  attachSourceLines(model, src);
  assert.deepEqual(model.lines, [4, 5, 6, 7]);
  assert.equal(instanceLabel(model, 0, 0), '0:vmovups:4');
  assert.equal(instanceLabel(model, 2, 1), '2:vfmadd231ps:5');
});

test('corpus .full.s files map every mnemonic or return none', () => {
  const dir = join(here, 'corpus/asm');
  if (!existsSync(dir)) return; // the corpus is not on every base
  const fulls = readdirSync(dir).filter((f) => f.endsWith('.full.s'));
  assert.ok(fulls.length > 0, 'no corpus .full.s files found');
  // the region files hold the same loop, so each full file's region must
  // match its region file's instructions one to one
  for (const f of fulls) {
    const regionPath = join(dir, f.replace('.full.s', '.region.s'));
    if (!existsSync(regionPath)) continue;
    const region = readFileSync(regionPath, 'utf8');
    const instructions = [];
    for (const raw of region.split('\n')) {
      const s = raw.trim();
      if (s === '' || s.startsWith('#') || s.startsWith(';') || s.startsWith('//') || s.startsWith('@')) continue;
      if (s.startsWith('.')) continue;
      if (/^[A-Za-z_.$][\w.$]*\s*:/.test(s)) continue;
      instructions.push(mnemonic(s));
    }
    const lines = sourceLines(readFileSync(join(dir, f), 'utf8'), instructions);
    if (lines === null) continue; // tolerated: no wrong numbers ever
    assert.equal(lines.length, instructions.length, `${f}: mapped ${lines.length} of ${instructions.length}`);
    const srcLines = readFileSync(join(dir, f), 'utf8').split('\n');
    lines.forEach((line, k) => {
      assert.equal(mnemonic(srcLines[line - 1]), instructions[k], `${f}: line ${line} is not ${instructions[k]}`);
    });
  }
});
