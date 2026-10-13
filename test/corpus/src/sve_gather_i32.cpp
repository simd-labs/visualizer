#include <stdint.h>
#ifdef __ARM_FEATURE_SVE
#include <arm_sve.h>
#endif

#define MCA_BEGIN(name) __asm__ volatile("# LLVM-MCA-BEGIN " #name)
#define MCA_END(name)   __asm__ volatile("# LLVM-MCA-END " #name)

#ifdef __ARM_FEATURE_SVE
void sve_gather_i32(const int32_t* __restrict base,
                    const int32_t* __restrict idx,
                    int32_t* __restrict out, long n) {
  MCA_BEGIN(sve_gather_i32);
  for (long i = 0; i < n; i += svcntw()) {
    svbool_t pg = svwhilelt_b32((uint64_t)i, (uint64_t)n);
    svint32_t vi = svld1_s32(pg, idx + i);
    svint32_t v = svld1_gather_s32index_s32(pg, base, vi);
    svst1_s32(pg, out + i, v);
  }
  MCA_END(sve_gather_i32);
}
#endif
