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
  };
}
