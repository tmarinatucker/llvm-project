; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -verify-machineinstrs < %s -mtriple=powerpc64-unknown-linux-gnu -mcpu=pwr7 -mattr=-vsx | FileCheck --check-prefix=CHECK-P7 %s
; RUN: llc -verify-machineinstrs < %s -mtriple=powerpc64le-unknown-linux-gnu -mcpu=pwr8 | FileCheck --check-prefix=CHECK-P8 %s
; RUN: llc -verify-machineinstrs < %s -mtriple=powerpc64le-unknown-linux-gnu -mcpu=pwr9 | FileCheck --check-prefix=CHECK-P9 %s

target datalayout = "E-p:64:64:64-i1:8:8-i8:8:8-i16:16:16-i32:32:32-i64:64:64-f32:32:32-f64:64:64-f128:128:128-v128:128:128-n32:64"

declare double @llvm.sqrt.f64(double)
declare float @llvm.sqrt.f32(float)
declare fp128 @llvm.sqrt.f128(fp128)
declare <4 x float> @llvm.sqrt.v4f32(<4 x float>)
declare <2 x double> @llvm.sqrt.v2f64(<2 x double>)

define double @foo_fmf(double %a, double %b) nounwind {
; CHECK-P7-LABEL: foo_fmf:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    frsqrte 0, 2
; CHECK-P7-NEXT:    addis 3, 2, .LCPI0_0@toc@ha
; CHECK-P7-NEXT:    addis 4, 2, .LCPI0_1@toc@ha
; CHECK-P7-NEXT:    lfs 4, .LCPI0_0@toc@l(3)
; CHECK-P7-NEXT:    lfs 5, .LCPI0_1@toc@l(4)
; CHECK-P7-NEXT:    fmul 3, 2, 0
; CHECK-P7-NEXT:    fmadd 3, 3, 0, 4
; CHECK-P7-NEXT:    fmul 0, 0, 5
; CHECK-P7-NEXT:    fmul 0, 0, 3
; CHECK-P7-NEXT:    fmul 2, 2, 0
; CHECK-P7-NEXT:    fmadd 2, 2, 0, 4
; CHECK-P7-NEXT:    fmul 0, 0, 5
; CHECK-P7-NEXT:    fmul 0, 0, 2
; CHECK-P7-NEXT:    fmul 1, 1, 0
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: foo_fmf:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xsrsqrtedp 0, 2
; CHECK-P8-NEXT:    addis 3, 2, .LCPI0_0@toc@ha
; CHECK-P8-NEXT:    lfs 4, .LCPI0_0@toc@l(3)
; CHECK-P8-NEXT:    addis 3, 2, .LCPI0_1@toc@ha
; CHECK-P8-NEXT:    lfs 5, .LCPI0_1@toc@l(3)
; CHECK-P8-NEXT:    fmr 6, 4
; CHECK-P8-NEXT:    xsmuldp 3, 2, 0
; CHECK-P8-NEXT:    xsmaddadp 6, 3, 0
; CHECK-P8-NEXT:    xsmuldp 0, 0, 5
; CHECK-P8-NEXT:    xsmuldp 0, 0, 6
; CHECK-P8-NEXT:    xsmuldp 2, 2, 0
; CHECK-P8-NEXT:    xsmaddadp 4, 2, 0
; CHECK-P8-NEXT:    xsmuldp 0, 0, 5
; CHECK-P8-NEXT:    xsmuldp 0, 0, 4
; CHECK-P8-NEXT:    xsmuldp 1, 1, 0
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: foo_fmf:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xsrsqrtedp 0, 2
; CHECK-P9-NEXT:    addis 3, 2, .LCPI0_0@toc@ha
; CHECK-P9-NEXT:    lfs 4, .LCPI0_0@toc@l(3)
; CHECK-P9-NEXT:    addis 3, 2, .LCPI0_1@toc@ha
; CHECK-P9-NEXT:    xsmuldp 3, 2, 0
; CHECK-P9-NEXT:    fmr 5, 4
; CHECK-P9-NEXT:    xsmaddadp 5, 3, 0
; CHECK-P9-NEXT:    lfs 3, .LCPI0_1@toc@l(3)
; CHECK-P9-NEXT:    xsmuldp 0, 0, 3
; CHECK-P9-NEXT:    xsmuldp 0, 0, 5
; CHECK-P9-NEXT:    xsmuldp 2, 2, 0
; CHECK-P9-NEXT:    xsmaddadp 4, 2, 0
; CHECK-P9-NEXT:    xsmuldp 0, 0, 3
; CHECK-P9-NEXT:    xsmuldp 0, 0, 4
; CHECK-P9-NEXT:    xsmuldp 1, 1, 0
; CHECK-P9-NEXT:    blr
  %x = call arcp reassoc double @llvm.sqrt.f64(double %b)
  %r = fdiv arcp reassoc double %a, %x
  ret double %r
}

define double @foo_safe(double %a, double %b) nounwind {
; CHECK-P7-LABEL: foo_safe:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    fsqrt 0, 2
; CHECK-P7-NEXT:    fdiv 1, 1, 0
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: foo_safe:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xssqrtdp 0, 2
; CHECK-P8-NEXT:    xsdivdp 1, 1, 0
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: foo_safe:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xssqrtdp 0, 2
; CHECK-P9-NEXT:    xsdivdp 1, 1, 0
; CHECK-P9-NEXT:    blr
  %x = call double @llvm.sqrt.f64(double %b)
  %r = fdiv double %a, %x
  ret double %r
}

define double @no_estimate_refinement_f64(double %a, double %b) #0 {
; CHECK-P7-LABEL: no_estimate_refinement_f64:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    frsqrte 0, 2
; CHECK-P7-NEXT:    fmul 1, 1, 0
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: no_estimate_refinement_f64:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xsrsqrtedp 0, 2
; CHECK-P8-NEXT:    xsmuldp 1, 1, 0
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: no_estimate_refinement_f64:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xsrsqrtedp 0, 2
; CHECK-P9-NEXT:    xsmuldp 1, 1, 0
; CHECK-P9-NEXT:    blr
  %x = call arcp reassoc double @llvm.sqrt.f64(double %b)
  %r = fdiv arcp reassoc double %a, %x
  ret double %r
}

define double @foof_fmf(double %a, float %b) nounwind {
; CHECK-P7-LABEL: foof_fmf:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    frsqrtes 0, 2
; CHECK-P7-NEXT:    addis 3, 2, .LCPI3_0@toc@ha
; CHECK-P7-NEXT:    addis 4, 2, .LCPI3_1@toc@ha
; CHECK-P7-NEXT:    lfs 3, .LCPI3_0@toc@l(3)
; CHECK-P7-NEXT:    lfs 4, .LCPI3_1@toc@l(4)
; CHECK-P7-NEXT:    fmuls 2, 2, 0
; CHECK-P7-NEXT:    fmadds 2, 2, 0, 3
; CHECK-P7-NEXT:    fmuls 0, 0, 4
; CHECK-P7-NEXT:    fmuls 0, 0, 2
; CHECK-P7-NEXT:    fmul 1, 1, 0
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: foof_fmf:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xsrsqrtesp 0, 2
; CHECK-P8-NEXT:    addis 3, 2, .LCPI3_0@toc@ha
; CHECK-P8-NEXT:    addis 4, 2, .LCPI3_1@toc@ha
; CHECK-P8-NEXT:    lfs 3, .LCPI3_0@toc@l(3)
; CHECK-P8-NEXT:    lfs 4, .LCPI3_1@toc@l(4)
; CHECK-P8-NEXT:    xsmulsp 2, 2, 0
; CHECK-P8-NEXT:    xsmaddasp 3, 2, 0
; CHECK-P8-NEXT:    xsmulsp 0, 0, 4
; CHECK-P8-NEXT:    xsmulsp 0, 0, 3
; CHECK-P8-NEXT:    xsmuldp 1, 1, 0
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: foof_fmf:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xsrsqrtesp 0, 2
; CHECK-P9-NEXT:    addis 3, 2, .LCPI3_0@toc@ha
; CHECK-P9-NEXT:    lfs 3, .LCPI3_0@toc@l(3)
; CHECK-P9-NEXT:    addis 3, 2, .LCPI3_1@toc@ha
; CHECK-P9-NEXT:    xsmulsp 2, 2, 0
; CHECK-P9-NEXT:    xsmaddasp 3, 2, 0
; CHECK-P9-NEXT:    lfs 2, .LCPI3_1@toc@l(3)
; CHECK-P9-NEXT:    xsmulsp 0, 0, 2
; CHECK-P9-NEXT:    xsmulsp 0, 0, 3
; CHECK-P9-NEXT:    xsmuldp 1, 1, 0
; CHECK-P9-NEXT:    blr
  %x = call reassoc arcp float @llvm.sqrt.f32(float %b)
  %y = fpext float %x to double
  %r = fdiv reassoc arcp double %a, %y
  ret double %r
}

