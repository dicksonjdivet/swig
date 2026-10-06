import 'sizet.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

void main() {
  var s = 2000;
  s = sizet.test1(s + 1);
  s = sizet.test2(s + 1);
  s = sizet.test3(s + 1);
  s = sizet.test4(s + 1);
  check(s, 2004);
}
