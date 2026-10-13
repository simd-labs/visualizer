#include <stdint.h>
#include <arm_neon.h>

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

void neon_uzip3_rgb8(const uint8_t* __restrict rgb24, uint8_t* __restrict r,
                     uint8_t* __restrict g, uint8_t* __restrict b, long npx) {
  long i = 0;
  MCA_BEGIN(neon_uzip3_rgb8);
  for (; i + 8 <= npx; i += 8) {
    uint8x8x3_t v = vld3_u8(rgb24 + 3 * i);
    vst1_u8(r + i, v.val[0]);
    vst1_u8(g + i, v.val[1]);
    vst1_u8(b + i, v.val[2]);
  }
  MCA_END(neon_uzip3_rgb8);
}
