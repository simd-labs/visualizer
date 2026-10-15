// Vendor-style names for llvm-mca's resource names, from unit-names.json:
// rules in order, first match wins, filtered by the rule's cpus list.
import data from './unit-names.json' with { type: 'json' };

const rules = data.rules.map((r) => ({ ...r, re: new RegExp(r.match) }));
const ruleFor = (cpu, base) => rules.find((r) => (r.cpus.includes(cpu) || r.cpus.includes('*')) && r.re.test(base));

// Hand-rule display-role abbreviations spelled out, so no bare "st" or "AGU"
// reaches the page from them; probe rules already use the short role words and
// stay as they are. FP, FMA and LSU stay: fp/fma are the ISA term and LSU
// expands inline in the JSON ("LSU: load/store unit").
const WORDS = [
  [/\bAGU\b/g, 'address generation unit'],
  [/\bALU\b/g, 'arithmetic logic unit'],
  [/\bASIMD\b/g, 'SIMD'],
  [/\bCMP\b/g, 'compare'],
  [/\bctrl\b/g, 'control'],
  [/\bDiv\b/g, 'division'],
  [/\bint\b/g, 'integer'],
  [/\bmem\b/g, 'memory'],
  [/\bmul\b/g, 'multiply'],
  [/\bSqrt\b/g, 'square root'],
  [/\bSt\b/g, 'Store'],
  [/\bst\b/g, 'store'],
  [/\bvec\b/g, 'vector'],
  [/\bVec\b/g, 'vector'],
];
const spellOut = (role) => WORDS.reduce((s, [re, word]) => s.replace(re, word), role);

// Fallback: drop the model prefix (Zn4, SKL, ...Unit) and split camelCase,
// "ZN4Store0" -> "Store 0"; the cluster is a keyword guess.
function humanize(base) {
  const s = base.replace(/^.*Unit|^(?:[A-Z]+\d*|[A-Z][a-z]+\d+)(?=[A-Z])/, '') || base;
  const name = s.replace(/([a-z])([A-Z\d])|([A-Z])([A-Z][a-z])|(\d)([A-Za-z])/g, (_m, a, b, c, d, e, f) => `${a || c || e} ${b || d || f}`);
  const cluster = /load|store|agu|mem|ld|st/i.test(s) ? 'mem' : /fp|vec|simd|^v\d/i.test(s) ? 'vec' : /^b(r|ranch|$)/i.test(s) ? 'branch' : 'int';
  return { head: name[0].toUpperCase() + name.slice(1), role: '', cluster, port: null, fallback: true };
}

function named(cpu, base) {
  const rule = ruleFor(cpu, base);
  if (rule.label !== 'fallback') {
    const [, head, role = ''] = base.replace(rule.re, rule.display).match(/^(.*?)(?: \((.*)\))?$/);
    const out = { head, role: rule.family.startsWith('probe-') ? role : spellOut(role), cluster: rule.cluster, port: rule.port ?? null, fallback: false };
    if (rule.full) out.full = rule.full; // every role, for the tooltip when the sub-label caps at three
    return out;
  }
  // the /.*(\.\d+)?$/ expansion: a group like "Zn4AGU01" is named after its units AGU0 and AGU1
  const [, stem, digits] = base.match(/^(.*?)(\d{2,})$/) ?? [];
  const parts = digits ? [...digits].map((d) => named(cpu, stem + d)) : [];
  if (parts.length && parts.every((p) => !p.fallback)) return { ...parts[0], head: parts.map((p) => p.head).join('/') };
  return humanize(base);
}

// llvm-mca names the instances of a ProcResource<N> "Base.\x00", "Base.\x01":
// the rules match the base, and instance k takes the k-th of "L0/L1" or gets
// k appended.
export function lookup(cpu, raw) {
  const [, base, inst] = raw.match(/^(.*?)(?:\.([\x00-\x1f]|\d+))?$/);
  const u = named(cpu, base);
  let name = u.head;
  if (inst !== undefined) {
    const k = /\d/.test(inst) ? +inst : inst.charCodeAt(0);
    const alt = name.match(/^(\D+)(\d+)\/(?:\1)?(\d+)$/); // "L0/L1", "FP4/5"
    name = alt && k < 2 ? alt[1] + alt[2 + k] : `${name} ${k}`;
  }
  const out = { name, role: u.role, display: u.role ? `${name} (${u.role})` : name, cluster: u.cluster, port: u.port, fallback: u.fallback };
  if (u.full) out.full = u.full;
  return out;
}
