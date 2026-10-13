#include <stdint.h>
#include <immintrin.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void avx512_maskz_add(const float* __restrict x, const float* __restrict y,
                      float* __restrict out, long n) {
  MCA_BEGIN(avx512_maskz_add);
  for (long i = 0; i < n; i += 16) {
    __m512 a = _mm512_loadu_ps(x + i);
    __m512 b = _mm512_loadu_ps(y + i);
    __mmask16 m = _mm512_cmp_ps_mask(a, _mm512_set1_ps(0.5f), _CMP_GT_OQ);
    _mm512_mask_storeu_ps(out + i, m, _mm512_add_ps(a, b));
  }
  MCA_END(avx512_maskz_add);
}
