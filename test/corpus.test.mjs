// Corpus test: every compiled kernel in test/corpus/asm through the WASM
// llvm-mca with the page's args, then through src/model.js. One test per
// (asm file, kind, cpu) so failures name both the kernel and the CPU.
//
// Statuses recorded in test/corpus/results.json per case:
//   pass           wasm ran clean, model built, every invariant held
//   expected-fail  case is on KNOWN_FAILURES and failed the way it says
//   fail           case failed in a new way, or a KNOWN_FAILURES case passed
//   skip           the CPU lacks the ISA the asm was compiled for
// The suite is red on 'fail'; a newly fixed known failure is also red, with
// the message telling you to drop it from KNOWN_FAILURES.
import { test, after } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync, readdirSync, writeFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { run } from '../wasm/run.mjs';
import { buildModel, tokenPositionsAt, TimelineMappingError } from '../src/model.js';

const here = dirname(fileURLToPath(import.meta.url));
const ASM = join(here, 'corpus/asm');
const cpus = JSON.parse(readFileSync(join(here, '../cpus.json'), 'utf8'));

const TRIPLE_TAG = {
  x86: 'x86_64-unknown-linux-gnu',
  aarch64: 'aarch64-unknown-linux-gnu',
  riscv64: 'riscv64-unknown-linux-gnu',
};

// The -march in the file name sets the ISA floor. A zmm or %k register in the
// asm raises it to AVX-512 (see effectiveIsa below).
const ISA_OF = (tag) => {
  if (tag.includes('rv64gcv')) return 'rvv';
  if (tag.includes('sve2')) return 'sve2';
  if (tag.includes('armv8.2')) return 'neon';
  if (tag.includes('x86-64-v4') || tag.includes('sapphirerapids')) return 'avx512';
  if (tag.includes('x86-64-v3') || tag.includes('znver4')) return 'avx2';
  return 'sse4';
};

const CPU_ISA = {
  'x86_64-unknown-linux-gnu': {
    'skylake': 'avx2', 'icelake-server': 'avx512', 'alderlake': 'avx2',
    'znver3': 'avx2', 'znver4': 'avx512', 'znver5': 'avx512',
  },
  'aarch64-unknown-linux-gnu': {
    'neoverse-n1': 'neon', 'neoverse-v2': 'sve2', 'cortex-a55': 'neon',
    'cortex-a76': 'neon', 'apple-m1': 'neon', 'neoverse-v1': 'sve',
    'neoverse-n2': 'sve2', 'a64fx': 'sve', 'grace': 'sve2',
  },
  'riscv64-unknown-linux-gnu': {
    'sifive-u74': 'scalar', 'sifive-p670': 'rvv', 'sifive-x280': 'rvv',
    'sifive-p550': 'scalar', 'sifive-p870-d': 'rvv', 'rocket-rv64': 'scalar',
  },
};

// "case @ cpu" -> the error substring that case must still fail with. Each
// entry is a known failure (see the reason in known-failures.json): a case that
// starts passing, or fails differently, fails the suite until its entry changes.
const KNOWN_FAILURES = new Map(
  Object.entries(JSON.parse(readFileSync(join(here, 'corpus/known-failures.json'), 'utf8')))
);


const files = readdirSync(ASM).filter((f) => f.endsWith('.s')).sort();

// Full files are the paste format: the compiler's whole output for one TU.
// Region files hold just the marked loop, re-indented with loop alignment.

const results = [];
const tally = { pass: 0, 'expected-fail': 0, fail: 0, skip: 0 };
const byKey = new Map();

function record(caseName, cpu, status, error) {
  const key = `${caseName}|${cpu}`;
  if (byKey.has(key)) throw new Error(`duplicate case key ${key}`);
  byKey.set(key, { case: caseName, cpu, status, error: error ?? null });
  results.push(byKey.get(key));
  tally[status]++;
}