define double @foof_safe(double %a, float %b) nounwind {
; CHECK-P7-LABEL: foof_safe:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    fsqrts 0, 2
; CHECK-P7-NEXT:    fdiv 1, 1, 0
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: foof_safe:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xssqrtsp 0, 2
; CHECK-P8-NEXT:    xsdivdp 1, 1, 0
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: foof_safe:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xssqrtsp 0, 2
; CHECK-P9-NEXT:    xsdivdp 1, 1, 0
; CHECK-P9-NEXT:    blr
  %x = call float @llvm.sqrt.f32(float %b)
  %y = fpext float %x to double
  %r = fdiv double %a, %y
  ret double %r
}

define float @food_fmf(float %a, double %b) nounwind {
; CHECK-P7-LABEL: food_fmf:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    frsqrte 0, 2
; CHECK-P7-NEXT:    addis 3, 2, .LCPI5_0@toc@ha
; CHECK-P7-NEXT:    addis 4, 2, .LCPI5_1@toc@ha
; CHECK-P7-NEXT:    lfs 4, .LCPI5_0@toc@l(3)
; CHECK-P7-NEXT:    lfs 5, .LCPI5_1@toc@l(4)
; CHECK-P7-NEXT:    fmul 3, 2, 0
; CHECK-P7-NEXT:    fmadd 3, 3, 0, 4
; CHECK-P7-NEXT:    fmul 0, 0, 5
; CHECK-P7-NEXT:    fmul 0, 0, 3
; CHECK-P7-NEXT:    fmul 2, 2, 0
; CHECK-P7-NEXT:    fmadd 2, 2, 0, 4
; CHECK-P7-NEXT:    fmul 0, 0, 5
; CHECK-P7-NEXT:    fmul 0, 0, 2
; CHECK-P7-NEXT:    frsp 0, 0
; CHECK-P7-NEXT:    fmuls 1, 1, 0
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: food_fmf:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xsrsqrtedp 0, 2
; CHECK-P8-NEXT:    addis 3, 2, .LCPI5_0@toc@ha
; CHECK-P8-NEXT:    lfs 4, .LCPI5_0@toc@l(3)
; CHECK-P8-NEXT:    addis 3, 2, .LCPI5_1@toc@ha
; CHECK-P8-NEXT:    lfs 5, .LCPI5_1@toc@l(3)
; CHECK-P8-NEXT:    fmr 6, 4
; CHECK-P8-NEXT:    xsmuldp 3, 2, 0
; CHECK-P8-NEXT:    xsmaddadp 6, 3, 0
; CHECK-P8-NEXT:    xsmuldp 0, 0, 5
; CHECK-P8-NEXT:    xsmuldp 0, 0, 6
; CHECK-P8-NEXT:    xsmuldp 2, 2, 0
; CHECK-P8-NEXT:    xsmaddadp 4, 2, 0
; CHECK-P8-NEXT:    xsmuldp 0, 0, 5
; CHECK-P8-NEXT:    xsmuldp 0, 0, 4
; CHECK-P8-NEXT:    frsp 0, 0
; CHECK-P8-NEXT:    xsmulsp 1, 1, 0
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: food_fmf:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xsrsqrtedp 0, 2
; CHECK-P9-NEXT:    addis 3, 2, .LCPI5_0@toc@ha
; CHECK-P9-NEXT:    lfs 4, .LCPI5_0@toc@l(3)
; CHECK-P9-NEXT:    addis 3, 2, .LCPI5_1@toc@ha
; CHECK-P9-NEXT:    xsmuldp 3, 2, 0
; CHECK-P9-NEXT:    fmr 5, 4
; CHECK-P9-NEXT:    xsmaddadp 5, 3, 0
; CHECK-P9-NEXT:    lfs 3, .LCPI5_1@toc@l(3)
; CHECK-P9-NEXT:    xsmuldp 0, 0, 3
; CHECK-P9-NEXT:    xsmuldp 0, 0, 5
; CHECK-P9-NEXT:    xsmuldp 2, 2, 0
; CHECK-P9-NEXT:    xsmaddadp 4, 2, 0
; CHECK-P9-NEXT:    xsmuldp 0, 0, 3
; CHECK-P9-NEXT:    xsmuldp 0, 0, 4
; CHECK-P9-NEXT:    frsp 0, 0
; CHECK-P9-NEXT:    xsmulsp 1, 1, 0
; CHECK-P9-NEXT:    blr
  %x = call reassoc arcp double @llvm.sqrt.f64(double %b)
  %y = fptrunc double %x to float
  %r = fdiv reassoc arcp float %a, %y
  ret float %r
}

define float @food_safe(float %a, double %b) nounwind {
; CHECK-P7-LABEL: food_safe:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    fsqrt 0, 2
; CHECK-P7-NEXT:    frsp 0, 0
; CHECK-P7-NEXT:    fdivs 1, 1, 0
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: food_safe:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xssqrtdp 0, 2
; CHECK-P8-NEXT:    frsp 0, 0
; CHECK-P8-NEXT:    xsdivsp 1, 1, 0
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: food_safe:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xssqrtdp 0, 2
; CHECK-P9-NEXT:    frsp 0, 0
; CHECK-P9-NEXT:    xsdivsp 1, 1, 0
; CHECK-P9-NEXT:    blr
  %x = call double @llvm.sqrt.f64(double %b)
  %y = fptrunc double %x to float
  %r = fdiv float %a, %y
  ret float %r
}

define float @goo_fmf(float %a, float %b) nounwind {
; CHECK-P7-LABEL: goo_fmf:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    frsqrtes 0, 2
; CHECK-P7-NEXT:    addis 3, 2, .LCPI7_0@toc@ha
; CHECK-P7-NEXT:    addis 4, 2, .LCPI7_1@toc@ha
; CHECK-P7-NEXT:    lfs 3, .LCPI7_0@toc@l(3)
; CHECK-P7-NEXT:    lfs 4, .LCPI7_1@toc@l(4)
; CHECK-P7-NEXT:    fmuls 2, 2, 0
; CHECK-P7-NEXT:    fmadds 2, 2, 0, 3
; CHECK-P7-NEXT:    fmuls 0, 0, 4
; CHECK-P7-NEXT:    fmuls 0, 0, 2
; CHECK-P7-NEXT:    fmuls 1, 1, 0
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: goo_fmf:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xsrsqrtesp 0, 2
; CHECK-P8-NEXT:    addis 3, 2, .LCPI7_0@toc@ha
; CHECK-P8-NEXT:    addis 4, 2, .LCPI7_1@toc@ha
; CHECK-P8-NEXT:    lfs 3, .LCPI7_0@toc@l(3)
; CHECK-P8-NEXT:    lfs 4, .LCPI7_1@toc@l(4)
; CHECK-P8-NEXT:    xsmulsp 2, 2, 0
; CHECK-P8-NEXT:    xsmaddasp 3, 2, 0
; CHECK-P8-NEXT:    xsmulsp 0, 0, 4
; CHECK-P8-NEXT:    xsmulsp 0, 0, 3
; CHECK-P8-NEXT:    xsmulsp 1, 1, 0
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: goo_fmf:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xsrsqrtesp 0, 2
; CHECK-P9-NEXT:    addis 3, 2, .LCPI7_0@toc@ha
; CHECK-P9-NEXT:    lfs 3, .LCPI7_0@toc@l(3)
; CHECK-P9-NEXT:    addis 3, 2, .LCPI7_1@toc@ha
; CHECK-P9-NEXT:    xsmulsp 2, 2, 0
; CHECK-P9-NEXT:    xsmaddasp 3, 2, 0
; CHECK-P9-NEXT:    lfs 2, .LCPI7_1@toc@l(3)
; CHECK-P9-NEXT:    xsmulsp 0, 0, 2
; CHECK-P9-NEXT:    xsmulsp 0, 0, 3
; CHECK-P9-NEXT:    xsmulsp 1, 1, 0
; CHECK-P9-NEXT:    blr
  %x = call reassoc arcp float @llvm.sqrt.f32(float %b)
  %r = fdiv reassoc arcp float %a, %x
  ret float %r
}

