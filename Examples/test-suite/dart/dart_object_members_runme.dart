import 'dart_object_members.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

void main() {
  check(dart_object_members.toString_(1), 'int 1');
  check(dart_object_members.noSuchMethod_(), 2);
  check(dart_object_members.hashCode_, 3);
  dart_object_members.hashCode_ = 30;
  check(dart_object_members.hashCode_, 30);
  check(dart_object_members.runtimeType_, 4);

  // Members keep the existing rule
  final t = Thing();
  check(t.toString_(), 'Thing');
  check(t.toString().contains('Thing'), true); // Object.toString of the proxy
}
