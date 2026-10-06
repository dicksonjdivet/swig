import 'aggregate.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

void main() {
  // Confirm that move() returns correct results under normal use
  check(aggregate.move(aggregate.UP), aggregate.UP);
  check(aggregate.move(aggregate.DOWN), aggregate.DOWN);
  check(aggregate.move(aggregate.LEFT), aggregate.LEFT);
  check(aggregate.move(aggregate.RIGHT), aggregate.RIGHT);

  // Confirm that move() raises an exception when the contract is violated
  try {
    aggregate.move(0);
    throw Exception('0 test failed');
  } on ArgumentError {
    // expected
  }
}
