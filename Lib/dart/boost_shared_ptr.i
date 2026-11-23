/* -----------------------------------------------------------------------------
 * boost_shared_ptr.i
 *
 * Dart implementation of the shared_ptr support (%shared_ptr), used by std_shared_ptr.i
 * and boost_shared_ptr.i.
 *
 * The C++ side follows the C# module: the proxy of a class managed by a shared_ptr holds
 * a pointer to a heap allocated shared_ptr, not to the object, and deleting the proxy
 * deletes that shared_ptr.
 *
 * Each level of a class hierarchy holds its own shared_ptr: a derived proxy class passes a
 * new shared_ptr of its base class (SWIGSmartPtrUpcast) to the base class constructor, so
 * every level owns, finalizes and disposes of its own shared_ptr. The fields are named after
 * the class, as a field redeclared in a Dart subclass would override the base class one.
 *
 * Not supported: directors for a class managed by a shared_ptr.
 * ----------------------------------------------------------------------------- */

// Users can provide their own SWIG_SHARED_PTR_TYPEMAPS macro before including this file.
#ifndef SWIG_SHARED_PTR_TYPEMAPS
#define SWIG_SHARED_PTR_TYPEMAPS(CONST, TYPE...) SWIG_SHARED_PTR_TYPEMAPS_IMPLEMENTATION(CONST, TYPE)
#endif

%include <shared_ptr.i>

// Language specific macro implementing all the customisations for handling the smart pointer
%define SWIG_SHARED_PTR_TYPEMAPS_IMPLEMENTATION(CONST, TYPE...)

// %naturalvar is as documented for member variables
%naturalvar TYPE;
%naturalvar SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >;

// destructor mods
%feature("unref") TYPE "(void)arg1; delete smartarg1;"

// Typemap customisations...

