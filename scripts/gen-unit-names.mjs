#!/usr/bin/env node
// Generate vendor-style names for llvm-mca's execution resources, for every
// CPU the page offers. Stock llvm-mca only: for each CPU family (CPUs grouped
// by identical resource lists) one probe instruction per class runs under
// 'llvm-mca -json'; the ResourcePressureView of the probe tells which units
// the class uses. A unit's role is the list of classes whose probe touched
// it, so the table is derived data, not hand knowledge.
//
// Deterministic: instructions and iteration order are fixed, output is
// sorted. Re-run to regenerate; generated rules carry family 'probe-*' and
// replace the previous generated set, hand-written rules are never touched.
//
// Usage: node scripts/gen-unit-names.mjs   (env MCA overrides the binary)
import { readFileSync, writeFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const MCA = process.env.MCA || 'llvm-mca-23';
const cpus = JSON.parse(readFileSync(`${root}/cpus.json`, 'utf8'));
const tablePath = `${root}/src/unit-names.json`;
const table = JSON.parse(readFileSync(tablePath, 'utf8'));
const source = {
  type: 'probe',
  url: 'none',
  note: `${MCA} -json, one instruction per class; role is the classes whose probe shows the unit in ResourcePressureView`,
};

// Probe classes, fixed order: the role lists them in this order. One probe is
// a single instruction, so every nonzero ResourceUsage in its view is caused
// by that class. A probe the target rejects (exit != 0 or bad JSON) simply
// adds no class, so missing extensions (FMA, RVV) leave no role entry.
const CLASSES = {
  'x86_64-unknown-linux-gnu': [
    ['alu', 'ALU', 'addl %ecx, %eax\n'],
    ['shift', 'shift', 'shll $1, %eax\n'],
    ['imul', 'mul', 'imull %ecx, %eax\n'],
    ['idiv', 'div', 'idivl %ecx\n'],
    ['branch', 'branch', 'loop:\njne loop\n'],
    ['load', 'load', 'movl (%rcx), %eax\n'],
    ['store', 'store', 'movl %eax, (%rcx)\n'],
    ['agu', 'AGU', 'leal (%rcx,%rax,4), %eax\n'],
    ['fpadd', 'FP add', 'addps %xmm1, %xmm0\n'],
    ['fpmul', 'FP mul', 'mulps %xmm1, %xmm0\n'],
    ['fma', 'FMA', 'vfmadd231ps %xmm2, %xmm1, %xmm0\n'],
    ['fpdiv', 'FP div', 'divps %xmm1, %xmm0\nsqrtps %xmm0, %xmm1\n'],
    ['shuffle', 'shuffle', 'pshufd $1, %xmm0, %xmm1\n'],
    ['vecint', 'vec int', 'paddd %xmm1, %xmm0\n'],
    ['cvt', 'cvt', 'cvtdq2ps %xmm0, %xmm1\n'],
  ],
  // No separate AGU class: AArch64 and RISC-V sched models fold addressing
  // into the load/store units.
  'aarch64-unknown-linux-gnu': [
    ['alu', 'ALU', 'add w0, w0, w1\n'],
    ['shift', 'shift', 'lsl w0, w0, #1\n'],
    ['imul', 'mul', 'mul w0, w0, w1\n'],
    ['idiv', 'div', 'sdiv w0, w0, w1\n'],
    ['branch', 'branch', 'loop:\ncbnz w0, loop\n'],
    ['load', 'load', 'ldr w0, [x1]\n'],
    ['store', 'store', 'str w0, [x1]\n'],
    ['fpadd', 'FP add', 'fadd v0.4s, v0.4s, v1.4s\n'],
    ['fpmul', 'FP mul', 'fmul v0.4s, v0.4s, v1.4s\n'],
    ['fma', 'FMA', 'fmla v0.4s, v1.4s, v2.4s\n'],
    ['fpdiv', 'FP div', 'fdiv v0.4s, v0.4s, v1.4s\nfsqrt v0.4s, v0.4s\n'],
    ['shuffle', 'shuffle', 'zip1 v0.16b, v0.16b, v1.16b\n'],
    ['vecint', 'vec int', 'add v0.4s, v0.4s, v1.4s\n'],
    ['cvt', 'cvt', 'fcvtzs w0, s0\n'],
  ],
  'riscv64-unknown-linux-gnu': [
    ['alu', 'ALU', 'add a0, a0, a1\n'],
    ['shift', 'shift', 'slliw a0, a0, 1\n'],
    ['imul', 'mul', 'mulw a0, a0, a1\n'],
    ['idiv', 'div', 'divw a0, a0, a1\n'],
    ['branch', 'branch', 'loop:\nbnez a0, loop\n'],
    ['load', 'load', 'ld a0, 0(a1)\n'],
    ['store', 'store', 'sd a0, 0(a1)\n'],
    ['fpadd', 'FP add', 'fadd.d fa0, fa0, fa1\n'],
    ['fpmul', 'FP mul', 'fmul.d fa0, fa0, fa1\n'],
    ['fma', 'FMA', 'fmadd.d fa0, fa0, fa1, fa2\n'],
    ['fpdiv', 'FP div', 'fdiv.d fa0, fa0, fa1\nfsqrt.d fa0, fa0\n'],
    ['shuffle', 'shuffle', 'vrgather.vv v0, v0, v1\n'],
    ['vecint', 'vec int', 'vadd.vv v0, v0, v1\n'],
    ['cvt', 'cvt', 'fcvt.d.w fa0, a0\n'],
  ],
};

// "Zn4Store0" -> "Store 0", "V2UnitL23" -> "L 23", "LNLPPort00" -> "Port 00",
// "C1UUnitV0" -> "V 0". Prefixes strip one pattern at a time, in order;
// role keywords (Port, Pipe, Div...) never strip.
const KEEP = new Set(['Port', 'Pipe', 'Div', 'LS', 'LDST', 'IEU', 'FPU', 'AGLU', 'FP', 'MAC', 'ALU', 'MUL', 'EXQ', 'Branch', 'Load', 'Store']);
const PREFIXES = [
  /^[A-Z]+(?=[A-Z][a-z])/,   // LNLP before a mixed-case word
  /^VLEN\d+(?=[A-Z][a-z])/,  // VLEN512SiFive -> SiFive...
  /^[A-Z][a-z]+\d*(?=\S)/,   // vendor words, optional digits: Si, Five7, Unit
  /^[A-Z]\d+[A-Z]?(?=[A-Z]|\d)/,   // C1U, V3, M5, A510 (never letters into the name)
  /^[A-Z]{2,}\d*(?=[A-Z][a-z])/, // SMX before a mixed-case word
];
function humanize(base) {
  let s = base;
  for (;;) {
    const p = PREFIXES.find((re) => {
      const m = re.exec(s);
      // KEEP guards the letter stem, so "Port0" counts as the keyword "Port"
      return m && m[0].length < s.length && !KEEP.has(m[0].replace(/\d+/g, ''));
    });
    if (!p) break;
    const m = p.exec(s);
    s = s.slice(m[0].length);
  }
  if (!s) s = base;
  const name = s
    .replace(/([A-Za-z])(\d+)$/, '$1 $2')
    .replace(/([a-z])([A-Z\d])|([A-Z])([A-Z][a-z])|(\d)([A-Za-z])/g, (_m, a, b, c, d, e, f) => `${a || c || e} ${b || d || f}`);
  return name[0].toUpperCase() + name.slice(1);
}

function run(triple, cpu, asm) {
  for (const extra of EXTRA_FLAGS[triple] ?? [[]]) {
    const r = spawnSync(MCA, [`--mtriple=${triple}`, `-mcpu=${cpu}`, ...extra, '-json', '-'], { input: asm, encoding: 'utf8', maxBuffer: 64 << 20 });
    if (r.error || r.status !== 0) continue;
    try {
      return JSON.parse(r.stdout);
    } catch {
      continue;
    }
  }
  return null;
}

// Retry a rejected probe with the ISA baseline flags the sched model was
// written for; a CPU that truly lacks the unit shows a shorter role only
// when even the flagged probe fails.
const EXTRA_FLAGS = {
  'riscv64-unknown-linux-gnu': [[], ['-mattr=+d'], ['-mattr=+v,+d']],
};

const baseOf = (raw) => raw.replace(/\.(?:[\x00-\x1f]|\d+)$/, '');

// Hand-written rules decide what is already covered; generated rules are
// rebuilt wholesale below and never consulted here.
const hand = table.rules.filter((r) => !r.family.startsWith('probe-')).map((r) => ({ ...r, re: new RegExp(r.match) }));
const covered = (cpu, base) => {
  const r = hand.find((x) => (x.cpus.includes(cpu) || x.cpus.includes('*')) && x.re.test(base));
  return !!r && r.label !== 'fallback';
};

// 1. Inventory probe per CPU (the ALU class doubles as it), grouping CPUs
// with identical resource lists so one model is classified once.
const groups = new Map(); // sig -> { triple, cpus, resources }
for (const triple of Object.keys(cpus).sort()) {
  for (const cpu of [...cpus[triple]].sort()) {
    const j = run(triple, cpu, CLASSES[triple][0][2]);
    if (!j?.TargetInfo?.Resources) throw new Error(`${MCA} failed for ${triple}/${cpu}`);
    const sig = `${triple}\n${j.TargetInfo.Resources.join('\n')}`;
    const g = groups.get(sig) ?? { triple, cpus: [], resources: j.TargetInfo.Resources };
    g.cpus.push(cpu);
    groups.set(sig, g);
  }
}

// 2. Classify every base of each group with the class probes.
const ordered = [...groups.values()].sort((a, b) => a.triple.localeCompare(b.triple) || a.cpus[0].localeCompare(b.cpus[0]));
const rules = [];
const usedLabels = new Set(hand.map((r) => r.label));
for (const g of ordered) {
  const classes = CLASSES[g.triple];
  const bases = [...new Set(g.resources.map(baseOf))];
  const use = new Map(bases.map((b) => [b, []])); // base -> role words, class order
  const rep = g.cpus[0];
  for (const [, word, asm] of classes) {
    const j = run(g.triple, rep, asm);
    if (!j) continue;
    for (const e of j.CodeRegions?.[0]?.ResourcePressureView?.ResourcePressureInfo ?? []) {
      if (!(e.ResourceUsage > 0)) continue;
      const b = baseOf(j.TargetInfo.Resources[e.ResourceIndex]);
      const words = use.get(b);
      if (words && !words.includes(word)) words.push(word);
    }
  }
  // Groups like 'Zn4AGU01' stand for their single-digit units: inherit the
  // children's classes when the probe left the group itself untouched.
  for (const [b, words] of use) {
    if (words.length) continue;
    const m = /^(.*?)(\d{2,})$/.exec(b);
    if (!m) continue;
    const kids = [...new Set(m[2])].map((d) => m[1] + d);
    if (kids.every((k) => use.has(k))) for (const k of kids) for (const w of use.get(k)) if (!words.includes(w)) words.push(w);
  }
  // 3. Heads: strip vendor and model prefixes, split camelCase and digits;
  // digit groups take their children's heads ("Zn4AGU01" -> "AGU0/AGU1").
  const heads = new Map(bases.map((b) => [b, humanize(b)]));
  for (const [b, head] of [...heads]) {
    if (!/\d{2,}$/.test(head)) continue;
    const m = /^(.*?)(\d{2,})$/.exec(b);
    const kids = m && [...new Set(m[2])].map((d) => m[1] + d);
    if (kids && kids.every((k) => heads.has(k))) heads.set(b, kids.map((k) => heads.get(k)).join('/'));
  }
  const family = `probe-${rep.replace(/[^A-Za-z0-9_-]/g, '_')}`;
  // 4. One rule per base still uncovered for at least one CPU of the group.
  for (const b of bases) {
    const mine = g.cpus.filter((c) => !covered(c, b));
    if (!mine.length) continue;
    const words = use.get(b);
    // The visible sub-label caps at three short role words, +N counts the
    // rest; full carries every role for the tooltip.
    const show = words.slice(0, 3).join(', ');
    const display = words.length ? `${heads.get(b)} (${show}${words.length > 3 ? ` +${words.length - 3}` : ''})` : `${b} (unknown)`;
    let label = `${family}~${b.replace(/[^A-Za-z0-9_-]/g, '_')}`;
    for (let i = 2; usedLabels.has(label); i++) label = `${family}~${b.replace(/[^A-Za-z0-9_-]/g, '_')}_${i}`;
    usedLabels.add(label);
    rules.push({
      label,
      family,
      cpus: mine,
      match: `^${b.replace(/[$()*+.?[\\\]^{|}]/g, '\\$&')}$`,
      display,
      ...(words.length > 3 ? { full: words.join(' / ') } : {}),
      cluster: clusterOf(words),
      port: portOf(b),
      source,
    });
  }
}

// The '*' fallback is a catch-all and must stay last: ruleFor takes the
// first match, so generated rules before it would never fire.
const tail = hand.filter((r) => r.label === 'fallback').map(stripRe);
const out = JSON.stringify({ meta: metaWith(table.meta, ordered, rules), rules: [...hand.filter((r) => r.label !== 'fallback').map(stripRe), ...rules, ...tail] }, null, 1) + '\n';
writeFileSync(tablePath, out);
console.log(`groups=${ordered.length} generated rules=${rules.length} hand rules=${hand.length} -> ${tablePath}`);

function metaWith(meta, orderedGroups, gen) {
  const base = meta.generated.replace(/; probe-<cpu> rules.*$/, '');
  return {
    ...meta,
    generated: `${base}; probe-<cpu> rules by scripts/gen-unit-names.mjs: ${orderedGroups.length} sched models, ${gen.length} rules`,
  };
}

function stripRe(r) {
  const { re, ...rest } = r;
  return rest;
}

function clusterOf(words) {
  if (!words.length) return 'other';
  if (words.includes('branch')) return 'branch';
  const mem = words.some((w) => /load|store|AGU/.test(w));
  const vec = words.some((w) => /FP|vec|FMA|cvt|shuffle/.test(w));
  if (mem) return 'mem';
  if (vec) return 'vec';
  return 'int';
}

function portOf(b) {
  const m = /Port(\d+)/.exec(b);
  return m ? +m[0].slice(4) : null;
}
