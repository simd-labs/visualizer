// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void histogram_epi8(const unsigned char* __restrict img,
                    uint32_t* __restrict hist, long n) {
  MCA_BEGIN(histogram_epi8);
  for (long i = 0; i < n; ++i) ++hist[img[i]];
  MCA_END(histogram_epi8);
}
