// simdref rows beside the llvm-mca run: the annotation column and the
// validation view. The pure functions first; node tests drive them with
// fixtures. The loaders at the bottom fetch the simdref-web modules at
// run time and never touch the network at import time.

export const SIMDREF_ORIGIN = 'https://simdref.diamondinoia.com';

function num(v) {
  if (v === null || v === undefined || v === '') return null;
  const n = Number(v);
  return Number.isFinite(n) ? n : null;
}

// llvm-mca's own static values per instruction, indexed like
// CodeRegions[0].Instructions: InstructionInfoView in the -json output.
export function mcaInfo(json) {
  const list = json?.CodeRegions?.[0]?.InstructionInfoView?.InstructionList;
  const out = [];
  if (Array.isArray(list)) {
    for (const e of list) {
      if (e && Number.isInteger(e.Instruction)) {
        out[e.Instruction] = {
          latency: e.Latency,
          rthroughput: e.RThroughput,
          uops: e.NumMicroOpcodes,
        };
      }
    }
  }
  return out;
}

// The simdref key for a selected llvm -mcpu name, from cores.json. One
// exact name beats several llvm -mcpu matches; a tie resolves to null,
// never a guess between cores.
export function coreKeyFor(cores, cpu) {
  if (!cores || typeof cpu !== 'string') return null;
  const named = [];
  const mcpu = [];
  for (const [key, entry] of Object.entries(cores)) {
    if (!entry || typeof entry !== 'object') continue;
    if (Array.isArray(entry.aliases) && entry.aliases.includes(cpu)) named.push(key);
    else if (entry.llvm_cpu === cpu) mcpu.push(key);
  }
  if (named.length === 1) return named[0];
  if (named.length === 0 && mcpu.length === 1) return mcpu[0];
  return null;
}

// The measurement row of one detail record for the selected core.
export function refRowFor(record, coreKey) {
  const rows = record?.measurements;
  if (!coreKey || !Array.isArray(rows)) return null;
  for (const row of rows) {
    if (row && row.uarch === coreKey) return row;
  }
  return null;
}

// The annotation column's text for one row: latency, throughput, uops,
// ports, source and measured or modeled. "-" is the export's absent value.
// No row resolves to "unknown".
export function columnCell(row) {
  if (!row) return 'unknown';
  const parts = [];
  for (const [value, suffix] of [[row.latency, 'c'], [row.tpLoop, 'tp'], [row.uops, 'u']]) {
    if (value !== undefined && value !== null && value !== '' && value !== '-') parts.push(String(value) + suffix);
  }
  for (const value of [row.ports, row.source, row.sourceKind]) {
    if (value !== undefined && value !== null && value !== '' && value !== '-') parts.push(String(value));
  }
  return parts.length ? parts.join(' ') : 'unknown';
}

// The difference, llvm-mca minus simdref; null when either side has no number.
function diffNum(a, b) {
  const x = num(a);
  const y = num(b);
  return x === null || y === null ? null : x - y;
}

// Everything the column and the validation view show for one run. keys
// are the per-instruction catalog keys, records maps a key to its detail
// chunk record. Differences are llvm-mca minus simdref. The summary
// counts measured rows within 1 cycle and lines with no measured row.
export function buildAnnotations(model, json, keys, records, coreKey) {
  const info = mcaInfo(json);
  const cells = [];
  const rows = [];
  let within1 = 0;
  let noMeasured = 0;
  for (let i = 0; i < model.instructions.length; i++) {
    const key = keys ? keys[i] : null;
    const record = key && records ? records[key] : null;
    const ref = refRowFor(record, coreKey);
    cells.push(columnCell(ref));
    const mca = info[i] || null;
    const diff = {
      latency: diffNum(mca && mca.latency, ref && ref.latency),
      rthroughput: diffNum(mca && mca.rthroughput, ref && ref.tpLoop),
      uops: diffNum(mca && mca.uops, ref && ref.uops),
    };
    rows.push({
      instruction: model.instructions[i],
      mca: {
        latency: mca ? mca.latency : null,
        rthroughput: mca ? mca.rthroughput : null,
        uops: mca ? mca.uops : null,
      },
      ref: ref
        ? {
            latency: ref.latency ?? null,
            rthroughput: ref.tpLoop ?? null,
            uops: ref.uops ?? null,
            ports: ref.ports ?? null,
            source: ref.source ?? null,
            kind: ref.sourceKind ?? 'unknown',
          }
        : null,
      diff,
    });
    const measured = ref ? ref.sourceKind === 'measured' : false;
    if (measured && diff.latency !== null && Math.abs(diff.latency) <= 1) within1 += 1;
    if (!measured) noMeasured += 1;
  }
  return { cells, rows, summary: { within1, noMeasured, total: model.instructions.length } };
}

