import 'li_std_string.dart';

void check(Object? actual, Object? expected) {
  if (actual != expected) {
    throw Exception('Expected $expected, got $actual');
  }
}

void main() {
  // Checking expected use of %typemap(in) std::string {}
  li_std_string.test_value('Fee');

  // Checking expected result of %typemap(out) std::string {}
  check(li_std_string.test_value('Fi'), 'Fi');

  // Checking expected use of %typemap(in) const std::string & {}
  li_std_string.test_const_reference('Fo');

  // Checking expected result of %typemap(out) const std::string& {}
  check(li_std_string.test_const_reference('Fum'), 'Fum');

  // Non-ASCII characters are passed as UTF-8
  check(li_std_string.test_value('héllo ☺'), 'héllo ☺');

  // Input and output typemaps for pointers and non-const references to
  // std::string are *not* supported; the following tests confirm
  // that none of these cases are slipping through.
  SWIGTYPE_p_std__string? stringPtr = li_std_string.test_pointer_out();
  li_std_string.test_pointer(stringPtr);
  stringPtr = li_std_string.test_const_pointer_out();
  li_std_string.test_const_pointer(stringPtr);
  final SWIGTYPE_p_std__string stringRef = li_std_string.test_reference_out();
  li_std_string.test_reference(stringRef);

  // Check throw exception specification
  try {
    li_std_string.test_throw();
    throw Exception('Test 5 failed');
  } on SwigException catch (e) {
    check(e.message, 'test_throw message');
  }
  try {
    li_std_string.test_const_reference_throw();
    throw Exception('Test 6 failed');
  } on SwigException catch (e) {
    check(e.message, 'test_const_reference_throw message');
  }

  // Global variables
  const s = 'initial string';
  check(li_std_string.GlobalString2, 'global string 2');
  li_std_string.GlobalString2 = s;
  check(li_std_string.GlobalString2, s);
  check(li_std_string.ConstGlobalString, 'const global string');

  // Member variables
  final myStructure = Structure();
  check(myStructure.MemberString2, 'member string 2');
  myStructure.MemberString2 = s;
  check(myStructure.MemberString2, s);
  check(myStructure.ConstMemberString, 'const member string');

  check(Structure.StaticMemberString2, 'static member string 2');
  Structure.StaticMemberString2 = s;
  check(Structure.StaticMemberString2, s);
  check(Structure.ConstStaticMemberString, 'const static member string');

  check(li_std_string.stdstring_empty(), '');
  check(li_std_string.c_empty(), '');
  check(li_std_string.c_null(), null);
  check(li_std_string.get_null(li_std_string.c_null()), null);
  check(li_std_string.get_null(li_std_string.c_empty()), 'non-null');
  check(li_std_string.get_null(li_std_string.stdstring_empty()), 'non-null');
}
