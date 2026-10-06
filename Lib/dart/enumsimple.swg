/* -----------------------------------------------------------------------------
 * enumsimple.swg
 *
 * Include this file in order for C/C++ enums to be wrapped by integer constants.
 * Global enum items are wrapped by constants in the module class and enum items
 * declared within a C++ class are wrapped by constants in the Dart proxy class.
 * ----------------------------------------------------------------------------- */

// const enum SWIGTYPE & typemaps
%typemap(ctype) const enum SWIGTYPE & "int"
%typemap(ffitype) const enum SWIGTYPE & "ffi.Int"
%typemap(imtype) const enum SWIGTYPE & "int"
%typemap(darttype) const enum SWIGTYPE & "int"

%typemap(in) const enum SWIGTYPE & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input;
   $1 = &temp; %}
%typemap(out) const enum SWIGTYPE & %{ $result = (int)*$1; %}

%typemap(directorout,warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const enum SWIGTYPE &
%{ static $*1_ltype temp;
   temp = ($*1_ltype)$input;
   $result = &temp; %}
%typemap(directorin) const enum SWIGTYPE & "$input = (int)$1;"
%typemap(dartdirectorin) const enum SWIGTYPE & "$iminput"
%typemap(dartdirectorout) const enum SWIGTYPE & "$dartcall"

%typecheck(SWIG_TYPECHECK_INT32) const enum SWIGTYPE & ""

%typemap(throws, canthrow=1) const enum SWIGTYPE &
%{ (void)$1;
   SWIG_DartSetPendingException(SWIG_DartException, "C++ $1_type exception thrown");
   return $null; %}

%typemap(dartin) const enum SWIGTYPE & "$dartinput"
%typemap(dartout, excode=SWIGEXCODE) const enum SWIGTYPE & {
    final int ret = $imcall;$excode
    return ret;
  }

// enum SWIGTYPE typemaps
%typemap(ctype) enum SWIGTYPE "int"
%typemap(ffitype) enum SWIGTYPE "ffi.Int"
%typemap(imtype) enum SWIGTYPE "int"
%typemap(darttype) enum SWIGTYPE "int"

%typemap(in) enum SWIGTYPE %{ $1 = ($1_ltype)$input; %}
%typemap(out) enum SWIGTYPE %{ $result = (int)$1; %}

%typemap(directorout) enum SWIGTYPE %{ $result = ($1_ltype)$input; %}
%typemap(directorin) enum SWIGTYPE "$input = (int)$1;"
%typemap(dartdirectorin) enum SWIGTYPE "$iminput"
%typemap(dartdirectorout) enum SWIGTYPE "$dartcall"

%typecheck(SWIG_TYPECHECK_INT32) enum SWIGTYPE ""

%typemap(throws, canthrow=1) enum SWIGTYPE
%{ (void)$1;
   SWIG_DartSetPendingException(SWIG_DartException, "C++ $1_type exception thrown");
   return $null; %}

%typemap(dartin) enum SWIGTYPE "$dartinput"
%typemap(dartout, excode=SWIGEXCODE) enum SWIGTYPE {
    final int ret = $imcall;$excode
    return ret;
  }

%typemap(dartbase)           enum SWIGTYPE ""
%typemap(dartclassmodifiers) enum SWIGTYPE ""
%typemap(dartcode)           enum SWIGTYPE ""
%typemap(dartimports)        enum SWIGTYPE ""
%typemap(dartinterfaces)     enum SWIGTYPE ""

%typemap(dartbody) enum SWIGTYPE ""

%dartenum(simple);
