import 'rename_simple.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

void main() {
  final s = NewStruct();
  check(s.NewInstanceVariable, 111);
  check(s.NewInstanceMethod(), 222);
  check(NewStruct.NewStaticMethod(), 333);
  check(NewStruct.NewStaticVariable, 444);
  check(rename_simple.NewFunction(), 555);
  check(rename_simple.NewGlobalVariable, 666);

  s.NewInstanceVariable = 1111;
  NewStruct.NewStaticVariable = 4444;
  rename_simple.NewGlobalVariable = 6666;

  check(s.NewInstanceVariable, 1111);
  check(NewStruct.NewStaticVariable, 4444);
  check(rename_simple.NewGlobalVariable, 6666);
}
