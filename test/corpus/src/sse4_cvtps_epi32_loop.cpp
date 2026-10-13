#include <stdint.h>
#include <immintrin.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void sse4_cvtps_epi32_loop(const float* __restrict x, int32_t* __restrict y, long n4) {
  MCA_BEGIN(sse4_cvtps_epi32);
  for (long i = 0; i < n4; i += 4) {
    __m128 v = _mm_load_ps(x + i);
    _mm_stream_si128((__m128i*)(y + i), _mm_cvtps_epi32(v));
  }
  MCA_END(sse4_cvtps_epi32);
}
