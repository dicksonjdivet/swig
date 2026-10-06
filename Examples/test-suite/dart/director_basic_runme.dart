import 'director_basic.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

class director_basic_MyFoo extends Foo {
  director_basic_MyFoo() : super();

  @override
  String ping() => 'director_basic_MyFoo::ping()';
}

class MyOverriddenClass extends MyClass {
  bool expectNull = false;

  @override
  Bar? pmethod(Bar? b) {
    if (expectNull && b != null) {
      throw Exception('null not received as expected');
    }
    return b;
  }
}

class MyClassMiddle extends MyClass {
  @override
  int nonVirtual() => 202;
}

class MyClassEnd extends MyClassMiddle {}

void main() {
  final a = director_basic_MyFoo();
  check(a.ping(), 'director_basic_MyFoo::ping()');
  check(a.pong(), 'Foo::pong();director_basic_MyFoo::ping()');

  final b = Foo();
  check(b.ping(), 'Foo::ping()');
  check(b.pong(), 'Foo::pong();Foo::ping()');

  final a1 = A1(1, false);
  a1.dispose();

  final my = MyOverriddenClass();
  my.expectNull = true;
  check(MyClass.call_pmethod(my, null), null);

  final myBar = Bar();
  my.expectNull = false;
  final myNewBar = MyClass.call_pmethod(my, myBar)!;
  myNewBar.x = 10;
  check(myBar.x, 10);

  // These should not call the Dart implementations as they are not overridden
  check(MyClass.call_nonVirtual(my), 100);
  check(MyClass.call_nonOverride(my), 101);

  // A mix of overridden and non-overridden
  final myend = MyClassEnd();
  final MyClass mc = myend;
  check(mc.nonVirtual(), 202);
  check(MyClass.call_nonVirtual(mc), 202);
  check(MyClass.call_nonVirtual(myend), 202);
  check(MyClass.call_nonOverride(mc), 101);
  check(MyClass.call_nonOverride(myend), 101);

  my.dispose();
  myend.dispose();
}
