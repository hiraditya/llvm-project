// RUN: mlir-opt %s --transform-interpreter | FileCheck %s

// CHECK-LABEL: func @nop_shape_cast
// CHECK-SAME: %[[A:.*]]: vector<16xf32>
// CHECK:      return %[[A]] : vector<16xf32>
func.func @nop_shape_cast(%arg0: vector<16xf32>) -> vector<16xf32> {
  %0 = vector.shape_cast %arg0 : vector<16xf32> to vector<16xf32>
  return %0 : vector<16xf32>
}

// CHECK-LABEL: func @cancel_shape_cast
// CHECK-SAME: %[[A:.*]]: vector<16xf32>
// CHECK:      return %[[A]] : vector<16xf32>

func.func @cancel_shape_cast(%arg0: vector<16xf32>) -> vector<16xf32> {
  %0 = vector.shape_cast %arg0 : vector<16xf32> to vector<4x4xf32>
  %1 = vector.shape_cast %0 : vector<4x4xf32> to vector<16xf32>
  return %1 : vector<16xf32>
}

// Shape up and downcasts for 2-D vectors, for supporting conversion to
// llvm.matrix operations
// CHECK-LABEL: func @shape_casts
func.func @shape_casts(%a: vector<2x2xf32>) -> (vector<4xf32>, vector<2x2xf32>) {
  // CHECK-DAG: %[[ub22:.*]] = ub.poison : vector<2x2xf32>
  // CHECK-DAG: %[[ub:.*]] = ub.poison : vector<4xf32>
  // CHECK: %[[ex0:.*]] = vector.extract %{{.*}}[0] : vector<2xf32> from vector<2x2xf32>
  //
  // CHECK: %[[in0:.*]] = vector.insert_strided_slice %[[ex0]], %[[ub]]
  // CHECK-SAME: {offsets = [0], strides = [1]} : vector<2xf32> into vector<4xf32>
  //
  // CHECK: %[[ex1:.*]] = vector.extract %{{.*}}[1] : vector<2xf32> from vector<2x2xf32>
  //
  // CHECK: %[[in2:.*]] = vector.insert_strided_slice %[[ex1]], %[[in0]]
  // CHECK-SAME: {offsets = [2], strides = [1]} : vector<2xf32> into vector<4xf32>
  //
  %0 = vector.shape_cast %a : vector<2x2xf32> to vector<4xf32>
  // CHECK: %[[add:.*]] = arith.addf %[[in2]], %[[in2]] : vector<4xf32>
  %r0 = arith.addf %0, %0: vector<4xf32>
  //
  // CHECK: %[[ss0:.*]] = vector.extract_strided_slice %[[add]]
  // CHECK-SAME: {offsets = [0], sizes = [2], strides = [1]} :
  // CHECK-SAME: vector<4xf32> to vector<2xf32>
  //
  // CHECK: %[[res0:.*]] = vector.insert %[[ss0]], %[[ub22]] [0] :
  // CHECK-SAME: vector<2xf32> into vector<2x2xf32>
  //
  // CHECK: %[[s2:.*]] = vector.extract_strided_slice %[[add]]
  // CHECK-SAME: {offsets = [2], sizes = [2], strides = [1]} :
  // CHECK-SAME: vector<4xf32> to vector<2xf32>
  //
  // CHECK: %[[res1:.*]] = vector.insert %[[s2]], %[[res0]] [1] :
  // CHECK-SAME: vector<2xf32> into vector<2x2xf32>
  //
  %1 = vector.shape_cast %r0  : vector<4xf32> to vector<2x2xf32>
  // CHECK: return %[[add]], %[[res1]] : vector<4xf32>, vector<2x2xf32>
  return %r0, %1 : vector<4xf32>, vector<2x2xf32>
}

// CHECK-LABEL: func @shape_cast_2d2d
// CHECK-SAME: %[[A:.*]]: vector<3x2xf32>
// CHECK: %[[UB:.*]] = ub.poison : vector<2x3xf32>
// CHECK: %[[T0:.*]] = vector.extract %[[A]][0, 0] : f32 from vector<3x2xf32>
// CHECK: %[[T1:.*]] = vector.insert %[[T0]], %[[UB]] [0, 0] : f32 into vector<2x3xf32>
// CHECK: %[[T2:.*]] = vector.extract %[[A]][0, 1] : f32 from vector<3x2xf32>
// CHECK: %[[T3:.*]] = vector.insert %[[T2]], %[[T1]] [0, 1] : f32 into vector<2x3xf32>
// CHECK: %[[T4:.*]] = vector.extract %[[A]][1, 0] : f32 from vector<3x2xf32>
// CHECK: %[[T5:.*]] = vector.insert %[[T4]], %[[T3]] [0, 2] : f32 into vector<2x3xf32>
// CHECK: %[[T6:.*]] = vector.extract %[[A]][1, 1] : f32 from vector<3x2xf32>
// CHECK: %[[T7:.*]] = vector.insert %[[T6]], %[[T5]] [1, 0] : f32 into vector<2x3xf32>
// CHECK: %[[T8:.*]] = vector.extract %[[A]][2, 0] : f32 from vector<3x2xf32>
// CHECK: %[[T9:.*]] = vector.insert %[[T8]], %[[T7]] [1, 1] : f32 into vector<2x3xf32>
// CHECK: %[[T10:.*]] = vector.extract %[[A]][2, 1] : f32 from vector<3x2xf32>
// CHECK: %[[T11:.*]] = vector.insert %[[T10]], %[[T9]] [1, 2] : f32 into vector<2x3xf32>
// CHECK: return %[[T11]] : vector<2x3xf32>

