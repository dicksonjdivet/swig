import 'overload_simple.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

void main() {
  check(overload_simple.foo(3), 'foo:int');
  check(overload_simple.foo(3.0), 'foo:double');
  check(overload_simple.foo('hello'), 'foo:char *');

  final f = Foo();
  final b = Bar();
  check(overload_simple.foo(f), 'foo:Foo *');
  check(overload_simple.foo(b), 'foo:Bar *');

  final v = overload_simple.malloc_void(32);
  check(overload_simple.foo(v), 'foo:void *');

  var s = Spam();
  check(s.foo(3), 'foo:int');
  check(s.foo(3.0), 'foo:double');
  check(s.foo('hello'), 'foo:char *');
  check(s.foo(f), 'foo:Foo *');
  check(s.foo(b), 'foo:Bar *');
  check(s.foo(v), 'foo:void *');

  check(Spam.bar(3), 'bar:int');
  check(Spam.bar(3.0), 'bar:double');
  check(Spam.bar('hello'), 'bar:char *');
  check(Spam.bar(f), 'bar:Foo *');
  check(Spam.bar(b), 'bar:Bar *');
  check(Spam.bar(v), 'bar:void *');

  // Test constructors
  s = Spam();
  check(s.type, 'none');
  s = Spam(3);
  check(s.type, 'int');
  s = Spam(3.4);
  check(s.type, 'double');
  s = Spam('hello');
  check(s.type, 'char *');
  s = Spam(f);
  check(s.type, 'Foo *');
  s = Spam(b);
  check(s.type, 'Bar *');
  s = Spam(v);
  check(s.type, 'void *');

  overload_simple.free_void(v);

  final a = ClassA();
  a.method1(1);

  // No matching overload
  try {
    overload_simple.foo(true);
    throw Exception('missed ArgumentError');
  } on ArgumentError {
    // expected
  }
}
