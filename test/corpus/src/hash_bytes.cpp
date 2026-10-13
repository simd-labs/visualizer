// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

uint64_t hash_bytes(const unsigned char* __restrict p, long n) {
  uint64_t h = 0xcbf29ce484222325ull;
  MCA_BEGIN(hash_bytes);
  for (long i = 0; i < n; ++i) { h ^= p[i]; h *= 0x100000001b3ull; }
  MCA_END(hash_bytes);
  return h;
}