define float @goo_safe(float %a, float %b) nounwind {
; CHECK-P7-LABEL: goo_safe:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    fsqrts 0, 2
; CHECK-P7-NEXT:    fdivs 1, 1, 0
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: goo_safe:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xssqrtsp 0, 2
; CHECK-P8-NEXT:    xsdivsp 1, 1, 0
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: goo_safe:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xssqrtsp 0, 2
; CHECK-P9-NEXT:    xsdivsp 1, 1, 0
; CHECK-P9-NEXT:    blr
  %x = call float @llvm.sqrt.f32(float %b)
  %r = fdiv float %a, %x
  ret float %r
}

define float @no_estimate_refinement_f32(float %a, float %b) #0 {
; CHECK-P7-LABEL: no_estimate_refinement_f32:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    frsqrtes 0, 2
; CHECK-P7-NEXT:    fmuls 1, 1, 0
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: no_estimate_refinement_f32:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xsrsqrtesp 0, 2
; CHECK-P8-NEXT:    xsmulsp 1, 1, 0
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: no_estimate_refinement_f32:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xsrsqrtesp 0, 2
; CHECK-P9-NEXT:    xsmulsp 1, 1, 0
; CHECK-P9-NEXT:    blr
  %x = call reassoc arcp float @llvm.sqrt.f32(float %b)
  %r = fdiv reassoc arcp float %a, %x
  ret float %r
}

define float @rsqrt_fmul_fmf(float %a, float %b, float %c) {
; CHECK-P7-LABEL: rsqrt_fmul_fmf:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    frsqrtes 0, 1
; CHECK-P7-NEXT:    addis 3, 2, .LCPI10_0@toc@ha
; CHECK-P7-NEXT:    addis 4, 2, .LCPI10_1@toc@ha
; CHECK-P7-NEXT:    lfs 4, .LCPI10_0@toc@l(3)
; CHECK-P7-NEXT:    lfs 5, .LCPI10_1@toc@l(4)
; CHECK-P7-NEXT:    fmuls 1, 1, 0
; CHECK-P7-NEXT:    fmadds 1, 1, 0, 4
; CHECK-P7-NEXT:    fmuls 0, 0, 5
; CHECK-P7-NEXT:    fmuls 0, 0, 1
; CHECK-P7-NEXT:    fres 1, 2
; CHECK-P7-NEXT:    fmuls 4, 0, 1
; CHECK-P7-NEXT:    fnmsubs 0, 2, 4, 0
; CHECK-P7-NEXT:    fmadds 0, 1, 0, 4
; CHECK-P7-NEXT:    fmuls 1, 3, 0
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: rsqrt_fmul_fmf:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xsrsqrtesp 0, 1
; CHECK-P8-NEXT:    addis 3, 2, .LCPI10_0@toc@ha
; CHECK-P8-NEXT:    addis 4, 2, .LCPI10_1@toc@ha
; CHECK-P8-NEXT:    lfs 4, .LCPI10_0@toc@l(3)
; CHECK-P8-NEXT:    lfs 5, .LCPI10_1@toc@l(4)
; CHECK-P8-NEXT:    xsmulsp 1, 1, 0
; CHECK-P8-NEXT:    xsmaddasp 4, 1, 0
; CHECK-P8-NEXT:    xsmulsp 0, 0, 5
; CHECK-P8-NEXT:    xsresp 1, 2
; CHECK-P8-NEXT:    xsmulsp 0, 0, 4
; CHECK-P8-NEXT:    xsmulsp 4, 0, 1
; CHECK-P8-NEXT:    xsnmsubasp 0, 2, 4
; CHECK-P8-NEXT:    xsmaddasp 4, 1, 0
; CHECK-P8-NEXT:    xsmulsp 1, 3, 4
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: rsqrt_fmul_fmf:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xsrsqrtesp 0, 1
; CHECK-P9-NEXT:    addis 3, 2, .LCPI10_0@toc@ha
; CHECK-P9-NEXT:    lfs 4, .LCPI10_0@toc@l(3)
; CHECK-P9-NEXT:    addis 3, 2, .LCPI10_1@toc@ha
; CHECK-P9-NEXT:    xsmulsp 1, 1, 0
; CHECK-P9-NEXT:    xsmaddasp 4, 1, 0
; CHECK-P9-NEXT:    lfs 1, .LCPI10_1@toc@l(3)
; CHECK-P9-NEXT:    xsmulsp 0, 0, 1
; CHECK-P9-NEXT:    xsresp 1, 2
; CHECK-P9-NEXT:    xsmulsp 0, 0, 4
; CHECK-P9-NEXT:    xsmulsp 4, 0, 1
; CHECK-P9-NEXT:    xsnmsubasp 0, 2, 4
; CHECK-P9-NEXT:    xsmaddasp 4, 1, 0
; CHECK-P9-NEXT:    xsmulsp 1, 3, 4
; CHECK-P9-NEXT:    blr
  %x = call reassoc arcp nsz float @llvm.sqrt.f32(float %a)
  %y = fmul reassoc nsz float %x, %b
  %z = fdiv reassoc arcp nsz ninf float %c, %y
  ret float %z
}

define float @rsqrt_fmul_safe(float %a, float %b, float %c) {
; CHECK-P7-LABEL: rsqrt_fmul_safe:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    fsqrts 0, 1
; CHECK-P7-NEXT:    fmuls 0, 0, 2
; CHECK-P7-NEXT:    fdivs 1, 3, 0
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: rsqrt_fmul_safe:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xssqrtsp 0, 1
; CHECK-P8-NEXT:    xsmulsp 0, 0, 2
; CHECK-P8-NEXT:    xsdivsp 1, 3, 0
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: rsqrt_fmul_safe:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xssqrtsp 0, 1
; CHECK-P9-NEXT:    xsmulsp 0, 0, 2
; CHECK-P9-NEXT:    xsdivsp 1, 3, 0
; CHECK-P9-NEXT:    blr
  %x = call float @llvm.sqrt.f32(float %a)
  %y = fmul float %x, %b
  %z = fdiv float %c, %y
  ret float %z
}

