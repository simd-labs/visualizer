// Worker: instantiate the WASM llvm-mca once and run it on one input file.
// Reads JSON from stdin: { module, input, args }. llvm-mca writes -json
// through C stdout, which doubles under this Emscripten build (write() + print
// hook), so we pass "-o /out.txt" and read it back from MEMFS instead.
// Emscripten reads argv from Module.arguments, not from callMain.
import { readFileSync } from 'node:fs';
import { pathToFileURL } from 'node:url';

const { module: modPath, input, args } = JSON.parse(readFileSync(0, 'utf8'));
const { default: createModule } = await import(pathToFileURL(modPath).href);
let stderr = '';
try {
  const mod = {
    print: () => {},
    printErr: t => { stderr += t + '\n'; },
    arguments: [...args, '-o', '/out.txt', '/input.s'],
    preRun: [() => mod.FS.writeFile('/input.s', input)],
  };
  const M = await createModule(mod);
  const exit = M.callMain([]);
  // The Emscripten printErr hook fires twice per line for reasons internal to
  // this build, so consecutive duplicates are collapsed before reporting.
  stderr = [...new Set(stderr.split('\n'))].join('\n');
  let stdout = '';
  try { stdout = M.FS.readFile('/out.txt', { encoding: 'utf8' }); } catch { /* -o unused, e.g. -mcpu=help */ }
  process.stdout.write(JSON.stringify({ exit, stdout, stderr }));
} catch (e) {
  process.stdout.write(JSON.stringify({ exit: -1, stdout: '', stderr: stderr + '\n' + String(e) }));
}
