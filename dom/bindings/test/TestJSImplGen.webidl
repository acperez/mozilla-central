/* -*- Mode: IDL; tab-width: 2; indent-tabs-mode: nil; c-basic-offset: 2 -*- */
/* This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this file,
 * You can obtain one at http://mozilla.org/MPL/2.0/.
 */

typedef TestJSImplInterface AnotherNameForTestJSImplInterface;
typedef TestJSImplInterface YetAnotherNameForTestJSImplInterface;
typedef TestJSImplInterface? NullableTestJSImplInterface;

callback MyTestCallback = void();

TestInterface implements ImplementedInterface;

enum MyTestEnum {
  "a",
  "b"
};

[Constructor, JSImplementation="@mozilla.org/test-js-impl-interface;1"]
interface TestJSImplInterface {
  // Integer types
  // XXXbz add tests for throwing versions of all the integer stuff
  readonly attribute byte readonlyByte;
  attribute byte writableByte;
  void passByte(byte arg);
  byte receiveByte();
  void passOptionalByte(optional byte arg);
  // Callback interface limitation.  See bug 841429.
  // void passOptionalByteWithDefault(optional byte arg = 0);
  void passNullableByte(byte? arg);
  void passOptionalNullableByte(optional byte? arg);
  void passVariadicByte(byte... arg);

  readonly attribute short readonlyShort;
  attribute short writableShort;
  void passShort(short arg);
  short receiveShort();
  void passOptionalShort(optional short arg);
  // Callback interface limitation.  See bug 841429.
  //void passOptionalShortWithDefault(optional short arg = 5);

  readonly attribute long readonlyLong;
  attribute long writableLong;
  void passLong(long arg);
  long receiveLong();
  void passOptionalLong(optional long arg);
  // Callback interface limitation.  See bug 841429.
  //void passOptionalLongWithDefault(optional long arg = 7);

  readonly attribute long long readonlyLongLong;
  attribute long long writableLongLong;
  void passLongLong(long long arg);
  long long receiveLongLong();
  void passOptionalLongLong(optional long long arg);
  // Callback interface limitation.  See bug 841429.
  //void passOptionalLongLongWithDefault(optional long long arg = -12);

  readonly attribute octet readonlyOctet;
  attribute octet writableOctet;
  void passOctet(octet arg);
  octet receiveOctet();
  void passOptionalOctet(optional octet arg);
  // Callback interface limitation.  See bug 841429.
  //void passOptionalOctetWithDefault(optional octet arg = 19);

  readonly attribute unsigned short readonlyUnsignedShort;
  attribute unsigned short writableUnsignedShort;
  void passUnsignedShort(unsigned short arg);
  unsigned short receiveUnsignedShort();
  void passOptionalUnsignedShort(optional unsigned short arg);
  // Callback interface limitation.  See bug 841429.
  //void passOptionalUnsignedShortWithDefault(optional unsigned short arg = 2);

  readonly attribute unsigned long readonlyUnsignedLong;
  attribute unsigned long writableUnsignedLong;
  void passUnsignedLong(unsigned long arg);
  unsigned long receiveUnsignedLong();
  void passOptionalUnsignedLong(optional unsigned long arg);
  // Callback interface limitation.  See bug 841429.
  //void passOptionalUnsignedLongWithDefault(optional unsigned long arg = 6);

  readonly attribute unsigned long long readonlyUnsignedLongLong;
  attribute unsigned long long  writableUnsignedLongLong;
  void passUnsignedLongLong(unsigned long long arg);
  unsigned long long receiveUnsignedLongLong();
  void passOptionalUnsignedLongLong(optional unsigned long long arg);
  // Callback interface limitation.  See bug 841429.
  //void passOptionalUnsignedLongLongWithDefault(optional unsigned long long arg = 17);

