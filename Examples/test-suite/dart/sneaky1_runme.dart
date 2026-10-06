import 'sneaky1.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

void main() {
  check(sneaky1.add(3, 4), 7);
  check(sneaky1.subtract(3, 4), -1);
  check(sneaky1.mul(3, 4), 12);
  check(sneaky1.divide(12, 4), 3);
}
