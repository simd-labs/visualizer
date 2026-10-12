// Run the WASM llvm-mca once: input via MEMFS, argv via callMain, returns
// { exit, stdout, stderr }. One node process per call, because an Emscripten
// instance cannot safely callMain twice.
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import { dirname, resolve } from 'node:path';

const here = dirname(fileURLToPath(import.meta.url));
const WORKER = resolve(here, 'run-worker.mjs');
const MODULE = process.env.MCA_WASM || resolve(here, 'dist/llvm-mca.js');

export function run(source, args) {
  const r = spawnSync(process.execPath, [WORKER], {
    input: JSON.stringify({ module: MODULE, input: source, args }),
    encoding: 'utf8',
    maxBuffer: 64 << 20,
  });
  return JSON.parse(r.stdout);
}