// The architecture key the identity worker expects, from an llvm triple.
export function archOf(triple) {
  const t = String(triple || '');
  return t.startsWith('x86') ? 'x86' : t.startsWith('riscv') ? 'riscv64' : 'aarch64';
}

// ---- run-time loaders ------------------------------------------------

let runtimePromise = null;

// Load data.js and lines.js from the simdref-web site, check the export
// schema and read cores.json. Any failure marks the data unavailable and
// the page keeps working.
export function loadRuntime() {
  if (!runtimePromise) {
    runtimePromise = (async () => {
      try {
        const [data, lines] = await Promise.all([
          import(SIMDREF_ORIGIN + '/data.js'),
          import(SIMDREF_ORIGIN + '/lines.js'),
        ]);
        const stamp = await data.fetchJson('build_stamp.json');
        if (data.schemaCheck(stamp)) return { ok: false, reason: 'schema mismatch' };
        const cores = await data.fetchJson('cores.json');
        if (!cores) return { ok: false, reason: 'cores.json missing' };
        return { ok: true, data, lines, cores };
      } catch (e) {
        return { ok: false, reason: String((e && e.message) || e) };
      }
    })();
  }
  return runtimePromise;
}

let workerPromise = null;
let seq = 0;

// identity.js is a worker script; a blob import keeps the worker on this
// page while the module itself loads from the simdref-web site. The
// message protocol is the module's own: init, then identify per document.
function identityWorker() {
  if (!workerPromise) {
    workerPromise = (async () => {
      const rt = await loadRuntime();
      if (!rt.ok) throw new Error(rt.reason);
      const rows = await rt.data.loadEncodingsShard();
      if (!rows) throw new Error('encodings shard missing');
      const src = 'import ' + JSON.stringify(SIMDREF_ORIGIN + '/identity.js');
      const url = URL.createObjectURL(new Blob([src], { type: 'text/javascript' }));
      const worker = new Worker(url, { type: 'module' });
      URL.revokeObjectURL(url);
      const pending = new Map();
      let onInit = null;
      worker.addEventListener('message', (e) => {
        const m = e.data;
        if (onInit && (m.type === 'ready' || m.type === 'init-failed')) {
          const settle = onInit;
          onInit = null;
          if (m.type === 'ready') settle[0]();
          else settle[1](new Error(m.error));
          return;
        }
        const pair = pending.get(m.seq);
        if (!pair) return;
        pending.delete(m.seq);
        if (m.type === 'result') pair[0](m.results);
        else pair[1](new Error(m.error));
      });
      await new Promise((resolve, reject) => {
        onInit = [resolve, reject];
        worker.postMessage({ type: 'init', rows, base: SIMDREF_ORIGIN + '/wasm-v1/' });
      });
      return {
        identify(text, arch) {
          const id = ++seq;
          return new Promise((resolve, reject) => {
            pending.set(id, [resolve, reject]);
            worker.postMessage({ type: 'identify', seq: id, text, arch });
          });
        },
      };
    })();
  }
  return workerPromise;
}

// Resolve one document of instruction lines to catalog keys, one slot per
// line. Returns null when the data is unavailable.
export async function resolveKeys(texts, arch) {
  try {
    const rt = await loadRuntime();
    if (!rt.ok) return null;
    const text = texts.join('\n');
    const lines = rt.lines.splitAsmLines(text);
    const results = await identityWorker().then((w) => w.identify(text, arch));
    if (!Array.isArray(results)) return null;
    const keys = new Array(lines.length).fill(null);
    for (const r of results) {
      if (r && Number.isInteger(r.n) && r.n >= 1 && r.n <= lines.length && r.status === 'row') {
        keys[r.n - 1] = r.key;
      }
    }
    return keys;
  } catch (e) {
    return null;
  }
}

// The catalog mnemonic inside a db_key: "x86:jnz (rel32)" is "jnz",
// "riscv:addi" is "addi". The chunk file is keyed by it, and an alias
// spelling (jne, decl) never names its own chunk.
export function mnemonicOfKey(key) {
  const s = String(key || '');
  const colon = s.indexOf(':');
  const rest = colon >= 0 ? s.slice(colon + 1) : s;
  let end = rest.length;
  for (const sep of [' ', '(']) {
    const i = rest.indexOf(sep);
    if (i >= 0 && i < end) end = i;
  }
  return rest.slice(0, end);
}

// The detail records behind one run's keys: one chunk fetch per key's
// mnemonic. Returns a map from catalog key to record.
export async function loadRecords(data, keys) {
  const records = {};
  const seen = new Set();
  for (const key of keys) {
    if (!key) continue;
    const prefix = data.chunkPrefix(mnemonicOfKey(key));
    if (seen.has(prefix)) continue;
    seen.add(prefix);
    const chunk = await data.loadChunk(prefix);
    if (chunk) for (const [k, record] of Object.entries(chunk)) records[k] = record;
  }
  return records;
}
