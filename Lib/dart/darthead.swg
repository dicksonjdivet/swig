/* -----------------------------------------------------------------------------
 * darthead.swg
 *
 * Support code for Dart: native library loading, memory management of strings
 * and conversion of C/C++ errors into Dart exceptions.
 * ----------------------------------------------------------------------------- */

%insert(runtime) %{
#include <stdlib.h>
#include <string.h>
#include <stdio.h>

/* Storage class for the pending exception, which needs to be thread local as Dart isolates can run on different threads */
#if !defined(SWIG_DART_THREAD_LOCAL)
# if defined(__cplusplus) && __cplusplus >= 201103L
#  define SWIG_DART_THREAD_LOCAL thread_local
# elif defined(__STDC_VERSION__) && __STDC_VERSION__ >= 201112L && !defined(__STDC_NO_THREADS__)
#  define SWIG_DART_THREAD_LOCAL _Thread_local
# elif defined(_MSC_VER)
#  define SWIG_DART_THREAD_LOCAL __declspec(thread)
# elif defined(__GNUC__)
#  define SWIG_DART_THREAD_LOCAL __thread
# else
#  define SWIG_DART_THREAD_LOCAL
# endif
#endif

/* Support for throwing Dart exceptions, see the swigTakePendingException method in the generated Dart code */
typedef enum {
  SWIG_DartException = 1,
  SWIG_DartArgumentError,
  SWIG_DartArgumentNullError,
  SWIG_DartRangeError,
  SWIG_DartStateError,
  SWIG_DartUnsupportedError,
  SWIG_DartOutOfMemoryError
} SWIG_DartExceptionCodes;

static SWIG_DART_THREAD_LOCAL int SWIG_dart_pending_exception_code = 0;
static SWIG_DART_THREAD_LOCAL char *SWIG_dart_pending_exception_message = 0;

/* Copy a string into memory that is freed with free(), the Dart code frees strings passed to it with free() */
static char * SWIGUNUSED SWIG_DartStrdup(const char *s) {
  char *copy;
  size_t len;
  if (!s)
    return 0;
  len = strlen(s) + 1;
  copy = (char *)malloc(len);
  if (copy)
    memcpy(copy, s, len);
  return copy;
}

static void SWIGUNUSED SWIG_DartSetPendingException(SWIG_DartExceptionCodes code, const char *msg) {
  free(SWIG_dart_pending_exception_message);
  SWIG_dart_pending_exception_code = (int)code;
  SWIG_dart_pending_exception_message = SWIG_DartStrdup(msg ? msg : "");
}

#define SWIG_contract_assert(nullreturn, expr, msg) do { if (!(expr)) { SWIG_DartSetPendingException(SWIG_DartArgumentError, msg); return nullreturn; } } while (0)

#ifdef __cplusplus
extern "C" {
#endif

SWIGEXPORT void * SWIGSTDCALL SWIG_DartMalloc_$module(size_t size) {
  return malloc(size);
}

SWIGEXPORT void SWIGSTDCALL SWIG_DartFree_$module(void *ptr) {
  free(ptr);
}

SWIGEXPORT int SWIGSTDCALL SWIG_DartPendingExceptionCode_$module(void) {
  return SWIG_dart_pending_exception_code;
}

SWIGEXPORT char * SWIGSTDCALL SWIG_DartTakePendingExceptionMessage_$module(void) {
  char *msg = SWIG_dart_pending_exception_message;
  SWIG_dart_pending_exception_code = 0;
  SWIG_dart_pending_exception_message = 0;
  return msg;
}

#ifdef __cplusplus
}
#endif
%}

