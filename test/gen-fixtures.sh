#!/bin/sh
# Regenerate llvm-mca fixtures: JSON+text timelines for znver4, skylake,
# neoverse-v2 at -iterations=3. znver4-i100 pins the iteration cap, znver4-cap18
# and skylake-idivq pin the cycle cap, malformed.json and wrong-schema.json are broken inputs.
set -eu
cd "$(dirname "$0")"

# Fixtures are pinned to LLVM 23: the browser WASM build of llvm-mca is
# pinned to llvmorg-23.1.3 and v1 compares its output against these files.
MCA=/usr/bin/llvm-mca-23
BASE="-timeline -iterations=3"
$MCA -mcpu=znver4   $BASE -json fixtures/loop.s > fixtures/znver4.json
$MCA -mcpu=znver4   $BASE       fixtures/loop.s > fixtures/znver4.txt
$MCA -mcpu=skylake  $BASE -json fixtures/loop.s > fixtures/skylake.json
$MCA -mcpu=skylake  $BASE       fixtures/loop.s > fixtures/skylake.txt
$MCA --mtriple=aarch64-unknown-linux-gnu -mcpu=neoverse-v2 $BASE -json fixtures/loop_a64.s > fixtures/neoverse-v2.json
$MCA --mtriple=aarch64-unknown-linux-gnu -mcpu=neoverse-v2 $BASE       fixtures/loop_a64.s > fixtures/neoverse-v2.txt
$MCA -mcpu=znver4 -timeline -iterations=100 -json fixtures/loop.s > fixtures/znver4-i100.json
$MCA -mcpu=znver4 -timeline -iterations=100       fixtures/loop.s > fixtures/znver4-i100.txt
$MCA -mcpu=znver4 -timeline -iterations=10 -timeline-max-cycles=18 -json fixtures/loop.s > fixtures/znver4-cap18.json
$MCA -mcpu=znver4 -timeline -iterations=10 -timeline-max-cycles=18       fixtures/loop.s > fixtures/znver4-cap18.txt
$MCA -mcpu=skylake $BASE -json fixtures/loop_idiv.s > fixtures/skylake-idivq.json
$MCA -mcpu=skylake $BASE       fixtures/loop_idiv.s > fixtures/skylake-idivq.txt
printf '{"CodeRegions": [' > fixtures/malformed.json
printf '{"not": "llvm-mca"}\n' > fixtures/wrong-schema.json
