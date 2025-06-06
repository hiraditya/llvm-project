; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -mattr=+v -verify-machineinstrs < %s | \
; RUN:   FileCheck %s -check-prefix=RV32
; RUN: llc -mtriple=riscv64 -mattr=+v -verify-machineinstrs < %s | \
; RUN:   FileCheck %s -check-prefix=RV64

; ================================================================================
; trunc <vscale x 1 x float>
; ================================================================================

declare <vscale x 1 x float> @llvm.trunc.nxv1f32(<vscale x 1 x float>)

define <vscale x 1 x i8> @trunc_nxv1f32_to_si8(<vscale x 1 x float> %x) {
; RV32-LABEL: trunc_nxv1f32_to_si8:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, mf2, ta, ma
; RV32-NEXT:    vfabs.v v9, v8
; RV32-NEXT:    lui a0, 307200
; RV32-NEXT:    fmv.w.x fa5, a0
; RV32-NEXT:    vmflt.vf v0, v9, fa5
; RV32-NEXT:    vfcvt.rtz.x.f.v v9, v8, v0.t
; RV32-NEXT:    vfcvt.f.x.v v9, v9, v0.t
; RV32-NEXT:    vsetvli zero, zero, e32, mf2, ta, mu
; RV32-NEXT:    vfsgnj.vv v8, v9, v8, v0.t
; RV32-NEXT:    vsetvli zero, zero, e16, mf4, ta, ma
; RV32-NEXT:    vfncvt.rtz.x.f.w v9, v8
; RV32-NEXT:    vsetvli zero, zero, e8, mf8, ta, ma
; RV32-NEXT:    vnsrl.wi v8, v9, 0
; RV32-NEXT:    ret
;
; RV64-LABEL: trunc_nxv1f32_to_si8:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, mf2, ta, ma
; RV64-NEXT:    vfabs.v v9, v8
; RV64-NEXT:    lui a0, 307200
; RV64-NEXT:    fmv.w.x fa5, a0
; RV64-NEXT:    vmflt.vf v0, v9, fa5
; RV64-NEXT:    vfcvt.rtz.x.f.v v9, v8, v0.t
; RV64-NEXT:    vfcvt.f.x.v v9, v9, v0.t
; RV64-NEXT:    vsetvli zero, zero, e32, mf2, ta, mu
; RV64-NEXT:    vfsgnj.vv v8, v9, v8, v0.t
; RV64-NEXT:    vsetvli zero, zero, e16, mf4, ta, ma
; RV64-NEXT:    vfncvt.rtz.x.f.w v9, v8
; RV64-NEXT:    vsetvli zero, zero, e8, mf8, ta, ma
; RV64-NEXT:    vnsrl.wi v8, v9, 0
; RV64-NEXT:    ret
  %a = call <vscale x 1 x float> @llvm.trunc.nxv1f32(<vscale x 1 x float> %x)
  %b = fptosi <vscale x 1 x float> %a to <vscale x 1 x i8>
  ret <vscale x 1 x i8> %b
}

define <vscale x 1 x i8> @trunc_nxv1f32_to_ui8(<vscale x 1 x float> %x) {
; RV32-LABEL: trunc_nxv1f32_to_ui8:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, mf2, ta, ma
; RV32-NEXT:    vfabs.v v9, v8
; RV32-NEXT:    lui a0, 307200
; RV32-NEXT:    fmv.w.x fa5, a0
; RV32-NEXT:    vmflt.vf v0, v9, fa5
; RV32-NEXT:    vfcvt.rtz.x.f.v v9, v8, v0.t
; RV32-NEXT:    vfcvt.f.x.v v9, v9, v0.t
; RV32-NEXT:    vsetvli zero, zero, e32, mf2, ta, mu
; RV32-NEXT:    vfsgnj.vv v8, v9, v8, v0.t
; RV32-NEXT:    vsetvli zero, zero, e16, mf4, ta, ma
; RV32-NEXT:    vfncvt.rtz.xu.f.w v9, v8
; RV32-NEXT:    vsetvli zero, zero, e8, mf8, ta, ma
; RV32-NEXT:    vnsrl.wi v8, v9, 0
; RV32-NEXT:    ret
;
; RV64-LABEL: trunc_nxv1f32_to_ui8:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, mf2, ta, ma
; RV64-NEXT:    vfabs.v v9, v8
; RV64-NEXT:    lui a0, 307200
; RV64-NEXT:    fmv.w.x fa5, a0
; RV64-NEXT:    vmflt.vf v0, v9, fa5
; RV64-NEXT:    vfcvt.rtz.x.f.v v9, v8, v0.t
; RV64-NEXT:    vfcvt.f.x.v v9, v9, v0.t
; RV64-NEXT:    vsetvli zero, zero, e32, mf2, ta, mu
; RV64-NEXT:    vfsgnj.vv v8, v9, v8, v0.t
; RV64-NEXT:    vsetvli zero, zero, e16, mf4, ta, ma
; RV64-NEXT:    vfncvt.rtz.xu.f.w v9, v8
; RV64-NEXT:    vsetvli zero, zero, e8, mf8, ta, ma
; RV64-NEXT:    vnsrl.wi v8, v9, 0
; RV64-NEXT:    ret
  %a = call <vscale x 1 x float> @llvm.trunc.nxv1f32(<vscale x 1 x float> %x)
  %b = fptoui <vscale x 1 x float> %a to <vscale x 1 x i8>
  ret <vscale x 1 x i8> %b
}

define <vscale x 1 x i16> @trunc_nxv1f32_to_si16(<vscale x 1 x float> %x) {
; RV32-LABEL: trunc_nxv1f32_to_si16:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e16, mf4, ta, ma
; RV32-NEXT:    vfncvt.rtz.x.f.w v9, v8
; RV32-NEXT:    vmv1r.v v8, v9
; RV32-NEXT:    ret
;
; RV64-LABEL: trunc_nxv1f32_to_si16:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e16, mf4, ta, ma
; RV64-NEXT:    vfncvt.rtz.x.f.w v9, v8
; RV64-NEXT:    vmv1r.v v8, v9
; RV64-NEXT:    ret
  %a = call <vscale x 1 x float> @llvm.trunc.nxv1f32(<vscale x 1 x float> %x)
  %b = fptosi <vscale x 1 x float> %a to <vscale x 1 x i16>
  ret <vscale x 1 x i16> %b
}

