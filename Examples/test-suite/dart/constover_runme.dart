import 'constover.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

void main() {
  check(constover.test('test'), 'test');
  check(constover.test_pconst('test'), 'test_pconst');

  final f = Foo();
  check(f.test('test'), 'test');
  check(f.test_pconst('test'), 'test_pconst');
  check(f.test_constm('test'), 'test_constmethod');
  check(f.test_pconstm('test'), 'test_pconstmethod');
}