%pragma(dart) imclasscode=%{
  static final $imclassname _instance = $imclassname._();

  factory $imclassname() => _instance;

  // The native library. Set it before the first use of the module to override the default library loading.
  static ffi.DynamicLibrary? swigLibrary;

  final ffi.DynamicLibrary _library;

  $imclassname._() : _library = swigLibrary ??= _swigOpenLibrary('$dllimport');

  static ffi.DynamicLibrary _swigOpenLibrary(String name) {
    final List<String> fileNames;
    if (swig_io.Platform.isWindows) {
      fileNames = [name + '.dll', name + '-d.dll'];
    } else if (swig_io.Platform.isIOS) {
      fileNames = [name + '.framework/' + name, 'lib' + name + '.dylib'];
    } else if (swig_io.Platform.isMacOS) {
      fileNames = ['lib' + name + '.dylib', 'lib' + name + '-d.dylib'];
    } else {
      fileNames = ['lib' + name + '.so', 'lib' + name + '-d.so'];
    }
    Object? error;
    for (final fileName in fileNames) {
      try {
        return ffi.DynamicLibrary.open(fileName);
      } on ArgumentError catch (e) {
        error ??= e;
      }
    }
    if (swig_io.Platform.isIOS) {
      // Statically linked into the application
      return ffi.DynamicLibrary.process();
    }
    throw error!;
  }

  late final _swigMalloc = _library.lookupFunction<ffi.Pointer<ffi.Void> Function(ffi.Size), ffi.Pointer<ffi.Void> Function(int)>('SWIG_DartMalloc_$module', isLeaf: true);
  late final _swigFree = _library.lookupFunction<ffi.Void Function(ffi.Pointer<ffi.Void>), void Function(ffi.Pointer<ffi.Void>)>('SWIG_DartFree_$module', isLeaf: true);
  late final _swigPendingExceptionCode = _library.lookupFunction<ffi.Int Function(), int Function()>('SWIG_DartPendingExceptionCode_$module', isLeaf: true);
  late final _swigTakePendingExceptionMessage = _library.lookupFunction<ffi.Pointer<ffi.Uint8> Function(), ffi.Pointer<ffi.Uint8> Function()>('SWIG_DartTakePendingExceptionMessage_$module', isLeaf: true);

  // Returns a native function pointer, for example to use as a NativeFinalizer callback.
  ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>> swigLookupDeleter(String symbol) {
    return _library.lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<ffi.Void>)>>(symbol);
  }

  // Allocates native memory, which must be released with swigFree.
  static ffi.Pointer<ffi.Void> swigMalloc(int size) {
    final ffi.Pointer<ffi.Void> ptr = _instance._swigMalloc(size);
    if (ptr == ffi.nullptr) {
      throw StateError('Out of memory allocating ' + size.toString() + ' bytes');
    }
    return ptr;
  }

  static void swigFree(ffi.Pointer<ffi.NativeType> ptr) {
    _instance._swigFree(ptr.cast<ffi.Void>());
  }

  // Converts a Dart string into a null terminated UTF-8 C string, which must be released with swigFree.
  static ffi.Pointer<ffi.Uint8> swigToNativeString(String? s) {
    if (s == null) {
      return ffi.nullptr;
    }
    final List<int> bytes = swig_convert.utf8.encode(s);
    final ffi.Pointer<ffi.Uint8> ptr = swigMalloc(bytes.length + 1).cast<ffi.Uint8>();
    final typed = ptr.asTypedList(bytes.length + 1);
    typed.setAll(0, bytes);
    typed[bytes.length] = 0;
    return ptr;
  }

  // Converts a Dart string into UTF-8 bytes preceded by the number of bytes as a 64-bit integer, which must be released with swigFree.
  static ffi.Pointer<ffi.Void> swigToNativeStringWithLength(String? s) {
    if (s == null) {
      return ffi.nullptr;
    }
    final List<int> bytes = swig_convert.utf8.encode(s);
    final ffi.Pointer<ffi.Void> ptr = swigMalloc(8 + bytes.length + 1);
    ptr.cast<ffi.Int64>().value = bytes.length;
    final typed = ffi.Pointer<ffi.Uint8>.fromAddress(ptr.address + 8).asTypedList(bytes.length + 1);
    typed.setAll(0, bytes);
    typed[bytes.length] = 0;
    return ptr;
  }

  // Converts a null terminated UTF-8 C string into a Dart string.
  static String? swigFromNativeString(ffi.Pointer<ffi.Uint8> ptr) {
    if (ptr == ffi.nullptr) {
      return null;
    }
    int length = 0;
    while (ptr[length] != 0) {
      length++;
    }
    return swig_convert.utf8.decode(ptr.asTypedList(length), allowMalformed: true);
  }

  // Converts a null terminated UTF-8 C string into a Dart string and releases the C string.
  static String? swigFromNativeStringAndFree(ffi.Pointer<ffi.Uint8> ptr) {
    try {
      return swigFromNativeString(ptr);
    } finally {
      if (ptr != ffi.nullptr) {
        swigFree(ptr);
      }
    }
  }

  static bool get swigPendingException => _instance._swigPendingExceptionCode() != 0;

  // Converts and clears the pending C/C++ error into a Dart exception or error to throw.
  static Object swigTakePendingException() {
    final int code = _instance._swigPendingExceptionCode();
    final String message = swigFromNativeStringAndFree(_instance._swigTakePendingExceptionMessage()) ?? '';
    switch (code) {
      case 2: // SWIG_DartArgumentError
        return ArgumentError(message);
      case 3: // SWIG_DartArgumentNullError
        return ArgumentError.notNull(message);
      case 4: // SWIG_DartRangeError
        return RangeError(message);
      case 5: // SWIG_DartStateError
        return StateError(message);
      case 6: // SWIG_DartUnsupportedError
        return UnsupportedError(message);
      default:
        return SwigException(message);
    }
  }
%}

%pragma(dart) librarycode=%{
// Marker for an argument not passed to a function dispatching to overloaded C/C++ functions.
class _SwigNoArg {
  const _SwigNoArg();
}

const Object _swigNoArg = _SwigNoArg();

// Exception thrown when the wrapped C/C++ code reports an error.
class SwigException implements Exception {
  final String message;

  SwigException(this.message);

  String toString() => 'SwigException: ' + message;
}
%}