define <4 x float> @hoo_fmf(<4 x float> %a, <4 x float> %b) nounwind {
; CHECK-P7-LABEL: hoo_fmf:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    vspltisw 4, -1
; CHECK-P7-NEXT:    addis 3, 2, .LCPI12_0@toc@ha
; CHECK-P7-NEXT:    vrsqrtefp 5, 3
; CHECK-P7-NEXT:    addi 3, 3, .LCPI12_0@toc@l
; CHECK-P7-NEXT:    lvx 0, 0, 3
; CHECK-P7-NEXT:    addis 3, 2, .LCPI12_1@toc@ha
; CHECK-P7-NEXT:    addi 3, 3, .LCPI12_1@toc@l
; CHECK-P7-NEXT:    lvx 1, 0, 3
; CHECK-P7-NEXT:    vslw 4, 4, 4
; CHECK-P7-NEXT:    vmaddfp 3, 3, 5, 4
; CHECK-P7-NEXT:    vmaddfp 3, 3, 5, 0
; CHECK-P7-NEXT:    vmaddfp 5, 5, 1, 4
; CHECK-P7-NEXT:    vmaddfp 3, 5, 3, 4
; CHECK-P7-NEXT:    vmaddfp 2, 2, 3, 4
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: hoo_fmf:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xvrsqrtesp 0, 35
; CHECK-P8-NEXT:    addis 3, 2, .LCPI12_0@toc@ha
; CHECK-P8-NEXT:    addis 4, 2, .LCPI12_1@toc@ha
; CHECK-P8-NEXT:    addi 3, 3, .LCPI12_0@toc@l
; CHECK-P8-NEXT:    xvmulsp 1, 35, 0
; CHECK-P8-NEXT:    lvx 3, 0, 3
; CHECK-P8-NEXT:    addi 3, 4, .LCPI12_1@toc@l
; CHECK-P8-NEXT:    lvx 4, 0, 3
; CHECK-P8-NEXT:    xvmaddasp 35, 1, 0
; CHECK-P8-NEXT:    xvmulsp 0, 0, 36
; CHECK-P8-NEXT:    xvmulsp 0, 0, 35
; CHECK-P8-NEXT:    xvmulsp 34, 34, 0
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: hoo_fmf:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xvrsqrtesp 0, 35
; CHECK-P9-NEXT:    addis 3, 2, .LCPI12_0@toc@ha
; CHECK-P9-NEXT:    addi 3, 3, .LCPI12_0@toc@l
; CHECK-P9-NEXT:    lxvx 2, 0, 3
; CHECK-P9-NEXT:    addis 3, 2, .LCPI12_1@toc@ha
; CHECK-P9-NEXT:    addi 3, 3, .LCPI12_1@toc@l
; CHECK-P9-NEXT:    xvmulsp 1, 35, 0
; CHECK-P9-NEXT:    xvmaddasp 2, 1, 0
; CHECK-P9-NEXT:    lxvx 1, 0, 3
; CHECK-P9-NEXT:    xvmulsp 0, 0, 1
; CHECK-P9-NEXT:    xvmulsp 0, 0, 2
; CHECK-P9-NEXT:    xvmulsp 34, 34, 0
; CHECK-P9-NEXT:    blr
  %x = call reassoc arcp <4 x float> @llvm.sqrt.v4f32(<4 x float> %b)
  %r = fdiv reassoc arcp <4 x float> %a, %x
  ret <4 x float> %r
}

define <4 x float> @hoo_safe(<4 x float> %a, <4 x float> %b) nounwind {
; CHECK-P7-LABEL: hoo_safe:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    addi 3, 1, -32
; CHECK-P7-NEXT:    stvx 3, 0, 3
; CHECK-P7-NEXT:    addi 3, 1, -48
; CHECK-P7-NEXT:    lfs 0, -20(1)
; CHECK-P7-NEXT:    lfs 3, -24(1)
; CHECK-P7-NEXT:    lfs 1, -32(1)
; CHECK-P7-NEXT:    lfs 2, -28(1)
; CHECK-P7-NEXT:    stvx 2, 0, 3
; CHECK-P7-NEXT:    addi 3, 1, -16
; CHECK-P7-NEXT:    fsqrts 0, 0
; CHECK-P7-NEXT:    lfs 4, -36(1)
; CHECK-P7-NEXT:    fsqrts 3, 3
; CHECK-P7-NEXT:    fsqrts 2, 2
; CHECK-P7-NEXT:    fsqrts 1, 1
; CHECK-P7-NEXT:    fdivs 0, 4, 0
; CHECK-P7-NEXT:    stfs 0, -4(1)
; CHECK-P7-NEXT:    lfs 0, -40(1)
; CHECK-P7-NEXT:    fdivs 0, 0, 3
; CHECK-P7-NEXT:    stfs 0, -8(1)
; CHECK-P7-NEXT:    lfs 0, -44(1)
; CHECK-P7-NEXT:    fdivs 0, 0, 2
; CHECK-P7-NEXT:    stfs 0, -12(1)
; CHECK-P7-NEXT:    lfs 0, -48(1)
; CHECK-P7-NEXT:    fdivs 0, 0, 1
; CHECK-P7-NEXT:    stfs 0, -16(1)
; CHECK-P7-NEXT:    lvx 2, 0, 3
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: hoo_safe:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xvsqrtsp 0, 35
; CHECK-P8-NEXT:    xvdivsp 34, 34, 0
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: hoo_safe:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xvsqrtsp 0, 35
; CHECK-P9-NEXT:    xvdivsp 34, 34, 0
; CHECK-P9-NEXT:    blr
  %x = call <4 x float> @llvm.sqrt.v4f32(<4 x float> %b)
  %r = fdiv <4 x float> %a, %x
  ret <4 x float> %r
}

define double @foo2_fmf(double %a, double %b) nounwind {
; CHECK-P7-LABEL: foo2_fmf:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    fre 0, 2
; CHECK-P7-NEXT:    addis 3, 2, .LCPI14_0@toc@ha
; CHECK-P7-NEXT:    lfs 3, .LCPI14_0@toc@l(3)
; CHECK-P7-NEXT:    fmadd 3, 2, 0, 3
; CHECK-P7-NEXT:    fnmsub 0, 0, 3, 0
; CHECK-P7-NEXT:    fmul 3, 1, 0
; CHECK-P7-NEXT:    fnmsub 1, 2, 3, 1
; CHECK-P7-NEXT:    fmadd 1, 0, 1, 3
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: foo2_fmf:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xsredp 3, 2
; CHECK-P8-NEXT:    addis 3, 2, .LCPI14_0@toc@ha
; CHECK-P8-NEXT:    lfs 0, .LCPI14_0@toc@l(3)
; CHECK-P8-NEXT:    xsmaddadp 0, 2, 3
; CHECK-P8-NEXT:    xsnmsubadp 3, 3, 0
; CHECK-P8-NEXT:    xsmuldp 0, 1, 3
; CHECK-P8-NEXT:    xsnmsubadp 1, 2, 0
; CHECK-P8-NEXT:    xsmaddadp 0, 3, 1
; CHECK-P8-NEXT:    fmr 1, 0
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: foo2_fmf:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    addis 3, 2, .LCPI14_0@toc@ha
; CHECK-P9-NEXT:    xsredp 3, 2
; CHECK-P9-NEXT:    lfs 0, .LCPI14_0@toc@l(3)
; CHECK-P9-NEXT:    xsmaddadp 0, 2, 3
; CHECK-P9-NEXT:    xsnmsubadp 3, 3, 0
; CHECK-P9-NEXT:    xsmuldp 0, 1, 3
; CHECK-P9-NEXT:    xsnmsubadp 1, 2, 0
; CHECK-P9-NEXT:    xsmaddadp 0, 3, 1
; CHECK-P9-NEXT:    fmr 1, 0
; CHECK-P9-NEXT:    blr
  %r = fdiv reassoc arcp nsz ninf double %a, %b
  ret double %r
}

define double @foo2_safe(double %a, double %b) nounwind {
; CHECK-P7-LABEL: foo2_safe:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    fdiv 1, 1, 2
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: foo2_safe:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xsdivdp 1, 1, 2
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: foo2_safe:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xsdivdp 1, 1, 2
; CHECK-P9-NEXT:    blr
  %r = fdiv double %a, %b
  ret double %r
}

