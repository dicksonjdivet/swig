import 'char_constant.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

void main() {
  check(char_constant.CHAR_CONSTANT, 'x');
  check(char_constant.STRING_CONSTANT, 'xyzzy');
  check(char_constant.ia, 97);
  check(char_constant.ib, 98);
  check(char_constant.iparen, ';'.codeUnitAt(0));
}
