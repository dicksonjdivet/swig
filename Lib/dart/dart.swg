/* -----------------------------------------------------------------------------
 * dart.swg
 *
 * Dart typemaps
 * ----------------------------------------------------------------------------- */

%include <darthead.swg>

/* The ctype, ffitype, imtype and darttype typemaps work together and so there should be one of each.
 * The ctype typemap contains the C type used in the exported C/C++ wrapper functions.
 * The ffitype typemap contains the dart:ffi native type used to describe the C type to Dart, eg ffi.Int for int.
 * The imtype typemap contains the Dart type corresponding to the ffitype used in the intermediary (FFI) class.
 * The darttype typemap contains the Dart type used in the Dart proxy classes, type wrapper classes and module class.
 * The dartin and dartout typemaps convert between the imtype and the darttype. */

/* Fragments */
%fragment("SWIG_PackData", "header") {
/* Pack binary data into a string */
SWIGINTERN char * SWIG_PackData(char *c, void *ptr, size_t sz) {
  static const char hex[17] = "0123456789abcdef";
  const unsigned char *u = (unsigned char *) ptr;
  const unsigned char *eu =  u + sz;
  for (; u != eu; ++u) {
    unsigned char uu = *u;
    *(c++) = hex[(uu & 0xf0) >> 4];
    *(c++) = hex[uu & 0xf];
  }
  return c;
}
}

%fragment("SWIG_UnPackData", "header") {
/* Unpack binary data from a string */
SWIGINTERN const char * SWIG_UnpackData(const char *c, void *ptr, size_t sz) {
  unsigned char *u = (unsigned char *) ptr;
  const unsigned char *eu = u + sz;
  for (; u != eu; ++u) {
    char d = *(c++);
    unsigned char uu;
    if ((d >= '0') && (d <= '9'))
      uu = ((d - '0') << 4);
    else if ((d >= 'a') && (d <= 'f'))
      uu = ((d - ('a'-10)) << 4);
    else
      return (char *) 0;
    d = *(c++);
    if ((d >= '0') && (d <= '9'))
      uu |= (d - '0');
    else if ((d >= 'a') && (d <= 'f'))
      uu |= (d - ('a'-10));
    else
      return (char *) 0;
    *u = uu;
  }
  return c;
}
}

/* The $excode special variable is replaced by the excode typemap attribute code if the
 * method can throw any exceptions from the C/C++ code, otherwise replaced by nothing. */
%define SWIGEXCODE "\n    if ($imclassname.swigPendingException) throw $imclassname.swigTakePendingException();" %enddef

/* Primitive types */

%define %dart_primitive(TYPE, CTYPE, FFITYPE, DARTTYPE)
%typemap(ctype) TYPE, const TYPE & "CTYPE"
%typemap(ffitype) TYPE, const TYPE & "FFITYPE"
%typemap(imtype) TYPE, const TYPE & "DARTTYPE"
%typemap(darttype) TYPE, const TYPE & "DARTTYPE"

%typemap(in) TYPE %{ $1 = ($1_ltype)$input; %}
%typemap(in) const TYPE & ($*1_ltype temp) %{ temp = ($*1_ltype)$input;
   $1 = &temp; %}
%typemap(out) TYPE %{ $result = (CTYPE)$1; %}
%typemap(out) const TYPE & %{ $result = (CTYPE)*$1; %}