define float @goo2_fmf(float %a, float %b) nounwind {
; CHECK-P7-LABEL: goo2_fmf:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    fres 0, 2
; CHECK-P7-NEXT:    fmuls 3, 1, 0
; CHECK-P7-NEXT:    fnmsubs 1, 2, 3, 1
; CHECK-P7-NEXT:    fmadds 1, 0, 1, 3
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: goo2_fmf:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xsresp 3, 2
; CHECK-P8-NEXT:    xsmulsp 0, 1, 3
; CHECK-P8-NEXT:    xsnmsubasp 1, 2, 0
; CHECK-P8-NEXT:    xsmaddasp 0, 3, 1
; CHECK-P8-NEXT:    fmr 1, 0
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: goo2_fmf:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xsresp 3, 2
; CHECK-P9-NEXT:    xsmulsp 0, 1, 3
; CHECK-P9-NEXT:    xsnmsubasp 1, 2, 0
; CHECK-P9-NEXT:    xsmaddasp 0, 3, 1
; CHECK-P9-NEXT:    fmr 1, 0
; CHECK-P9-NEXT:    blr
  %r = fdiv reassoc arcp nsz ninf float %a, %b
  ret float %r
}

define float @goo2_safe(float %a, float %b) nounwind {
; CHECK-P7-LABEL: goo2_safe:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    fdivs 1, 1, 2
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: goo2_safe:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xsdivsp 1, 1, 2
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: goo2_safe:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xsdivsp 1, 1, 2
; CHECK-P9-NEXT:    blr
  %r = fdiv float %a, %b
  ret float %r
}

define <4 x float> @hoo2_fmf(<4 x float> %a, <4 x float> %b) nounwind {
; CHECK-P7-LABEL: hoo2_fmf:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    vspltisw 4, -1
; CHECK-P7-NEXT:    vrefp 5, 3
; CHECK-P7-NEXT:    vspltisb 0, -1
; CHECK-P7-NEXT:    vslw 0, 0, 0
; CHECK-P7-NEXT:    vslw 4, 4, 4
; CHECK-P7-NEXT:    vsubfp 3, 0, 3
; CHECK-P7-NEXT:    vmaddfp 4, 2, 5, 4
; CHECK-P7-NEXT:    vmaddfp 2, 3, 4, 2
; CHECK-P7-NEXT:    vmaddfp 2, 5, 2, 4
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: hoo2_fmf:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xvresp 1, 35
; CHECK-P8-NEXT:    xvmulsp 0, 34, 1
; CHECK-P8-NEXT:    xvnmsubasp 34, 35, 0
; CHECK-P8-NEXT:    xvmaddasp 0, 1, 34
; CHECK-P8-NEXT:    xxlor 34, 0, 0
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: hoo2_fmf:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xvresp 1, 35
; CHECK-P9-NEXT:    xvmulsp 0, 34, 1
; CHECK-P9-NEXT:    xvnmsubasp 34, 35, 0
; CHECK-P9-NEXT:    xvmaddasp 0, 1, 34
; CHECK-P9-NEXT:    xxlor 34, 0, 0
; CHECK-P9-NEXT:    blr
  %r = fdiv reassoc arcp nsz ninf <4 x float> %a, %b
  ret <4 x float> %r
}

define <4 x float> @hoo2_safe(<4 x float> %a, <4 x float> %b) nounwind {
; CHECK-P7-LABEL: hoo2_safe:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    addi 3, 1, -32
; CHECK-P7-NEXT:    addi 4, 1, -48
; CHECK-P7-NEXT:    stvx 3, 0, 3
; CHECK-P7-NEXT:    stvx 2, 0, 4
; CHECK-P7-NEXT:    lfs 0, -20(1)
; CHECK-P7-NEXT:    lfs 1, -36(1)
; CHECK-P7-NEXT:    addi 3, 1, -16
; CHECK-P7-NEXT:    fdivs 0, 1, 0
; CHECK-P7-NEXT:    lfs 1, -40(1)
; CHECK-P7-NEXT:    stfs 0, -4(1)
; CHECK-P7-NEXT:    lfs 0, -24(1)
; CHECK-P7-NEXT:    fdivs 0, 1, 0
; CHECK-P7-NEXT:    lfs 1, -44(1)
; CHECK-P7-NEXT:    stfs 0, -8(1)
; CHECK-P7-NEXT:    lfs 0, -28(1)
; CHECK-P7-NEXT:    fdivs 0, 1, 0
; CHECK-P7-NEXT:    lfs 1, -48(1)
; CHECK-P7-NEXT:    stfs 0, -12(1)
; CHECK-P7-NEXT:    lfs 0, -32(1)
; CHECK-P7-NEXT:    fdivs 0, 1, 0
; CHECK-P7-NEXT:    stfs 0, -16(1)
; CHECK-P7-NEXT:    lvx 2, 0, 3
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: hoo2_safe:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xvdivsp 34, 34, 35
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: hoo2_safe:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xvdivsp 34, 34, 35
; CHECK-P9-NEXT:    blr
  %r = fdiv <4 x float> %a, %b
  ret <4 x float> %r
}

define double @foo3_fmf(double %a) nounwind {
; CHECK-P7-LABEL: foo3_fmf:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    fabs 0, 1
; CHECK-P7-NEXT:    addis 3, 2, .LCPI20_2@toc@ha
; CHECK-P7-NEXT:    lfd 2, .LCPI20_2@toc@l(3)
; CHECK-P7-NEXT:    fcmpu 0, 0, 2
; CHECK-P7-NEXT:    blt 0, .LBB20_2
; CHECK-P7-NEXT:  # %bb.1:
; CHECK-P7-NEXT:    frsqrte 0, 1
; CHECK-P7-NEXT:    addis 3, 2, .LCPI20_0@toc@ha
; CHECK-P7-NEXT:    addis 4, 2, .LCPI20_1@toc@ha
; CHECK-P7-NEXT:    lfs 3, .LCPI20_0@toc@l(3)
; CHECK-P7-NEXT:    lfs 4, .LCPI20_1@toc@l(4)
; CHECK-P7-NEXT:    fmul 2, 1, 0
; CHECK-P7-NEXT:    fmadd 2, 2, 0, 3
; CHECK-P7-NEXT:    fmul 0, 0, 4
; CHECK-P7-NEXT:    fmul 0, 0, 2
; CHECK-P7-NEXT:    fmul 1, 1, 0
; CHECK-P7-NEXT:    fmadd 0, 1, 0, 3
; CHECK-P7-NEXT:    fmul 1, 1, 4
; CHECK-P7-NEXT:    fmul 1, 1, 0
; CHECK-P7-NEXT:    blr
; CHECK-P7-NEXT:  .LBB20_2:
; CHECK-P7-NEXT:    addis 3, 2, .LCPI20_3@toc@ha
; CHECK-P7-NEXT:    lfs 1, .LCPI20_3@toc@l(3)
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: foo3_fmf:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xsabsdp 0, 1
; CHECK-P8-NEXT:    addis 3, 2, .LCPI20_2@toc@ha
; CHECK-P8-NEXT:    lfd 2, .LCPI20_2@toc@l(3)
; CHECK-P8-NEXT:    xscmpudp 0, 0, 2
; CHECK-P8-NEXT:    xxlxor 0, 0, 0
; CHECK-P8-NEXT:    blt 0, .LBB20_2
; CHECK-P8-NEXT:  # %bb.1:
; CHECK-P8-NEXT:    xsrsqrtedp 0, 1
; CHECK-P8-NEXT:    addis 3, 2, .LCPI20_0@toc@ha
; CHECK-P8-NEXT:    lfs 3, .LCPI20_0@toc@l(3)
; CHECK-P8-NEXT:    addis 3, 2, .LCPI20_1@toc@ha
; CHECK-P8-NEXT:    lfs 4, .LCPI20_1@toc@l(3)
; CHECK-P8-NEXT:    fmr 5, 3
; CHECK-P8-NEXT:    xsmuldp 2, 1, 0
; CHECK-P8-NEXT:    xsmaddadp 5, 2, 0
; CHECK-P8-NEXT:    xsmuldp 0, 0, 4
; CHECK-P8-NEXT:    xsmuldp 0, 0, 5
; CHECK-P8-NEXT:    xsmuldp 1, 1, 0
; CHECK-P8-NEXT:    xsmaddadp 3, 1, 0
; CHECK-P8-NEXT:    xsmuldp 0, 1, 4
; CHECK-P8-NEXT:    xsmuldp 0, 0, 3
; CHECK-P8-NEXT:  .LBB20_2:
; CHECK-P8-NEXT:    fmr 1, 0
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: foo3_fmf:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    addis 3, 2, .LCPI20_2@toc@ha
; CHECK-P9-NEXT:    lfd 2, .LCPI20_2@toc@l(3)
; CHECK-P9-NEXT:    xsabsdp 0, 1
; CHECK-P9-NEXT:    xscmpudp 0, 0, 2
; CHECK-P9-NEXT:    xxlxor 0, 0, 0
; CHECK-P9-NEXT:    blt 0, .LBB20_2
; CHECK-P9-NEXT:  # %bb.1:
; CHECK-P9-NEXT:    xsrsqrtedp 0, 1
; CHECK-P9-NEXT:    addis 3, 2, .LCPI20_0@toc@ha
; CHECK-P9-NEXT:    lfs 3, .LCPI20_0@toc@l(3)
; CHECK-P9-NEXT:    addis 3, 2, .LCPI20_1@toc@ha
; CHECK-P9-NEXT:    xsmuldp 2, 1, 0
; CHECK-P9-NEXT:    fmr 4, 3
; CHECK-P9-NEXT:    xsmaddadp 4, 2, 0
; CHECK-P9-NEXT:    lfs 2, .LCPI20_1@toc@l(3)
; CHECK-P9-NEXT:    xsmuldp 0, 0, 2
; CHECK-P9-NEXT:    xsmuldp 0, 0, 4
; CHECK-P9-NEXT:    xsmuldp 1, 1, 0
; CHECK-P9-NEXT:    xsmaddadp 3, 1, 0
; CHECK-P9-NEXT:    xsmuldp 0, 1, 2
; CHECK-P9-NEXT:    xsmuldp 0, 0, 3
; CHECK-P9-NEXT:  .LBB20_2:
; CHECK-P9-NEXT:    fmr 1, 0
; CHECK-P9-NEXT:    blr
  %r = call reassoc ninf afn double @llvm.sqrt.f64(double %a)
  ret double %r
}

