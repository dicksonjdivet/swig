// This example illustrates how a C++ virtual method can be overridden in Dart using directors.

import 'example.dart';

class DartCallback extends Callback {
  @override
  void run() {
    print('DartCallback.run()');
  }
}

void main() {
  print('Adding and calling a normal C++ callback');
  print('----------------------------------------');

  final caller = Caller();
  final callback = Callback();
  caller.setCallback(callback);
  caller.call();
  caller.resetCallback();
  callback.dispose();

  print('');
  print('Adding and calling a Dart callback');
  print('----------------------------------');

  final dartCallback = DartCallback();
  caller.setCallback(dartCallback);
  caller.call();
  caller.resetCallback();
  dartCallback.dispose();

  print('');
  print('Dart exit');
}
