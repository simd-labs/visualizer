#include <stdint.h>
#include <immintrin.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

int32_t avx2_hmax_epi32(const int32_t* __restrict x, long n8) {
  __m256i m = _mm256_setzero_si256();
  MCA_BEGIN(avx2_hmax_epi32);
  for (long i = 0; i < n8; i += 8) {
    __m256i v = _mm256_loadu_si256((const __m256i*)(x + i));
    m = _mm256_max_epi32(m, v);
  }
  MCA_END(avx2_hmax_epi32);
  __m128i lo = _mm256_castsi256_si128(m), hi = _mm256_extracti128_si256(m, 1);
  lo = _mm_max_epi32(lo, hi);
  return _mm_cvtsi128_si32(lo);
}
