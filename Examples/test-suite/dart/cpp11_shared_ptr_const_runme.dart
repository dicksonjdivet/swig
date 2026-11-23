import 'cpp11_shared_ptr_const.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

void main() {
  check(cpp11_shared_ptr_const.single_foo(Foo(1))!.get_m(), 1);
  check(cpp11_shared_ptr_const.const_single_foo(Foo(2))!.get_m(), 2);
  check(cpp11_shared_ptr_const.foo_vec(Foo(3))[0]!.get_m(), 3);
  check(cpp11_shared_ptr_const.const_foo_vec(Foo(4))[0]!.get_m(), 4);
}