define double @foo3_safe(double %a) nounwind {
; CHECK-P7-LABEL: foo3_safe:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    fsqrt 1, 1
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: foo3_safe:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xssqrtdp 1, 1
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: foo3_safe:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xssqrtdp 1, 1
; CHECK-P9-NEXT:    blr
  %r = call double @llvm.sqrt.f64(double %a)
  ret double %r
}

define float @goo3_fmf(float %a) nounwind {
; CHECK-P7-LABEL: goo3_fmf:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    fabs 0, 1
; CHECK-P7-NEXT:    addis 3, 2, .LCPI22_2@toc@ha
; CHECK-P7-NEXT:    lfs 2, .LCPI22_2@toc@l(3)
; CHECK-P7-NEXT:    fcmpu 0, 0, 2
; CHECK-P7-NEXT:    blt 0, .LBB22_2
; CHECK-P7-NEXT:  # %bb.1:
; CHECK-P7-NEXT:    frsqrtes 0, 1
; CHECK-P7-NEXT:    addis 3, 2, .LCPI22_0@toc@ha
; CHECK-P7-NEXT:    addis 4, 2, .LCPI22_1@toc@ha
; CHECK-P7-NEXT:    lfs 2, .LCPI22_0@toc@l(3)
; CHECK-P7-NEXT:    lfs 3, .LCPI22_1@toc@l(4)
; CHECK-P7-NEXT:    fmuls 1, 1, 0
; CHECK-P7-NEXT:    fmadds 0, 1, 0, 2
; CHECK-P7-NEXT:    fmuls 1, 1, 3
; CHECK-P7-NEXT:    fmuls 1, 1, 0
; CHECK-P7-NEXT:    blr
; CHECK-P7-NEXT:  .LBB22_2:
; CHECK-P7-NEXT:    addis 3, 2, .LCPI22_3@toc@ha
; CHECK-P7-NEXT:    lfs 1, .LCPI22_3@toc@l(3)
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: goo3_fmf:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xsabsdp 0, 1
; CHECK-P8-NEXT:    addis 3, 2, .LCPI22_2@toc@ha
; CHECK-P8-NEXT:    lfs 2, .LCPI22_2@toc@l(3)
; CHECK-P8-NEXT:    fcmpu 0, 0, 2
; CHECK-P8-NEXT:    xxlxor 0, 0, 0
; CHECK-P8-NEXT:    blt 0, .LBB22_2
; CHECK-P8-NEXT:  # %bb.1:
; CHECK-P8-NEXT:    xsrsqrtesp 0, 1
; CHECK-P8-NEXT:    addis 3, 2, .LCPI22_0@toc@ha
; CHECK-P8-NEXT:    addis 4, 2, .LCPI22_1@toc@ha
; CHECK-P8-NEXT:    lfs 2, .LCPI22_0@toc@l(3)
; CHECK-P8-NEXT:    lfs 3, .LCPI22_1@toc@l(4)
; CHECK-P8-NEXT:    xsmulsp 1, 1, 0
; CHECK-P8-NEXT:    xsmaddasp 2, 1, 0
; CHECK-P8-NEXT:    xsmulsp 0, 1, 3
; CHECK-P8-NEXT:    xsmulsp 0, 0, 2
; CHECK-P8-NEXT:  .LBB22_2:
; CHECK-P8-NEXT:    fmr 1, 0
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: goo3_fmf:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    addis 3, 2, .LCPI22_2@toc@ha
; CHECK-P9-NEXT:    lfs 2, .LCPI22_2@toc@l(3)
; CHECK-P9-NEXT:    xsabsdp 0, 1
; CHECK-P9-NEXT:    fcmpu 0, 0, 2
; CHECK-P9-NEXT:    xxlxor 0, 0, 0
; CHECK-P9-NEXT:    blt 0, .LBB22_2
; CHECK-P9-NEXT:  # %bb.1:
; CHECK-P9-NEXT:    xsrsqrtesp 0, 1
; CHECK-P9-NEXT:    addis 3, 2, .LCPI22_0@toc@ha
; CHECK-P9-NEXT:    lfs 2, .LCPI22_0@toc@l(3)
; CHECK-P9-NEXT:    addis 3, 2, .LCPI22_1@toc@ha
; CHECK-P9-NEXT:    xsmulsp 1, 1, 0
; CHECK-P9-NEXT:    xsmaddasp 2, 1, 0
; CHECK-P9-NEXT:    lfs 0, .LCPI22_1@toc@l(3)
; CHECK-P9-NEXT:    xsmulsp 0, 1, 0
; CHECK-P9-NEXT:    xsmulsp 0, 0, 2
; CHECK-P9-NEXT:  .LBB22_2:
; CHECK-P9-NEXT:    fmr 1, 0
; CHECK-P9-NEXT:    blr
  %r = call reassoc ninf afn float @llvm.sqrt.f32(float %a)
  ret float %r
}

define float @goo3_safe(float %a) nounwind {
; CHECK-P7-LABEL: goo3_safe:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    fsqrts 1, 1
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: goo3_safe:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xssqrtsp 1, 1
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: goo3_safe:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xssqrtsp 1, 1
; CHECK-P9-NEXT:    blr
  %r = call float @llvm.sqrt.f32(float %a)
  ret float %r
}

