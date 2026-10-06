import 'virtual_poly.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

void main() {
  final d = NDouble(3.5);
  final i = NInt(2);

  // Covariant return types are supported in Dart
  final NDouble dc = d.copy()!;
  final NInt ic = i.copy()!;

  final ddc = NDouble.narrow(dc)!;
  final dic = NInt.narrow(ic)!;
  check(ddc.get(), 3.5);
  check(dic.get(), 2);

  virtual_poly.incr(ic);
  check(i.get() + 1, ic.get());

  // Checking a pure user downcast
  final NNumber n1 = d.copy()!;
  final NNumber n2 = d.nnumber()!;
  final dn1 = NDouble.narrow(n1)!;
  final dn2 = NDouble.narrow(n2)!;
  check(dn1.get(), dn2.get());

  // Checking the ref polymorphic case
  final NNumber nr = d.ref_this();
  final dr1 = NDouble.narrow(nr)!;
  final dr2 = d.ref_this();
  check(dr1.get(), dr2.get());
}
