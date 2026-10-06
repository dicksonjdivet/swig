import 'bools.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

void main() {
  for (final input in [false, true]) {
    for (var i = 0; i < 1000; i++) {
      check(bools.bo(input), input);
    }
  }
}