// plain value
%typemap(in, canthrow=1) CONST TYPE ($&1_type argp = 0) %{
  argp = ((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input) ? ((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input)->get() : 0;
  if (!argp) {
    SWIG_DartSetPendingException(SWIG_DartArgumentNullError, "Attempt to dereference null $1_type");
    return $null;
  }
  $1 = *argp; %}
%typemap(out) CONST TYPE
%{ $result = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(new $1_ltype($1)); %}

%typemap(directorin) CONST TYPE
%{ $input = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > (new $1_ltype(SWIG_STD_MOVE($1))); %}

%typemap(directorout) CONST TYPE
%{ if (!$input) {
    SWIG_DartSetPendingException(SWIG_DartArgumentNullError, "Attempt to dereference null $1_type");
    return $null;
  }
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input;
  $result = *smartarg->get();
%}

// plain pointer
%typemap(in, canthrow=1) CONST TYPE * (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = 0) %{
  smartarg = (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input;
  $1 = (TYPE *)(smartarg ? smartarg->get() : 0); %}
%typemap(out, fragment="SWIG_null_deleter") CONST TYPE * %{
  $result = $1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_$owner) : 0;
%}

%typemap(directorin) CONST TYPE *
%{ $input = $1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_0) : 0; %}

%typemap(directorout) CONST TYPE * %{
#error "typemaps for $1_type not available"
%}

// plain reference
%typemap(in, canthrow=1) CONST TYPE & %{
  $1 = ($1_ltype)(((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input) ? ((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input)->get() : 0);
  if (!$1) {
    SWIG_DartSetPendingException(SWIG_DartArgumentNullError, "$1_type reference is null");
    return $null;
  } %}
%typemap(out, fragment="SWIG_null_deleter") CONST TYPE &
%{ $result = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_$owner); %}

%typemap(directorin) CONST TYPE &
%{ $input = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > (&$1 SWIG_NO_NULL_DELETER_0); %}

%typemap(directorout) CONST TYPE & %{
#error "typemaps for $1_type not available"
%}

// plain pointer by reference
%typemap(in) TYPE *CONST& ($*1_ltype temp = 0)
%{ temp = (TYPE *)(((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input) ? ((SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input)->get() : 0);
   $1 = &temp; %}
%typemap(out, fragment="SWIG_null_deleter") TYPE *CONST&
%{ $result = new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1 SWIG_NO_NULL_DELETER_$owner); %}

%typemap(directorin) TYPE *CONST&
%{ $input = $1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1 SWIG_NO_NULL_DELETER_0) : 0; %}

%typemap(directorout) TYPE *CONST& %{
#error "typemaps for $1_type not available"
%}

// shared_ptr by value
%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >
%{ if ($input) $1 = *($&1_ltype)$input; %}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >
%{ $result = $1 ? new $1_ltype($1) : 0; %}

%typemap(directorin) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >
%{ $input = $1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1) : 0; %}

%typemap(directorout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >
%{ if ($input) {
    SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *smartarg = (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *)$input;
    $result = *smartarg;
  }
%}

// shared_ptr by reference
%typemap(in, canthrow=1) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & ($*1_ltype tempnull)
%{ $1 = $input ? ($1_ltype)$input : &tempnull; %}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &
%{ $result = *$1 ? new $*1_ltype(*$1) : 0; %}

%typemap(directorin) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &
%{ $input = $1 ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >($1) : 0; %}

%typemap(directorout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > & %{
#error "typemaps for $1_type not available"
%}

// shared_ptr by pointer
%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * ($*1_ltype tempnull)
%{ $1 = $input ? ($1_ltype)$input : &tempnull; %}
%typemap(out, fragment="SWIG_null_deleter") SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *
%{ $result = ($1 && *$1) ? new $*1_ltype(*$1) : 0;
   if ($owner) delete $1; %}

%typemap(directorin) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *
%{ $input = ($1 && *$1) ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1) : 0; %}

%typemap(directorout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > * %{
#error "typemaps for $1_type not available"
%}

// shared_ptr by pointer reference
%typemap(in) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& (SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > tempnull, $*1_ltype temp = 0)
%{ temp = $input ? *($1_ltype)&$input : &tempnull;
   $1 = &temp; %}
%typemap(out) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *&
%{ *($1_ltype)&$result = (*$1 && **$1) ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(**$1) : 0; %}

%typemap(directorin) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *&
%{ $input = ($1 && *$1) ? new SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >(*$1) : 0; %}

%typemap(directorout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& %{
#error "typemaps for $1_type not available"
%}

// various missing typemaps - If ever used (unlikely) ensure compilation error rather than runtime bug
%typemap(in) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}
%typemap(out) CONST TYPE[], CONST TYPE[ANY], CONST TYPE (CLASS::*) %{
#error "typemaps for $1_type not available"
%}


// Every form of the shared_ptr is passed as a pointer to a shared_ptr
%typemap(ctype) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "void *"
%typemap(ffitype) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "ffi.Pointer<ffi.Void>"
%typemap(imtype) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                 SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                 SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                 SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "ffi.Pointer<ffi.Void>"
// A shared_ptr can be empty: null in Dart
%typemap(darttype) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                   SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                   SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                   SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "$typemap(darttype, TYPE)?"

%typemap(dartin) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                 SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                 SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                 SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& "$typemap(darttype, TYPE).swigGetCPtr($dartinput)"

%typemap(dartout, excode=SWIGEXCODE) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                                     SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                                     SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                                     SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *& {
    final ffi.Pointer<ffi.Void> cPtr = $imcall;$excode
    return (cPtr == ffi.nullptr) ? null : $typemap(darttype, TYPE).swigFromPtr(cPtr, true);
  }

// The out typemaps above return a new shared_ptr for the plain value, pointer and reference too:
// the proxy always owns it
%typemap(dartout, excode=SWIGEXCODE) CONST TYPE, CONST TYPE & {
    final ffi.Pointer<ffi.Void> cPtr = $imcall;$excode
    return $typemap(darttype, TYPE).swigFromPtr(cPtr, true);
  }
%typemap(dartout, excode=SWIGEXCODE) CONST TYPE *, TYPE *CONST& {
    final ffi.Pointer<ffi.Void> cPtr = $imcall;$excode
    return (cPtr == ffi.nullptr) ? null : $typemap(darttype, TYPE).swigFromPtr(cPtr, true);
  }

%typemap(dartdirectorin) CONST TYPE,
                         CONST TYPE &,
                         SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
                         SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
                         SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
                         SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *&,
                         CONST TYPE *,
                         TYPE *CONST& "(($iminput == ffi.nullptr) ? null : $typemap(darttype, TYPE).swigFromPtr($iminput, true))"

%typemap(dartdirectorout) SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > "$typemap(darttype, TYPE).swigGetCPtr($dartcall)"

// Proxy classes (base classes, ie, not derived classes)
%typemap(dartbody) TYPE %{
  ffi.Pointer<ffi.Void> _swigCPtr_$dartclassname;
  bool swigCMemOwn_$dartclassname;
  static final ffi.NativeFinalizer? _swigFinalizer = $finalizer;

  $dartclassname.swigFromPtr(ffi.Pointer<ffi.Void> cPtr, bool cMemoryOwn) : _swigCPtr_$dartclassname = cPtr, swigCMemOwn_$dartclassname = cMemoryOwn {
    if (cMemoryOwn) {
      _swigFinalizer?.attach(this, cPtr, detach: this);
    }$directorconnect
  }

  // Used by the derived classes: cPtr is a new shared_ptr of this class, owned by this level
  $dartclassname.swigDerived(ffi.Pointer<ffi.Void> cPtr, bool cMemoryOwn) : _swigCPtr_$dartclassname = cPtr, swigCMemOwn_$dartclassname = cMemoryOwn {
    if (cMemoryOwn) {
      _swigFinalizer?.attach(this, cPtr, detach: this);
    }
  }

  static ffi.Pointer<ffi.Void> swigGetCPtr($dartclassname? obj) {
    return (obj == null) ? ffi.nullptr : obj._swigCPtr_$dartclassname;
  }

  static ffi.Pointer<ffi.Void> swigRelease($dartclassname? obj) {
    throw UnsupportedError('Cannot release the ownership of an object managed by a shared_ptr');
  }
%}

// Derived proxy classes
%typemap(dartbody_derived) TYPE %{
  ffi.Pointer<ffi.Void> _swigCPtr_$dartclassname;
  bool swigCMemOwn_$dartclassname;
  static final ffi.NativeFinalizer? _swigFinalizer = $finalizer;

  $dartclassname.swigFromPtr(ffi.Pointer<ffi.Void> cPtr, bool cMemoryOwn) : _swigCPtr_$dartclassname = cPtr, swigCMemOwn_$dartclassname = cMemoryOwn, super.swigDerived($imclassname().$dartclazznameSWIGSmartPtrUpcast(cPtr), true) {
    if (cMemoryOwn) {
      _swigFinalizer?.attach(this, cPtr, detach: this);
    }$directorconnect
  }

  $dartclassname.swigDerived(ffi.Pointer<ffi.Void> cPtr, bool cMemoryOwn) : _swigCPtr_$dartclassname = cPtr, swigCMemOwn_$dartclassname = cMemoryOwn, super.swigDerived($imclassname().$dartclazznameSWIGSmartPtrUpcast(cPtr), true) {
    if (cMemoryOwn) {
      _swigFinalizer?.attach(this, cPtr, detach: this);
    }
  }

  static ffi.Pointer<ffi.Void> swigGetCPtr($dartclassname? obj) {
    return (obj == null) ? ffi.nullptr : obj._swigCPtr_$dartclassname;
  }

  static ffi.Pointer<ffi.Void> swigRelease($dartclassname? obj) {
    throw UnsupportedError('Cannot release the ownership of an object managed by a shared_ptr');
  }
%}

// Each level deletes its own shared_ptr
%typemap(dartdispose) TYPE %{
  void dispose() {
    _swigFinalizer?.detach(this);
    if (swigCMemOwn_$dartclassname) {
      swigCMemOwn_$dartclassname = false;$directordispose
      $imcall;
    }
    _swigCPtr_$dartclassname = ffi.nullptr;
  }
%}

%typemap(dartdispose_derived) TYPE %{
  void dispose() {
    _swigFinalizer?.detach(this);
    if (swigCMemOwn_$dartclassname) {
      swigCMemOwn_$dartclassname = false;$directordispose
      $imcall;
    }
    _swigCPtr_$dartclassname = ffi.nullptr;
    super.dispose();
  }
%}

// Typecheck typemaps
%typemap(typecheck, precedence=SWIG_TYPECHECK_POINTER, equivalent="TYPE *")
  TYPE CONST,
  TYPE CONST &,
  TYPE CONST *,
  TYPE *CONST&,
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >,
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > &,
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *,
  SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE > *&
  ""

%template() SWIG_SHARED_PTR_QNAMESPACE::shared_ptr< CONST TYPE >;
%enddef
