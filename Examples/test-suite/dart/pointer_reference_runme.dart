import 'pointer_reference.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

void main() {
  final s = pointer_reference.get()!;
  check(s.value, 10);

  final ss = Struct(20);
  pointer_reference.set(ss);
  check(Struct.instance!.value, 20);

  check(pointer_reference.overloading(1), 111);
  check(pointer_reference.overloading(ss), 222);
}
