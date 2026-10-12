// Runs the WASM llvm-mca in a Web Worker so the page stays responsive.
// The worker fetches and compiles the ~12 MB binary as soon as the page
// loads and reports progress; runs wait on that one-time load.
const worker = new Worker(new URL('mca-worker.js', import.meta.url), { type: 'module' });
let pendingRun = null;
let queue = Promise.resolve();

export function initMca({ onProgress, onReady, onLoadError }) {
  worker.addEventListener('message', (e) => {
    const m = e.data;
    if (m.type === 'progress') onProgress(m.got, m.total);
    else if (m.type === 'ready') onReady();
    else if (m.type === 'load-error') onLoadError(m.message);
    else if (m.type === 'result' && pendingRun) {
      pendingRun(m);
      pendingRun = null;
    }
  });
}

// One run at a time: an Emscripten instance cannot safely callMain twice,
// so each run rebuilds an instance from the cached compiled module.
export function runMca(input, args) {
  const run = queue.then(() => new Promise((resolve) => {
    pendingRun = resolve;
    worker.postMessage({ input, args });
  }));
  queue = run.catch(() => {});
  return run;
}
