import 'cpp11_shared_ptr_nullptr_in_containers.dart';

// The vector of shared_ptr has no %template name, so it is an opaque pointer in Dart: its elements
// can't be read, only passed back to C++. ret_vec_c_shared_ptr() returns {C(0), empty, C(2)}.
// The empty shared_ptr in a named vector is tested by dart_shared_ptr_runme.dart.
void main() {
  final v = cpp11_shared_ptr_nullptr_in_containers.ret_vec_c_shared_ptr();
  if (cpp11_shared_ptr_nullptr_in_containers.is_last_null(v)) {
    throw Exception('the last element is C(2), not an empty shared_ptr');
  }
  final copy = cpp11_shared_ptr_nullptr_in_containers.ret_arg_vec(v);
  if (cpp11_shared_ptr_nullptr_in_containers.is_last_null(copy)) {
    throw Exception('the copy should keep its last element');
  }
}
