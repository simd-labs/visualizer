export class TimelineMappingError extends Error {
  constructor(message) {
    super(message);
    this.name = 'TimelineMappingError';
  }
}

// Entry i covers instruction i % n, iteration floor(i / n). llvm-mca's JSON keeps
// the rows before the first row that has not retired within -timeline-max-cycles,
// so a cycle cap leaves a prefix. A cap on iterations keeps n x iterations entries.
// Both cases map the same way; more entries than n x SummaryView.Iterations cannot happen.
export function buildModel(json) {
  const regions = json?.CodeRegions ?? [];
  const region = regions[0];
  if (
    regions.length !== 1 ||
    !Array.isArray(region.Instructions) ||
    !Array.isArray(region.TimelineView?.TimelineInfo) ||
    !Number.isInteger(region.SummaryView?.Iterations) ||
    !Array.isArray(region.ResourcePressureView?.ResourcePressureInfo) ||
    !Array.isArray(json.TargetInfo?.Resources)
  ) {
    throw new TimelineMappingError('not llvm-mca -timeline -json output with exactly one code region');
  }
  const instructions = region.Instructions;
  const entries = region.TimelineView.TimelineInfo;
  const CYCLES = ['CycleDispatched', 'CycleReady', 'CycleIssued', 'CycleExecuted', 'CycleRetired'];
  if (entries.some((e) => CYCLES.some((k) => !Number.isInteger(e[k]) || e[k] < 0))) {
    throw new TimelineMappingError('a TimelineInfo entry has a missing or non-integer cycle field');
  }
  const n = instructions.length;
  const total = region.SummaryView.Iterations;
  if (n === 0) throw new TimelineMappingError('no instructions in CodeRegions[0]');
  if (entries.length > n * total) {
    throw new TimelineMappingError(
      `TimelineInfo has ${entries.length} entries, more than ${n} instructions x ${total} iterations`
    );
  }

  const rows = entries.map((e, i) => ({
    instr: i % n,
    iter: Math.floor(i / n),
    dispatched: e.CycleDispatched,
    ready: e.CycleReady,
    issued: e.CycleIssued,
    executed: e.CycleExecuted,
    retired: e.CycleRetired,
  }));

  const nRes = json.TargetInfo.Resources.length;
  const matrix = Array.from({ length: n + 1 }, () => new Array(nRes).fill(0));
  // ResourcePressureInfo rows are already per-iteration: InstructionIndex
  // < n is the instruction's mean pressure, the row with
  // InstructionIndex == n is the per-iteration totals row. Both match the
  // text tables "Resource pressure by instruction"/"per iteration".
  for (const { InstructionIndex, ResourceIndex, ResourceUsage } of region.ResourcePressureView.ResourcePressureInfo) {
    if (InstructionIndex <= n) matrix[InstructionIndex][ResourceIndex] = ResourceUsage;
  }

  const events = parseIssueEvents(region);
  // Cycle-indexed token lookup, built once per model so tokenPositionsAt
  // does not rescan every event of a long run per slider tick. Each bucket
  // lists the row indexes entering a stage at that cycle, so the work per
  // cycle stays proportional to the machine's width, not the event count.
  const maxCycle = rows.length ? Math.max(...rows.map((r) => Math.max(r.retired, r.issued + 1))) : 0;
  const enter = Array.from({ length: maxCycle + 1 }, () => []);
  const rowEvents = new Array(rows.length).fill(null);
  if (events) {
    for (const ev of events) rowEvents[ev.instr + ev.iter * n] = ev;
  }
  rows.forEach((r, i) => {
    const ev = rowEvents[i];
    const span = (a, b, stage, opts) => {
      if (b <= a || b > maxCycle + 1 || a > maxCycle) return;
      enter[a].push([i, stage, opts ?? null, b]);
    };
    span(r.dispatched + 1, r.ready, 'waiting');
    // "Ready" is not drawable while dispatched: an instruction that becomes
    // ready before its dispatch cycle (cortex-a55 issues in the order it
    // dispatches, so dispatched < issued) waits on width or an in-order
    // scoreboard entry, not on operands.
    span(Math.max(r.ready, r.dispatched + 1), r.issued, 'ready');
    span(r.dispatched, r.dispatched + 1, 'dispatch');
    if (ev) {
      let holdEnd = ev.cycle;
      // the latency token parks on the unit whose hold ends last, as before
      let lastUnits = [];
      for (const u of ev.units) {
        holdEnd = Math.max(holdEnd, ev.cycle + u.hold);
        if (ev.cycle + u.hold >= holdEnd) lastUnits = [u.unit];
      }
      holdEnd = Math.max(holdEnd, ev.cycle + 1);
      span(ev.cycle, Math.min(holdEnd, r.executed), 'execute', { units: ev.units.map((u) => [u.unit, ev.cycle, ev.cycle + u.hold]) });
      span(Math.max(holdEnd, ev.cycle), r.executed, 'execute', { latency: true, lastUnits, allUnits: ev.units.map((u) => u.unit) });
    } else {
      span(r.issued, r.executed, 'execute', { latency: true });
    }
    span(r.executed, r.retired, 'retire');
  });

  return {
    resources: json.TargetInfo.Resources,
    instructions,
    iters: Math.floor(entries.length / n), // full iterations; a partial one is drawn but not counted
    total,
    complete: entries.length === n * total,
    // the file cannot tell the caps apart unless the cut falls mid-iteration or leaves no rows
    cycleCut: entries.length === 0 || entries.length % n !== 0,
    rows,
    matrix,
    // null unless run with our patched llvm-mca's -issue-events flag
    events,
    cycleIndex: { enter, maxCycle },
  };
}

