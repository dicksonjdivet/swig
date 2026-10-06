import 'char_strings.dart';

const CPLUSPLUS_MSG = 'A message from the deep dark world of C++, where anything is possible.';
const OTHERLAND_MSG = 'Little message from the safe world.';

void check(Object? actual, Object? expected, String msg) {
  if (actual != expected) {
    throw Exception('$msg: expected $expected, got $actual');
  }
}

void main() {
  const count = 10000;

  // get functions
  for (var i = 0; i < count; i++) {
    check(char_strings.GetCharHeapString(), CPLUSPLUS_MSG, 'Test char get 1');
    char_strings.DeleteCharHeapString();
  }
  for (var i = 0; i < count; i++) {
    check(char_strings.GetConstCharProgramCodeString(), CPLUSPLUS_MSG, 'Test char get 2');
    char_strings.DeleteCharHeapString();
  }
  for (var i = 0; i < count; i++) {
    check(char_strings.GetCharStaticString(), CPLUSPLUS_MSG, 'Test char get 3');
  }
  for (var i = 0; i < count; i++) {
    check(char_strings.GetCharStaticStringFixed(), CPLUSPLUS_MSG, 'Test char get 4');
  }
  for (var i = 0; i < count; i++) {
    check(char_strings.GetConstCharStaticStringFixed(), CPLUSPLUS_MSG, 'Test char get 5');
  }

  // set functions
  for (var i = 0; i < count; i++) {
    check(char_strings.SetCharHeapString('$OTHERLAND_MSG$i', i), true, 'Test char set 1');
  }
  for (var i = 0; i < count; i++) {
    check(char_strings.SetCharStaticString('$OTHERLAND_MSG$i', i), true, 'Test char set 2');
  }
  for (var i = 0; i < count; i++) {
    check(char_strings.SetCharArrayStaticString('$OTHERLAND_MSG$i', i), true, 'Test char set 3');
  }
  for (var i = 0; i < count; i++) {
    check(char_strings.SetConstCharHeapString('$OTHERLAND_MSG$i', i), true, 'Test char set 4');
  }
  for (var i = 0; i < count; i++) {
    check(char_strings.SetConstCharStaticString('$OTHERLAND_MSG$i', i), true, 'Test char set 5');
  }
  for (var i = 0; i < count; i++) {
    check(char_strings.SetConstCharArrayStaticString('$OTHERLAND_MSG$i', i), true, 'Test char set 6');
  }
  for (var i = 0; i < count; i++) {
    check(char_strings.SetCharConstStaticString('$OTHERLAND_MSG$i', i), true, 'Test char set 7');
  }
  for (var i = 0; i < count; i++) {
    check(char_strings.SetConstCharConstStaticString('$OTHERLAND_MSG$i', i), true, 'Test char set 8');
  }
  for (var i = 0; i < count; i++) {
    check(char_strings.SetConstCharTypedefString('$OTHERLAND_MSG$i', i), true, 'Test char set 9');
  }

  // get set function
  for (var i = 0; i < count * 10; i++) {
    final ping = '$OTHERLAND_MSG$i';
    check(char_strings.CharPingPong(ping), ping, 'Test PingPong 1');
  }
  for (var i = 0; i < count; i++) {
    final ping = '$OTHERLAND_MSG$i';
    check(char_strings.CharArrayPingPong(ping), ping, 'Test PingPong 2');
  }
  for (var i = 0; i < count; i++) {
    final ping = '$OTHERLAND_MSG$i';
    check(char_strings.CharArrayDimsPingPong(ping), ping, 'Test PingPong 3');
  }

  // variables
  for (var i = 0; i < count; i++) {
    char_strings.global_char = '$OTHERLAND_MSG$i';
    check(char_strings.global_char, '$OTHERLAND_MSG$i', 'Test variables 1');
  }
  for (var i = 0; i < count; i++) {
    char_strings.global_char_array1 = '$OTHERLAND_MSG$i';
    check(char_strings.global_char_array1, '$OTHERLAND_MSG$i', 'Test variables 2');
  }
  for (var i = 0; i < count; i++) {
    char_strings.global_char_array2 = '$OTHERLAND_MSG$i';
    check(char_strings.global_char_array2, '$OTHERLAND_MSG$i', 'Test variables 3');
  }
  for (var i = 0; i < count; i++) {
    check(char_strings.global_const_char, CPLUSPLUS_MSG, 'Test variables 4');
  }
  for (var i = 0; i < count; i++) {
    check(char_strings.global_const_char_array1, CPLUSPLUS_MSG, 'Test variables 5');
  }
  for (var i = 0; i < count; i++) {
    check(char_strings.global_const_char_array2, CPLUSPLUS_MSG, 'Test variables 6');
  }

  // char *& tests
  for (var i = 0; i < count; i++) {
    check(char_strings.GetCharPointerRef(), CPLUSPLUS_MSG, 'Test char pointer ref get');
  }
  for (var i = 0; i < count; i++) {
    check(char_strings.SetCharPointerRef('$OTHERLAND_MSG$i', i), true, 'Test char pointer ref set');
  }
  for (var i = 0; i < count; i++) {
    check(char_strings.GetConstCharPointerRef(), CPLUSPLUS_MSG, 'Test const char pointer ref get');
  }
  for (var i = 0; i < count; i++) {
    check(char_strings.SetConstCharPointerRef('$OTHERLAND_MSG$i', i), true, 'Test const char pointer ref set');
  }
}
