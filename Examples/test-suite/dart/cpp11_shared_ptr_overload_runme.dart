import 'cpp11_shared_ptr_overload.dart';

void check(String actual, String expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

void main() {
  // ref
  check(cpp11_shared_ptr_overload.UseA(MyType('123')), '123 ref');
  check(cpp11_shared_ptr_overload.UseB(0, MyType('123')), '123 ref');
  check(cpp11_shared_ptr_overload.UseC(0, MyType('123'), MyType('456')), '123 ref');

  // sharedptr
  check(cpp11_shared_ptr_overload.UseX(MyType('123')), '123 sharedptr');
  check(cpp11_shared_ptr_overload.UseY(0, MyType('123')), '123 sharedptr');
  check(cpp11_shared_ptr_overload.UseZ(0, MyType('123'), MyType('456')), '123 sharedptr');

  // Combo1-4
  check(cpp11_shared_ptr_overload.Combo1(MyType('XXX')), 'XXXCombo1');
  check(cpp11_shared_ptr_overload.Combo2(MyType('XXX')), 'XXXCombo2');
  check(cpp11_shared_ptr_overload.Combo3(MyType('XXX')), 'XXXCombo3');
  check(cpp11_shared_ptr_overload.Combo4(MyType('XXX')), 'XXXCombo4');

  // Combo5-7
  check(cpp11_shared_ptr_overload.Combo5(MyType('XXX')), 'XXXCombo5');
  check(cpp11_shared_ptr_overload.Combo6(MyType('XXX')), 'XXXCombo6');
  check(cpp11_shared_ptr_overload.Combo7(MyType('XXX')), 'XXXCombo7');
}
