/* -----------------------------------------------------------------------------
 * std_except.i
 *
 * Typemaps used by the STL wrappers that throw exceptions. These typemaps are
 * used when methods are declared with an STL exception specification, such as
 *   size_t at() const throw (std::out_of_range);
 * ----------------------------------------------------------------------------- */

%{
#include <typeinfo>
#include <stdexcept>
%}

namespace std
{
  %ignore exception;
  struct exception {};
}

%typemap(throws, canthrow=1) std::bad_cast        "SWIG_DartSetPendingException(SWIG_DartException, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::bad_exception   "SWIG_DartSetPendingException(SWIG_DartException, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::domain_error    "SWIG_DartSetPendingException(SWIG_DartArgumentError, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::exception       "SWIG_DartSetPendingException(SWIG_DartException, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::invalid_argument "SWIG_DartSetPendingException(SWIG_DartArgumentError, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::length_error    "SWIG_DartSetPendingException(SWIG_DartRangeError, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::logic_error     "SWIG_DartSetPendingException(SWIG_DartStateError, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::out_of_range    "SWIG_DartSetPendingException(SWIG_DartRangeError, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::overflow_error  "SWIG_DartSetPendingException(SWIG_DartException, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::range_error     "SWIG_DartSetPendingException(SWIG_DartRangeError, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::runtime_error   "SWIG_DartSetPendingException(SWIG_DartException, $1.what());\n return $null;"
%typemap(throws, canthrow=1) std::underflow_error "SWIG_DartSetPendingException(SWIG_DartException, $1.what());\n return $null;"
