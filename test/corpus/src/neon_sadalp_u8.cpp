#include <stdint.h>
#include <arm_neon.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

int32_t neon_sadalp_u8(const uint8_t* __restrict x, long n8) {
  uint32x4_t acc = vdupq_n_u32(0);
  MCA_BEGIN(neon_sadalp_u8);
  for (long i = 0; i < n8; i += 16) {
    uint8x16_t v = vld1q_u8(x + i);
    acc = vaddq_u32(acc, vpaddlq_u16(vpaddlq_u8(v)));
  }
  MCA_END(neon_sadalp_u8);
  return (int32_t)vaddvq_u32(acc);
}
