/* -----------------------------------------------------------------------------
 * enums.swg
 *
 * Include this file in order for C/C++ enums to be wrapped by Dart enums.
 * Each Dart enum value has a swigValue getter returning the C/C++ enum value
 * and the enum has a static swigToEnum method to look up the Dart enum value from
 * the C/C++ enum value. The C/C++ enum is passed as an int in the FFI layer.
 * ----------------------------------------------------------------------------- */

// const enum SWIGTYPE & typemaps
%typemap(ctype) const enum SWIGTYPE & "int"
%typemap(ffitype) const enum SWIGTYPE & "ffi.Int"
%typemap(imtype) const enum SWIGTYPE & "int"
%typemap(darttype) const enum SWIGTYPE & "$*dartclassname"

%typemap(in) const enum SWIGTYPE & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input;
   $1 = &temp; %}
%typemap(out) const enum SWIGTYPE & %{ $result = (int)*$1; %}

%typemap(directorout,warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const enum SWIGTYPE &
%{ static $*1_ltype temp = ($*1_ltype)$input;
   $result = &temp; %}
%typemap(directorin) const enum SWIGTYPE & "$input = (int)$1;"
%typemap(dartdirectorin) const enum SWIGTYPE & "$*dartclassname.swigToEnum($iminput)"
%typemap(dartdirectorout) const enum SWIGTYPE & "$*dartclassname.swigToValue($dartcall)"

%typecheck(SWIG_TYPECHECK_POINTER) const enum SWIGTYPE & ""

%typemap(throws, canthrow=1) const enum SWIGTYPE &
%{ (void)$1;
   SWIG_DartSetPendingException(SWIG_DartException, "C++ $1_type exception thrown");
   return $null; %}

%typemap(dartin) const enum SWIGTYPE & "$*dartclassname.swigToValue($dartinput)"
%typemap(dartout, excode=SWIGEXCODE) const enum SWIGTYPE & {
    final $*dartclassname ret = $*dartclassname.swigToEnum($imcall);$excode
    return ret;
  }

// enum SWIGTYPE typemaps
%typemap(ctype) enum SWIGTYPE "int"
%typemap(ffitype) enum SWIGTYPE "ffi.Int"
%typemap(imtype) enum SWIGTYPE "int"
%typemap(darttype) enum SWIGTYPE "$dartclassname"

%typemap(in) enum SWIGTYPE %{ $1 = ($1_ltype)$input; %}
%typemap(out) enum SWIGTYPE %{ $result = (int)$1; %}

%typemap(directorout) enum SWIGTYPE %{ $result = ($1_ltype)$input; %}
%typemap(directorin) enum SWIGTYPE "$input = (int)$1;"
%typemap(dartdirectorin) enum SWIGTYPE "$dartclassname.swigToEnum($iminput)"
%typemap(dartdirectorout) enum SWIGTYPE "$dartclassname.swigToValue($dartcall)"

%typecheck(SWIG_TYPECHECK_POINTER) enum SWIGTYPE ""

%typemap(throws, canthrow=1) enum SWIGTYPE
%{ (void)$1;
   SWIG_DartSetPendingException(SWIG_DartException, "C++ $1_type exception thrown");
   return $null; %}

%typemap(dartin) enum SWIGTYPE "$dartclassname.swigToValue($dartinput)"
%typemap(dartout, excode=SWIGEXCODE) enum SWIGTYPE {
    final $dartclassname ret = $dartclassname.swigToEnum($imcall);$excode
    return ret;
  }

%typemap(dartbase)           enum SWIGTYPE ""
%typemap(dartclassmodifiers) enum SWIGTYPE "enum"
%typemap(dartcode)           enum SWIGTYPE ""
%typemap(dartimports)        enum SWIGTYPE ""
%typemap(dartinterfaces)     enum SWIGTYPE ""

/* $enumvalues is replaced by the comma separated list of the C/C++ values of the enum items */
%typemap(dartbody) enum SWIGTYPE %{
  int get swigValue => _swigValues[index];

  static final List<int> _swigValues = [$enumvalues];

  static int swigToValue($dartclassname value) => value.swigValue;

  static $dartclassname swigToEnum(int swigValue) {
    for (final $dartclassname value in values) {
      if (value.swigValue == swigValue) {
        return value;
      }
    }
    throw ArgumentError('No enum value in $dartclassname for ' + swigValue.toString());
  }
%}

%dartenum(proper);
