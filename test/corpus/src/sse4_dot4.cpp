#include <stdint.h>
#include <immintrin.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

float sse4_dot4(const float* __restrict a, const float* __restrict b, long n4) {
  __m128 acc = _mm_setzero_ps();
  MCA_BEGIN(sse4_dot4);
  for (long i = 0; i < n4; i += 4) {
    __m128 va = _mm_load_ps(a + i);
    __m128 vb = _mm_load_ps(b + i);
    acc = _mm_add_ps(acc, _mm_mul_ps(va, vb));
  }
  MCA_END(sse4_dot4);
  return _mm_cvtss_f32(acc);
}