define <4 x float> @hoo3_fmf(<4 x float> %a) #1 {
; CHECK-P7-LABEL: hoo3_fmf:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    vspltisw 3, -1
; CHECK-P7-NEXT:    addis 3, 2, .LCPI24_0@toc@ha
; CHECK-P7-NEXT:    vrsqrtefp 4, 2
; CHECK-P7-NEXT:    addi 3, 3, .LCPI24_0@toc@l
; CHECK-P7-NEXT:    lvx 0, 0, 3
; CHECK-P7-NEXT:    addis 3, 2, .LCPI24_1@toc@ha
; CHECK-P7-NEXT:    addi 3, 3, .LCPI24_1@toc@l
; CHECK-P7-NEXT:    lvx 1, 0, 3
; CHECK-P7-NEXT:    vslw 3, 3, 3
; CHECK-P7-NEXT:    vmaddfp 5, 2, 4, 3
; CHECK-P7-NEXT:    vmaddfp 4, 5, 4, 0
; CHECK-P7-NEXT:    vmaddfp 5, 5, 1, 3
; CHECK-P7-NEXT:    vxor 0, 0, 0
; CHECK-P7-NEXT:    vmaddfp 3, 5, 4, 3
; CHECK-P7-NEXT:    vcmpeqfp 2, 2, 0
; CHECK-P7-NEXT:    vsel 2, 3, 0, 2
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: hoo3_fmf:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xvrsqrtesp 0, 34
; CHECK-P8-NEXT:    addis 3, 2, .LCPI24_0@toc@ha
; CHECK-P8-NEXT:    addis 4, 2, .LCPI24_1@toc@ha
; CHECK-P8-NEXT:    addi 3, 3, .LCPI24_0@toc@l
; CHECK-P8-NEXT:    lvx 3, 0, 3
; CHECK-P8-NEXT:    addi 3, 4, .LCPI24_1@toc@l
; CHECK-P8-NEXT:    lvx 4, 0, 3
; CHECK-P8-NEXT:    xvmulsp 1, 34, 0
; CHECK-P8-NEXT:    xvmaddasp 35, 1, 0
; CHECK-P8-NEXT:    xvmulsp 0, 1, 36
; CHECK-P8-NEXT:    xxlxor 1, 1, 1
; CHECK-P8-NEXT:    xvcmpeqsp 2, 34, 1
; CHECK-P8-NEXT:    xvmulsp 0, 0, 35
; CHECK-P8-NEXT:    xxsel 34, 0, 1, 2
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: hoo3_fmf:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xvrsqrtesp 0, 34
; CHECK-P9-NEXT:    addis 3, 2, .LCPI24_0@toc@ha
; CHECK-P9-NEXT:    addi 3, 3, .LCPI24_0@toc@l
; CHECK-P9-NEXT:    lxvx 2, 0, 3
; CHECK-P9-NEXT:    addis 3, 2, .LCPI24_1@toc@ha
; CHECK-P9-NEXT:    addi 3, 3, .LCPI24_1@toc@l
; CHECK-P9-NEXT:    xvmulsp 1, 34, 0
; CHECK-P9-NEXT:    xvmaddasp 2, 1, 0
; CHECK-P9-NEXT:    lxvx 0, 0, 3
; CHECK-P9-NEXT:    xvmulsp 0, 1, 0
; CHECK-P9-NEXT:    xxlxor 1, 1, 1
; CHECK-P9-NEXT:    xvmulsp 0, 0, 2
; CHECK-P9-NEXT:    xvcmpeqsp 2, 34, 1
; CHECK-P9-NEXT:    xxsel 34, 0, 1, 2
; CHECK-P9-NEXT:    blr
  %r = call reassoc ninf afn <4 x float> @llvm.sqrt.v4f32(<4 x float> %a)
  ret <4 x float> %r
}

define <4 x float> @hoo3_safe(<4 x float> %a) nounwind {
; CHECK-P7-LABEL: hoo3_safe:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    addi 3, 1, -32
; CHECK-P7-NEXT:    stvx 2, 0, 3
; CHECK-P7-NEXT:    addi 3, 1, -16
; CHECK-P7-NEXT:    lfs 0, -20(1)
; CHECK-P7-NEXT:    fsqrts 0, 0
; CHECK-P7-NEXT:    stfs 0, -4(1)
; CHECK-P7-NEXT:    lfs 0, -24(1)
; CHECK-P7-NEXT:    fsqrts 0, 0
; CHECK-P7-NEXT:    stfs 0, -8(1)
; CHECK-P7-NEXT:    lfs 0, -28(1)
; CHECK-P7-NEXT:    fsqrts 0, 0
; CHECK-P7-NEXT:    stfs 0, -12(1)
; CHECK-P7-NEXT:    lfs 0, -32(1)
; CHECK-P7-NEXT:    fsqrts 0, 0
; CHECK-P7-NEXT:    stfs 0, -16(1)
; CHECK-P7-NEXT:    lvx 2, 0, 3
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: hoo3_safe:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xvsqrtsp 34, 34
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: hoo3_safe:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xvsqrtsp 34, 34
; CHECK-P9-NEXT:    blr
  %r = call <4 x float> @llvm.sqrt.v4f32(<4 x float> %a)
  ret <4 x float> %r
}

