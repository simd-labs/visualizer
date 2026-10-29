#!/usr/bin/env bash
# Build llvm-mca, llvm-mc 23.1.4 (X86, AArch64, RISCV) and Intel XED decoder to WASM.
# Flags verified in the spike (memory/visualizer/spike/notes.md): output is
# byte-identical to native llvm-mca-23 for znver4 and neoverse-v2.
# XED pins match simdref-llvm-mc/xed-version.txt.
# Source and build trees live in $WORK (default: cache dir, outside the repo);
# the emcc artifacts land in wasm/dist/ (gitignored).
set -eu

LLVM_TAG=llvmorg-23.1.4
EMSDK_VER=6.0.12
NATIVE_TOOL_DIR=${NATIVE_TOOL_DIR:-/usr/lib/llvm-23/bin}
WORK=${WORK:-${XDG_CACHE_HOME:-$HOME/.cache}/visualizer-wasm}
ROOT=$(cd "$(dirname "$0")/.." && pwd)
DIST=$ROOT/wasm/dist

# XED decoder-only build pins (from simdref-llvm-mc/xed-version.txt).
XED_TAG=v2025.06.08
XED_SHA256=ef1d8662519d1d65051f933a849e9701b7f4a1d869cfdbc46eefa2d44a8c98de
MBUILD_TAG=v2024.11.04
MBUILD_SHA256=866d17a3aa3b3f4d8d7157d747d54b13b4300c9fd5bf15ad9289b1b3309e0b71

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
for p in "$ROOT"/wasm/patches/*.patch; do
  [ -e "$p" ] || continue
  if git apply --check "$p" 2>/dev/null; then
    git apply "$p"
    echo "applied $(basename "$p")"
  elif git apply --check -R "$p" 2>/dev/null; then
    echo "already applied: $(basename "$p")"
  else
    echo "FATAL: $p does not apply cleanly to $LLVM_TAG" >&2
    exit 1
  fi
done
cd "$WORK"

if [ ! -d emsdk ]; then
  git clone --depth 1 --branch $EMSDK_VER https://github.com/emscripten-core/emsdk.git
fi
if ! ./emsdk/emsdk list 2>/dev/null | grep -q "$EMSDK_VER \*INSTALLED\*\|$EMSDK_VER.*INSTALLED"; then
  ./emsdk/emsdk install $EMSDK_VER
fi
./emsdk/emsdk activate $EMSDK_VER
. ./emsdk/emsdk_env.sh > /dev/null
# A failed activation falls back to the system emcc in /usr/share (6.0.5), so refuse anything but the pin.
emcc --version | head -1 | grep -q " $EMSDK_VER (" ||
  { echo "FATAL: emcc is not $EMSDK_VER: $(emcc --version | head -1)" >&2; exit 1; }

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
ninja llvm-mca llvm-mc

mkdir -p "$DIST"
cp bin/llvm-mca.js bin/llvm-mca.wasm bin/llvm-mc.js bin/llvm-mc.wasm ../llvm-project/LICENSE.TXT "$DIST/"

# XED decoder-only WASM build
# Reuse the emsdk activation from above; emcc is already on PATH.
XED_WORK=$WORK/xed
XED_CACHE=$WORK/xed-cache
mkdir -p "$XED_WORK" "$XED_CACHE"

XED_SOURCES=$ROOT/wasm/sources/xedform.c

fetch_xed() {
  local f=$XED_CACHE/$1
  if [ ! -f "$f" ]; then curl -fL -o "$f" "$2"; fi
  echo "$3  $f" | sha256sum -c -
}

fetch_xed xed-$XED_TAG.tar.gz \
  "https://github.com/intelxed/xed/archive/refs/tags/$XED_TAG.tar.gz" "$XED_SHA256"
fetch_xed mbuild-$MBUILD_TAG.tar.gz \
  "https://github.com/intelxed/mbuild/archive/refs/tags/$MBUILD_TAG.tar.gz" "$MBUILD_SHA256"

if [ ! -d "$XED_WORK/xed-src" ]; then
  mkdir -p "$XED_WORK/xed-src"
  tar -xzf "$XED_CACHE/xed-$XED_TAG.tar.gz" --strip-components=1 -C "$XED_WORK/xed-src"
fi
if [ ! -d "$XED_WORK/xed-src/mbuild" ]; then
  mkdir -p "$XED_WORK/xed-src/mbuild"
  tar -xzf "$XED_CACHE/mbuild-$MBUILD_TAG.tar.gz" --strip-components=1 \
    -C "$XED_WORK/xed-src/mbuild"
fi

cd "$XED_WORK/xed-src"
rm -rf obj
# XED decoder-only static library through XED's own mfile.py, driven at the
# emcc tools. Same knobs as the wheel's CMake XED step plus the tool override.
# shortcut: --host-cpu=aarch64; mbuild normalizes every x86 name to x86-64 and
# then adds -m64, which emcc builds as wasm64 and wasm-ld refuses to link with
# wasm32 xedform.o. No wasm64 output wanted here, and XED code is host-agnostic.
PYTHONPATH=$PWD/mbuild python3 mfile.py --static --opt=2 --no-encoder \
  --compiler=gnu --no-werror --host-cpu=aarch64 \
  --cc="$(command -v emcc)" --cxx="$(command -v em++)" \
  --ar="$(command -v emar)" --linker="$(command -v emcc)" \
  --as="$(command -v emcc)" --jobs="$(nproc)"

KIT=$XED_WORK/xed-src/obj/wkit
test -f "$KIT/lib/libxed.a" || { echo "FATAL: no $KIT/lib/libxed.a" >&2; exit 1; }

# Build xedform.wasm from the vendored xedform.c
emcc -O2 -sSTACK_SIZE=2MB -sALLOW_MEMORY_GROWTH \
  -I"$KIT/include" "$XED_SOURCES" "$KIT/lib/libxed.a" -o "$DIST/xedform.cjs"

ls -l "$DIST"
echo "test with: node $ROOT/wasm/test.mjs"
