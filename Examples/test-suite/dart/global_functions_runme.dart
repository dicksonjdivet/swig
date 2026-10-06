import 'global_functions.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

void main() {
  global_functions.global_void();
  check(global_functions.global_one(1), 1);
  check(global_functions.global_two(2, 2), 4);
}
