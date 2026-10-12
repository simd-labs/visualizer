// Diff WASM llvm-mca JSON output against the committed fixtures for the three
// fixture loops, then re-run one fixture with a swapped -mcpu to prove the
// comparison can actually fail. Then check -issue-events: summing each unit's
// cycles over all issue events must reproduce the ResourcePressureView cells
// (per instruction, plus the per-iteration totals row) at llvm-mca's printed
// precision. Port of the spike's check_issue_events.py to JS.
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { run } from './run.mjs';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const fix = join(root, 'test/fixtures');
const cases = JSON.parse(readFileSync(join(root, 'wasm/fixture-cases.json'), 'utf8'));

let failed = 0;
const fail = msg => { console.log(`FAIL ${msg}`); failed = 1; };

for (const c of cases) {
  const expected = readFileSync(join(fix, c.fixture), 'utf8');
  const { exit, stdout, stderr } = run(readFileSync(join(fix, c.input), 'utf8'), c.args);
  const ok = exit === 0 && stdout === expected;
  if (!ok) failed = 1;
  console.log(`${ok ? 'PASS' : 'FAIL'} ${c.fixture} exit=${exit}` +
    (ok ? '' : ` stderr=${JSON.stringify(stderr.slice(0, 200))}` +
      ` cmp=${stdout === expected ? 'same' : 'DIFF'}`));
}

// Mutation: same loop, different -mcpu must not match.
const c0 = cases[0];
const wrong = run(readFileSync(join(fix, c0.input), 'utf8'),
  c0.args.map(a => a === c0.swap.from ? c0.swap.to : a));
const mutationCaught = wrong.exit === 0 && wrong.stdout !== readFileSync(join(fix, c0.fixture), 'utf8');
console.log(`${mutationCaught ? 'PASS' : 'FAIL'} mutation ${c0.swap.from} -> ${c0.swap.to}: diff ${mutationCaught ? 'non-empty' : 'empty'}`);
if (!mutationCaught) failed = 1;

// Issue events vs ResourcePressureView, cell by cell.
// env DROP_UNIT=u drops that unit's issue events (mutation: must fail).
const DROP_UNIT = 'DROP_UNIT' in process.env ? Number(process.env.DROP_UNIT) : null;
const round2 = v => Math.round(100 * v) / 100;
for (const c of cases) {
  const iters = Number(c.args.find(a => a.startsWith('-iterations=')).split('=')[1]);
  const source = readFileSync(join(fix, c.input), 'utf8');
  const res = run(source, [...c.args, '-issue-events']);
  if (res.exit !== 0) { fail(`${c.fixture} issue-events run exit=${res.exit}`); continue; }
  const on = JSON.parse(res.stdout);
  let match = 0, mismatch = 0;
  for (const reg of on.CodeRegions) {
    const nInst = reg.Instructions.length;
    const tl = reg.TimelineView.TimelineInfo;
    const nUnits = on.TargetInfo.Resources.length;
    // LLVM 23 pads multi-unit resource names with a control character (unit
    // id within the group, e.g. "Zn4FP45\x01"); WASM events print ".1" instead.
    const norm = n => n.replace(/[\x00-\x1f]/g, ch => String(ch.charCodeAt(0)));
    const resNames = new Set(on.TargetInfo.Resources.map(norm));
    // Every event: indices in range, cycle inside its timeline instance's
    // [issued, executed) window, unit id < nUnits and its name in TargetInfo.
    for (const ev of reg.IssueEventView.IssueEvents) {
      const row = tl[ev.instruction + ev.iteration * nInst];
      if (ev.instruction < 0 || ev.instruction >= nInst ||
          ev.iteration < 0 || ev.iteration >= iters || !row ||
          ev.cycle < row.CycleIssued || ev.cycle >= row.CycleExecuted)
        { mismatch++; console.log(`[${c.fixture}] BAD EVENT ${JSON.stringify(ev)}`.slice(0, 200)); continue; }
      for (const u of ev.units)
        if (u.unit < 0 || u.unit >= nUnits || !resNames.has(norm(u.name))) {
          mismatch++;
          console.log(`[${c.fixture}] BAD UNIT ${JSON.stringify(u)}`);
        }
    }
    // (inst, unit) -> fraction the events hold that unit over all iterations.
    const sums = new Map();
    for (const ev of reg.IssueEventView.IssueEvents)
      for (const u of ev.units) {
        if (u.unit === DROP_UNIT) continue;
        const k = `${ev.instruction},${u.unit}`;
        sums.set(k, (sums.get(k) ?? 0) + u.cycles_num / u.cycles_den);
      }
    // inst -> unit -> usage; inst == nInst is the per-iteration totals row.
    const rpi = new Map();
    for (const cell of reg.ResourcePressureView.ResourcePressureInfo) {
      if (!rpi.has(cell.InstructionIndex)) rpi.set(cell.InstructionIndex, new Map());
      rpi.get(cell.InstructionIndex).set(cell.ResourceIndex, cell.ResourceUsage);
    }
    for (let i = 0; i < nInst; i++) {
      for (const u of rpi.get(i)?.keys() ?? []) {
        const want = round2(rpi.get(i).get(u) * iters);
        const got = sums.get(`${i},${u}`) ?? 0;
        if (Math.abs(got - want) < 1e-9) match++;
        else {
          mismatch++;
          if (mismatch <= 5)
            console.log(`[${c.fixture}] MISMATCH inst=${i} unit=${u}: events=${got} want=${want}`);
        }
      }
    }
    // Totals row per unit column: sum of the column's printed per-inst cells
    // gives llvm-mca's printed total, so comparing event-sums against that
    // one printed number avoids the 1/3 accumulation mismatch.
    for (const [u, totUsage] of rpi.get(nInst) ?? []) {
      const want = round2(totUsage * iters);
      let got = 0;
      for (const [k, v] of sums) if (Number(k.split(',')[1]) === u) got += v;
      if (Math.abs(got - want) < 1e-9) match++;
      else {
        mismatch++;
        if (mismatch <= 5)
          console.log(`[${c.fixture}] TOT MISMATCH unit=${u}: events=${got} want=${want}`);
      }
    }
  }
  const expectedCells = { 'znver4.json': 30, 'skylake.json': 15, 'neoverse-v2.json': 22 }[c.fixture];
  const ok = mismatch === 0 && match === expectedCells;
  if (match !== expectedCells) fail(`${c.fixture} expected ${expectedCells} cells, compared ${match}`);
  if (!ok) failed = 1;
  console.log(`${ok ? 'PASS' : 'FAIL'} ${c.fixture} issue-events: ${match} cells matched, ${mismatch} mismatched`);
}

if (failed) fail('see MISMATCH lines above');
process.exit(failed);