define <vscale x 1 x i16> @trunc_nxv1f32_to_ui16(<vscale x 1 x float> %x) {
; RV32-LABEL: trunc_nxv1f32_to_ui16:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e16, mf4, ta, ma
; RV32-NEXT:    vfncvt.rtz.xu.f.w v9, v8
; RV32-NEXT:    vmv1r.v v8, v9
; RV32-NEXT:    ret
;
; RV64-LABEL: trunc_nxv1f32_to_ui16:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e16, mf4, ta, ma
; RV64-NEXT:    vfncvt.rtz.xu.f.w v9, v8
; RV64-NEXT:    vmv1r.v v8, v9
; RV64-NEXT:    ret
  %a = call <vscale x 1 x float> @llvm.trunc.nxv1f32(<vscale x 1 x float> %x)
  %b = fptoui <vscale x 1 x float> %a to <vscale x 1 x i16>
  ret <vscale x 1 x i16> %b
}

define <vscale x 1 x i32> @trunc_nxv1f32_to_si32(<vscale x 1 x float> %x) {
; RV32-LABEL: trunc_nxv1f32_to_si32:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, mf2, ta, ma
; RV32-NEXT:    vfcvt.rtz.x.f.v v8, v8
; RV32-NEXT:    ret
;
; RV64-LABEL: trunc_nxv1f32_to_si32:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, mf2, ta, ma
; RV64-NEXT:    vfcvt.rtz.x.f.v v8, v8
; RV64-NEXT:    ret
  %a = call <vscale x 1 x float> @llvm.trunc.nxv1f32(<vscale x 1 x float> %x)
  %b = fptosi <vscale x 1 x float> %a to <vscale x 1 x i32>
  ret <vscale x 1 x i32> %b
}

define <vscale x 1 x i32> @trunc_nxv1f32_to_ui32(<vscale x 1 x float> %x) {
; RV32-LABEL: trunc_nxv1f32_to_ui32:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, mf2, ta, ma
; RV32-NEXT:    vfcvt.rtz.xu.f.v v8, v8
; RV32-NEXT:    ret
;
; RV64-LABEL: trunc_nxv1f32_to_ui32:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, mf2, ta, ma
; RV64-NEXT:    vfcvt.rtz.xu.f.v v8, v8
; RV64-NEXT:    ret
  %a = call <vscale x 1 x float> @llvm.trunc.nxv1f32(<vscale x 1 x float> %x)
  %b = fptoui <vscale x 1 x float> %a to <vscale x 1 x i32>
  ret <vscale x 1 x i32> %b
}

define <vscale x 1 x i64> @trunc_nxv1f32_to_si64(<vscale x 1 x float> %x) {
; RV32-LABEL: trunc_nxv1f32_to_si64:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, mf2, ta, ma
; RV32-NEXT:    vfwcvt.rtz.x.f.v v9, v8
; RV32-NEXT:    vmv1r.v v8, v9
; RV32-NEXT:    ret
;
; RV64-LABEL: trunc_nxv1f32_to_si64:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, mf2, ta, ma
; RV64-NEXT:    vfwcvt.rtz.x.f.v v9, v8
; RV64-NEXT:    vmv1r.v v8, v9
; RV64-NEXT:    ret
  %a = call <vscale x 1 x float> @llvm.trunc.nxv1f32(<vscale x 1 x float> %x)
  %b = fptosi <vscale x 1 x float> %a to <vscale x 1 x i64>
  ret <vscale x 1 x i64> %b
}

define <vscale x 1 x i64> @trunc_nxv1f32_to_ui64(<vscale x 1 x float> %x) {
; RV32-LABEL: trunc_nxv1f32_to_ui64:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, mf2, ta, ma
; RV32-NEXT:    vfwcvt.rtz.xu.f.v v9, v8
; RV32-NEXT:    vmv1r.v v8, v9
; RV32-NEXT:    ret
;
; RV64-LABEL: trunc_nxv1f32_to_ui64:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, mf2, ta, ma
; RV64-NEXT:    vfwcvt.rtz.xu.f.v v9, v8
; RV64-NEXT:    vmv1r.v v8, v9
; RV64-NEXT:    ret
  %a = call <vscale x 1 x float> @llvm.trunc.nxv1f32(<vscale x 1 x float> %x)
  %b = fptoui <vscale x 1 x float> %a to <vscale x 1 x i64>
  ret <vscale x 1 x i64> %b
}

; ================================================================================
; trunc <vscale x 4 x float>
; ================================================================================

declare <vscale x 4 x float> @llvm.trunc.nxv4f32(<vscale x 4 x float>)

define <vscale x 4 x i8> @trunc_nxv4f32_to_si8(<vscale x 4 x float> %x) {
; RV32-LABEL: trunc_nxv4f32_to_si8:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV32-NEXT:    vfabs.v v10, v8
; RV32-NEXT:    lui a0, 307200
; RV32-NEXT:    fmv.w.x fa5, a0
; RV32-NEXT:    vmflt.vf v0, v10, fa5
; RV32-NEXT:    vfcvt.rtz.x.f.v v10, v8, v0.t
; RV32-NEXT:    vfcvt.f.x.v v10, v10, v0.t
; RV32-NEXT:    vsetvli zero, zero, e32, m2, ta, mu
; RV32-NEXT:    vfsgnj.vv v8, v10, v8, v0.t
; RV32-NEXT:    vsetvli zero, zero, e16, m1, ta, ma
; RV32-NEXT:    vfncvt.rtz.x.f.w v10, v8
; RV32-NEXT:    vsetvli zero, zero, e8, mf2, ta, ma
; RV32-NEXT:    vnsrl.wi v8, v10, 0
; RV32-NEXT:    ret
;
; RV64-LABEL: trunc_nxv4f32_to_si8:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV64-NEXT:    vfabs.v v10, v8
; RV64-NEXT:    lui a0, 307200
; RV64-NEXT:    fmv.w.x fa5, a0
; RV64-NEXT:    vmflt.vf v0, v10, fa5
; RV64-NEXT:    vfcvt.rtz.x.f.v v10, v8, v0.t
; RV64-NEXT:    vfcvt.f.x.v v10, v10, v0.t
; RV64-NEXT:    vsetvli zero, zero, e32, m2, ta, mu
; RV64-NEXT:    vfsgnj.vv v8, v10, v8, v0.t
; RV64-NEXT:    vsetvli zero, zero, e16, m1, ta, ma
; RV64-NEXT:    vfncvt.rtz.x.f.w v10, v8
; RV64-NEXT:    vsetvli zero, zero, e8, mf2, ta, ma
; RV64-NEXT:    vnsrl.wi v8, v10, 0
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.trunc.nxv4f32(<vscale x 4 x float> %x)
  %b = fptosi <vscale x 4 x float> %a to <vscale x 4 x i8>
  ret <vscale x 4 x i8> %b
}

