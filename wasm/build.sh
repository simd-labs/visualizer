#!/usr/bin/env bash
# Build llvm-mca 23.1.3 (X86, AArch64, RISCV) to WASM with Emscripten.
# Flags verified in the spike (memory/visualizer/spike/notes.md): output is
# byte-identical to native llvm-mca-23 for znver4 and neoverse-v2.
# Source and build trees live in $WORK (default: cache dir, outside the repo);
# the emcc artifacts land in wasm/dist/ (gitignored).
set -eu

LLVM_TAG=llvmorg-23.1.3
EMSDK_VER=6.0.12
NATIVE_TOOL_DIR=${NATIVE_TOOL_DIR:-/usr/lib/llvm-23/bin}
WORK=${WORK:-${XDG_CACHE_HOME:-$HOME/.cache}/visualizer-wasm}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
DIST=$ROOT/wasm/dist

test -x "$NATIVE_TOOL_DIR/llvm-tblgen" || {
  echo "need llvm-tblgen in NATIVE_TOOL_DIR=$NATIVE_TOOL_DIR" >&2; exit 1; }
# The pinned LLVM 23.x sources need a matching native tablegen.
"$NATIVE_TOOL_DIR/llvm-tblgen" --version 2>/dev/null | head -1 | grep -q 'LLVM (http://llvm.org/):\s*23\.\|version 23\.\|LLVM 23\.' || {
  echo "need LLVM 23.x native llvm-tblgen in NATIVE_TOOL_DIR=$NATIVE_TOOL_DIR" >&2
  "$NATIVE_TOOL_DIR/llvm-tblgen" --version 2>&1 | head -3 >&2
  exit 1; }

mkdir -p "$WORK"
cd "$WORK"

if [ ! -d llvm-project ]; then
  git clone --depth 1 --branch $LLVM_TAG https://github.com/llvm/llvm-project.git
fi
cd llvm-project && git fetch --depth 1 origin tag $LLVM_TAG 2>/dev/null || true
git checkout -q $LLVM_TAG
cd "$WORK"

if [ ! -d emsdk ]; then
  git clone --depth 1 --branch $EMSDK_VER https://github.com/emscripten-core/emsdk.git
fi
if ! ./emsdk/emsdk list 2>/dev/null | grep -q "$EMSDK_VER \*INSTALLED\*\|$EMSDK_VER.*INSTALLED"; then
  ./emsdk/emsdk install $EMSDK_VER
fi
./emsdk/emsdk activate $EMSDK_VER
. ./emsdk/emsdk_env.sh > /dev/null
emcc --version | head -1

mkdir -p build
cd build
emcmake cmake -G Ninja -S ../llvm-project/llvm \
  -DCMAKE_BUILD_TYPE=MinSizeRel \
  -DLLVM_TARGETS_TO_BUILD="X86;AArch64;RISCV" \
  -DLLVM_ENABLE_THREADS=OFF \
  -DLLVM_INCLUDE_TESTS=OFF -DLLVM_INCLUDE_BENCHMARKS=OFF \
  -DLLVM_INCLUDE_EXAMPLES=OFF -DLLVM_INCLUDE_DOCS=OFF \
  -DLLVM_ENABLE_ZLIB=OFF -DLLVM_ENABLE_ZSTD=OFF \
  -DLLVM_ENABLE_TERMINFO=OFF -DLLVM_ENABLE_LIBXML2=OFF \
  -DLLVM_NATIVE_TOOL_DIR="$NATIVE_TOOL_DIR" \
  -DCMAKE_EXE_LINKER_FLAGS="-sMODULARIZE -sEXPORT_ES6 -sALLOW_MEMORY_GROWTH -sFORCE_FILESYSTEM -sEXPORTED_RUNTIME_METHODS=FS,callMain -sENVIRONMENT=node,web"
ninja llvm-mca

mkdir -p "$DIST"
cp bin/llvm-mca.js bin/llvm-mca.wasm ../llvm-project/LICENSE.TXT "$DIST/"
ls -l "$DIST"
echo "test with: node $ROOT/wasm/test.mjs"
