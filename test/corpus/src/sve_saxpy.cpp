#include <stdint.h>
#ifdef __ARM_FEATURE_SVE
#include <arm_sve.h>
#endif

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

#ifdef __ARM_FEATURE_SVE
void sve_saxpy(float a_, const float* __restrict x, float* __restrict y, long n) {
  MCA_BEGIN(sve_saxpy);
  for (long i = 0; i < n; i += svcntw()) {
    svbool_t pg = svwhilelt_b32((uint64_t)i, (uint64_t)n);
    svfloat32_t vx = svld1_f32(pg, x + i);
    svfloat32_t vy = svld1_f32(pg, y + i);
    svst1_f32(pg, y + i, svmad_f32_m(pg, svdup_n_f32(a_), vx, vy));
  }
  MCA_END(sve_saxpy);
}

#endif
