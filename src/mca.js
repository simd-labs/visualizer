// Runs the WASM llvm-mca in a Web Worker so the page stays responsive.
// The module starts the ~12 MB download as soon as the page has rendered,
// which is what the spec's "lazy" means here: it never blocks first paint,
// only runs. The Run button shows progress until the module is ready.
const worker = new Worker(new URL('mca-worker.js', import.meta.url), { type: 'module' });
let pendingRun = null;
let hooks = null;
let loadFailed = false;
let queue = Promise.resolve();

worker.addEventListener('error', (e) => {
  e.preventDefault(); // keep the failure off the console's unhandled list; we surface it ourselves
  fail(new Error(e.message || 'llvm-mca worker failed'));
});
worker.addEventListener('messageerror', () => fail(new Error('llvm-mca worker sent an unreadable message')));

// A bootstrap failure (worker 'error' before ready, or a 'load-error'
// message) is permanent; a failure once the module is ready rejects only the
// pending run, so the page shows the error and Run stays retryable.
let ready = false;

function fail(error) {
  if (!ready) {
    if (loadFailed) return;
    loadFailed = true;
  }
  if (pendingRun) {
    pendingRun(Promise.reject(error));
    pendingRun = null;
  }
  if (!ready) hooks?.onLoadError(String(error.message ?? error));
}

export function initMca({ onProgress, onReady, onLoadError }) {
  hooks = { onProgress, onReady, onLoadError };
  worker.addEventListener('message', (e) => {
    const m = e.data;
    if (m.type === 'progress') onProgress(m.got, m.total);
    else if (m.type === 'ready') { ready = true; onReady(); }
    else if (m.type === 'load-error') fail(new Error(m.message));
    else if (m.type === 'result' && pendingRun) {
      pendingRun(m);
      pendingRun = null;
    }
  });
}

// One run at a time: an Emscripten instance cannot safely callMain twice,
// so each run rebuilds an instance from the cached compiled module.
export function runMca(input, args) {
  const run = queue.then(
    () =>
      new Promise((resolve, reject) => {
        if (loadFailed) {
          reject(new Error('llvm-mca failed to load'));
          return;
        }
        pendingRun = resolve;
        worker.postMessage({ input, args });
      })
  );
  queue = run.catch(() => {});
  return run;
}
