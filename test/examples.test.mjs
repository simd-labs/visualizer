// Run each architecture's example loop (src/examples.js) on every CPU of that
// architecture in cpus.json, with the args src/render.js passes to llvm-mca.
import { test } from 'node:test';
import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
import { dirname, join } from 'node:path';
import { run } from '../wasm/run.mjs';
import { buildModel } from '../src/model.js';
import { exampleFor } from '../src/examples.js';

const here = dirname(fileURLToPath(import.meta.url));
const cpus = JSON.parse(readFileSync(join(here, '../cpus.json'), 'utf8'));

assert.deepEqual(Object.keys(cpus).map((t) => t.split('-')[0]).sort(), ['aarch64', 'riscv64', 'x86_64']);
for (const [triple, list] of Object.entries(cpus)) {
  console.log(`examples: ${triple.split('-')[0]} runs on ${list.length} CPUs`);
  for (const cpu of list) {
    test(`${triple} ${cpu}`, () => {
      // the page's args: -mtriple from the option's triple, -mcpu, its default 100 iterations
      const args = ['-mtriple=' + triple, '-mcpu=' + cpu, '-iterations=100', '-timeline', '-json', '-issue-events'];
      const { exit, stdout, stderr } = run(exampleFor(triple), args);
      assert.equal(exit, 0, stderr.slice(0, 300));
      const region = JSON.parse(stdout).CodeRegions[0];
      assert.ok(region.TimelineView.TimelineInfo.length > 0, 'empty timeline');
      assert.ok(region.IssueEventView.IssueEvents.length > 0, 'no issue events');
      buildModel(JSON.parse(stdout));
    });
  }
}