define <2 x double> @hoo4_fmf(<2 x double> %a) #1 {
; CHECK-P7-LABEL: hoo4_fmf:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    addis 3, 2, .LCPI26_2@toc@ha
; CHECK-P7-NEXT:    fmr 3, 1
; CHECK-P7-NEXT:    addis 4, 2, .LCPI26_1@toc@ha
; CHECK-P7-NEXT:    lfs 0, .LCPI26_2@toc@l(3)
; CHECK-P7-NEXT:    addis 3, 2, .LCPI26_0@toc@ha
; CHECK-P7-NEXT:    lfs 4, .LCPI26_1@toc@l(4)
; CHECK-P7-NEXT:    lfs 5, .LCPI26_0@toc@l(3)
; CHECK-P7-NEXT:    fcmpu 0, 1, 0
; CHECK-P7-NEXT:    fmr 1, 0
; CHECK-P7-NEXT:    bne 0, .LBB26_3
; CHECK-P7-NEXT:  # %bb.1:
; CHECK-P7-NEXT:    fcmpu 0, 2, 0
; CHECK-P7-NEXT:    bne 0, .LBB26_4
; CHECK-P7-NEXT:  .LBB26_2:
; CHECK-P7-NEXT:    fmr 2, 0
; CHECK-P7-NEXT:    blr
; CHECK-P7-NEXT:  .LBB26_3:
; CHECK-P7-NEXT:    frsqrte 1, 3
; CHECK-P7-NEXT:    fmul 6, 3, 1
; CHECK-P7-NEXT:    fmadd 6, 6, 1, 5
; CHECK-P7-NEXT:    fmul 1, 1, 4
; CHECK-P7-NEXT:    fmul 1, 1, 6
; CHECK-P7-NEXT:    fmul 3, 3, 1
; CHECK-P7-NEXT:    fmadd 1, 3, 1, 5
; CHECK-P7-NEXT:    fmul 3, 3, 4
; CHECK-P7-NEXT:    fmul 1, 3, 1
; CHECK-P7-NEXT:    fcmpu 0, 2, 0
; CHECK-P7-NEXT:    beq 0, .LBB26_2
; CHECK-P7-NEXT:  .LBB26_4:
; CHECK-P7-NEXT:    frsqrte 0, 2
; CHECK-P7-NEXT:    fmul 3, 2, 0
; CHECK-P7-NEXT:    fmadd 3, 3, 0, 5
; CHECK-P7-NEXT:    fmul 0, 0, 4
; CHECK-P7-NEXT:    fmul 0, 0, 3
; CHECK-P7-NEXT:    fmul 2, 2, 0
; CHECK-P7-NEXT:    fmadd 0, 2, 0, 5
; CHECK-P7-NEXT:    fmul 2, 2, 4
; CHECK-P7-NEXT:    fmul 0, 2, 0
; CHECK-P7-NEXT:    fmr 2, 0
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: hoo4_fmf:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xvrsqrtedp 0, 34
; CHECK-P8-NEXT:    addis 3, 2, .LCPI26_0@toc@ha
; CHECK-P8-NEXT:    addi 3, 3, .LCPI26_0@toc@l
; CHECK-P8-NEXT:    lxvd2x 1, 0, 3
; CHECK-P8-NEXT:    addis 3, 2, .LCPI26_1@toc@ha
; CHECK-P8-NEXT:    addi 3, 3, .LCPI26_1@toc@l
; CHECK-P8-NEXT:    lxvd2x 3, 0, 3
; CHECK-P8-NEXT:    xxswapd 1, 1
; CHECK-P8-NEXT:    xvmuldp 2, 34, 0
; CHECK-P8-NEXT:    xxswapd 3, 3
; CHECK-P8-NEXT:    xxlor 4, 1, 1
; CHECK-P8-NEXT:    xvmaddadp 4, 2, 0
; CHECK-P8-NEXT:    xvmuldp 0, 0, 3
; CHECK-P8-NEXT:    xvmuldp 0, 0, 4
; CHECK-P8-NEXT:    xvmuldp 2, 34, 0
; CHECK-P8-NEXT:    xvmaddadp 1, 2, 0
; CHECK-P8-NEXT:    xvmuldp 0, 2, 3
; CHECK-P8-NEXT:    xxlxor 2, 2, 2
; CHECK-P8-NEXT:    xvcmpeqdp 34, 34, 2
; CHECK-P8-NEXT:    xvmuldp 0, 0, 1
; CHECK-P8-NEXT:    xxsel 34, 0, 2, 34
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: hoo4_fmf:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xvrsqrtedp 0, 34
; CHECK-P9-NEXT:    addis 3, 2, .LCPI26_0@toc@ha
; CHECK-P9-NEXT:    addi 3, 3, .LCPI26_0@toc@l
; CHECK-P9-NEXT:    lxvx 2, 0, 3
; CHECK-P9-NEXT:    addis 3, 2, .LCPI26_1@toc@ha
; CHECK-P9-NEXT:    addi 3, 3, .LCPI26_1@toc@l
; CHECK-P9-NEXT:    xvmuldp 1, 34, 0
; CHECK-P9-NEXT:    xxlor 3, 2, 2
; CHECK-P9-NEXT:    xvmaddadp 3, 1, 0
; CHECK-P9-NEXT:    lxvx 1, 0, 3
; CHECK-P9-NEXT:    xvmuldp 0, 0, 1
; CHECK-P9-NEXT:    xvmuldp 0, 0, 3
; CHECK-P9-NEXT:    xvmuldp 3, 34, 0
; CHECK-P9-NEXT:    xvmaddadp 2, 3, 0
; CHECK-P9-NEXT:    xvmuldp 0, 3, 1
; CHECK-P9-NEXT:    xxlxor 1, 1, 1
; CHECK-P9-NEXT:    xvcmpeqdp 34, 34, 1
; CHECK-P9-NEXT:    xvmuldp 0, 0, 2
; CHECK-P9-NEXT:    xxsel 34, 0, 1, 34
; CHECK-P9-NEXT:    blr
  %r = call reassoc ninf afn <2 x double> @llvm.sqrt.v2f64(<2 x double> %a)
  ret <2 x double> %r
}

define <2 x double> @hoo4_safe(<2 x double> %a) #1 {
; CHECK-P7-LABEL: hoo4_safe:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    fsqrt 1, 1
; CHECK-P7-NEXT:    fsqrt 2, 2
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: hoo4_safe:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    xvsqrtdp 34, 34
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: hoo4_safe:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    xvsqrtdp 34, 34
; CHECK-P9-NEXT:    blr
  %r = call <2 x double> @llvm.sqrt.v2f64(<2 x double> %a)
  ret <2 x double> %r
}

define fp128 @hoo5_fmf(fp128 %a) #1 {
; CHECK-P7-LABEL: hoo5_fmf:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    mflr 0
; CHECK-P7-NEXT:    std 0, 16(1)
; CHECK-P7-NEXT:    stdu 1, -112(1)
; CHECK-P7-NEXT:    bl sqrtl
; CHECK-P7-NEXT:    nop
; CHECK-P7-NEXT:    addi 1, 1, 112
; CHECK-P7-NEXT:    ld 0, 16(1)
; CHECK-P7-NEXT:    mtlr 0
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: hoo5_fmf:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    mflr 0
; CHECK-P8-NEXT:    std 0, 16(1)
; CHECK-P8-NEXT:    stdu 1, -32(1)
; CHECK-P8-NEXT:    bl sqrtl
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    addi 1, 1, 32
; CHECK-P8-NEXT:    ld 0, 16(1)
; CHECK-P8-NEXT:    mtlr 0
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: hoo5_fmf:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    mflr 0
; CHECK-P9-NEXT:    std 0, 16(1)
; CHECK-P9-NEXT:    stdu 1, -32(1)
; CHECK-P9-NEXT:    bl sqrtl
; CHECK-P9-NEXT:    nop
; CHECK-P9-NEXT:    addi 1, 1, 32
; CHECK-P9-NEXT:    ld 0, 16(1)
; CHECK-P9-NEXT:    mtlr 0
; CHECK-P9-NEXT:    blr
  %r = call reassoc ninf afn fp128 @llvm.sqrt.f128(fp128 %a)
  ret fp128 %r
}

define fp128 @hoo5_safe(fp128 %a) #1 {
; CHECK-P7-LABEL: hoo5_safe:
; CHECK-P7:       # %bb.0:
; CHECK-P7-NEXT:    mflr 0
; CHECK-P7-NEXT:    std 0, 16(1)
; CHECK-P7-NEXT:    stdu 1, -112(1)
; CHECK-P7-NEXT:    bl sqrtl
; CHECK-P7-NEXT:    nop
; CHECK-P7-NEXT:    addi 1, 1, 112
; CHECK-P7-NEXT:    ld 0, 16(1)
; CHECK-P7-NEXT:    mtlr 0
; CHECK-P7-NEXT:    blr
;
; CHECK-P8-LABEL: hoo5_safe:
; CHECK-P8:       # %bb.0:
; CHECK-P8-NEXT:    mflr 0
; CHECK-P8-NEXT:    std 0, 16(1)
; CHECK-P8-NEXT:    stdu 1, -32(1)
; CHECK-P8-NEXT:    bl sqrtl
; CHECK-P8-NEXT:    nop
; CHECK-P8-NEXT:    addi 1, 1, 32
; CHECK-P8-NEXT:    ld 0, 16(1)
; CHECK-P8-NEXT:    mtlr 0
; CHECK-P8-NEXT:    blr
;
; CHECK-P9-LABEL: hoo5_safe:
; CHECK-P9:       # %bb.0:
; CHECK-P9-NEXT:    mflr 0
; CHECK-P9-NEXT:    std 0, 16(1)
; CHECK-P9-NEXT:    stdu 1, -32(1)
; CHECK-P9-NEXT:    bl sqrtl
; CHECK-P9-NEXT:    nop
; CHECK-P9-NEXT:    addi 1, 1, 32
; CHECK-P9-NEXT:    ld 0, 16(1)
; CHECK-P9-NEXT:    mtlr 0
; CHECK-P9-NEXT:    blr
  %r = call fp128 @llvm.sqrt.f128(fp128 %a)
  ret fp128 %r
}

attributes #0 = { nounwind "reciprocal-estimates"="sqrtf:0,sqrtd:0" }
attributes #1 = { nounwind "denormal-fp-math"="preserve-sign,preserve-sign" }