define <vscale x 4 x i8> @trunc_nxv4f32_to_ui8(<vscale x 4 x float> %x) {
; RV32-LABEL: trunc_nxv4f32_to_ui8:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV32-NEXT:    vfabs.v v10, v8
; RV32-NEXT:    lui a0, 307200
; RV32-NEXT:    fmv.w.x fa5, a0
; RV32-NEXT:    vmflt.vf v0, v10, fa5
; RV32-NEXT:    vfcvt.rtz.x.f.v v10, v8, v0.t
; RV32-NEXT:    vfcvt.f.x.v v10, v10, v0.t
; RV32-NEXT:    vsetvli zero, zero, e32, m2, ta, mu
; RV32-NEXT:    vfsgnj.vv v8, v10, v8, v0.t
; RV32-NEXT:    vsetvli zero, zero, e16, m1, ta, ma
; RV32-NEXT:    vfncvt.rtz.xu.f.w v10, v8
; RV32-NEXT:    vsetvli zero, zero, e8, mf2, ta, ma
; RV32-NEXT:    vnsrl.wi v8, v10, 0
; RV32-NEXT:    ret
;
; RV64-LABEL: trunc_nxv4f32_to_ui8:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV64-NEXT:    vfabs.v v10, v8
; RV64-NEXT:    lui a0, 307200
; RV64-NEXT:    fmv.w.x fa5, a0
; RV64-NEXT:    vmflt.vf v0, v10, fa5
; RV64-NEXT:    vfcvt.rtz.x.f.v v10, v8, v0.t
; RV64-NEXT:    vfcvt.f.x.v v10, v10, v0.t
; RV64-NEXT:    vsetvli zero, zero, e32, m2, ta, mu
; RV64-NEXT:    vfsgnj.vv v8, v10, v8, v0.t
; RV64-NEXT:    vsetvli zero, zero, e16, m1, ta, ma
; RV64-NEXT:    vfncvt.rtz.xu.f.w v10, v8
; RV64-NEXT:    vsetvli zero, zero, e8, mf2, ta, ma
; RV64-NEXT:    vnsrl.wi v8, v10, 0
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.trunc.nxv4f32(<vscale x 4 x float> %x)
  %b = fptoui <vscale x 4 x float> %a to <vscale x 4 x i8>
  ret <vscale x 4 x i8> %b
}

define <vscale x 4 x i16> @trunc_nxv4f32_to_si16(<vscale x 4 x float> %x) {
; RV32-LABEL: trunc_nxv4f32_to_si16:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e16, m1, ta, ma
; RV32-NEXT:    vfncvt.rtz.x.f.w v10, v8
; RV32-NEXT:    vmv.v.v v8, v10
; RV32-NEXT:    ret
;
; RV64-LABEL: trunc_nxv4f32_to_si16:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e16, m1, ta, ma
; RV64-NEXT:    vfncvt.rtz.x.f.w v10, v8
; RV64-NEXT:    vmv.v.v v8, v10
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.trunc.nxv4f32(<vscale x 4 x float> %x)
  %b = fptosi <vscale x 4 x float> %a to <vscale x 4 x i16>
  ret <vscale x 4 x i16> %b
}

define <vscale x 4 x i16> @trunc_nxv4f32_to_ui16(<vscale x 4 x float> %x) {
; RV32-LABEL: trunc_nxv4f32_to_ui16:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e16, m1, ta, ma
; RV32-NEXT:    vfncvt.rtz.xu.f.w v10, v8
; RV32-NEXT:    vmv.v.v v8, v10
; RV32-NEXT:    ret
;
; RV64-LABEL: trunc_nxv4f32_to_ui16:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e16, m1, ta, ma
; RV64-NEXT:    vfncvt.rtz.xu.f.w v10, v8
; RV64-NEXT:    vmv.v.v v8, v10
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.trunc.nxv4f32(<vscale x 4 x float> %x)
  %b = fptoui <vscale x 4 x float> %a to <vscale x 4 x i16>
  ret <vscale x 4 x i16> %b
}

define <vscale x 4 x i32> @trunc_nxv4f32_to_si32(<vscale x 4 x float> %x) {
; RV32-LABEL: trunc_nxv4f32_to_si32:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV32-NEXT:    vfcvt.rtz.x.f.v v8, v8
; RV32-NEXT:    ret
;
; RV64-LABEL: trunc_nxv4f32_to_si32:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV64-NEXT:    vfcvt.rtz.x.f.v v8, v8
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.trunc.nxv4f32(<vscale x 4 x float> %x)
  %b = fptosi <vscale x 4 x float> %a to <vscale x 4 x i32>
  ret <vscale x 4 x i32> %b
}

define <vscale x 4 x i32> @trunc_nxv4f32_to_ui32(<vscale x 4 x float> %x) {
; RV32-LABEL: trunc_nxv4f32_to_ui32:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV32-NEXT:    vfcvt.rtz.xu.f.v v8, v8
; RV32-NEXT:    ret
;
; RV64-LABEL: trunc_nxv4f32_to_ui32:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV64-NEXT:    vfcvt.rtz.xu.f.v v8, v8
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.trunc.nxv4f32(<vscale x 4 x float> %x)
  %b = fptoui <vscale x 4 x float> %a to <vscale x 4 x i32>
  ret <vscale x 4 x i32> %b
}

define <vscale x 4 x i64> @trunc_nxv4f32_to_si64(<vscale x 4 x float> %x) {
; RV32-LABEL: trunc_nxv4f32_to_si64:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV32-NEXT:    vmv2r.v v12, v8
; RV32-NEXT:    vfwcvt.rtz.x.f.v v8, v12
; RV32-NEXT:    ret
;
; RV64-LABEL: trunc_nxv4f32_to_si64:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV64-NEXT:    vmv2r.v v12, v8
; RV64-NEXT:    vfwcvt.rtz.x.f.v v8, v12
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.trunc.nxv4f32(<vscale x 4 x float> %x)
  %b = fptosi <vscale x 4 x float> %a to <vscale x 4 x i64>
  ret <vscale x 4 x i64> %b
}

define <vscale x 4 x i64> @trunc_nxv4f32_to_ui64(<vscale x 4 x float> %x) {
; RV32-LABEL: trunc_nxv4f32_to_ui64:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV32-NEXT:    vmv2r.v v12, v8
; RV32-NEXT:    vfwcvt.rtz.xu.f.v v8, v12
; RV32-NEXT:    ret
;
; RV64-LABEL: trunc_nxv4f32_to_ui64:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV64-NEXT:    vmv2r.v v12, v8
; RV64-NEXT:    vfwcvt.rtz.xu.f.v v8, v12
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.trunc.nxv4f32(<vscale x 4 x float> %x)
  %b = fptoui <vscale x 4 x float> %a to <vscale x 4 x i64>
  ret <vscale x 4 x i64> %b
}

; ================================================================================
; ceil <vscale x 1 x float>
; ================================================================================

declare <vscale x 1 x float> @llvm.ceil.nxv1f32(<vscale x 1 x float>)

