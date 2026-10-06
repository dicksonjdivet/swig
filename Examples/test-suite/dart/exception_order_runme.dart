import 'exception_order.dart';

void checkThrows(void Function() f, String expectedMessage) {
  try {
    f();
  } on SwigException catch (e) {
    if (e.message != expectedMessage) {
      throw Exception('bad exception order: ${e.message}');
    }
    return;
  }
  throw Exception('missed exception');
}

void main() {
  final a = A();
  checkThrows(() => a.foo(), 'C++ E1 exception thrown');
  checkThrows(() => a.bar(), 'C++ E2 exception thrown');
  checkThrows(() => a.foobar(), 'postcatch unknown');
  checkThrows(() => a.barfoo(1), 'C++ E1 exception thrown');
  checkThrows(() => a.barfoo(2), 'C++ E2 * exception thrown');
}
