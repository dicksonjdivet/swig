import 'cpp11_rvalue_reference_move.dart';

void check(bool condition, String message) {
  if (!condition) {
    throw Exception(message);
  }
}

void main() {
  {
    // Function containing rvalue reference parameter
    Counter.reset_counts();
    final mo = MovableCopyable(222);
    Counter.check_counts(1, 0, 0, 0, 0, 0);
    MovableCopyable.movein(mo);
    Counter.check_counts(1, 0, 0, 1, 0, 2);
    check(MovableCopyable.is_nullptr(mo), 'is_nullptr failed');
    mo.dispose();
    Counter.check_counts(1, 0, 0, 1, 0, 2);
  }

  {
    // Move constructor test
    Counter.reset_counts();
    final mo = MovableCopyable(222);
    Counter.check_counts(1, 0, 0, 0, 0, 0);
    final mo_moved = MovableCopyable(mo);
    Counter.check_counts(1, 0, 0, 1, 0, 1);
    check(MovableCopyable.is_nullptr(mo), 'is_nullptr failed');
    mo.dispose();
    Counter.check_counts(1, 0, 0, 1, 0, 1);
    mo_moved.dispose();
    Counter.check_counts(1, 0, 0, 1, 0, 2);
  }

  {
    // Move assignment operator test
    Counter.reset_counts();
    final mo111 = MovableCopyable(111);
    final mo222 = MovableCopyable(222);
    Counter.check_counts(2, 0, 0, 0, 0, 0);
    mo111.MoveAssign(mo222);
    Counter.check_counts(2, 0, 0, 0, 1, 1);
    check(MovableCopyable.is_nullptr(mo222), 'is_nullptr failed');
    mo222.dispose();
    Counter.check_counts(2, 0, 0, 0, 1, 1);
    mo111.dispose();
    Counter.check_counts(2, 0, 0, 0, 1, 2);
  }

  {
    // output
    Counter.reset_counts();
    final mc = MovableCopyable.moveout(1234);
    Counter.check_counts(2, 0, 0, 0, 1, 1);
    MovableCopyable.check_numbers_match(mc, 1234);

    var exceptionThrown = false;
    try {
      MovableCopyable.movein(mc);
    } on StateError catch (e) {
      check(e.message.contains('Cannot release ownership as memory is not owned'), 'incorrect exception message');
      exceptionThrown = true;
    }
    check(exceptionThrown, "Should have thrown 'Cannot release ownership as memory is not owned' error");
    Counter.check_counts(2, 0, 0, 0, 1, 1);
  }

  {
    // Objects moved to C++ are not deleted again when garbage collected
    for (var i = 0; i < 1000; i++) {
      MovableCopyable.movein(MovableCopyable(i));
    }
  }
}
