import 'ret_by_value.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

void main() {
  final a = ret_by_value.get_test();
  check(a.myInt, 100);
  check(a.myShort, 200);
  a.dispose();
}
