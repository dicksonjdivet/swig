import 'dart:ffi' as ffi;

import 'dart_shared_ptr.dart';

// Every proxy that holds a shared_ptr is disposed explicitly: a proxy left to the garbage collector
// keeps its shared_ptr until it is finalized, which would make the counts below nondeterministic.

void check(Object? actual, Object? expected, [String what = '']) {
  if (actual != expected) {
    throw Exception('$what: expected $expected, got $actual');
  }
}

int live() => dart_shared_ptr.live_count();

void main() {
  // A base class proxy holds one shared_ptr
  var baseline = live();
  final b = Base(3);
  check(live(), baseline + 1, 'Base created');
  check(b.value, 3, 'Base.value');
  check(dart_shared_ptr.use_count_of(b), 1, 'Base use count');
  dart_shared_ptr.keep(b);
  check(dart_shared_ptr.kept_use_count(), 2, 'Base kept use count');
  b.dispose();
  check(dart_shared_ptr.kept_use_count(), 1, 'Base disposed, kept by C++');
  check(live(), baseline + 1, 'object alive while C++ keeps it');
  dart_shared_ptr.release_kept();
  check(live(), baseline, 'Base deleted with its last shared_ptr');
  b.dispose(); // disposing twice does nothing

  // Every level of a derived proxy holds its own shared_ptr: Derived and Base
  baseline = live();
  final d = Derived(5);
  check(live(), baseline + 1, 'Derived created');
  check(d.get(), 50, 'Derived.get');
  check(d.value, 5, 'member of the base class');
  check(dart_shared_ptr.use_count_of(d), 2, 'Derived use count');
  dart_shared_ptr.keep(d);
  check(dart_shared_ptr.kept_use_count(), 3, 'Derived kept use count');
  d.dispose();
  check(dart_shared_ptr.kept_use_count(), 1, 'Derived disposed: both levels released');
  dart_shared_ptr.release_kept();
  check(live(), baseline, 'Derived deleted');

  // Three levels
  baseline = live();
  final md = dart_shared_ptr.make_more_derived(2)!;
  check(md.get(), 200, 'MoreDerived.get');
  check(dart_shared_ptr.use_count_of(md), 3, 'MoreDerived use count');
  check(dart_shared_ptr.by_const_ref(md), 200, 'MoreDerived as const Base &');
  md.dispose();
  check(live(), baseline, 'MoreDerived deleted');

  // Returned as a shared_ptr of the base class: a Base proxy, virtual calls still dispatched in C++
  baseline = live();
  final asBase = dart_shared_ptr.make_as_base(4)!;
  check(asBase.get(), 40, 'virtual call through a Base proxy');
  asBase.dispose();
  check(live(), baseline, 'deleted through the Base proxy');

  // An empty shared_ptr is null, both ways
  check(dart_shared_ptr.make_null(), null, 'empty shared_ptr returned');
  check(dart_shared_ptr.by_shared_ptr(null), -1, 'null as shared_ptr');
  check(dart_shared_ptr.by_shared_ptr_ref(null), -1, 'null as shared_ptr &');
  check(dart_shared_ptr.by_shared_ptr_const_ref(null), -1, 'null as const shared_ptr &');
  check(dart_shared_ptr.by_shared_ptr_ptr(null), -1, 'null as shared_ptr *');
  check(dart_shared_ptr.by_ptr(null), -1, 'null as Base *');

  // A proxy without C++ object, passed by value or reference: an ArgumentError, not a crash
  final empty = Base.swigFromPtr(ffi.nullptr, false);
  for (final call in <void Function()>[
    () => dart_shared_ptr.by_value(empty),
    () => dart_shared_ptr.by_ref(empty),
    () => dart_shared_ptr.by_const_ref(empty),
  ]) {
    try {
      call();
      throw Exception('missed ArgumentError');
    } on ArgumentError {
      // expected
    }
  }

  // The different ways to pass an object, from a derived proxy
  baseline = live();
  final d2 = dart_shared_ptr.make_derived(6)!;
  check(dart_shared_ptr.by_value(d2), 6, 'by value (sliced copy)');
  check(dart_shared_ptr.by_ref(d2), 60, 'by reference');
  check(dart_shared_ptr.by_const_ref(d2), 60, 'by const reference');
  check(dart_shared_ptr.by_ptr(d2), 60, 'by pointer');
  check(dart_shared_ptr.by_shared_ptr(d2), 60, 'by shared_ptr');
  check(dart_shared_ptr.by_shared_ptr_ref(d2), 60, 'by shared_ptr &');
  check(dart_shared_ptr.by_shared_ptr_const_ref(d2), 60, 'by const shared_ptr &');
  check(dart_shared_ptr.by_shared_ptr_ptr(d2), 60, 'by shared_ptr *');
  check(dart_shared_ptr.use_count_of(d2), 2, 'no reference left behind by the calls');
  d2.dispose();
  check(live(), baseline, 'no copy left behind by the calls');

  // The different ways to return an object
  baseline = live();
  final rv = dart_shared_ptr.ret_value();
  check(rv.value, 7, 'returned by value');
  check(dart_shared_ptr.use_count_of(rv), 1, 'returned by value: owned by Dart only');
  rv.dispose();
  check(live(), baseline, 'object returned by value deleted');

  final rr = dart_shared_ptr.ret_ref();
  check(rr.value, 8, 'returned by reference');
  baseline = live();
  rr.dispose();
  check(live(), baseline, 'object returned by reference not deleted by Dart');
  final rr2 = dart_shared_ptr.ret_ref();
  check(rr2.value, 8, 'object returned by reference still alive');
  rr2.dispose();

  final rp = dart_shared_ptr.ret_ptr()!;
  check(rp.value, 9, 'returned by pointer');
  baseline = live();
  rp.dispose();
  check(live(), baseline, 'object returned by pointer not deleted by Dart');
  check(dart_shared_ptr.ret_null_ptr(), null, 'null pointer returned');

  final rs = dart_shared_ptr.ret_shared_ptr_ref()!;
  check(rs.value, 11, 'returned by const shared_ptr &');
  check(dart_shared_ptr.use_count_of(rs), 2, 'shared with the static shared_ptr');
  rs.dispose();
  final rs2 = dart_shared_ptr.ret_shared_ptr_ref()!;
  check(dart_shared_ptr.use_count_of(rs2), 2, 'first copy released');
  rs2.dispose();

  // Vectors of shared_ptr, with an empty one
  baseline = live();
  final v = dart_shared_ptr.make_vector();
  check(v.length, 3, 'vector length');
  final e0 = v[0]!;
  check(e0.value, 1, 'vector element 0');
  e0.dispose();
  check(v[1], null, 'empty shared_ptr in a vector');
  final e2 = v[2]!;
  check(e2.get(), 30, 'derived object in a vector');
  e2.dispose();
  final nd = Derived(2);
  v[1] = nd;
  nd.dispose();
  final e1 = v[1]!;
  check(e1.get(), 20, 'element set from Dart, kept by the vector');
  e1.dispose();
  v.add(null);
  check(v.length, 4, 'null added');
  check(v.last, null, 'null element');
  check(live(), baseline + 3, 'objects held by the vector only');
  v.dispose();
  check(live(), baseline, 'vector disposed: its objects deleted');
}
