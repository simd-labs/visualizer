#include <stdint.h>
#include <arm_neon.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

float neon_dot_f32(const float* __restrict a, const float* __restrict b, long n4) {
  float32x4_t acc = vdupq_n_f32(0.f);
  MCA_BEGIN(neon_dot_f32);
  for (long i = 0; i < n4; i += 4) {
    float32x4_t va = vld1q_f32(a + i);
    float32x4_t vb = vld1q_f32(b + i);
    acc = vfmaq_f32(acc, va, vb);
  }
  MCA_END(neon_dot_f32);
  return vaddvq_f32(acc);
}
