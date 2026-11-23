import 'cpp11_std_array.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

ArrayInt6 toArray6(List<int> values) {
  final a = ArrayInt6();
  a.setAll(0, values);
  return a;
}

void compareContainers(ArrayInt6 actual, List<int> expected) {
  check(actual.length, expected.length);
  for (var i = 0; i < actual.length; ++i) {
    check(actual[i], expected[i]);
  }
  check(actual.isEmpty, false);
  check(actual.empty(), false);
}

void main() {
  // A wrapped std::array is a fixed-length Dart List
  final ai = ArrayInt6();
  compareContainers(ai, [0, 0, 0, 0, 0, 0]);
  check(ai.size(), 6);

  final vals = [10, 20, 30, 40, 50, 60];
  for (var i = 0; i < ai.length; ++i) {
    ai[i] = vals[i];
  }
  compareContainers(ai, vals);
  check(ai.where((i) => i > 30).toList().toString(), '[40, 50, 60]');
  check(ai.indexOf(50), 4);
  check(ai.toString(), '[10, 20, 30, 40, 50, 60]');

  // Return values
  compareContainers(cpp11_std_array.arrayOutVal(), [-2, -1, 0, 0, 1, 2]);
  compareContainers(cpp11_std_array.arrayOutConstRef(), [-2, -1, 0, 0, 1, 2]);
  compareContainers(cpp11_std_array.arrayOutRef(), [-2, -1, 0, 0, 1, 2]);
  compareContainers(cpp11_std_array.arrayOutPtr()!, [-2, -1, 0, 0, 1, 2]);

  // Arguments
  compareContainers(cpp11_std_array.arrayInVal(toArray6([9, 8, 7, 6, 5, 4])), [90, 80, 70, 60, 50, 40]);
  compareContainers(cpp11_std_array.arrayInConstRef(toArray6([9, 8, 7, 6, 5, 4])), [90, 80, 70, 60, 50, 40]);

  var inout = toArray6([9, 8, 7, 6, 5, 4]);
  cpp11_std_array.arrayInRef(inout);
  compareContainers(inout, [90, 80, 70, 60, 50, 40]);

  inout = toArray6([9, 8, 7, 6, 5, 4]);
  cpp11_std_array.arrayInPtr(inout);
  compareContainers(inout, [90, 80, 70, 60, 50, 40]);

  // Overloads
  compareContainers(cpp11_std_array.overloadFunc(toArray6([1, 2, 3, 4, 5, 6])), [100, 200, 300, 400, 500, 600]);
  cpp11_std_array.overloadFunc(1, 2);

  // Copy constructor: a different C++ object
  final copy = ArrayInt6(ai);
  copy[0] = 99;
  check(copy[0], 99);
  check(ai[0], 10);

  // fill and swap
  ai.fill(111);
  compareContainers(ai, [111, 111, 111, 111, 111, 111]);
  final other = toArray6([1, 2, 3, 4, 5, 6]);
  ai.swap(other);
  compareContainers(ai, [1, 2, 3, 4, 5, 6]);
  compareContainers(other, [111, 111, 111, 111, 111, 111]);

  // In place List operations that keep the length
  ai.setAll(0, [6, 5, 4, 3, 2, 1]);
  ai.sort();
  compareContainers(ai, [1, 2, 3, 4, 5, 6]);

  // Out of range
  for (final index in [ai.length, -1]) {
    try {
      ai[index] = 0;
      throw Exception('missed RangeError for setitem($index)');
    } on RangeError {
      // expected
    }
    try {
      ai[index];
      throw Exception('missed RangeError for getitem($index)');
    } on RangeError {
      // expected
    }
  }

  // The length is fixed
  for (final change in <void Function()>[
    () => ai.length = 3,
    () => ai.add(7),
    () => ai.removeLast(),
    () => ai.clear(),
  ]) {
    try {
      change();
      throw Exception('missed UnsupportedError');
    } on UnsupportedError {
      // expected
    }
  }
  check(ai.length, 6);
}
