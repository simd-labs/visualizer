// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void xor_bytes(const unsigned char* __restrict a, const unsigned char* __restrict b,
               unsigned char* __restrict out, long n) {
  MCA_BEGIN(xor_bytes);
  for (long i = 0; i < n; ++i) out[i] = (unsigned char)(a[i] ^ b[i]);
  MCA_END(xor_bytes);
}
