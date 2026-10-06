import 'director_string.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

class director_string_B extends A {
  director_string_B(String first) : super(first);

  @override
  String get_first() => 'director_string_B.get_first';

  @override
  String get(int n) => 'director_string_B.get: ' + super.get(n);
}

class director_string_A extends A {
  director_string_A(String first) : super(first);

  @override
  String get(int n) => n.toString();
}

void main() {
  final c = director_string_A('hi');
  for (var i = 0; i < 3; i++) {
    check(c.call_get(i), i.toString());
  }

  final b = director_string_B('hello');
  check(b.get_first(), 'director_string_B.get_first');
  check(b.call_get_first(), 'director_string_B.get_first');
  check(b.call_get(0), 'director_string_B.get: hello');
}
