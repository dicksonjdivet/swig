// This is the union runtime testcase. It ensures that values within a
// union embedded within a struct can be set and read correctly.

import 'unions.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

void main() {
  // Create new instances of SmallStruct and BigStruct for later use
  final small = SmallStruct();
  small.jill = 200;

  final big = BigStruct();
  big.smallstruct = small;
  big.jack = 300;

  // Use SmallStruct then BigStruct to setup EmbeddedUnionTest.
  // Ensure values in EmbeddedUnionTest are set correctly for each.
  final eut = EmbeddedUnionTest();

  // First check the SmallStruct in EmbeddedUnionTest
  eut.number = 1;
  eut.uni.small = small;
  check(eut.uni.small.jill, 200);
  check(eut.number, 1);

  // Secondly check the BigStruct in EmbeddedUnionTest
  eut.number = 2;
  eut.uni.big = big;
  check(eut.uni.big.jack, 300);
  check(eut.uni.big.smallstruct.jill, 200);
  check(eut.number, 2);
}
