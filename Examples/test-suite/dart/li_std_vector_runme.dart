import 'li_std_vector.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

void main() {
  // A wrapped std::vector is a Dart List
  final iv = IntVector();
  check(iv.isEmpty, true);
  iv.add(1);
  iv.addAll([2, 3, 4]);
  check(iv.length, 4);
  check(iv.size(), 4);
  check(iv[2], 3);
  iv[2] = 30;
  check(iv[2], 30);
  check(iv.contains(30), true);
  check(iv.indexOf(4), 3);
  check(iv.where((i) => i > 2).toList().toString(), '[30, 4]');
  check(iv.removeAt(0), 1);
  check(iv.toString(), '[2, 30, 4]');
  iv.insert(0, 10);
  check(iv.first, 10);
  iv.removeRange(1, 3);
  check(iv.toString(), '[10, 4]');
  iv.length = 1;
  check(iv.length, 1);
  iv.clear();
  check(iv.length, 0);

  try {
    iv[5];
    throw Exception('missed RangeError');
  } on RangeError {
    // expected
  }

  // Passing a vector by value and by reference
  final v = IntVector();
  for (var i = 1; i <= 4; i++) {
    v.add(i);
  }
  check(li_std_vector.average(v), 2.5);

  final rv = RealVector();
  rv.addAll([10.0, 20.0]);
  final half = li_std_vector.half(rv);
  check(half.toString(), '[5.0, 10.0]');

  final dv = DoubleVector();
  dv.addAll([2.0, 4.0]);
  li_std_vector.halve_in_place(dv);
  check(dv[0], 1.0);
  check(dv[1], 2.0);

  final bv = BoolVector();
  bv.addAll([true, false]);
  check(bv.toString(), '[true, false]');

  final sv = StringVector();
  sv.addAll(['one', 'two']);
  check(sv.join(','), 'one,two');

  final cv = CharVector();
  cv.add('a');
  check(cv[0], 'a');

  // Vectors of class instances
  final structs = StructVector();
  structs.add(Struct(5));
  structs.add(Struct(6));
  check(structs[1].num, 6.0);
  final copied = li_std_vector.vecstruct(structs);
  check(copied.map((s) => s.num).join(','), '5.0,6.0');

  final ptrs = StructPtrVector();
  ptrs.add(Struct(7));
  ptrs.add(null);
  check(ptrs[0]!.num, 7.0);
  check(ptrs[1], null);
}