define <vscale x 1 x i8> @ceil_nxv1f32_to_si8(<vscale x 1 x float> %x) {
; RV32-LABEL: ceil_nxv1f32_to_si8:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, mf2, ta, ma
; RV32-NEXT:    vfabs.v v9, v8
; RV32-NEXT:    lui a0, 307200
; RV32-NEXT:    fmv.w.x fa5, a0
; RV32-NEXT:    vmflt.vf v0, v9, fa5
; RV32-NEXT:    fsrmi a0, 3
; RV32-NEXT:    vfcvt.x.f.v v9, v8, v0.t
; RV32-NEXT:    fsrm a0
; RV32-NEXT:    vfcvt.f.x.v v9, v9, v0.t
; RV32-NEXT:    vsetvli zero, zero, e32, mf2, ta, mu
; RV32-NEXT:    vfsgnj.vv v8, v9, v8, v0.t
; RV32-NEXT:    vsetvli zero, zero, e16, mf4, ta, ma
; RV32-NEXT:    vfncvt.rtz.x.f.w v9, v8
; RV32-NEXT:    vsetvli zero, zero, e8, mf8, ta, ma
; RV32-NEXT:    vnsrl.wi v8, v9, 0
; RV32-NEXT:    ret
;
; RV64-LABEL: ceil_nxv1f32_to_si8:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, mf2, ta, ma
; RV64-NEXT:    vfabs.v v9, v8
; RV64-NEXT:    lui a0, 307200
; RV64-NEXT:    fmv.w.x fa5, a0
; RV64-NEXT:    vmflt.vf v0, v9, fa5
; RV64-NEXT:    fsrmi a0, 3
; RV64-NEXT:    vfcvt.x.f.v v9, v8, v0.t
; RV64-NEXT:    fsrm a0
; RV64-NEXT:    vfcvt.f.x.v v9, v9, v0.t
; RV64-NEXT:    vsetvli zero, zero, e32, mf2, ta, mu
; RV64-NEXT:    vfsgnj.vv v8, v9, v8, v0.t
; RV64-NEXT:    vsetvli zero, zero, e16, mf4, ta, ma
; RV64-NEXT:    vfncvt.rtz.x.f.w v9, v8
; RV64-NEXT:    vsetvli zero, zero, e8, mf8, ta, ma
; RV64-NEXT:    vnsrl.wi v8, v9, 0
; RV64-NEXT:    ret
  %a = call <vscale x 1 x float> @llvm.ceil.nxv1f32(<vscale x 1 x float> %x)
  %b = fptosi <vscale x 1 x float> %a to <vscale x 1 x i8>
  ret <vscale x 1 x i8> %b
}

define <vscale x 1 x i8> @ceil_nxv1f32_to_ui8(<vscale x 1 x float> %x) {
; RV32-LABEL: ceil_nxv1f32_to_ui8:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, mf2, ta, ma
; RV32-NEXT:    vfabs.v v9, v8
; RV32-NEXT:    lui a0, 307200
; RV32-NEXT:    fmv.w.x fa5, a0
; RV32-NEXT:    vmflt.vf v0, v9, fa5
; RV32-NEXT:    fsrmi a0, 3
; RV32-NEXT:    vfcvt.x.f.v v9, v8, v0.t
; RV32-NEXT:    fsrm a0
; RV32-NEXT:    vfcvt.f.x.v v9, v9, v0.t
; RV32-NEXT:    vsetvli zero, zero, e32, mf2, ta, mu
; RV32-NEXT:    vfsgnj.vv v8, v9, v8, v0.t
; RV32-NEXT:    vsetvli zero, zero, e16, mf4, ta, ma
; RV32-NEXT:    vfncvt.rtz.xu.f.w v9, v8
; RV32-NEXT:    vsetvli zero, zero, e8, mf8, ta, ma
; RV32-NEXT:    vnsrl.wi v8, v9, 0
; RV32-NEXT:    ret
;
; RV64-LABEL: ceil_nxv1f32_to_ui8:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, mf2, ta, ma
; RV64-NEXT:    vfabs.v v9, v8
; RV64-NEXT:    lui a0, 307200
; RV64-NEXT:    fmv.w.x fa5, a0
; RV64-NEXT:    vmflt.vf v0, v9, fa5
; RV64-NEXT:    fsrmi a0, 3
; RV64-NEXT:    vfcvt.x.f.v v9, v8, v0.t
; RV64-NEXT:    fsrm a0
; RV64-NEXT:    vfcvt.f.x.v v9, v9, v0.t
; RV64-NEXT:    vsetvli zero, zero, e32, mf2, ta, mu
; RV64-NEXT:    vfsgnj.vv v8, v9, v8, v0.t
; RV64-NEXT:    vsetvli zero, zero, e16, mf4, ta, ma
; RV64-NEXT:    vfncvt.rtz.xu.f.w v9, v8
; RV64-NEXT:    vsetvli zero, zero, e8, mf8, ta, ma
; RV64-NEXT:    vnsrl.wi v8, v9, 0
; RV64-NEXT:    ret
  %a = call <vscale x 1 x float> @llvm.ceil.nxv1f32(<vscale x 1 x float> %x)
  %b = fptoui <vscale x 1 x float> %a to <vscale x 1 x i8>
  ret <vscale x 1 x i8> %b
}

define <vscale x 1 x i16> @ceil_nxv1f32_to_si16(<vscale x 1 x float> %x) {
; RV32-LABEL: ceil_nxv1f32_to_si16:
; RV32:       # %bb.0:
; RV32-NEXT:    fsrmi a0, 3
; RV32-NEXT:    vsetvli a1, zero, e16, mf4, ta, ma
; RV32-NEXT:    vfncvt.x.f.w v9, v8
; RV32-NEXT:    fsrm a0
; RV32-NEXT:    vmv1r.v v8, v9
; RV32-NEXT:    ret
;
; RV64-LABEL: ceil_nxv1f32_to_si16:
; RV64:       # %bb.0:
; RV64-NEXT:    fsrmi a0, 3
; RV64-NEXT:    vsetvli a1, zero, e16, mf4, ta, ma
; RV64-NEXT:    vfncvt.x.f.w v9, v8
; RV64-NEXT:    fsrm a0
; RV64-NEXT:    vmv1r.v v8, v9
; RV64-NEXT:    ret
  %a = call <vscale x 1 x float> @llvm.ceil.nxv1f32(<vscale x 1 x float> %x)
  %b = fptosi <vscale x 1 x float> %a to <vscale x 1 x i16>
  ret <vscale x 1 x i16> %b
}

