#!/bin/sh
# Regenerate test/corpus/asm from test/corpus/src with clang++-23.
# One .s pair per (kernel, target, march): <kernel>_<triple>_<march>.full.s is
# the full compiler output a user would paste, <kernel>_<triple>_<march>.region.s
# is the LLVM-MCA-BEGIN..END region, re-indented with .p2align 4 before loop
# headers. Committed, so the test suite needs no compiler.
set -eu
cd "$(dirname "$0")"

CXX=${CXX:-clang++-23}
BASE="-ffreestanding -fno-exceptions -fno-rtti -fno-stack-protector"
mkdir -p corpus/asm

compile() { # src tag target march
  "$CXX" -S -O2 $BASE --target="$3" -march="$4" -o "corpus/asm/$2.full.s" "corpus/src/$1" \
    || { echo "FAIL $2 ($3 $4)" >&2; exit 1; }
  node corpus/extract_region.js "corpus/asm/$2.full.s" > "corpus/asm/$2.region.s"
}

# A subset of kernels runs at every march; the rest at one representative
# march per family, so the corpus stays wide without quadratic growth.
CORE="saxpy dot_f32 dot_f64 dot_i32 matmul_inner prefix_sum copy_f32 strlen_like histogram_epi8 chained_reduction sdiv_i32_loop sqrt_f32_loop gather_f32 popcount_u64 clamp_branchy unroll4_scale"
EXTRA_X86="xor_bytes memmove_overlap sum_mod_fold lfsr_steps madd_i16 mincol_f32 hash_bytes conv3_f32 memset_u32"
EXTRA_A64="xor_bytes memmove_overlap sum_mod_fold lfsr_steps madd_i16 mincol_f32 hash_bytes conv3_f32 memset_u32"
SCALAR="saxpy dot_f32 dot_f64 dot_i32 matmul_inner prefix_sum copy_f32 strlen_like histogram_epi8 chained_reduction sdiv_i32_loop sqrt_f32_loop gather_f32 popcount_u64 clamp_branchy unroll4_scale xor_bytes memmove_overlap sum_mod_fold lfsr_steps madd_i16 mincol_f32 hash_bytes conv3_f32 memset_u32"
SSE4="sse4_dot4 sse4_hsum_epi32 sse4_cvtps_epi32_loop"
AVX2="avx2_dot8 avx2_hmax_epi32 avx2_gather_f32"
AVX512="avx512_dot_f32x16 avx512_maskz_add"
NEON="neon_dot_f32 neon_sadalp_u8 neon_fma_tile neon_uzip3_rgb8"
RVV="rvv_dot_f32 rvv_saxpy rvv_gather_i32 rvv_reduce_add_i64 rvv_widen_mul_i16"

T_X86=x86_64-unknown-linux-gnu
for k in $CORE; do
  for m in x86-64-v2 x86-64-v3 x86-64-v4 znver4 sapphirerapids; do
    compile "$k.cpp" "${k}_x86_${m}" $T_X86 "$m"
  done
done
for k in $EXTRA_X86; do
  compile "$k.cpp" "${k}_x86_x86-64-v3" $T_X86 x86-64-v3
done
for k in $SSE4; do
  for m in x86-64-v2 x86-64-v3; do
    compile "$k.cpp" "${k}_x86_${m}" $T_X86 "$m"
  done
done
for k in $AVX2; do
  for m in x86-64-v3 znver4; do
    compile "$k.cpp" "${k}_x86_${m}" $T_X86 "$m"
  done
done
for k in $AVX512; do
  for m in x86-64-v4 sapphirerapids; do
    compile "$k.cpp" "${k}_x86_${m}" $T_X86 "$m"
  done
done

T_A64=aarch64-linux-gnu
for k in $CORE; do
  for m in armv8.2-a armv9-a+sve2; do
    compile "$k.cpp" "${k}_aarch64_${m}" $T_A64 "$m"
  done
done
for k in $EXTRA_A64; do
  compile "$k.cpp" "${k}_aarch64_armv8.2-a" $T_A64 armv8.2-a
done
for k in $NEON; do
  compile "$k.cpp" "${k}_aarch64_armv8.2-a" $T_A64 armv8.2-a
done
compile neon_uzip3_rgb8.cpp neon_uzip3_rgb8_aarch64_armv9-a-sve2 $T_A64 armv9-a+sve2
for k in sve_dot_f32 sve_saxpy sve_gather_i32; do
  compile "$k.cpp" "${k}_aarch64_armv9-a-sve2" $T_A64 armv9-a+sve2
done

T_RV=riscv64-linux-gnu
for k in $SCALAR; do
  compile "$k.cpp" "${k}_riscv64_rv64gcv" $T_RV rv64gcv
done
for k in $RVV; do
  compile "$k.cpp" "${k}_riscv64_rv64gcv" $T_RV rv64gcv
done

echo "generated $(ls corpus/asm/*.full.s | wc -l) full/region pairs"
