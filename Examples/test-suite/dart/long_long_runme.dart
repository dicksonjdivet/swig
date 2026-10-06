import 'long_long.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

void main() {
  // The Dart int is a 64-bit signed integer
  for (final v in [0, 1, -1, 0x7FFFFFFFFFFFFFFF, -0x8000000000000000, 1234567890123]) {
    long_long.ll = v;
    check(long_long.ll, v);
  }

  // unsigned long long values above 0x7FFFFFFFFFFFFFFF are negative Dart ints
  long_long.ull = 0x7FFFFFFFFFFFFFFF;
  check(long_long.ull, 0x7FFFFFFFFFFFFFFF);
  long_long.ull = -1;
  check(long_long.ull, -1);
  check(long_long.UnsignedToSigned(-1), -1);
  check(long_long.UnsignedToSigned(0x7FFFFFFFFFFFFFFF), 0x7FFFFFFFFFFFFFFF);

  check(long_long.bar1(), 0);
  check(long_long.bar6(), 0);
  long_long.foo1(-5);
  long_long.foo6(5);

  check(long_long.lconst1, 1234567890);
  check(long_long.lconst2, 1234567890);
  check(long_long.lconst3, 1234567);
  check(long_long.lconst4, 1234567);
  check(long_long.lconst5, 987654321);
  check(long_long.lconst6, 987654321);
}
