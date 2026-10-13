#include <stdint.h>
#include <immintrin.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void avx512_dot_f32x16(const float* __restrict a, const float* __restrict b,
                       float* __restrict acc, long n16) {
  __m512 acc512 = _mm512_setzero_ps();
  MCA_BEGIN(avx512_dot_f32);
  for (long i = 0; i < n16; i += 16) {
    __m512 va = _mm512_loadu_ps(a + i);
    __m512 vb = _mm512_loadu_ps(b + i);
    acc512 = _mm512_fmadd_ps(va, vb, acc512);
  }
  MCA_END(avx512_dot_f32);
  *acc = _mm512_reduce_add_ps(acc512);
}
