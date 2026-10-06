import 'enums.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

void main() {
  enums.bar1(foo1.CSP_ITERATION_BWD);
  enums.bar2(foo3.FGHJI);
  enums.bar3(foo3.ABCDE);

  check(foo1.CSP_ITERATION_FWD.swigValue, 0);
  check(foo1.CSP_ITERATION_BWD.swigValue, 11);
  check(foo1.swigToEnum(11), foo1.CSP_ITERATION_BWD);
  check(sad.hoo.swigValue, 5);

  check(enums.enumInstance, Exclamation.me);
  check(enums.Slap, ContainYourself.slap);
  check(enums.Mine, ContainYourself.mine);
  check(enums.Thigh, ContainYourself.thigh);
  check(enums.Thigh.swigValue, 12);
  enums.Slap = ContainYourself.thigh;
  check(enums.Slap, ContainYourself.thigh);

  // Anonymous enums
  check(enums.globalinstance3, 30);
  check(enums.AnonEnum2, 100);
  enums.GlobalInstance = enums.globalinstance2;
  check(enums.GlobalInstance, 1);
  check(Foo.BAR2, 1);

  check(WideCharEnum.WideCharW.swigValue, 'w'.codeUnitAt(0));
  check(WideCharEnum.WideCharE.swigValue, 0xE9);
  check(WideCharEnum.WideCharSmile.swigValue, 0x263A);
}
