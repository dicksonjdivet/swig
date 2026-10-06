import 'catches.dart';

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
  // test_catches()
  checkThrows(() => catches.test_catches(1), 'C++ int exception thrown, value: 1');
  checkThrows(() => catches.test_catches(2), 'two');
  checkThrows(() => catches.test_catches(3), 'C++ ThreeException const & exception thrown');

  // test_exception_specification()
  checkThrows(() => catches.test_exception_specification(1), 'C++ int exception thrown, value: 1');
  checkThrows(() => catches.test_exception_specification(2), 'unknown exception');
  checkThrows(() => catches.test_exception_specification(3), 'unknown exception');

  // test_catches_all()
  checkThrows(() => catches.test_catches_all(1), 'unknown exception');
}