%typemap(directorin) TYPE, const TYPE & "$input = (CTYPE)$1;"
%typemap(directorout) TYPE %{ $result = ($1_ltype)$input; %}
%typemap(directorout, warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const TYPE &
%{ static $*1_ltype temp;
   temp = ($*1_ltype)$input;
   $result = &temp; %}

%typemap(dartin) TYPE, const TYPE & "$dartinput"
%typemap(dartout, excode=SWIGEXCODE) TYPE, const TYPE & {
    final DARTTYPE ret = $imcall;$excode
    return ret;
  }
%typemap(dartdirectorin) TYPE, const TYPE & "$iminput"
%typemap(dartdirectorout) TYPE, const TYPE & "$dartcall"
%enddef

%dart_primitive(signed char,        signed char,        ffi.SignedChar,       int)
%dart_primitive(unsigned char,      unsigned char,      ffi.UnsignedChar,     int)
%dart_primitive(short,              short,              ffi.Short,            int)
%dart_primitive(unsigned short,     unsigned short,     ffi.UnsignedShort,    int)
%dart_primitive(int,                int,                ffi.Int,              int)
%dart_primitive(unsigned int,       unsigned int,       ffi.UnsignedInt,      int)
%dart_primitive(long,               long,               ffi.Long,             int)
%dart_primitive(unsigned long,      unsigned long,      ffi.UnsignedLong,     int)
%dart_primitive(long long,          long long,          ffi.LongLong,         int)
%dart_primitive(unsigned long long, unsigned long long, ffi.UnsignedLongLong, int)
%dart_primitive(size_t,             size_t,             ffi.Size,             int)
%dart_primitive(float,              float,              ffi.Float,            double)
%dart_primitive(double,             double,             ffi.Double,           double)

/* bool is passed as an int as a C bool is not available in all C compilers */
%typemap(ctype) bool, const bool & "int"
%typemap(ffitype) bool, const bool & "ffi.Int"
%typemap(imtype) bool, const bool & "int"
%typemap(darttype) bool, const bool & "bool"
%typemap(in) bool %{ $1 = $input ? true : false; %}
%typemap(in) const bool & ($*1_ltype temp) %{ temp = $input ? true : false;
   $1 = &temp; %}
%typemap(out) bool %{ $result = $1 ? 1 : 0; %}
%typemap(out) const bool & %{ $result = *$1 ? 1 : 0; %}
%typemap(directorin) bool, const bool & "$input = $1 ? 1 : 0;"
%typemap(directorout) bool %{ $result = $input ? true : false; %}
%typemap(directorout, warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const bool &
%{ static $*1_ltype temp;
   temp = $input ? true : false;
   $result = &temp; %}
%typemap(dartin) bool, const bool & "($dartinput ? 1 : 0)"
%typemap(dartout, excode=SWIGEXCODE) bool, const bool & {
    final bool ret = $imcall != 0;$excode
    return ret;
  }
%typemap(dartdirectorin) bool, const bool & "($iminput != 0)"
%typemap(dartdirectorout) bool, const bool & "($dartcall ? 1 : 0)"

/* char is a single character Dart String */
%typemap(ctype) char, const char & "char"
%typemap(ffitype) char, const char & "ffi.Char"
%typemap(imtype) char, const char & "int"
%typemap(darttype) char, const char & "String"
%typemap(in) char %{ $1 = ($1_ltype)$input; %}
%typemap(in) const char & ($*1_ltype temp) %{ temp = ($*1_ltype)$input;
   $1 = &temp; %}
%typemap(out) char %{ $result = $1; %}
%typemap(out) const char & %{ $result = *$1; %}
%typemap(directorin) char, const char & "$input = $1;"
%typemap(directorout) char %{ $result = ($1_ltype)$input; %}
%typemap(directorout, warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) const char &
%{ static $*1_ltype temp;
   temp = ($*1_ltype)$input;
   $result = &temp; %}
%typemap(dartin) char, const char & "($dartinput.isEmpty ? 0 : $dartinput.codeUnitAt(0))"
%typemap(dartout, excode=SWIGEXCODE) char, const char & {
    final String ret = String.fromCharCode($imcall & 0xff);$excode
    return ret;
  }
%typemap(dartdirectorin) char, const char & "String.fromCharCode($iminput & 0xff)"
%typemap(dartdirectorout) char, const char & "$dartcall.codeUnitAt(0)"

/* void */
%typemap(ctype) void "void"
%typemap(ffitype) void "ffi.Void"
%typemap(imtype) void "void"
%typemap(darttype) void "void"
%typemap(out, null="") void ""
%typemap(directorin) void ""
%typemap(dartout, excode=SWIGEXCODE) void {
    $imcall;$excode
  }
%typemap(dartdirectorin) void "$iminput"
%typemap(dartdirectorout) void "$dartcall"

/* C strings, these are converted to and from UTF-8. Returned strings are copied as the Dart
 * code cannot know how long the C string remains valid. NULL maps to a Dart null. */
%typemap(ctype) char *, char *&, char[ANY], char[] "char *"
%typemap(ffitype) char *, char *&, char[ANY], char[] "ffi.Pointer<ffi.Uint8>"
%typemap(imtype) char *, char *&, char[ANY], char[] "ffi.Pointer<ffi.Uint8>"
%typemap(darttype) char *, char *&, char[ANY], char[] "String?"

%typemap(in) char *, char[ANY], char[] %{ $1 = ($1_ltype)$input; %}
%typemap(in) char *& ($*1_ltype temp = 0) %{ temp = ($*1_ltype)$input;
   $1 = &temp; %}
%typemap(out) char *, char[ANY], char[] %{ $result = SWIG_DartStrdup((const char *)$1); %}
%typemap(out) char *& %{ $result = SWIG_DartStrdup((const char *)*$1); %}
%typemap(directorin) char *, char[ANY], char[] %{ $input = SWIG_DartStrdup((const char *)$1); %}
%typemap(directorout, warning=SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) char *, char[ANY], char[] %{ $result = ($1_ltype)$input; %}

%typemap(dartin, pre="    final ffi.Pointer<ffi.Uint8> swig_$dartinput = $imclassname.swigToNativeString($dartinput);",
         post="      $imclassname.swigFree(swig_$dartinput);") char *, char *&, char[ANY], char[] "swig_$dartinput"
%typemap(dartout, excode=SWIGEXCODE) char *, char *&, char[ANY], char[] {
    final ffi.Pointer<ffi.Uint8> cString = $imcall;$excode
    return $imclassname.swigFromNativeStringAndFree(cString);
  }
%typemap(dartdirectorin) char *, char[ANY], char[] "$imclassname.swigFromNativeStringAndFree($iminput)"
%typemap(dartdirectorout) char *, char[ANY], char[] "$imclassname.swigToNativeString($dartcall)"

/* Non primitive types, a pointer to the C/C++ object is passed */
%typemap(ctype) SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE *const& "void *"
%typemap(ffitype) SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE *const& "ffi.Pointer<ffi.Void>"
%typemap(imtype) SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE *const& "ffi.Pointer<ffi.Void>"
%typemap(darttype) SWIGTYPE "$&dartclassname"
%typemap(darttype) SWIGTYPE *, SWIGTYPE [] "$dartclassname?"
%typemap(darttype) SWIGTYPE &, SWIGTYPE && "$dartclassname"
%typemap(darttype) SWIGTYPE *const& "$*dartclassname?"

/* Pointer to a class member, passed as a string */
%typemap(ctype) SWIGTYPE (CLASS::*) "char *"
%typemap(ffitype) SWIGTYPE (CLASS::*) "ffi.Pointer<ffi.Uint8>"
%typemap(imtype) SWIGTYPE (CLASS::*) "ffi.Pointer<ffi.Uint8>"
%typemap(darttype) SWIGTYPE (CLASS::*) "$dartclassname?"

/* Object passed by value. Convert to a pointer */
%typemap(in, canthrow=1) SWIGTYPE ($&1_type argp)
%{ argp = ($&1_ltype)$input;
   if (!argp) {
     SWIG_DartSetPendingException(SWIG_DartArgumentNullError, "Attempt to dereference null $1_type");
     return $null;
   }
   $1 = *argp; %}

%typemap(out) SWIGTYPE
#ifdef __cplusplus
%{ $result = new $1_ltype($1); %}
#else
{
  $&1_ltype $1ptr = ($&1_ltype) malloc(sizeof($1_ltype));
  memmove($1ptr, &$1, sizeof($1_type));
  $result = $1ptr;
}
#endif

%typemap(directorin) SWIGTYPE
%{ $input = (void *)new $1_ltype(SWIG_STD_MOVE($1)); %}
%typemap(directorout, canthrow=1) SWIGTYPE
%{ if (!$input) {
     SWIG_DartSetPendingException(SWIG_DartArgumentNullError, "Unexpected null return for type $1_type");
     return $null;
   }
   $result = *($&1_ltype)$input; %}

/* Generic pointers and references */
%typemap(in) SWIGTYPE *, SWIGTYPE [] %{ $1 = ($1_ltype)$input; %}
%typemap(in, canthrow=1) SWIGTYPE & %{ $1 = ($1_ltype)$input;
  if (!$1) {
    SWIG_DartSetPendingException(SWIG_DartArgumentNullError, "$1_type is null");
    return $null;
  } %}
%typemap(in, canthrow=1, fragment="<memory>") SWIGTYPE && (std::unique_ptr<$*1_ltype> rvrdeleter) %{ $1 = ($1_ltype)$input;
  if (!$1) {
    SWIG_DartSetPendingException(SWIG_DartArgumentNullError, "$1_type is null");
    return $null;
  }
  rvrdeleter.reset($1); %}
%typemap(in) SWIGTYPE *const& ($*1_ltype temp = 0)
%{ temp = ($*1_ltype)$input;
   $1 = ($1_ltype)&temp; %}
%typemap(in, fragment="SWIG_UnPackData") SWIGTYPE (CLASS::*) %{
  SWIG_UnpackData($input, (void *)&$1, sizeof($1));
%}

%typemap(out) SWIGTYPE *, SWIGTYPE &, SWIGTYPE && %{ $result = (void *)$1; %}
%typemap(out) SWIGTYPE [] %{ $result = (void *)$1; %}
%typemap(out) SWIGTYPE *const& %{ $result = (void *)*$1; %}
%typemap(out, fragment="SWIG_PackData") SWIGTYPE (CLASS::*) %{
  char buf[128];
  char *data = SWIG_PackData(buf, (void *)&$1, sizeof($1));
  *data = '\0';
  $result = SWIG_DartStrdup(buf);
%}

%typemap(directorin) SWIGTYPE *, SWIGTYPE (CLASS::*) %{ $input = (void *) $1; %}
%typemap(directorin) SWIGTYPE *const& %{ $input = (void *) $1; %}
%typemap(directorin) SWIGTYPE &, SWIGTYPE && %{ $input = ($1_ltype) &$1; %}
%typemap(directorout, warning=SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) SWIGTYPE *, SWIGTYPE (CLASS::*) %{ $result = ($1_ltype)$input; %}
%typemap(directorout, warning=SWIGWARN_TYPEMAP_THREAD_UNSAFE_MSG) SWIGTYPE *const&
%{ static $*1_ltype swig_temp;
   swig_temp = ($*1_ltype)$input;
   $result = &swig_temp; %}
%typemap(directorout, canthrow=1, warning=SWIGWARN_TYPEMAP_DIRECTOROUT_PTR_MSG) SWIGTYPE &, SWIGTYPE &&
%{ if (!$input) {
     SWIG_DartSetPendingException(SWIG_DartArgumentNullError, "Unexpected null return for type $1_type");
     return $null;
   }
   $result = ($1_ltype)$input; %}

%typemap(dartin) SWIGTYPE "$&dartclassname.swigGetCPtr($dartinput)"
%typemap(dartin) SWIGTYPE *, SWIGTYPE &, SWIGTYPE [] "$dartclassname.swigGetCPtr($dartinput)"
%typemap(dartin) SWIGTYPE && "$dartclassname.swigRelease($dartinput)"
%typemap(dartin) SWIGTYPE *const& "$*dartclassname.swigGetCPtr($dartinput)"
%typemap(dartin, pre="    final ffi.Pointer<ffi.Uint8> swig_$dartinput = $imclassname.swigToNativeString($dartclassname.swigGetCMemberPtr($dartinput));",
         post="      $imclassname.swigFree(swig_$dartinput);") SWIGTYPE (CLASS::*) "swig_$dartinput"

%typemap(dartout, excode=SWIGEXCODE) SWIGTYPE {
    final ffi.Pointer<ffi.Void> cPtr = $imcall;$excode
    return $&dartclassname.swigFromPtr(cPtr, true);
  }
%typemap(dartout, excode=SWIGEXCODE) SWIGTYPE &, SWIGTYPE && {
    final ffi.Pointer<ffi.Void> cPtr = $imcall;$excode
    return $dartclassname.swigFromPtr(cPtr, $owner);
  }
%typemap(dartout, excode=SWIGEXCODE) SWIGTYPE *, SWIGTYPE [] {
    final ffi.Pointer<ffi.Void> cPtr = $imcall;$excode
    return (cPtr == ffi.nullptr) ? null : $dartclassname.swigFromPtr(cPtr, $owner);
  }
%typemap(dartout, excode=SWIGEXCODE) SWIGTYPE *const& {
    final ffi.Pointer<ffi.Void> cPtr = $imcall;$excode
    return (cPtr == ffi.nullptr) ? null : $*dartclassname.swigFromPtr(cPtr, $owner);
  }
%typemap(dartout, excode=SWIGEXCODE) SWIGTYPE (CLASS::*) {
    final String? cMemberPtr = $imclassname.swigFromNativeStringAndFree($imcall);$excode
    return (cMemberPtr == null) ? null : $dartclassname.swigFromCMemberPtr(cMemberPtr, $owner);
  }

%typemap(dartdirectorin) SWIGTYPE "$&dartclassname.swigFromPtr($iminput, true)"
%typemap(dartdirectorin) SWIGTYPE *, SWIGTYPE (CLASS::*) "(($iminput == ffi.nullptr) ? null : $dartclassname.swigFromPtr($iminput, false))"
%typemap(dartdirectorin) SWIGTYPE &, SWIGTYPE && "$dartclassname.swigFromPtr($iminput, false)"
%typemap(dartdirectorin) SWIGTYPE *const& "(($iminput == ffi.nullptr) ? null : $*dartclassname.swigFromPtr($iminput, false))"
%typemap(dartdirectorout) SWIGTYPE "$&dartclassname.swigGetCPtr($dartcall)"
%typemap(dartdirectorout) SWIGTYPE *, SWIGTYPE (CLASS::*), SWIGTYPE &, SWIGTYPE && "$dartclassname.swigGetCPtr($dartcall)"
%typemap(dartdirectorout) SWIGTYPE *const& "$*dartclassname.swigGetCPtr($dartcall)"

/* Typecheck typemaps - The purpose of these is merely to issue a warning for overloaded C++ functions
 * that cannot be overloaded in Dart as more than one C++ type maps to a single Dart type */

%typecheck(SWIG_TYPECHECK_BOOL) bool, const bool & ""
%typecheck(SWIG_TYPECHECK_CHAR) char, const char & ""
%typecheck(SWIG_TYPECHECK_INT8) signed char, const signed char & ""
%typecheck(SWIG_TYPECHECK_UINT8) unsigned char, const unsigned char & ""
%typecheck(SWIG_TYPECHECK_INT16) short, const short & ""
%typecheck(SWIG_TYPECHECK_UINT16) unsigned short, const unsigned short & ""
%typecheck(SWIG_TYPECHECK_INT32) int, long, const int &, const long & ""
%typecheck(SWIG_TYPECHECK_UINT32) unsigned int, unsigned long, const unsigned int &, const unsigned long & ""
%typecheck(SWIG_TYPECHECK_INT64) long long, const long long & ""
%typecheck(SWIG_TYPECHECK_UINT64) unsigned long long, const unsigned long long & ""
%typecheck(SWIG_TYPECHECK_SIZE) size_t, const size_t & ""
%typecheck(SWIG_TYPECHECK_FLOAT) float, const float & ""
%typecheck(SWIG_TYPECHECK_DOUBLE) double, const double & ""
%typecheck(SWIG_TYPECHECK_STRING) char *, char *&, char[ANY], char[] ""
%typecheck(SWIG_TYPECHECK_POINTER) SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE *const&, SWIGTYPE [], SWIGTYPE (CLASS::*) ""

/* Exception handling */

%typemap(throws, canthrow=1) int,
                 long,
                 short,
                 unsigned int,
                 unsigned long,
                 unsigned short
%{ char error_msg[256];
   SWIG_snprintf(error_msg, sizeof(error_msg), "C++ $1_type exception thrown, value: %d", (int)$1);
   SWIG_DartSetPendingException(SWIG_DartException, error_msg);
   return $null; %}

%typemap(throws, canthrow=1) SWIGTYPE, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE *, SWIGTYPE [ANY]
%{ (void)$1;
   SWIG_DartSetPendingException(SWIG_DartException, "C++ $1_type exception thrown");
   return $null; %}

%typemap(throws, canthrow=1) char *
%{ SWIG_DartSetPendingException(SWIG_DartException, $1);
   return $null; %}

/* Typemaps used for the generation of proxy and type wrapper class code */
%typemap(dartbase)                    SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(dartclassmodifiers)          SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE (CLASS::*) "class"
%typemap(dartcode)                    SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(dartimports)                 SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(dartinterfaces)              SWIGTYPE "ffi.Finalizable"
%typemap(dartinterfaces)              SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE (CLASS::*) ""
%typemap(dartinterfaces_derived)      SWIGTYPE, SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [], SWIGTYPE (CLASS::*) ""

/* dartbody typemaps for the proxy classes.
 * Each proxy class stores the pointer to its C++ class type in its own field as a derived C++ class
 * pointer is not necessarily the same address as its base class pointer.
 * swigFromPtr is the constructor used to wrap an existing C/C++ pointer, which takes ownership
 * of the C++ object if cMemoryOwn is true. swigDerived is used by derived classes so that only the
 * most derived class attaches a finalizer and deletes the C++ object. */

// Proxy classes (base classes, ie, not derived classes)
%typemap(dartbody) SWIGTYPE %{
  ffi.Pointer<ffi.Void> _swigCPtr_$dartclassname;
  bool swigCMemOwn;
  static final ffi.NativeFinalizer? _swigFinalizer = $finalizer;

  $dartclassname.swigFromPtr(ffi.Pointer<ffi.Void> cPtr, bool cMemoryOwn) : _swigCPtr_$dartclassname = cPtr, swigCMemOwn = cMemoryOwn {
    if (cMemoryOwn) {
      _swigFinalizer?.attach(this, cPtr, detach: this);
    }$directorconnect
  }

  $dartclassname.swigDerived(ffi.Pointer<ffi.Void> cPtr, bool cMemoryOwn) : _swigCPtr_$dartclassname = cPtr, swigCMemOwn = cMemoryOwn;

  static ffi.Pointer<ffi.Void> swigGetCPtr($dartclassname? obj) {
    return (obj == null) ? ffi.nullptr : obj._swigCPtr_$dartclassname;
  }

  static ffi.Pointer<ffi.Void> swigRelease($dartclassname? obj) {
    if (obj == null) {
      return ffi.nullptr;
    }
    if (!obj.swigCMemOwn) {
      throw StateError('Cannot release ownership as memory is not owned');
    }
    final ffi.Pointer<ffi.Void> ptr = obj._swigCPtr_$dartclassname;
    obj.swigCMemOwn = false;
    obj.dispose();
    return ptr;
  }
%}

// Derived proxy classes
%typemap(dartbody_derived) SWIGTYPE %{
  ffi.Pointer<ffi.Void> _swigCPtr_$dartclassname;
  static final ffi.NativeFinalizer? _swigFinalizer = $finalizer;

  $dartclassname.swigFromPtr(ffi.Pointer<ffi.Void> cPtr, bool cMemoryOwn) : _swigCPtr_$dartclassname = cPtr, super.swigDerived($imclassname().$dartclazznameSWIGUpcast(cPtr), cMemoryOwn) {
    if (cMemoryOwn) {
      _swigFinalizer?.attach(this, cPtr, detach: this);
    }$directorconnect
  }

  $dartclassname.swigDerived(ffi.Pointer<ffi.Void> cPtr, bool cMemoryOwn) : _swigCPtr_$dartclassname = cPtr, super.swigDerived($imclassname().$dartclazznameSWIGUpcast(cPtr), cMemoryOwn);

  static ffi.Pointer<ffi.Void> swigGetCPtr($dartclassname? obj) {
    return (obj == null) ? ffi.nullptr : obj._swigCPtr_$dartclassname;
  }

  static ffi.Pointer<ffi.Void> swigRelease($dartclassname? obj) {
    if (obj == null) {
      return ffi.nullptr;
    }
    if (!obj.swigCMemOwn) {
      throw StateError('Cannot release ownership as memory is not owned');
    }
    final ffi.Pointer<ffi.Void> ptr = obj._swigCPtr_$dartclassname;
    obj.swigCMemOwn = false;
    obj.dispose();
    return ptr;
  }
%}

// Type wrapper classes
%typemap(dartbody) SWIGTYPE *, SWIGTYPE &, SWIGTYPE &&, SWIGTYPE [] %{
  final ffi.Pointer<ffi.Void> _swigCPtr;

  $dartclassname.swigFromPtr(ffi.Pointer<ffi.Void> cPtr, bool futureUse) : _swigCPtr = cPtr;

  static ffi.Pointer<ffi.Void> swigGetCPtr($dartclassname? obj) {
    return (obj == null) ? ffi.nullptr : obj._swigCPtr;
  }

  static ffi.Pointer<ffi.Void> swigRelease($dartclassname? obj) {
    return (obj == null) ? ffi.nullptr : obj._swigCPtr;
  }
%}

// Type wrapper classes for pointers to class members
%typemap(dartbody) SWIGTYPE (CLASS::*) %{
  final String _swigCMemberPtr;

  $dartclassname.swigFromCMemberPtr(String cMemberPtr, bool futureUse) : _swigCMemberPtr = cMemberPtr;

  static String? swigGetCMemberPtr($dartclassname? obj) {
    return obj?._swigCMemberPtr;
  }
%}

/* The dispose method deletes the C++ object if it is owned. $imcall is replaced by the C++ destructor call */
%typemap(dartdispose) SWIGTYPE %{
  void dispose() {
    if (swigCMemOwn) {
      swigCMemOwn = false;
      _swigFinalizer?.detach(this);
      $imcall;
    }
    _swigCPtr_$dartclassname = ffi.nullptr;
  }
%}

%typemap(dartdispose_derived) SWIGTYPE %{
  void dispose() {
    if (swigCMemOwn) {
      swigCMemOwn = false;
      _swigFinalizer?.detach(this);
      $imcall;
    }
    _swigCPtr_$dartclassname = ffi.nullptr;
    super.dispose();
  }
%}

/* Constructors call the swigFromPtr constructor with the pointer to the newly created C++ object */
%typemap(dartconstruct) SWIGTYPE "this.swigFromPtr($imcall, true)"

/* Dart specific directives */
#define %dartconst(flag)            %feature("dart:const","flag")
#define %dartconstvalue(value)      %feature("dart:constvalue",value)
#define %dartenum(wrapapproach)     %feature("dart:enum","wrapapproach")
#define %dartmethodmodifiers        %feature("dart:methodmodifiers")
#define %dartnothrowexception       %feature("except")
#define %proxycode                  %insert("proxycode")

%pragma(dart) imclassclassmodifiers="final class"
%pragma(dart) moduleclassmodifiers="abstract final class"

/* Array reference typemaps */
%apply SWIGTYPE & { SWIGTYPE ((&)[ANY]) }
%apply SWIGTYPE && { SWIGTYPE ((&&)[ANY]) }

/* const pointers */
%apply SWIGTYPE * { SWIGTYPE *const }
%apply SWIGTYPE (CLASS::*) { SWIGTYPE (CLASS::*const) }
%apply SWIGTYPE & { SWIGTYPE (CLASS::*const&) }

/* String & length */
%typemap(ctype)    (char *STRING, size_t LENGTH) "char *"
%typemap(ffitype)  (char *STRING, size_t LENGTH) "ffi.Pointer<ffi.Uint8>"
%typemap(imtype)   (char *STRING, size_t LENGTH) "ffi.Pointer<ffi.Uint8>"
%typemap(darttype) (char *STRING, size_t LENGTH) "String?"
%typemap(in)       (char *STRING, size_t LENGTH) %{ $1 = ($1_ltype)$input;
  $2 = $1 ? ($2_ltype)strlen((const char *)$1) : 0; %}
%typemap(dartin, pre="    final ffi.Pointer<ffi.Uint8> swig_$dartinput = $imclassname.swigToNativeString($dartinput);",
         post="      $imclassname.swigFree(swig_$dartinput);") (char *STRING, size_t LENGTH) "swig_$dartinput"
%apply (char *STRING, size_t LENGTH) { (char *STRING, int LENGTH) }

%include <dartkw.swg>
%include <enums.swg>
