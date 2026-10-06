import 'li_constraints.dart';

void checkDouble(bool except, void Function(double) f, double val, String name) {
  var actual = true;
  try {
    f(val);
  } on ArgumentError catch (e) {
    actual = false;
    final expected = 'Expected a $name value.';
    if (e.message != expected) {
      throw Exception('Failed: $name, wrong exception message ${e.message}');
    }
  }
  if (actual != except) {
    throw Exception('Failed: $name with $val');
  }
}

void main() {
  checkDouble(true, li_constraints.test_nonnegative, 10, 'non-negative');
  checkDouble(true, li_constraints.test_nonnegative, 0, 'non-negative');
  checkDouble(false, li_constraints.test_nonnegative, -10, 'non-negative');

  checkDouble(false, li_constraints.test_nonpositive, 10, 'non-positive');
  checkDouble(true, li_constraints.test_nonpositive, 0, 'non-positive');
  checkDouble(true, li_constraints.test_nonpositive, -10, 'non-positive');

  checkDouble(true, li_constraints.test_positive, 10, 'positive');
  checkDouble(false, li_constraints.test_positive, 0, 'positive');
  checkDouble(false, li_constraints.test_positive, -10, 'positive');

  checkDouble(false, li_constraints.test_negative, 10, 'negative');
  checkDouble(false, li_constraints.test_negative, 0, 'negative');
  checkDouble(true, li_constraints.test_negative, -10, 'negative');

  checkDouble(true, li_constraints.test_nonzero, 10, 'nonzero');
  checkDouble(false, li_constraints.test_nonzero, 0, 'nonzero');
  checkDouble(true, li_constraints.test_nonzero, -10, 'nonzero');

  var haveException = false;
  try {
    li_constraints.test_nonnull(null);
  } on ArgumentError catch (e) {
    haveException = e.message == 'Received a NULL pointer.';
  }
  if (!haveException) {
    throw Exception('test_nonnull should perform proper exception with null value');
  }
  final nonnull = li_constraints.get_nonnull();
  li_constraints.test_nonnull(nonnull);
}
