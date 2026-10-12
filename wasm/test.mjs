// Diff WASM llvm-mca JSON output against the committed fixtures for the three
// fixture loops, then re-run one fixture with a swapped -mcpu to prove the
// comparison can actually fail.
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { run } from './run.mjs';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const fix = join(root, 'test/fixtures');
const cases = JSON.parse(readFileSync(join(root, 'wasm/fixture-cases.json'), 'utf8'));

let failed = 0;
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
const c = cases[0];
const wrong = run(readFileSync(join(fix, c.input), 'utf8'),
  c.args.map(a => a === c.swap.from ? c.swap.to : a));
const mutationCaught = wrong.stdout !== readFileSync(join(fix, c.fixture), 'utf8');
console.log(`${mutationCaught ? 'PASS' : 'FAIL'} mutation ${c.swap.from} -> ${c.swap.to}: diff ${mutationCaught ? 'non-empty' : 'empty'}`);
if (!mutationCaught) failed = 1;

process.exit(failed);