  attribute float writableFloat;
  attribute unrestricted float writableUnrestrictedFloat;
  attribute float? writableNullableFloat;
  attribute unrestricted float? writableNullableUnrestrictedFloat;
  attribute double writableDouble;
  attribute unrestricted double writableUnrestrictedDouble;
  attribute double? writableNullableDouble;
  attribute unrestricted double? writableNullableUnrestrictedDouble;
  void passFloat(float arg1, unrestricted float arg2,
                 float? arg3, unrestricted float? arg4,
                 double arg5, unrestricted double arg6,
                 double? arg7, unrestricted double? arg8,
                 sequence<float> arg9, sequence<unrestricted float> arg10,
                 sequence<float?> arg11, sequence<unrestricted float?> arg12,
                 sequence<double> arg13, sequence<unrestricted double> arg14,
                 sequence<double?> arg15, sequence<unrestricted double?> arg16);
  [LenientFloat]
  void passLenientFloat(float arg1, unrestricted float arg2,
                        float? arg3, unrestricted float? arg4,
                        double arg5, unrestricted double arg6,
                        double? arg7, unrestricted double? arg8,
                        sequence<float> arg9,
                        sequence<unrestricted float> arg10,
                        sequence<float?> arg11,
                        sequence<unrestricted float?> arg12,
                        sequence<double> arg13,
                        sequence<unrestricted double> arg14,
                        sequence<double?> arg15,
                        sequence<unrestricted double?> arg16);
  [LenientFloat]
  attribute float lenientFloatAttr;
  [LenientFloat]
  attribute double lenientDoubleAttr;

  // Castable interface types
  // XXXbz add tests for throwing versions of all the castable interface stuff
  TestJSImplInterface receiveSelf();
  TestJSImplInterface? receiveNullableSelf();

  // Callback interface ignores 'resultNotAddRefed'. See bug 843272.
  //TestJSImplInterface receiveWeakSelf();
  //TestJSImplInterface? receiveWeakNullableSelf();

  // A version to test for casting to TestJSImplInterface&
  void passSelf(TestJSImplInterface arg);
  // A version we can use to test for the exact type passed in
  void passSelf2(TestJSImplInterface arg);
  void passNullableSelf(TestJSImplInterface? arg);
  attribute TestJSImplInterface nonNullSelf;
  attribute TestJSImplInterface? nullableSelf;
  // Optional arguments
  void passOptionalSelf(optional TestJSImplInterface? arg);
  void passOptionalNonNullSelf(optional TestJSImplInterface arg);
  // Callback interface limitation.  See bug 841429.
  //void passOptionalSelfWithDefault(optional TestJSImplInterface? arg = null);

  // Non-wrapper-cache interface types
  [Creator]
  TestNonWrapperCacheInterface receiveNonWrapperCacheInterface();
  [Creator]
  TestNonWrapperCacheInterface? receiveNullableNonWrapperCacheInterface();

  // Can't return sequences of interfaces from callback interface methods.  See bug 843264.
  //[Creator]
  //sequence<TestNonWrapperCacheInterface> receiveNonWrapperCacheInterfaceSequence();
  //[Creator]
  //sequence<TestNonWrapperCacheInterface?> receiveNullableNonWrapperCacheInterfaceSequence();
  //[Creator]
  //sequence<TestNonWrapperCacheInterface>? receiveNonWrapperCacheInterfaceNullableSequence();
  //[Creator]
  //sequence<TestNonWrapperCacheInterface?>? receiveNullableNonWrapperCacheInterfaceNullableSequence();

  // Non-castable interface types
  IndirectlyImplementedInterface receiveOther();
  IndirectlyImplementedInterface? receiveNullableOther();
  // Callback interface ignores 'resultNotAddRefed'. See bug 843272.
  //IndirectlyImplementedInterface receiveWeakOther();
  //IndirectlyImplementedInterface? receiveWeakNullableOther();

  // A verstion to test for casting to IndirectlyImplementedInterface&
  void passOther(IndirectlyImplementedInterface arg);
  // A version we can use to test for the exact type passed in
  void passOther2(IndirectlyImplementedInterface arg);
  void passNullableOther(IndirectlyImplementedInterface? arg);
  attribute IndirectlyImplementedInterface nonNullOther;
  attribute IndirectlyImplementedInterface? nullableOther;
  // Optional arguments
  void passOptionalOther(optional IndirectlyImplementedInterface? arg);
  void passOptionalNonNullOther(optional IndirectlyImplementedInterface arg);
  // Callback interface limitation.  See bug 841429.
  //void passOptionalOtherWithDefault(optional IndirectlyImplementedInterface? arg = null);

