# simd-labs visualizer

A static web page that renders the output of llvm-mca's timeline and
resource pressure views. Open the page, drop a JSON file produced by
llvm-mca onto it, and it draws the pipeline timeline (dispatched, ready,
issued, executed, retired per instruction and iteration) plus a heatmap
of per-resource pressure.

## Generating input

The page can also analyze a loop directly: paste assembly, or drop a `.s`
file, pick a CPU from the list (filled from `cpus.json`) and an iteration
count, and hit Run. llvm-mca runs as WASM in a Web Worker, so the page stays
responsive; the ~12 MB binary downloads on page load and the Run button shows
progress until it is ready. Runs pass `-mtriple <group> -mcpu <cpu>
-iterations <n> -timeline -json -issue-events`; the timeline view keeps at most 10
iterations, and the page shows a notice when the cap cuts the output.

A CPU flow diagram sits under the heatmap: the dispatch, scheduler-waiting,
scheduler-ready, execution-unit and retire blocks, with one box per real unit
from the CPU's scheduling model. Issue events from our patched llvm-mca's
`-issue-events` flag (`wasm/patches/issue-view.patch`) place each instruction
token on its exact busy unit. A cycle slider with play and step buttons moves
the tokens cycle by cycle, highlights the same column in the timeline, and
updates an aria-live line with the cycle and busy units. Dropped JSON without
issue events shows a notice instead of the diagram.

To generate the same JSON by hand (fixtures are pinned to LLVM 23, because
the browser WASM build of llvm-mca tracks llvmorg-23.1.3 and the tests
compare its output against these fixtures):

```
llvm-mca-23 -mcpu=znver4 -timeline -iterations=3 -json loop.s > out.json
llvm-mca-23 --mtriple=aarch64-unknown-linux-gnu -mcpu=neoverse-v2 \
    -timeline -iterations=3 -json loop_a64.s > out.json
```

`-timeline-max-iterations` defaults to 10, so with higher `-iterations`
values the JSON timeline keeps only the first 10 iterations. `-timeline-max-cycles`
defaults to 80: llvm-mca keeps the rows before the first instruction that has not
retired by that cycle. The cycle cap can leave a partial last iteration, or no rows
at all. The page draws what the file contains, shows a partial last iteration as is,
and shows a notice that names the cap that cut it. Raise the limits on the llvm-mca
command line, and use `-timeline-max-cycles=0` for no cycle limit.

## Running

Serve the directory with any static server and open index.html:

```
python3 -m http.server
```

## Building the WASM

Run `bash wasm/build.sh` to build llvm-mca 23.1.3 (X86, AArch64, RISCV) with Emscripten
6.0.12 into `wasm/dist/` (llvm-mca.js, llvm-mca.wasm, LLVM's LICENSE.TXT).
It applies every `wasm/patches/*.patch` to the pinned checkout before
configuring (skips patches already in the tree, fails when one no longer
applies); `wasm/patches/issue-view.patch` adds llvm-mca's JSON-only
`-issue-events` flag.
Source and build trees default to `~/.cache/visualizer-wasm`; set `WORK` to
put them elsewhere, and `NATIVE_TOOL_DIR` if llvm-tblgen is not in
`/usr/lib/llvm-23/bin`. `wasm/test.mjs` diffs the module's JSON against the
fixtures; `wasm/cpus.mjs` regenerates `cpus.json`, the list of CPUs with a
real scheduling model.

## Tests

```
sh test/gen-fixtures.sh              # regenerate test/fixtures/*
npm test                             # node tests + playwright tests
```

The node tests check every JSON timeline row against llvm-mca's text
timeline output. The playwright tests drop or pick each fixture, then check
the rendered rows, cycles, tooltips, heatmap cells and table views against the JSON.

## Credit

Data model and timelines come from llvm-mca, part of the LLVM project
(https://llvm.org, Apache-2.0 with LLVM exceptions).
