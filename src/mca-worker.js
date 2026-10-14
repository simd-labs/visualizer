// Web Worker: fetch and compile the WASM llvm-mca once, then run it once per
// message. -json output goes through C stdout, which doubles under this
// Emscripten build, so each run passes "-o /out.txt" and reads MEMFS back.
let createModule;
let compiled;
let readyResolve;
const ready = new Promise((r) => { readyResolve = r; });

(async () => {
  try {
    const [response, glue] = await Promise.all([
      fetch('../wasm/dist/llvm-mca.wasm'),
      import('../wasm/dist/llvm-mca.js'),
    ]);
    if (!response.ok) throw new Error(`HTTP ${response.status} fetching llvm-mca.wasm`);
    // Content-Length is the compressed size while the reader counts the
    // decompressed body, so a gzip stream would show got > total ("3.7 MB of
    // 2.7 MB"). Under compression the header is useless: fall back to the
    // decompressed total, known at the end.
    const contentLength = +response.headers.get('content-length') || 0;
    postMessage({ type: 'progress', got: 0, total: contentLength });
    const chunks = [];
    let got = 0;
    for (const reader = response.body.getReader();;) {
      const { done, value } = await reader.read();
      if (done) break;
      chunks.push(value);
      got += value.length;
      postMessage({ type: 'progress', got, total: Math.max(contentLength, got) });
    }
    const bytes = new Uint8Array(got);
    let offset = 0;
    for (const c of chunks) { bytes.set(c, offset); offset += c.length; }
    createModule = glue.default;
    compiled = await WebAssembly.compile(bytes);
    readyResolve();
    postMessage({ type: 'ready' });
  } catch (e) {
    postMessage({ type: 'load-error', message: String(e) });
  }
})();

onmessage = async (e) => {
  await ready; // on a load error this never resolves; the page already heard about it
  const { input, args } = e.data;
  let stderr = '';
  let exit = -1;
  let stdout = '';
  try {
    const mod = {
      instantiateWasm: (imports, success) => {
        // Emscripten's createWasm Promise never rejects, so a failed
        // instantiate must throw on a macrotask: it becomes an onerror on the
        // worker, which the page relays to the pending run
        WebAssembly.instantiate(compiled, imports).then(success, (err) => setTimeout(() => { throw err; }));
        return {};
      },
      noInitialRun: true,
      print: () => {},
      printErr: (t) => { stderr += t + '\n'; },
      preRun: [() => mod.FS.writeFile('/input.s', input)],
    };
    const M = await createModule(mod);
    exit = M.callMain([...args, '-o', '/out.txt', '/input.s']);
    // The printErr hook fires twice per line on this build; collapse duplicates
    stderr = [...new Set(stderr.split('\n'))].join('\n');
    try { stdout = mod.FS.readFile('/out.txt', { encoding: 'utf8' }); } catch { /* nothing written on failure */ }
  } catch (e2) {
    stderr += '\n' + String(e2);
  }
  postMessage({ type: 'result', exit, stdout, stderr });
};
