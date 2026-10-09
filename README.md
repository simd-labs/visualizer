# simd-labs visualizer

A static web page that renders the output of llvm-mca's timeline and
resource pressure views. Open the page, drop a JSON file produced by
llvm-mca onto it, and it draws the pipeline timeline (dispatched, ready,
issued, executed, retired per instruction and iteration) plus a heatmap
of per-resource pressure.

## Generating input

Fixtures are pinned to LLVM 23 (`/usr/bin/llvm-mca-23`), because the
browser WASM build of llvm-mca tracks llvmorg-23.1.3 and later versions
of this tool compare its output against these fixtures.

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
