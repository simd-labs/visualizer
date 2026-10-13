// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void gather_f32(const float* __restrict base, const int32_t* __restrict idx,
                float* __restrict out, long n) {
  MCA_BEGIN(gather_f32);
  for (long i = 0; i < n; ++i) out[i] = base[idx[i]];
  MCA_END(gather_f32);
}
