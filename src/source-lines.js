// Map llvm-mca's CodeRegions[0].Instructions to 1-based editor lines. The
// region starts after '# LLVM-MCA-BEGIN' (or at the top without markers) and
// ends at '# LLVM-MCA-END'. Inside it, blanks, comments (# ; // @), labels
// (foo:) and .* directives are not instructions; the k-th real instruction
// line matches the k-th instruction. Any mnemonic mismatch drops the whole
// mapping (null), so a label never shows a wrong line.
export function sourceLines(source, instructions) {
  if (!source) return null;
  const region = [];
  let open = source.includes('LLVM-MCA-BEGIN') ? false : true;
  for (const [i, raw] of source.split('\n').entries()) {
    const s = raw.trim();
    if (/^#\s*LLVM-MCA-BEGIN/.test(s)) {
      open = true;
      continue;
    }
    if (/^#\s*LLVM-MCA-END/.test(s)) break;
    if (!open) continue;
    if (s === '' || s.startsWith('#') || s.startsWith(';') || s.startsWith('//') || s.startsWith('@')) continue;
    if (s.startsWith('.')) continue; // a directive (.text, .p2align, ...)
    if (/^[A-Za-z_.$][\w.$]*\s*:/.test(s)) continue; // a label (loop:, .LBB0_5:)
    region.push({ line: i + 1, mnemonic: s.split(/\s+/)[0].toLowerCase() });
  }
  if (region.length !== instructions.length) return null;
  const lines = new Array(instructions.length);
  for (let k = 0; k < instructions.length; k++) {
    const mnemonic = instructions[k].trim().split(/\s+/)[0].toLowerCase();
    if (region[k].mnemonic !== mnemonic) return null;
    lines[k] = region[k].line;
  }
  return lines;
}