func.func @shape_cast_2d2d(%arg0 : vector<3x2xf32>) -> vector<2x3xf32> {
  %s = vector.shape_cast %arg0: vector<3x2xf32> to vector<2x3xf32>
  return %s : vector<2x3xf32>
}

// CHECK-LABEL: func @shape_cast_3d1d
// CHECK-SAME: %[[A:.*]]: vector<1x3x2xf32>
// CHECK: %[[UB:.*]] = ub.poison : vector<6xf32>
// CHECK: %[[T0:.*]] = vector.extract %[[A]][0, 0] : vector<2xf32> from vector<1x3x2xf32>
// CHECK: %[[T1:.*]] = vector.insert_strided_slice %[[T0]], %[[UB]]
// CHECK-SAME:           {offsets = [0], strides = [1]} : vector<2xf32> into vector<6xf32>
// CHECK: %[[T2:.*]] = vector.extract %[[A]][0, 1] : vector<2xf32> from vector<1x3x2xf32>
// CHECK: %[[T3:.*]] = vector.insert_strided_slice %[[T2]], %[[T1]]
// CHECK-SAME:           {offsets = [2], strides = [1]} : vector<2xf32> into vector<6xf32>
// CHECK: %[[T4:.*]] = vector.extract %[[A]][0, 2] : vector<2xf32> from vector<1x3x2xf32>
// CHECK: %[[T5:.*]] = vector.insert_strided_slice %[[T4]], %[[T3]]
// CHECK-SAME:           {offsets = [4], strides = [1]} : vector<2xf32> into vector<6xf32>
// CHECK: return %[[T5]] : vector<6xf32>

func.func @shape_cast_3d1d(%arg0 : vector<1x3x2xf32>) -> vector<6xf32> {
  %s = vector.shape_cast %arg0 : vector<1x3x2xf32> to vector<6xf32>
  return %s : vector<6xf32>
}

// CHECK-LABEL: func @shape_cast_1d3d
// CHECK-SAME: %[[A:.*]]: vector<6xf32>
// CHECK: %[[UB:.*]] = ub.poison : vector<2x1x3xf32>
// CHECK: %[[T0:.*]] = vector.extract_strided_slice %[[A]]
// CHECK-SAME:           {offsets = [0], sizes = [3], strides = [1]} : vector<6xf32> to vector<3xf32>
// CHECK: %[[T1:.*]] = vector.insert %[[T0]], %[[UB]] [0, 0] : vector<3xf32> into vector<2x1x3xf32>
// CHECK: %[[T2:.*]] = vector.extract_strided_slice %[[A]]
// CHECK:                {offsets = [3], sizes = [3], strides = [1]} : vector<6xf32> to vector<3xf32>
// CHECK: %[[T3:.*]] = vector.insert %[[T2]], %[[T1]] [1, 0] : vector<3xf32> into vector<2x1x3xf32>
// CHECK: return %[[T3]] : vector<2x1x3xf32>

func.func @shape_cast_1d3d(%arg0 : vector<6xf32>) -> vector<2x1x3xf32> {
  %s = vector.shape_cast %arg0 : vector<6xf32> to vector<2x1x3xf32>
  return %s : vector<2x1x3xf32>
}

// CHECK-LABEL:   func.func @shape_cast_0d1d(
// CHECK-SAME:                               %[[ARG0:.*]]: vector<f32>) -> vector<1xf32> {
// CHECK:           %[[UB:.*]] = ub.poison : vector<1xf32>
// CHECK:           %[[EXTRACT0:.*]] = vector.extract %[[ARG0]][] : f32 from vector<f32>
// CHECK:           %[[RES:.*]] = vector.insert %[[EXTRACT0]], %[[UB]] [0] : f32 into vector<1xf32>
// CHECK:           return %[[RES]] : vector<1xf32>
// CHECK:         }

func.func @shape_cast_0d1d(%arg0 : vector<f32>) -> vector<1xf32> {
  %s = vector.shape_cast %arg0 : vector<f32> to vector<1xf32>
  return %s : vector<1xf32>
}

// CHECK-LABEL:   func.func @shape_cast_1d0d(
// CHECK-SAME:                               %[[ARG0:.*]]: vector<1xf32>) -> vector<f32> {
// CHECK:           %[[UB:.*]] = ub.poison : vector<f32>
// CHECK:           %[[EXTRACT0:.*]] = vector.extract %[[ARG0]][0] : f32 from vector<1xf32>
// CHECK:           %[[RES:.*]] = vector.insert %[[EXTRACT0]], %[[UB]] [] : f32 into vector<f32>
// CHECK:           return %[[RES]] : vector<f32>
// CHECK:         }

func.func @shape_cast_1d0d(%arg0 : vector<1xf32>) -> vector<f32> {
  %s = vector.shape_cast %arg0 : vector<1xf32> to vector<f32>
  return %s : vector<f32>
}

module attributes {transform.with_named_sequence} {
  transform.named_sequence @__transform_main(%module_op: !transform.any_op {transform.readonly}) {
    %f = transform.structured.match ops{["func.func"]} in %module_op
      : (!transform.any_op) -> !transform.any_op

    transform.apply_patterns to %f {
      transform.apply_patterns.vector.lower_shape_cast
    } : !transform.any_op
    transform.yield
  }
}