define <vscale x 1 x i16> @ceil_nxv1f32_to_ui16(<vscale x 1 x float> %x) {
; RV32-LABEL: ceil_nxv1f32_to_ui16:
; RV32:       # %bb.0:
; RV32-NEXT:    fsrmi a0, 3
; RV32-NEXT:    vsetvli a1, zero, e16, mf4, ta, ma
; RV32-NEXT:    vfncvt.xu.f.w v9, v8
; RV32-NEXT:    fsrm a0
; RV32-NEXT:    vmv1r.v v8, v9
; RV32-NEXT:    ret
;
; RV64-LABEL: ceil_nxv1f32_to_ui16:
; RV64:       # %bb.0:
; RV64-NEXT:    fsrmi a0, 3
; RV64-NEXT:    vsetvli a1, zero, e16, mf4, ta, ma
; RV64-NEXT:    vfncvt.xu.f.w v9, v8
; RV64-NEXT:    fsrm a0
; RV64-NEXT:    vmv1r.v v8, v9
; RV64-NEXT:    ret
  %a = call <vscale x 1 x float> @llvm.ceil.nxv1f32(<vscale x 1 x float> %x)
  %b = fptoui <vscale x 1 x float> %a to <vscale x 1 x i16>
  ret <vscale x 1 x i16> %b
}

define <vscale x 1 x i32> @ceil_nxv1f32_to_si32(<vscale x 1 x float> %x) {
; RV32-LABEL: ceil_nxv1f32_to_si32:
; RV32:       # %bb.0:
; RV32-NEXT:    fsrmi a0, 3
; RV32-NEXT:    vsetvli a1, zero, e32, mf2, ta, ma
; RV32-NEXT:    vfcvt.x.f.v v8, v8
; RV32-NEXT:    fsrm a0
; RV32-NEXT:    ret
;
; RV64-LABEL: ceil_nxv1f32_to_si32:
; RV64:       # %bb.0:
; RV64-NEXT:    fsrmi a0, 3
; RV64-NEXT:    vsetvli a1, zero, e32, mf2, ta, ma
; RV64-NEXT:    vfcvt.x.f.v v8, v8
; RV64-NEXT:    fsrm a0
; RV64-NEXT:    ret
  %a = call <vscale x 1 x float> @llvm.ceil.nxv1f32(<vscale x 1 x float> %x)
  %b = fptosi <vscale x 1 x float> %a to <vscale x 1 x i32>
  ret <vscale x 1 x i32> %b
}

define <vscale x 1 x i32> @ceil_nxv1f32_to_ui32(<vscale x 1 x float> %x) {
; RV32-LABEL: ceil_nxv1f32_to_ui32:
; RV32:       # %bb.0:
; RV32-NEXT:    fsrmi a0, 3
; RV32-NEXT:    vsetvli a1, zero, e32, mf2, ta, ma
; RV32-NEXT:    vfcvt.xu.f.v v8, v8
; RV32-NEXT:    fsrm a0
; RV32-NEXT:    ret
;
; RV64-LABEL: ceil_nxv1f32_to_ui32:
; RV64:       # %bb.0:
; RV64-NEXT:    fsrmi a0, 3
; RV64-NEXT:    vsetvli a1, zero, e32, mf2, ta, ma
; RV64-NEXT:    vfcvt.xu.f.v v8, v8
; RV64-NEXT:    fsrm a0
; RV64-NEXT:    ret
  %a = call <vscale x 1 x float> @llvm.ceil.nxv1f32(<vscale x 1 x float> %x)
  %b = fptoui <vscale x 1 x float> %a to <vscale x 1 x i32>
  ret <vscale x 1 x i32> %b
}

define <vscale x 1 x i64> @ceil_nxv1f32_to_si64(<vscale x 1 x float> %x) {
; RV32-LABEL: ceil_nxv1f32_to_si64:
; RV32:       # %bb.0:
; RV32-NEXT:    fsrmi a0, 3
; RV32-NEXT:    vsetvli a1, zero, e32, mf2, ta, ma
; RV32-NEXT:    vfwcvt.x.f.v v9, v8
; RV32-NEXT:    fsrm a0
; RV32-NEXT:    vmv1r.v v8, v9
; RV32-NEXT:    ret
;
; RV64-LABEL: ceil_nxv1f32_to_si64:
; RV64:       # %bb.0:
; RV64-NEXT:    fsrmi a0, 3
; RV64-NEXT:    vsetvli a1, zero, e32, mf2, ta, ma
; RV64-NEXT:    vfwcvt.x.f.v v9, v8
; RV64-NEXT:    fsrm a0
; RV64-NEXT:    vmv1r.v v8, v9
; RV64-NEXT:    ret
  %a = call <vscale x 1 x float> @llvm.ceil.nxv1f32(<vscale x 1 x float> %x)
  %b = fptosi <vscale x 1 x float> %a to <vscale x 1 x i64>
  ret <vscale x 1 x i64> %b
}

define <vscale x 1 x i64> @ceil_nxv1f32_to_ui64(<vscale x 1 x float> %x) {
; RV32-LABEL: ceil_nxv1f32_to_ui64:
; RV32:       # %bb.0:
; RV32-NEXT:    fsrmi a0, 3
; RV32-NEXT:    vsetvli a1, zero, e32, mf2, ta, ma
; RV32-NEXT:    vfwcvt.xu.f.v v9, v8
; RV32-NEXT:    fsrm a0
; RV32-NEXT:    vmv1r.v v8, v9
; RV32-NEXT:    ret
;
; RV64-LABEL: ceil_nxv1f32_to_ui64:
; RV64:       # %bb.0:
; RV64-NEXT:    fsrmi a0, 3
; RV64-NEXT:    vsetvli a1, zero, e32, mf2, ta, ma
; RV64-NEXT:    vfwcvt.xu.f.v v9, v8
; RV64-NEXT:    fsrm a0
; RV64-NEXT:    vmv1r.v v8, v9
; RV64-NEXT:    ret
  %a = call <vscale x 1 x float> @llvm.ceil.nxv1f32(<vscale x 1 x float> %x)
  %b = fptoui <vscale x 1 x float> %a to <vscale x 1 x i64>
  ret <vscale x 1 x i64> %b
}

; ================================================================================
; ceil <vscale x 4 x float>
; ================================================================================

declare <vscale x 4 x float> @llvm.ceil.nxv4f32(<vscale x 4 x float>)