const checkModel = (stdout, iters) => {
  // Returns null on success, else the first error line. Capped model checks
  // are the common case; anything odd is returned verbatim.
  const json = JSON.parse(stdout);
  const model = buildModel(json);
  const nRes = json.TargetInfo.Resources.length;
  const { maxCycle } = model.cycleIndex;
  const stages = new Set(['dispatch', 'waiting', 'ready', 'execute', 'retire']);
  // an instance is live on [dispatched, retired): each live instance has exactly one token, nothing else has one
  const delta = new Array(maxCycle + 2).fill(0);
  const rowOf = new Map();
  for (const r of model.rows) {
    delta[r.dispatched] += 1;
    delta[r.retired] -= 1;
    rowOf.set(`${r.instr},${r.iter}`, r);
  }
  let live = 0;
  for (let c = 0; c <= maxCycle; c++) {
    live += delta[c];
    const seen = new Set();
    for (const t of tokenPositionsAt(model, c)) {
      const k = `${t.instr},${t.iter}`;
      if (seen.has(k)) return `cycle ${c}: instruction ${k} in two tokens (stage ${t.stage})`;
      seen.add(k);
      const r = rowOf.get(k);
      if (!r || c < r.dispatched || c >= r.retired)
        return `cycle ${c}: instruction ${k} in stage ${t.stage} outside its life [${r?.dispatched}, ${r?.retired})`;
      if (!stages.has(t.stage)) return `cycle ${c}: instruction ${k} in unknown stage ${t.stage}`;
      for (const u of [...t.units, ...t.lastUnits])
        if (!(u >= 0 && u < nRes))
          return `cycle ${c}: instruction ${k} on unit ${u}, only ${nRes} resources exist`;
    }
    if (seen.size !== live) return `cycle ${c}: ${seen.size} tokens for ${live} live instances`;
  }
  const reg = json.CodeRegions[0];
  const n = model.instructions.length;
  const sums = new Map();
  for (const ev of reg.IssueEventView.IssueEvents)
    for (const u of ev.units)
      sums.set(`${ev.instruction},${u.unit}`,
        (sums.get(`${ev.instruction},${u.unit}`) ?? 0) + u.cycles_num / u.cycles_den);
  const rpi = new Map();
  for (const cell of reg.ResourcePressureView.ResourcePressureInfo) {
    if (!rpi.has(cell.InstructionIndex)) rpi.set(cell.InstructionIndex, new Map());
    rpi.get(cell.InstructionIndex).set(cell.ResourceIndex, cell.ResourceUsage);
  }
  const round2 = (v) => Math.round(100 * v) / 100;
  for (let i = 0; i < n; i++)
    for (const [u, usage] of rpi.get(i) ?? []) {
      const want = round2(usage * iters);
      const got = sums.get(`${i},${u}`) ?? 0;
      if (Math.abs(got - want) > 1e-9)
        return `heatmap: inst ${i} unit ${u} events=${got} want=${want}`;
    }
  for (const [u, tot] of rpi.get(n) ?? []) {
    let got = 0;
    for (const [k, v] of sums) if (Number(k.split(',')[1]) === u) got += v;
    if (Math.abs(got - round2(tot * iters)) > 1e-9)
      return `heatmap totals row: unit ${u} events=${got} want=${round2(tot * iters)}`;
  }
  return null;
};


after(() => {
  writeFileSync(
    join(here, 'corpus/results.json'),
    JSON.stringify({ tally, results }, null, 1) + '\n'
  );
  console.log(`corpus results: ${results.length} runs over ${files.length} asm files`,
    JSON.stringify(tally));
});

for (const file of files) {
  const tag = file.replace(/\.(full|region)\.s$/, '');
  const triple = TRIPLE_TAG[Object.keys(TRIPLE_TAG).find((t) => tag.includes(t))];
  const isa = ISA_OF(tag);
  const src = readFileSync(join(ASM, file), 'utf8');

  // zmm/EVEX instructions need AVX512F even when the codegen targets znver4:
  // llvm-mca rejects zmm forms on AVX2-only CPUs with "unsupported instruction".
  const needsAvx512 = /\bzmm[0-9]+\b|\b%k[0-7]\b/.test(src);
  const effectiveIsa = needsAvx512 ? 'avx512' : isa;

  test(`${file}`, async (t) => {
    const list = cpus[triple] ?? [];
    const wanted = Object.keys(CPU_ISA[triple] ?? {}).filter((c) => list.includes(c));
    for (const cpu of wanted) {
      const cpuIsa = CPU_ISA[triple][cpu];
      const rank = { scalar: 0, sse4: 1, neon: 1, avx2: 2, avx512: 3, sve: 2, rvv: 2, sve2: 3 };
      if (rank[cpuIsa] < rank[effectiveIsa]) { record(file, cpu, 'skip', `cpu ${cpu} lacks ${effectiveIsa}`); continue; }

      const caseLabel = `${file} @ ${cpu}`;
      await t.test(cpu, () => {
        const { exit, stdout, stderr } = run(src, [
          '-mtriple=' + triple, '-mcpu=' + cpu,
          '-iterations=100', '-timeline', '-json', '-issue-events',
        ]);
        let firstError = null;
        const known = KNOWN_FAILURES.get(caseLabel);

        // any llvm-mca rejection counts as a failure, so the known list shows every one
        if (exit !== 0) {
          firstError = (stderr.split('\n').find((l) => l.trim()) || `exit ${exit}`).slice(0, 300);
        } else {
          try {
            const err = checkModel(stdout, 100);
            if (err) firstError = err;
          } catch (e) {
            if (e instanceof TimelineMappingError) firstError = `TimelineMappingError: ${e.message}`;
            else firstError = `${e.name}: ${e.message}`;
          }
        }

        if (firstError == null) {
          if (known) {
            record(file, cpu, 'fail', `known failure now passes: drop KNOWN_FAILURES entry for ${caseLabel}`);
            assert.fail(`KNOWN_FAILURES entry now passes, remove it: ${caseLabel}`);
          }
          record(file, cpu, 'pass');
          return;
        }
        if (known != null && known !== '' && firstError.includes(known)) {
          record(file, cpu, 'expected-fail', firstError);
          return;
        }
        if (known != null) {
          record(file, cpu, 'fail',
            `known failure changed shape: expected to contain ${JSON.stringify(known)}, got ${JSON.stringify(firstError)}`);
          assert.fail(`known failure changed shape for ${caseLabel}`);
          return;
        }
        record(file, cpu, 'fail', firstError);
        assert.fail(`${caseLabel}: ${firstError}`);
      });
    }
  });
}