  // External interface types
  TestExternalInterface receiveExternal();
  TestExternalInterface? receiveNullableExternal();
  // Callback interface ignores 'resultNotAddRefed'. See bug 843272.
  //TestExternalInterface receiveWeakExternal();
  //TestExternalInterface? receiveWeakNullableExternal();
  // A verstion to test for casting to TestExternalInterface&
  void passExternal(TestExternalInterface arg);
  // A version we can use to test for the exact type passed in
  void passExternal2(TestExternalInterface arg);
  void passNullableExternal(TestExternalInterface? arg);
  attribute TestExternalInterface nonNullExternal;
  attribute TestExternalInterface? nullableExternal;
  // Optional arguments
  void passOptionalExternal(optional TestExternalInterface? arg);
  void passOptionalNonNullExternal(optional TestExternalInterface arg);
  // Callback interface limitation.  See bug 841429.
  //void passOptionalExternalWithDefault(optional TestExternalInterface? arg = null);

  // Callback interface types
  TestCallbackInterface receiveCallbackInterface();
  TestCallbackInterface? receiveNullableCallbackInterface();
  // Callback interface ignores 'resultNotAddRefed'. See bug 843272.
  //TestCallbackInterface receiveWeakCallbackInterface();
  //TestCallbackInterface? receiveWeakNullableCallbackInterface();
  // A verstion to test for casting to TestCallbackInterface&
  void passCallbackInterface(TestCallbackInterface arg);
  // A version we can use to test for the exact type passed in
  void passCallbackInterface2(TestCallbackInterface arg);
  void passNullableCallbackInterface(TestCallbackInterface? arg);
  attribute TestCallbackInterface nonNullCallbackInterface;
  attribute TestCallbackInterface? nullableCallbackInterface;
  // Optional arguments
  void passOptionalCallbackInterface(optional TestCallbackInterface? arg);
  void passOptionalNonNullCallbackInterface(optional TestCallbackInterface arg);
  // Callback interface limitation.  See bug 841429.
  //void passOptionalCallbackInterfaceWithDefault(optional TestCallbackInterface? arg = null);

  // Miscellaneous interface tests
  IndirectlyImplementedInterface receiveConsequentialInterface();
  void passConsequentialInterface(IndirectlyImplementedInterface arg);

  // Sequence types
  sequence<long> receiveSequence();
  sequence<long>? receiveNullableSequence();
  sequence<long?> receiveSequenceOfNullableInts();
  sequence<long?>? receiveNullableSequenceOfNullableInts();
  void passSequence(sequence<long> arg);
  void passNullableSequence(sequence<long>? arg);
  void passSequenceOfNullableInts(sequence<long?> arg);
  void passOptionalSequenceOfNullableInts(optional sequence<long?> arg);
  void passOptionalNullableSequenceOfNullableInts(optional sequence<long?>? arg);
  // Can't return sequences of interfaces from callback interface methods.  See bug 843264.
  //sequence<TestJSImplInterface> receiveCastableObjectSequence();
  //sequence<TestCallbackInterface> receiveCallbackObjectSequence();
  //sequence<TestJSImplInterface?> receiveNullableCastableObjectSequence();
  //sequence<TestCallbackInterface?> receiveNullableCallbackObjectSequence();
  //sequence<TestJSImplInterface>? receiveCastableObjectNullableSequence();
  //sequence<TestJSImplInterface?>? receiveNullableCastableObjectNullableSequence();
  // Callback interface ignores 'resultNotAddRefed'. See bug 843272.
  //sequence<TestJSImplInterface> receiveWeakCastableObjectSequence();
  //sequence<TestJSImplInterface?> receiveWeakNullableCastableObjectSequence();
  //sequence<TestJSImplInterface>? receiveWeakCastableObjectNullableSequence();
  //sequence<TestJSImplInterface?>? receiveWeakNullableCastableObjectNullableSequence();
  void passCastableObjectSequence(sequence<TestJSImplInterface> arg);
  void passNullableCastableObjectSequence(sequence<TestJSImplInterface?> arg);
  void passCastableObjectNullableSequence(sequence<TestJSImplInterface>? arg);
  void passNullableCastableObjectNullableSequence(sequence<TestJSImplInterface?>? arg);
  void passOptionalSequence(optional sequence<long> arg);
  void passOptionalNullableSequence(optional sequence<long>? arg);
  // Callback interface limitation.  See bug 841429.
  //void passOptionalNullableSequenceWithDefaultValue(optional sequence<long>? arg = null);
  void passOptionalObjectSequence(optional sequence<TestJSImplInterface> arg);
  void passExternalInterfaceSequence(sequence<TestExternalInterface> arg);
  void passNullableExternalInterfaceSequence(sequence<TestExternalInterface?> arg);