define <vscale x 4 x i8> @ceil_nxv4f32_to_si8(<vscale x 4 x float> %x) {
; RV32-LABEL: ceil_nxv4f32_to_si8:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV32-NEXT:    vfabs.v v10, v8
; RV32-NEXT:    lui a0, 307200
; RV32-NEXT:    fmv.w.x fa5, a0
; RV32-NEXT:    vmflt.vf v0, v10, fa5
; RV32-NEXT:    fsrmi a0, 3
; RV32-NEXT:    vfcvt.x.f.v v10, v8, v0.t
; RV32-NEXT:    fsrm a0
; RV32-NEXT:    vfcvt.f.x.v v10, v10, v0.t
; RV32-NEXT:    vsetvli zero, zero, e32, m2, ta, mu
; RV32-NEXT:    vfsgnj.vv v8, v10, v8, v0.t
; RV32-NEXT:    vsetvli zero, zero, e16, m1, ta, ma
; RV32-NEXT:    vfncvt.rtz.x.f.w v10, v8
; RV32-NEXT:    vsetvli zero, zero, e8, mf2, ta, ma
; RV32-NEXT:    vnsrl.wi v8, v10, 0
; RV32-NEXT:    ret
;
; RV64-LABEL: ceil_nxv4f32_to_si8:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV64-NEXT:    vfabs.v v10, v8
; RV64-NEXT:    lui a0, 307200
; RV64-NEXT:    fmv.w.x fa5, a0
; RV64-NEXT:    vmflt.vf v0, v10, fa5
; RV64-NEXT:    fsrmi a0, 3
; RV64-NEXT:    vfcvt.x.f.v v10, v8, v0.t
; RV64-NEXT:    fsrm a0
; RV64-NEXT:    vfcvt.f.x.v v10, v10, v0.t
; RV64-NEXT:    vsetvli zero, zero, e32, m2, ta, mu
; RV64-NEXT:    vfsgnj.vv v8, v10, v8, v0.t
; RV64-NEXT:    vsetvli zero, zero, e16, m1, ta, ma
; RV64-NEXT:    vfncvt.rtz.x.f.w v10, v8
; RV64-NEXT:    vsetvli zero, zero, e8, mf2, ta, ma
; RV64-NEXT:    vnsrl.wi v8, v10, 0
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.ceil.nxv4f32(<vscale x 4 x float> %x)
  %b = fptosi <vscale x 4 x float> %a to <vscale x 4 x i8>
  ret <vscale x 4 x i8> %b
}

define <vscale x 4 x i8> @ceil_nxv4f32_to_ui8(<vscale x 4 x float> %x) {
; RV32-LABEL: ceil_nxv4f32_to_ui8:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV32-NEXT:    vfabs.v v10, v8
; RV32-NEXT:    lui a0, 307200
; RV32-NEXT:    fmv.w.x fa5, a0
; RV32-NEXT:    vmflt.vf v0, v10, fa5
; RV32-NEXT:    fsrmi a0, 3
; RV32-NEXT:    vfcvt.x.f.v v10, v8, v0.t
; RV32-NEXT:    fsrm a0
; RV32-NEXT:    vfcvt.f.x.v v10, v10, v0.t
; RV32-NEXT:    vsetvli zero, zero, e32, m2, ta, mu
; RV32-NEXT:    vfsgnj.vv v8, v10, v8, v0.t
; RV32-NEXT:    vsetvli zero, zero, e16, m1, ta, ma
; RV32-NEXT:    vfncvt.rtz.xu.f.w v10, v8
; RV32-NEXT:    vsetvli zero, zero, e8, mf2, ta, ma
; RV32-NEXT:    vnsrl.wi v8, v10, 0
; RV32-NEXT:    ret
;
; RV64-LABEL: ceil_nxv4f32_to_ui8:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV64-NEXT:    vfabs.v v10, v8
; RV64-NEXT:    lui a0, 307200
; RV64-NEXT:    fmv.w.x fa5, a0
; RV64-NEXT:    vmflt.vf v0, v10, fa5
; RV64-NEXT:    fsrmi a0, 3
; RV64-NEXT:    vfcvt.x.f.v v10, v8, v0.t
; RV64-NEXT:    fsrm a0
; RV64-NEXT:    vfcvt.f.x.v v10, v10, v0.t
; RV64-NEXT:    vsetvli zero, zero, e32, m2, ta, mu
; RV64-NEXT:    vfsgnj.vv v8, v10, v8, v0.t
; RV64-NEXT:    vsetvli zero, zero, e16, m1, ta, ma
; RV64-NEXT:    vfncvt.rtz.xu.f.w v10, v8
; RV64-NEXT:    vsetvli zero, zero, e8, mf2, ta, ma
; RV64-NEXT:    vnsrl.wi v8, v10, 0
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.ceil.nxv4f32(<vscale x 4 x float> %x)
  %b = fptoui <vscale x 4 x float> %a to <vscale x 4 x i8>
  ret <vscale x 4 x i8> %b
}

define <vscale x 4 x i16> @ceil_nxv4f32_to_si16(<vscale x 4 x float> %x) {
; RV32-LABEL: ceil_nxv4f32_to_si16:
; RV32:       # %bb.0:
; RV32-NEXT:    fsrmi a0, 3
; RV32-NEXT:    vsetvli a1, zero, e16, m1, ta, ma
; RV32-NEXT:    vfncvt.x.f.w v10, v8
; RV32-NEXT:    fsrm a0
; RV32-NEXT:    vmv.v.v v8, v10
; RV32-NEXT:    ret
;
; RV64-LABEL: ceil_nxv4f32_to_si16:
; RV64:       # %bb.0:
; RV64-NEXT:    fsrmi a0, 3
; RV64-NEXT:    vsetvli a1, zero, e16, m1, ta, ma
; RV64-NEXT:    vfncvt.x.f.w v10, v8
; RV64-NEXT:    fsrm a0
; RV64-NEXT:    vmv.v.v v8, v10
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.ceil.nxv4f32(<vscale x 4 x float> %x)
  %b = fptosi <vscale x 4 x float> %a to <vscale x 4 x i16>
  ret <vscale x 4 x i16> %b
}

define <vscale x 4 x i16> @ceil_nxv4f32_to_ui16(<vscale x 4 x float> %x) {
; RV32-LABEL: ceil_nxv4f32_to_ui16:
; RV32:       # %bb.0:
; RV32-NEXT:    fsrmi a0, 3
; RV32-NEXT:    vsetvli a1, zero, e16, m1, ta, ma
; RV32-NEXT:    vfncvt.xu.f.w v10, v8
; RV32-NEXT:    fsrm a0
; RV32-NEXT:    vmv.v.v v8, v10
; RV32-NEXT:    ret
;
; RV64-LABEL: ceil_nxv4f32_to_ui16:
; RV64:       # %bb.0:
; RV64-NEXT:    fsrmi a0, 3
; RV64-NEXT:    vsetvli a1, zero, e16, m1, ta, ma
; RV64-NEXT:    vfncvt.xu.f.w v10, v8
; RV64-NEXT:    fsrm a0
; RV64-NEXT:    vmv.v.v v8, v10
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.ceil.nxv4f32(<vscale x 4 x float> %x)
  %b = fptoui <vscale x 4 x float> %a to <vscale x 4 x i16>
  ret <vscale x 4 x i16> %b
}

