// Scalar and auto-vectorized baseline kernels, portable to all three targets.
// Types use <stdint.h> (a compiler-provided freestanding header).
#include <stdint.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void matmul_inner(const float* __restrict A, const float* __restrict B,
                  float* __restrict C, long n, long k) {
  // inner loop of ikj matmul: C[i*n+j] += A[i*n+k] * B[k*n+j] over j
  MCA_BEGIN(matmul_inner);
  for (long i = 0; i < 4; ++i)
    for (long j = 0; j < n; ++j) C[i * n + j] += A[i * n + k] * B[k * n + j];
  MCA_END(matmul_inner);
}