  // Can't return sequences of interfaces from callback interface methods.  See bug 843264.
  //sequence<DOMString> receiveStringSequence();
  // Callback interface problem.  See bug 843261.
  //void passStringSequence(sequence<DOMString> arg);
  // "Can't handle sequence member 'any'; need to sort out rooting issues"
  //sequence<any> receiveAnySequence();
  //sequence<any>? receiveNullableAnySequence();

  // ArrayBuffer is handled differently in callback interfaces and the example generator.
  // Need to figure out what should be done there.  Seems like other typed array stuff is
  // similarly not working in the JS implemented generator.  Probably some other issues
  // here as well.
  // Typed array types
  //void passArrayBuffer(ArrayBuffer arg);
  //void passNullableArrayBuffer(ArrayBuffer? arg);
  //void passOptionalArrayBuffer(optional ArrayBuffer arg);
  //void passOptionalNullableArrayBuffer(optional ArrayBuffer? arg);
  //void passOptionalNullableArrayBufferWithDefaultValue(optional ArrayBuffer? arg= null);
  //void passArrayBufferView(ArrayBufferView arg);
  //void passInt8Array(Int8Array arg);
  //void passInt16Array(Int16Array arg);
  //void passInt32Array(Int32Array arg);
  //void passUint8Array(Uint8Array arg);
  //void passUint16Array(Uint16Array arg);
  //void passUint32Array(Uint32Array arg);
  //void passUint8ClampedArray(Uint8ClampedArray arg);
  //void passFloat32Array(Float32Array arg);
  //void passFloat64Array(Float64Array arg);
  //Uint8Array receiveUint8Array();

  // String types
  void passString(DOMString arg);
  void passNullableString(DOMString? arg);
  void passOptionalString(optional DOMString arg);
  // Callback interface limitation.  See bug 841429.
  //void passOptionalStringWithDefaultValue(optional DOMString arg = "abc");
  void passOptionalNullableString(optional DOMString? arg);
  // Callback interface limitation.  See bug 841429.
  //void passOptionalNullableStringWithDefaultValue(optional DOMString? arg = null);
  void passVariadicString(DOMString... arg);

  // Enumerated types
  void passEnum(MyTestEnum arg);
  // No support for nullable enums yet
  // void passNullableEnum(MyTestEnum? arg);
  // Optional enum arg doesn't work with callback interfaces. See bug 843355.
  //void passOptionalEnum(optional MyTestEnum arg);
  // Callback interface limitation.  See bug 841429.
  //void passEnumWithDefault(optional MyTestEnum arg = "a");
  // void passOptionalNullableEnum(optional MyTestEnum? arg);
  // void passOptionalNullableEnumWithDefaultValue(optional MyTestEnum? arg = null);
  MyTestEnum receiveEnum();
  attribute MyTestEnum enumAttribute;
  readonly attribute MyTestEnum readonlyEnumAttribute;