define <vscale x 4 x i32> @ceil_nxv4f32_to_si32(<vscale x 4 x float> %x) {
; RV32-LABEL: ceil_nxv4f32_to_si32:
; RV32:       # %bb.0:
; RV32-NEXT:    fsrmi a0, 3
; RV32-NEXT:    vsetvli a1, zero, e32, m2, ta, ma
; RV32-NEXT:    vfcvt.x.f.v v8, v8
; RV32-NEXT:    fsrm a0
; RV32-NEXT:    ret
;
; RV64-LABEL: ceil_nxv4f32_to_si32:
; RV64:       # %bb.0:
; RV64-NEXT:    fsrmi a0, 3
; RV64-NEXT:    vsetvli a1, zero, e32, m2, ta, ma
; RV64-NEXT:    vfcvt.x.f.v v8, v8
; RV64-NEXT:    fsrm a0
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.ceil.nxv4f32(<vscale x 4 x float> %x)
  %b = fptosi <vscale x 4 x float> %a to <vscale x 4 x i32>
  ret <vscale x 4 x i32> %b
}

define <vscale x 4 x i32> @ceil_nxv4f32_to_ui32(<vscale x 4 x float> %x) {
; RV32-LABEL: ceil_nxv4f32_to_ui32:
; RV32:       # %bb.0:
; RV32-NEXT:    fsrmi a0, 3
; RV32-NEXT:    vsetvli a1, zero, e32, m2, ta, ma
; RV32-NEXT:    vfcvt.xu.f.v v8, v8
; RV32-NEXT:    fsrm a0
; RV32-NEXT:    ret
;
; RV64-LABEL: ceil_nxv4f32_to_ui32:
; RV64:       # %bb.0:
; RV64-NEXT:    fsrmi a0, 3
; RV64-NEXT:    vsetvli a1, zero, e32, m2, ta, ma
; RV64-NEXT:    vfcvt.xu.f.v v8, v8
; RV64-NEXT:    fsrm a0
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.ceil.nxv4f32(<vscale x 4 x float> %x)
  %b = fptoui <vscale x 4 x float> %a to <vscale x 4 x i32>
  ret <vscale x 4 x i32> %b
}

define <vscale x 4 x i64> @ceil_nxv4f32_to_si64(<vscale x 4 x float> %x) {
; RV32-LABEL: ceil_nxv4f32_to_si64:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV32-NEXT:    vmv2r.v v12, v8
; RV32-NEXT:    fsrmi a0, 3
; RV32-NEXT:    vfwcvt.x.f.v v8, v12
; RV32-NEXT:    fsrm a0
; RV32-NEXT:    ret
;
; RV64-LABEL: ceil_nxv4f32_to_si64:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV64-NEXT:    vmv2r.v v12, v8
; RV64-NEXT:    fsrmi a0, 3
; RV64-NEXT:    vfwcvt.x.f.v v8, v12
; RV64-NEXT:    fsrm a0
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.ceil.nxv4f32(<vscale x 4 x float> %x)
  %b = fptosi <vscale x 4 x float> %a to <vscale x 4 x i64>
  ret <vscale x 4 x i64> %b
}

define <vscale x 4 x i64> @ceil_nxv4f32_to_ui64(<vscale x 4 x float> %x) {
; RV32-LABEL: ceil_nxv4f32_to_ui64:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV32-NEXT:    vmv2r.v v12, v8
; RV32-NEXT:    fsrmi a0, 3
; RV32-NEXT:    vfwcvt.xu.f.v v8, v12
; RV32-NEXT:    fsrm a0
; RV32-NEXT:    ret
;
; RV64-LABEL: ceil_nxv4f32_to_ui64:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV64-NEXT:    vmv2r.v v12, v8
; RV64-NEXT:    fsrmi a0, 3
; RV64-NEXT:    vfwcvt.xu.f.v v8, v12
; RV64-NEXT:    fsrm a0
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.ceil.nxv4f32(<vscale x 4 x float> %x)
  %b = fptoui <vscale x 4 x float> %a to <vscale x 4 x i64>
  ret <vscale x 4 x i64> %b
}

; ================================================================================
; rint <vscale x 4 x float>
; ================================================================================

declare <vscale x 4 x float> @llvm.rint.nxv4f32(<vscale x 4 x float>)

define <vscale x 4 x i8> @rint_nxv4f32_to_si8(<vscale x 4 x float> %x) {
; RV32-LABEL: rint_nxv4f32_to_si8:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV32-NEXT:    vfabs.v v10, v8
; RV32-NEXT:    lui a0, 307200
; RV32-NEXT:    fmv.w.x fa5, a0
; RV32-NEXT:    vmflt.vf v0, v10, fa5
; RV32-NEXT:    vfcvt.x.f.v v10, v8, v0.t
; RV32-NEXT:    vfcvt.f.x.v v10, v10, v0.t
; RV32-NEXT:    vsetvli zero, zero, e32, m2, ta, mu
; RV32-NEXT:    vfsgnj.vv v8, v10, v8, v0.t
; RV32-NEXT:    vsetvli zero, zero, e16, m1, ta, ma
; RV32-NEXT:    vfncvt.rtz.x.f.w v10, v8
; RV32-NEXT:    vsetvli zero, zero, e8, mf2, ta, ma
; RV32-NEXT:    vnsrl.wi v8, v10, 0
; RV32-NEXT:    ret
;
; RV64-LABEL: rint_nxv4f32_to_si8:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV64-NEXT:    vfabs.v v10, v8
; RV64-NEXT:    lui a0, 307200
; RV64-NEXT:    fmv.w.x fa5, a0
; RV64-NEXT:    vmflt.vf v0, v10, fa5
; RV64-NEXT:    vfcvt.x.f.v v10, v8, v0.t
; RV64-NEXT:    vfcvt.f.x.v v10, v10, v0.t
; RV64-NEXT:    vsetvli zero, zero, e32, m2, ta, mu
; RV64-NEXT:    vfsgnj.vv v8, v10, v8, v0.t
; RV64-NEXT:    vsetvli zero, zero, e16, m1, ta, ma
; RV64-NEXT:    vfncvt.rtz.x.f.w v10, v8
; RV64-NEXT:    vsetvli zero, zero, e8, mf2, ta, ma
; RV64-NEXT:    vnsrl.wi v8, v10, 0
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.rint.nxv4f32(<vscale x 4 x float> %x)
  %b = fptosi <vscale x 4 x float> %a to <vscale x 4 x i8>
  ret <vscale x 4 x i8> %b
}

