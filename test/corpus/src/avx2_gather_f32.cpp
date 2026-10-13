#include <stdint.h>
#include <immintrin.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void avx2_gather_f32(const float* __restrict base, const int32_t* __restrict idx,
                     float* __restrict out, long n8) {
  MCA_BEGIN(avx2_gather_f32);
  for (long i = 0; i < n8; i += 8) {
    __m256i vidx = _mm256_loadu_si256((const __m256i*)(idx + i));
    __m256 v = _mm256_i32gather_ps(base, vidx, 4);
    _mm256_storeu_ps(out + i, v);
  }
  MCA_END(avx2_gather_f32);
}
