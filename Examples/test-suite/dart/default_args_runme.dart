import 'default_args.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

void checkThrows(void Function() f) {
  try {
    f();
  } on Object {
    return;
  }
  throw Exception('missed exception');
}

void main() {
  check(default_args.anonymous(), 7771);
  check(default_args.anonymous(1234), 1234);

  check(default_args.booltest(), true);
  check(default_args.booltest(true), true);
  check(default_args.booltest(false), false);

  final ec = EnumClass();
  check(ec.blah(), true);

  check(default_args.casts1(), null);
  check(default_args.casts2(), 'Hello');
  check(default_args.casts1('Ciao'), 'Ciao');

  check(default_args.chartest1(), 'x');
  check(default_args.chartest2(), '\u0000');
  check(default_args.chartest1('y'), 'y');

  check(default_args.reftest1(), 42);
  check(default_args.reftest1(400), 400);
  check(default_args.reftest2(), 'hello');

  // rename
  final foo = Foo();
  foo.newname();
  foo.newname(10);
  foo.renamed3arg(10, 10.0);
  foo.renamed2arg(10);
  foo.renamed1arg();

  // exception specifications
  checkThrows(() => default_args.exceptionspec());
  checkThrows(() => default_args.exceptionspec(-1));
  checkThrows(() => default_args.exceptionspec(100));
  final ex = Except(false);
  checkThrows(() => ex.exspec());
  checkThrows(() => ex.exspec(-1));
  checkThrows(() => ex.exspec(100));
  checkThrows(() => Except(true));
  checkThrows(() => Except(true, -2));

  // Default parameters in static class methods
  check(Statics.staticmethod(), 10 + 20 + 30);
  check(Statics.staticmethod(100), 100 + 20 + 30);
  check(Statics.staticmethod(100, 200, 300), 100 + 200 + 300);

  final tricky = Tricky();
  check(tricky.privatedefault(), 200);
  check(tricky.protectedint(), 2000);
  check(tricky.protecteddouble(), 987.654);
  check(tricky.functiondefault(), 500);
  check(tricky.contrived(), 'X');

  check(default_args.constructorcall().val, -1);
  check(default_args.constructorcall(Klass(2222)).val, 2222);
  check(default_args.constructorcall(Klass()).val, -1);

  // const methods
  final cm = ConstMethods();
  check(cm.coo(), 20);
  check(cm.coo(1.0), 20);
}
