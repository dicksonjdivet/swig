// Global functions and variables named like a member of Object are renamed (Lib/dart/dartkw.swg):
// they are static members of the Dart module class, which can't have the name of an instance member
// of Object (conflicting_static_and_instance).
%module dart_object_members

%warnfilter(SWIGWARN_PARSE_KEYWORD) toString;
%warnfilter(SWIGWARN_PARSE_KEYWORD) hashCode;
%warnfilter(SWIGWARN_PARSE_KEYWORD) noSuchMethod;
%warnfilter(SWIGWARN_PARSE_KEYWORD) runtimeType;

%include <std_string.i>

%inline %{
#include <string>
std::string toString(int i) { return "int " + std::to_string(i); }
int noSuchMethod() { return 2; }
int hashCode = 3;
const int runtimeType = 4;

struct Thing {
  std::string toString() const { return "Thing"; }
};
%}
