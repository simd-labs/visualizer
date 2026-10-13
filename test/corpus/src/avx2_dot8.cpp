#include <stdint.h>
#include <immintrin.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

float avx2_dot8(const float* __restrict a, const float* __restrict b, long n8) {
  __m256 acc = _mm256_setzero_ps();
  MCA_BEGIN(avx2_dot8);
  for (long i = 0; i < n8; i += 8) {
    __m256 va = _mm256_loadu_ps(a + i);
    __m256 vb = _mm256_loadu_ps(b + i);
    acc = _mm256_fmadd_ps(va, vb, acc);
  }
  MCA_END(avx2_dot8);
  __m128 lo = _mm256_castps256_ps128(acc), hi = _mm256_extractf128_ps(acc, 1);
  lo = _mm_add_ps(lo, hi);
  return _mm_cvtss_f32(lo);
}
