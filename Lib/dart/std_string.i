/* -----------------------------------------------------------------------------
 * std_string.i
 *
 * Typemaps for std::string and const std::string&
 * These are mapped to a Dart String and are passed around by value as UTF-8.
 *
 * To use non-const std::string references use the following %apply.  Note
 * that they are passed by value.
 * %apply const std::string & {std::string &};
 * ----------------------------------------------------------------------------- */

%{
#include <string>
%}

namespace std {

%naturalvar string;

class string;

// string
%typemap(ctype) string, const string & "char *"
%typemap(ffitype) string, const string & "ffi.Pointer<ffi.Uint8>"
%typemap(imtype) string, const string & "ffi.Pointer<ffi.Uint8>"
%typemap(darttype) string, const string & "String"

%typemap(in, canthrow=1) string
%{ if (!$input) {
    SWIG_DartSetPendingException(SWIG_DartArgumentNullError, "null string");
    return $null;
   }
   $1.assign($input); %}
%typemap(in, canthrow=1) const string &
%{ if (!$input) {
    SWIG_DartSetPendingException(SWIG_DartArgumentNullError, "null string");
    return $null;
   }
   $*1_ltype $1_str($input);
   $1 = &$1_str; %}

%typemap(out) string %{ $result = SWIG_DartStrdup($1.c_str()); %}
%typemap(out) const string & %{ $result = SWIG_DartStrdup($1->c_str()); %}

%typemap(directorin) string, const string & %{ $input = SWIG_DartStrdup($1.c_str()); %}

%typemap(directorout, canthrow=1) string
%{ if (!$input) {
    SWIG_DartSetPendingException(SWIG_DartArgumentNullError, "null string");
    return $null;
   }
   $result.assign($input);
   free($input); %}

%typemap(directorout, canthrow=1, warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const string &
%{ if (!$input) {
    SWIG_DartSetPendingException(SWIG_DartArgumentNullError, "null string");
    return $null;
   }
   /* possible thread/reentrant code problem */
   static $*1_ltype $1_str;
   $1_str = $input;
   free($input);
   $result = &$1_str; %}

%typemap(dartin, pre="    final ffi.Pointer<ffi.Uint8> swig_$dartinput = $imclassname.swigToNativeString($dartinput);",
         post="      $imclassname.swigFree(swig_$dartinput);") string, const string & "swig_$dartinput"
%typemap(dartout, excode=SWIGEXCODE) string, const string & {
    final ffi.Pointer<ffi.Uint8> cString = $imcall;$excode
    return $imclassname.swigFromNativeStringAndFree(cString)!;
  }

%typemap(dartdirectorin) string, const string & "$imclassname.swigFromNativeStringAndFree($iminput)!"
%typemap(dartdirectorout) string, const string & "$imclassname.swigToNativeString($dartcall)"

%typemap(typecheck) string, const string & = char *;

%typemap(throws, canthrow=1) string, const string &
%{ SWIG_DartSetPendingException(SWIG_DartException, $1.c_str());
   return $null; %}

}
