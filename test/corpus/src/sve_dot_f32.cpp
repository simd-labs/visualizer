#include <stdint.h>
#ifdef __ARM_FEATURE_SVE
#include <arm_sve.h>
#endif

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

#ifdef __ARM_FEATURE_SVE
float sve_dot_f32(const float* __restrict a, const float* __restrict b, long n) {
  float s = 0.f;
  MCA_BEGIN(sve_dot_f32);
  svfloat32_t acc = svdup_n_f32(0.f);
  for (long i = 0; i < n; i += svcntw()) {
    svbool_t pg = svwhilelt_b32((uint64_t)i, (uint64_t)n);
    svfloat32_t va = svld1_f32(pg, a + i);
    svfloat32_t vb = svld1_f32(pg, b + i);
    acc = svmla_f32_m(pg, acc, va, vb);
  }
  s = svaddv_f32(svptrue_b32(), acc);
  MCA_END(sve_dot_f32);
  return s;
}

#endif
