/* -----------------------------------------------------------------------------
 * swigmove.i
 *
 * Input typemaps library for implementing full move semantics when passing
 * parameters by value.
 * ----------------------------------------------------------------------------- */

%typemap(in, canthrow=1, fragment="<memory>") SWIGTYPE MOVE ($&1_type argp)
%{ argp = ($&1_ltype)$input;
   if (!argp) {
     SWIG_DartSetPendingException(SWIG_DartArgumentNullError, "Attempt to dereference null $1_type");
     return $null;
   }
   SwigValueWrapper< $1_ltype >::reset($1, argp); %}

%typemap(dartin) SWIGTYPE MOVE "$&dartclassname.swigRelease($dartinput)"
