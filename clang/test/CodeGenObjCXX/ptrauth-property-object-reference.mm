// RUN: %clang_cc1 %s -triple arm64-apple-ios11.0 -fobjc-runtime=ios-11.0 -fptrauth-calls -emit-llvm -o - | FileCheck %s

extern int DEFAULT();

struct TCPPObject
{
 TCPPObject();
 ~TCPPObject();
 TCPPObject(const TCPPObject& inObj, int i = DEFAULT());
 TCPPObject& operator=(const TCPPObject& inObj);
 int filler[64];
};


@interface MyDocument
{
@private
 TCPPObject _cppObject;
 TCPPObject _cppObject1;
}
@property (assign, readwrite, atomic) const TCPPObject MyProperty;
@property (assign, readwrite, atomic) const TCPPObject MyProperty1;
@end

@implementation MyDocument
  @synthesize MyProperty = _cppObject;
  @synthesize MyProperty1 = _cppObject1;
@end

// CHECK-LABEL: @__copy_helper_atomic_property_.ptrauth = private constant { i8*, i32, i64, i64 } { i8* bitcast (void (%struct.TCPPObject*, %struct.TCPPObject*)* @__copy_helper_atomic_property_ to i8*), i32 0, i64 0, i64 0 }, section "llvm.ptrauth", align 8

// CHECK-LABEL: @__assign_helper_atomic_property_.ptrauth = private constant { i8*, i32, i64, i64 } { i8* bitcast (void (%struct.TCPPObject*, %struct.TCPPObject*)* @__assign_helper_atomic_property_ to i8*), i32 0, i64 0, i64 0 }, section "llvm.ptrauth", align 8

// CHECK-LABEL: define internal void @__copy_helper_atomic_property_(%struct.TCPPObject* %0, %struct.TCPPObject* %1) #
// CHECK: [[TWO:%.*]] = load %struct.TCPPObject*, %struct.TCPPObject** [[ADDR:%.*]], align 8
// CHECK: [[THREE:%.*]] = load %struct.TCPPObject*, %struct.TCPPObject** [[ADDR1:%.*]], align 8
// CHECK: [[CALL:%.*]] = call i32 @_Z7DEFAULTv()
// CHECK:  call %struct.TCPPObject* @_ZN10TCPPObjectC1ERKS_i(%struct.TCPPObject* nonnull align {{[0-9]+}} dereferenceable(256) [[TWO]], %struct.TCPPObject* nonnull align {{[0-9]+}} dereferenceable({{[0-9]+}}) [[THREE]], i32 [[CALL]])
// CHECK:  ret void

// CHECK: define internal void @"\01-[MyDocument MyProperty]"(
// CHECK: [[ONE:%.*]] = bitcast i8* [[ADDPTR:%.*]] to %struct.TCPPObject*
// CHECK: [[TWO:%.*]] = bitcast %struct.TCPPObject* [[ONE]] to i8*
// CHECK: [[THREE:%.*]] = bitcast %struct.TCPPObject* [[AGGRESULT:%.*]] to i8*
// CHECK: call void @objc_copyCppObjectAtomic(i8* [[THREE]], i8* [[TWO]], i8* bitcast ({ i8*, i32, i64, i64 }* @__copy_helper_atomic_property_.ptrauth to i8*))
// CHECK: ret void

// CHECK-LABEL: define internal void @__assign_helper_atomic_property_(%struct.TCPPObject* %0, %struct.TCPPObject* %1) #
// CHECK: [[THREE:%.*]] = load %struct.TCPPObject*, %struct.TCPPObject** [[ADDR1:%.*]], align 8
// CHECK: [[TWO:%.*]] = load %struct.TCPPObject*, %struct.TCPPObject** [[ADDR:%.*]], align 8
// CHECK: [[CALL:%.*]] = call nonnull align {{[0-9]+}} dereferenceable({{[0-9]+}}) %struct.TCPPObject* @_ZN10TCPPObjectaSERKS_(%struct.TCPPObject* nonnull align {{[0-9]+}} dereferenceable(256) [[TWO]], %struct.TCPPObject* nonnull align {{[0-9]+}} dereferenceable({{[0-9]+}}) [[THREE]])
// CHECK:  ret void

// CHECK: define internal void @"\01-[MyDocument setMyProperty:]"(
// CHECK: [[ONE:%.*]] = bitcast i8* [[ADDRPTR:%.*]] to %struct.TCPPObject*
// CHECK: [[TWO:%.*]] = bitcast %struct.TCPPObject* [[ONE]] to i8*
// CHECK: [[THREE:%.*]] = bitcast %struct.TCPPObject* [[MYPROPERTY:%.*]] to i8*
// CHECK: call void @objc_copyCppObjectAtomic(i8* [[TWO]], i8* [[THREE]], i8* bitcast ({ i8*, i32, i64, i64 }* @__assign_helper_atomic_property_.ptrauth to i8*))
// CHECK: ret void
