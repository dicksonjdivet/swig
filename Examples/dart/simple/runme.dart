// This example illustrates how C functions and global variables can be used from Dart.

import 'example.dart';

void main() {
  // Call our gcd() function
  final x = 42;
  final y = 105;
  final g = example.gcd(x, y);
  print('The gcd of $x and $y is $g');

  // Manipulate the Foo global variable

  // Output its current value
  print('Foo = ${example.Foo}');

  // Change its value
  example.Foo = 3.1415926;

  // See if the change took effect
  print('Foo = ${example.Foo}');
}
