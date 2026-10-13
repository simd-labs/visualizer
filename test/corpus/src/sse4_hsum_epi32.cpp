#include <stdint.h>
#include <immintrin.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

int32_t sse4_hsum_epi32(const int32_t* __restrict x, long n4) {
  __m128i acc = _mm_setzero_si128();
  MCA_BEGIN(sse4_hsum_epi32);
  for (long i = 0; i < n4; i += 4) {
    __m128i v = _mm_load_si128((const __m128i*)(x + i));
    acc = _mm_add_epi32(acc, v);
  }
  MCA_END(sse4_hsum_epi32);
  __m128i shuf = _mm_shuffle_epi32(acc, _MM_SHUFFLE(1, 0, 3, 2));
  acc = _mm_add_epi32(acc, shuf);
  shuf = _mm_shuffle_epi32(acc, _MM_SHUFFLE(2, 3, 0, 1));
  acc = _mm_add_epi32(acc, shuf);
  return _mm_cvtsi128_si32(acc);
}
