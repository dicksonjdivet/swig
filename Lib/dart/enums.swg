/* -----------------------------------------------------------------------------
 * enums.swg
 *
 * Include this file in order for C/C++ enums to be wrapped by proper C# enums.
 * Note that the PINVOKE layer handles the enum as an int.
 * ----------------------------------------------------------------------------- */

// const enum SWIGTYPE & typemaps
%typemap(ctype) const enum SWIGTYPE & "int"
%typemap(imtype) const enum SWIGTYPE & "int"
%typemap(ffitype) const enum SWIGTYPE & "ffi.Int"
%typemap(cstype) const enum SWIGTYPE & "$*csclassname"

%typemap(in) const enum SWIGTYPE & ($*1_ltype temp)
%{ temp = ($*1_ltype)$input; 
   $1 = &temp; %}
%typemap(out) const enum SWIGTYPE & %{ $result = (int)*$1; %}

%typemap(directorout,warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const enum SWIGTYPE &
%{ static $*1_ltype temp = ($*1_ltype)$input; 
   $result = &temp; %}
%typemap(directorin) const enum SWIGTYPE & "$input = (int)$1;"
%typemap(csdirectorin) const enum SWIGTYPE & "$*csclassname.values[$iminput]"
%typemap(csdirectorout) const enum SWIGTYPE & "$cscall.index"

%typecheck(SWIG_TYPECHECK_POINTER) const enum SWIGTYPE & ""

%typemap(throws, canthrow=1) const enum SWIGTYPE &
%{ (void)$1;
   SWIG_CSharpSetPendingException(SWIG_CSharpApplicationException, "C++ $1_type exception thrown");
   return $null; %}

%typemap(csin) const enum SWIGTYPE & "$csinput.index"
%typemap(csout, excode=SWIGEXCODE) const enum SWIGTYPE & {
    $*csclassname ret = $*csclassname.values[$imcall];$excode
    return ret;
  }

%typemap(csvarout, excode=SWIGEXCODE2) const enum SWIGTYPE & %{
    get {
      $*csclassname ret = $*csclassname.values[$imcall];$excode
      return ret;
    } %}


// enum SWIGTYPE typemaps
%typemap(ctype) enum SWIGTYPE "int"
%typemap(imtype) enum SWIGTYPE "int"
%typemap(ffitype) enum SWIGTYPE "ffi.Int"
%typemap(cstype) enum SWIGTYPE "$csclassname"

%typemap(in) enum SWIGTYPE %{ $1 = ($1_ltype)$input; %}
%typemap(out) enum SWIGTYPE %{ $result = (int)$1; %}

%typemap(directorout) enum SWIGTYPE  %{ $result = ($1_ltype)$input; %}
%typemap(directorin) enum SWIGTYPE "$input = (int)$1;"
%typemap(csdirectorin) enum SWIGTYPE "$csclassname.values[$iminput]"
%typemap(csdirectorout) enum SWIGTYPE "$cscall.index"

%typecheck(SWIG_TYPECHECK_POINTER) enum SWIGTYPE ""

%typemap(throws, canthrow=1) enum SWIGTYPE
%{ (void)$1;
   SWIG_CSharpSetPendingException(SWIG_CSharpApplicationException, "C++ $1_type exception thrown");
   return $null; %}

%typemap(csin) enum SWIGTYPE "$csinput.index"
%typemap(csout, excode=SWIGEXCODE) enum SWIGTYPE {
    $csclassname ret = $csclassname.values[$imcall];$excode
    return ret;
  }

%typemap(csvarout, excode=SWIGEXCODE2) enum SWIGTYPE %{
    $returntype get $varname {
      $csclassname ret = $csclassname.values[$imcall];$excode
      return ret;
    } %}

%typemap(csbase)           enum SWIGTYPE ""
%typemap(csclassmodifiers) enum SWIGTYPE "enum"
%typemap(cscode)           enum SWIGTYPE ""
%typemap(csimports)        enum SWIGTYPE ""
%typemap(csinterfaces)     enum SWIGTYPE ""

%typemap(csbody) enum SWIGTYPE ""

%csenum(proper);