define <vscale x 4 x i8> @rint_nxv4f32_to_ui8(<vscale x 4 x float> %x) {
; RV32-LABEL: rint_nxv4f32_to_ui8:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV32-NEXT:    vfabs.v v10, v8
; RV32-NEXT:    lui a0, 307200
; RV32-NEXT:    fmv.w.x fa5, a0
; RV32-NEXT:    vmflt.vf v0, v10, fa5
; RV32-NEXT:    vfcvt.x.f.v v10, v8, v0.t
; RV32-NEXT:    vfcvt.f.x.v v10, v10, v0.t
; RV32-NEXT:    vsetvli zero, zero, e32, m2, ta, mu
; RV32-NEXT:    vfsgnj.vv v8, v10, v8, v0.t
; RV32-NEXT:    vsetvli zero, zero, e16, m1, ta, ma
; RV32-NEXT:    vfncvt.rtz.xu.f.w v10, v8
; RV32-NEXT:    vsetvli zero, zero, e8, mf2, ta, ma
; RV32-NEXT:    vnsrl.wi v8, v10, 0
; RV32-NEXT:    ret
;
; RV64-LABEL: rint_nxv4f32_to_ui8:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV64-NEXT:    vfabs.v v10, v8
; RV64-NEXT:    lui a0, 307200
; RV64-NEXT:    fmv.w.x fa5, a0
; RV64-NEXT:    vmflt.vf v0, v10, fa5
; RV64-NEXT:    vfcvt.x.f.v v10, v8, v0.t
; RV64-NEXT:    vfcvt.f.x.v v10, v10, v0.t
; RV64-NEXT:    vsetvli zero, zero, e32, m2, ta, mu
; RV64-NEXT:    vfsgnj.vv v8, v10, v8, v0.t
; RV64-NEXT:    vsetvli zero, zero, e16, m1, ta, ma
; RV64-NEXT:    vfncvt.rtz.xu.f.w v10, v8
; RV64-NEXT:    vsetvli zero, zero, e8, mf2, ta, ma
; RV64-NEXT:    vnsrl.wi v8, v10, 0
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.rint.nxv4f32(<vscale x 4 x float> %x)
  %b = fptoui <vscale x 4 x float> %a to <vscale x 4 x i8>
  ret <vscale x 4 x i8> %b
}

define <vscale x 4 x i16> @rint_nxv4f32_to_si16(<vscale x 4 x float> %x) {
; RV32-LABEL: rint_nxv4f32_to_si16:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e16, m1, ta, ma
; RV32-NEXT:    vfncvt.x.f.w v10, v8
; RV32-NEXT:    vmv.v.v v8, v10
; RV32-NEXT:    ret
;
; RV64-LABEL: rint_nxv4f32_to_si16:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e16, m1, ta, ma
; RV64-NEXT:    vfncvt.x.f.w v10, v8
; RV64-NEXT:    vmv.v.v v8, v10
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.rint.nxv4f32(<vscale x 4 x float> %x)
  %b = fptosi <vscale x 4 x float> %a to <vscale x 4 x i16>
  ret <vscale x 4 x i16> %b
}

define <vscale x 4 x i16> @rint_nxv4f32_to_ui16(<vscale x 4 x float> %x) {
; RV32-LABEL: rint_nxv4f32_to_ui16:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e16, m1, ta, ma
; RV32-NEXT:    vfncvt.xu.f.w v10, v8
; RV32-NEXT:    vmv.v.v v8, v10
; RV32-NEXT:    ret
;
; RV64-LABEL: rint_nxv4f32_to_ui16:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e16, m1, ta, ma
; RV64-NEXT:    vfncvt.xu.f.w v10, v8
; RV64-NEXT:    vmv.v.v v8, v10
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.rint.nxv4f32(<vscale x 4 x float> %x)
  %b = fptoui <vscale x 4 x float> %a to <vscale x 4 x i16>
  ret <vscale x 4 x i16> %b
}

define <vscale x 4 x i32> @rint_nxv4f32_to_si32(<vscale x 4 x float> %x) {
; RV32-LABEL: rint_nxv4f32_to_si32:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV32-NEXT:    vfcvt.x.f.v v8, v8
; RV32-NEXT:    ret
;
; RV64-LABEL: rint_nxv4f32_to_si32:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV64-NEXT:    vfcvt.x.f.v v8, v8
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.rint.nxv4f32(<vscale x 4 x float> %x)
  %b = fptosi <vscale x 4 x float> %a to <vscale x 4 x i32>
  ret <vscale x 4 x i32> %b
}

define <vscale x 4 x i32> @rint_nxv4f32_to_ui32(<vscale x 4 x float> %x) {
; RV32-LABEL: rint_nxv4f32_to_ui32:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV32-NEXT:    vfcvt.xu.f.v v8, v8
; RV32-NEXT:    ret
;
; RV64-LABEL: rint_nxv4f32_to_ui32:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV64-NEXT:    vfcvt.xu.f.v v8, v8
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.rint.nxv4f32(<vscale x 4 x float> %x)
  %b = fptoui <vscale x 4 x float> %a to <vscale x 4 x i32>
  ret <vscale x 4 x i32> %b
}

define <vscale x 4 x i64> @rint_nxv4f32_to_si64(<vscale x 4 x float> %x) {
; RV32-LABEL: rint_nxv4f32_to_si64:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV32-NEXT:    vmv2r.v v12, v8
; RV32-NEXT:    vfwcvt.x.f.v v8, v12
; RV32-NEXT:    ret
;
; RV64-LABEL: rint_nxv4f32_to_si64:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV64-NEXT:    vmv2r.v v12, v8
; RV64-NEXT:    vfwcvt.x.f.v v8, v12
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.rint.nxv4f32(<vscale x 4 x float> %x)
  %b = fptosi <vscale x 4 x float> %a to <vscale x 4 x i64>
  ret <vscale x 4 x i64> %b
}

define <vscale x 4 x i64> @rint_nxv4f32_to_ui64(<vscale x 4 x float> %x) {
; RV32-LABEL: rint_nxv4f32_to_ui64:
; RV32:       # %bb.0:
; RV32-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV32-NEXT:    vmv2r.v v12, v8
; RV32-NEXT:    vfwcvt.xu.f.v v8, v12
; RV32-NEXT:    ret
;
; RV64-LABEL: rint_nxv4f32_to_ui64:
; RV64:       # %bb.0:
; RV64-NEXT:    vsetvli a0, zero, e32, m2, ta, ma
; RV64-NEXT:    vmv2r.v v12, v8
; RV64-NEXT:    vfwcvt.xu.f.v v8, v12
; RV64-NEXT:    ret
  %a = call <vscale x 4 x float> @llvm.rint.nxv4f32(<vscale x 4 x float> %x)
  %b = fptoui <vscale x 4 x float> %a to <vscale x 4 x i64>
  ret <vscale x 4 x i64> %b
}