function parseIssueEvents(region) {
  const list = region.IssueEventView?.IssueEvents;
  if (!Array.isArray(list)) return null;
  return list.map((ev) => ({
    cycle: ev.cycle,
    instr: ev.instruction,
    iter: ev.iteration,
    units: ev.units.map((u) => ({ unit: u.unit, hold: u.cycles_num / u.cycles_den })),
  }));
}

// Where is each instruction instance at `cycle`, as [row index, stage,
// opts] per the model's cycle index? An instruction occupies the stage it
// entered at the latest cycle <= `cycle`; ties at one cycle resolve in
// enter-bucket order, retire last so it wins.
export function stageEntriesAt(model, cycle) {
  const { enter, maxCycle } = model.cycleIndex;
  if (cycle > maxCycle) return [];
  const at = new Map();
  for (let c = 0; c <= cycle; c++) {
    for (const [i, stage, opts, end] of enter[c]) {
      if (stage === 'retire') {
        if (cycle >= end) continue; // the span that started at c already ended
        at.set(i, [i, 'retire', null]);
        continue;
      }
      if (cycle >= end) continue; // the span that started at c already ended
      at.set(i, [i, stage, opts]);
    }
  }
  const list = [...at.values()];
  const order = { dispatch: 0, waiting: 1, ready: 2, execute: 3, retire: 4 };
  list.sort((a, b) => model.rows[a[0]].instr - model.rows[b[0]].instr || model.rows[a[0]].iter - model.rows[b[0]].iter || order[a[1]] - order[b[1]]);
  return list;
}

// Where is each instruction instance at `cycle`? A token enters the dispatch
// block on its dispatch cycle, then the scheduler queue until ready, the
// ready queue until issue, the execution block until executed (on its
// event's units while a hold covers the cycle, dimmed on the units it last
// held while only latency remains), and the retire block until retired.
// Spans are half-open [x, y), and -1/0 are real cycles too: in-order CPUs
// (cortex-a55) dispatch and issue the first instruction at cycle 0.
export function tokenPositionsAt(model, cycle) {
  const tokens = [];
  for (const [i, stage, opts] of stageEntriesAt(model, cycle)) {
    const r = model.rows[i];
    const units = [];
    let lastUnits = [];
    if (stage === 'execute' && opts) {
      if (opts.units) {
        for (const [unit, start, end] of opts.units) {
          if (cycle >= start && cycle < end) units.push(unit);
        }
      }
      if (opts.lastUnits) lastUnits = opts.lastUnits;
    }
    tokens.push({ instr: r.instr, iter: r.iter, stage, units, lastUnits });
  }
  return tokens;
}
