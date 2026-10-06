import 'throw_exception.dart';

void checkThrows(void Function() f, String name) {
  try {
    f();
  } on SwigException {
    return;
  }
  throw Exception('$name exception should have been thrown');
}

void main() {
  final f = Foo();
  checkThrows(() => f.test_int(), 'Integer');
  checkThrows(() => f.test_msg(), 'String');
  checkThrows(() => f.test_cls(), 'Class');
}