  // Callback types
  void passCallback(MyTestCallback arg);
  void passNullableCallback(MyTestCallback? arg);
  void passOptionalCallback(optional MyTestCallback arg);
  void passOptionalNullableCallback(optional MyTestCallback? arg);
  // Callback interface limitation.  See bug 841429.
  //void passOptionalNullableCallbackWithDefaultValue(optional MyTestCallback? arg = null);
  MyTestCallback receiveCallback();
  MyTestCallback? receiveNullableCallback();
  // Hmm. These two don't work, I think because I need a locally modified version of TestTreatAsNullCallback.
  //void passNullableTreatAsNullCallback(TestTreatAsNullCallback? arg);
  //void passOptionalNullableTreatAsNullCallback(optional TestTreatAsNullCallback? arg);
  // Callback interface limitation.  See bug 841429.
  //void passOptionalNullableTreatAsNullCallbackWithDefaultValue(optional TestTreatAsNullCallback? arg = null);

/* The rest of these are untested.
  // Any types
  void passAny(any arg);
  void passOptionalAny(optional any arg);
  void passAnyDefaultNull(optional any arg = null);
  any receiveAny();

  // object types
  void passObject(object arg);
  void passNullableObject(object? arg);
  void passOptionalObject(optional object arg);
  void passOptionalNullableObject(optional object? arg);
  void passOptionalNullableObjectWithDefaultValue(optional object? arg = null);
  object receiveObject();
  object? receiveNullableObject();

  // Union types
  void passUnion((object or long) arg);
  void passUnionWithNullable((object? or long) arg);
  void passNullableUnion((object or long)? arg);
  void passOptionalUnion(optional (object or long) arg);
  void passOptionalNullableUnion(optional (object or long)? arg);
  void passOptionalNullableUnionWithDefaultValue(optional (object or long)? arg = null);
  //void passUnionWithInterfaces((TestJSImplInterface or TestExternalInterface) arg);
  //void passUnionWithInterfacesAndNullable((TestJSImplInterface? or TestExternalInterface) arg);
  //void passUnionWithSequence((sequence<object> or long) arg);
  void passUnionWithArrayBuffer((ArrayBuffer or long) arg);
  void passUnionWithString((DOMString or object) arg);
  //void passUnionWithEnum((MyTestEnum or object) arg);
  // Trying to use a callback in a union won't include the test
  // headers, unfortunately, so won't compile.
  //  void passUnionWithCallback((MyTestCallback or long) arg);
  void passUnionWithObject((object or long) arg);
  //void passUnionWithDict((Dict or long) arg);

  // binaryNames tests
  void methodRenamedFrom();
  void methodRenamedFrom(byte argument);
  readonly attribute byte attributeGetterRenamedFrom;
  attribute byte attributeRenamedFrom;

  void passDictionary(optional Dict x);
  //UNSUPPORTED  Dict receiveDictionary();
  void passOtherDictionary(optional GrandparentDict x);
  void passSequenceOfDictionaries(sequence<Dict> x);
  void passDictionaryOrLong(optional Dict x);
  void passDictionaryOrLong(long x);

  void passDictContainingDict(optional DictContainingDict arg);
  void passDictContainingSequence(optional DictContainingSequence arg);
  //UNSUPPORTED DictContainingSequence receiveDictContainingSequence();

  // EnforceRange/Clamp tests
  void dontEnforceRangeOrClamp(byte arg);
  void doEnforceRange([EnforceRange] byte arg);
  void doClamp([Clamp] byte arg);

  // Typedefs
  const myLong myLongConstant = 5;
  // ???? What 
  void exerciseTypedefInterfaces1(AnotherNameForTestJSImplInterface arg);
  AnotherNameForTestJSImplInterface exerciseTypedefInterfaces2(NullableTestJSImplInterface arg);
  void exerciseTypedefInterfaces3(YetAnotherNameForTestJSImplInterface arg);

  // Static methods and attributes
  static attribute boolean staticAttribute;
  static void staticMethod(boolean arg);
  static void staticMethodWithContext(any arg);

  // Overload resolution tests
  //void overload1(DOMString... strs);
  boolean overload1(TestJSImplInterface arg);
  TestJSImplInterface overload1(DOMString strs, TestJSImplInterface arg);
  void overload2(TestJSImplInterface arg);
  void overload2(optional Dict arg);
  void overload2(DOMString arg);
  void overload3(TestJSImplInterface arg);
  void overload3(MyTestCallback arg);
  void overload3(DOMString arg);
  void overload4(TestJSImplInterface arg);
  void overload4(TestCallbackInterface arg);
  void overload4(DOMString arg);

  // Variadic handling
  void passVariadicThirdArg(DOMString arg1, long arg2, TestJSImplInterface... arg3);

  // Miscellania
  [LenientThis] attribute long attrWithLenientThis;
  [Unforgeable] readonly attribute long unforgeableAttr;
  [Unforgeable, ChromeOnly] readonly attribute long unforgeableAttr2;
  stringifier;
  void passRenamedInterface(TestRenamedInterface arg);
  [PutForwards=writableByte] readonly attribute TestJSImplInterface putForwardsAttr;
  [PutForwards=writableByte, LenientThis] readonly attribute TestJSImplInterface putForwardsAttr2;
  [PutForwards=writableByte, ChromeOnly] readonly attribute TestJSImplInterface putForwardsAttr3;
  [Throws] void throwingMethod();
  [Throws] attribute boolean throwingAttr;
  [GetterThrows] attribute boolean throwingGetterAttr;
  [SetterThrows] attribute boolean throwingSetterAttr;
*/
  // If you add things here, add them to TestCodeGen as well
};
