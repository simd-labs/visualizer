import { readFileSync } from 'node:fs';
const lines = readFileSync(process.argv[2], 'utf8').split('\n');
const out = [];
let on = false;
const label = /^(\.?[\w.$]+):/;
const loopMark = (s) => /Inner Loop Header|=>/.test(s);
for (let i = 0; i < lines.length; i++) {
  const l = lines[i];
  if (l.includes('LLVM-MCA-BEGIN')) { on = true; continue; }
  if (l.includes('LLVM-MCA-END')) break;
  if (!on) continue;
  const s = l.replace(/^\t+/, '');
  if (/^(#|\/\/) ?(NO_APP|APP|%bb)/.test(s.trim())) continue;
  const m = label.exec(s.trim());
  if (m) {
    if ((loopMark(s) || loopMark(lines[i + 1] || '')) && out[out.length - 1] !== '  .p2align 4') out.push('  .p2align 4');
    out.push(m[1] + ':');
    continue;
  }
  if (s.trim()) out.push('  ' + s.trimEnd());
}
process.stdout.write(out.join('\n') + '\n');
