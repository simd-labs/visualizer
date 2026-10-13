// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

int64_t lfsr_steps(uint32_t* __restrict taps, long n) {
  uint32_t s = 0xACE1u; int64_t sum = 0;
  MCA_BEGIN(lfsr_steps);
  for (long i = 0; i < n; ++i) {
    unsigned lsb = s & 1;
    s >>= 1;
    if (lsb) s ^= 0xB400u;
    sum += s & taps[i & 7];
  }
  MCA_END(lfsr_steps);
  return sum;
}
