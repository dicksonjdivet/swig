// This example illustrates how C++ classes can be used from Dart using SWIG.
// The Dart class gets mapped onto the C++ class and behaves as if it is a Dart class.

import 'example.dart';

void main() {
  // ----- Object creation -----

  print('Creating some objects:');
  final c = Circle(10);
  print('    Created circle $c');
  final s = Square(10);
  print('    Created square $s');

  // ----- Access a static member -----

  print('\nA total of ${Shape.nshapes} shapes were created');

  // ----- Member data access -----

  // Notice how we can do this using functions specific to
  // the 'Circle' class.
  c.x = 20;
  c.y = 30;

  // Now use the same functions in the base class
  Shape shape = s;
  shape.x = -10;
  shape.y = 5;

  print('\nHere is their current position:');
  print('    Circle = (${c.x} ${c.y})');
  print('    Square = (${s.x} ${s.y})');

  // ----- Call some methods -----

  print('\nHere are some properties of the shapes:');
  for (final shape in <Shape>[c, s]) {
    print('   $shape');
    print('        area      = ${shape.area()}');
    print('        perimeter = ${shape.perimeter()}');
  }

  // Notice how the area() and perimeter() functions really
  // invoke the appropriate virtual method on each object.

  // ----- Delete everything -----

  print('\nGuess I\'ll clean up now');

  // Note: the dispose() method calls the C++ destructor.
  // Objects which are not disposed are deleted when garbage collected.
  c.dispose();
  s.dispose();

  print('${Shape.nshapes} shapes remain');
  print('Goodbye');
}
