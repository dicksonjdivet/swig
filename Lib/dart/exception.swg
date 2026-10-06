/* -----------------------------------------------------------------------------
 * exception.swg
 *
 * Defines SWIG_exception(code, msg) and the SWIG_exception fragment with any support code that it needs.
 * SWIG_exception raises the target language error for a SWIG error code and leaves the wrapper function.
 * Included by swigcommon.swg.
 * ----------------------------------------------------------------------------- */

/* Map a SWIG error code to a Dart exception */
%fragment("SWIG_DartThrowException", "header") %{
SWIGINTERN void SWIG_DartThrowException(int code, const char *msg) {
  SWIG_DartExceptionCodes exception_code;
  switch(code) {
  case SWIG_IndexError:
    exception_code = SWIG_DartRangeError;
    break;
  case SWIG_ValueError:
    exception_code = SWIG_DartArgumentError;
    break;
  case SWIG_NullReferenceError:
    exception_code = SWIG_DartArgumentNullError;
    break;
  case SWIG_MemoryError:
    exception_code = SWIG_DartOutOfMemoryError;
    break;
  case SWIG_DivisionByZero:
  case SWIG_IOError:
  case SWIG_OverflowError:
  case SWIG_RuntimeError:
  case SWIG_TypeError:
  case SWIG_SyntaxError:
  case SWIG_SystemError:
  case SWIG_UnknownError:
  default:
    exception_code = SWIG_DartException;
    break;
  }
  SWIG_DartSetPendingException(exception_code, msg);
}
%}

/* Raise the error for a SWIG error code and leave the wrapper */
#define SWIG_exception(code, msg) { SWIG_DartThrowException(code, msg); return $null; }
%fragment("SWIG_exception", "header", fragment="SWIG_DartThrowException") {}
