/* -----------------------------------------------------------------------------
 * std_string.i
 *
 * Typemaps for std::string and const std::string&
 * These are mapped to a C# String and are passed around by value.
 *
 * To use non-const std::string references use the following %apply.  Note 
 * that they are passed by value.
 * %apply const std::string & {std::string &};
 * ----------------------------------------------------------------------------- */

%{
#include <string>
#include <cstdlib>
#include <cstring>
%}

namespace std {

%naturalvar string;

class string;

// string
%typemap(ctype) string "const char *"
%typemap(imtype) string "ffi.Pointer<Utf8>"
%typemap(ffitype) string "ffi.Pointer<Utf8>"
%typemap(cstype) string "String"

%typemap(csdirectorin) string "$iminput.toDartString()"
%typemap(csdirectorout) string "$cscall"

%typemap(in, canthrow=1) string 
%{ if (!$input) {
    SWIG_CSharpSetPendingExceptionArgument(SWIG_CSharpArgumentNullException, "null string", 0);
    return $null;
   }
   $1.assign($input); %}
%typemap(out) string %{ $result = (const char *)memcpy(malloc($1.size() + 1), $1.c_str(), $1.size() + 1); %}

%typemap(directorout, canthrow=1) string 
%{ if (!$input) {
    SWIG_CSharpSetPendingExceptionArgument(SWIG_CSharpArgumentNullException, "null string", 0);
    return $null;
   }
   $result.assign($input); %}

%typemap(directorin) string %{ $input = $1.c_str(); %}

%typemap(csin,
         pre="    ffi.Pointer<Utf8> $csinput_ptr = $csinput.toNativeUtf8();",
         post="      calloc.free($csinput_ptr);") string "$csinput_ptr"
%typemap(csout, excode=SWIGEXCODE) string {
    ffi.Pointer<Utf8> ret_ptr = $imcall;
    String ret = ret_ptr.toDartString();$excode
    calloc.free(ret_ptr);
    return ret;
  }

%typemap(typecheck) string = char *;

%typemap(throws, canthrow=1) string
%{ SWIG_CSharpSetPendingException(SWIG_CSharpApplicationException, $1.c_str());
   return $null; %}

// const string &
%typemap(ctype) const string & "const char *"
%typemap(imtype) const string & "ffi.Pointer<Utf8>"
%typemap(ffitype) const string & "ffi.Pointer<Utf8>"
%typemap(cstype) const string & "String"

%typemap(csdirectorin) const string & "$iminput.toDartString()"
%typemap(csdirectorout) const string & "$cscall"

%typemap(in, canthrow=1) const string &
%{ if (!$input) {
    SWIG_CSharpSetPendingExceptionArgument(SWIG_CSharpArgumentNullException, "null string", 0);
    return $null;
   }
   $*1_ltype $1_str($input);
   $1 = &$1_str; %}
%typemap(out) const string & %{ $result = (const char *)memcpy(malloc($1->size() + 1), $1->c_str(), $1->size() + 1); %}

%typemap(csin,
         pre="    ffi.Pointer<Utf8> $csinput_ptr = $csinput.toNativeUtf8();",
         post="      calloc.free($csinput_ptr);") const string & "$csinput_ptr"

%typemap(csout, excode=SWIGEXCODE) const string & {
    ffi.Pointer<Utf8> ret_ptr = $imcall;
    String ret = ret_ptr.toDartString();$excode
    calloc.free(ret_ptr);
    return ret;
  }

%typemap(directorout, canthrow=1, warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const string &
%{ if (!$input) {
    SWIG_CSharpSetPendingExceptionArgument(SWIG_CSharpArgumentNullException, "null string", 0);
    return $null;
   }
   /* possible thread/reentrant code problem */
   static $*1_ltype $1_str;
   $1_str = $input;
   $result = &$1_str; %}

%typemap(directorin) const string & %{ $input = $1.c_str(); %}

%typemap(csvarin, excode=SWIGEXCODE2) const string & %{
    set $varname ($paramtype dartValue) {
      ffi.Pointer<Utf8> value_ptr = dartValue.toNativeUtf8();
      $imcall;$excode
      calloc.free(value_ptr);
    }  %}
%typemap(csvarout, excode=SWIGEXCODE2) const string & %{
    $returntype get $varname {
      ffi.Pointer<Utf8> ret_ptr = $imcall;
      String ret = ret_ptr.toDartString();$excode
      calloc.free(ret_ptr);
      return ret;
    } %}

%typemap(typecheck) const string & = char *;

%typemap(throws, canthrow=1) const string &
%{ SWIG_CSharpSetPendingException(SWIG_CSharpApplicationException, $1.c_str());
   return $null; %}

}

