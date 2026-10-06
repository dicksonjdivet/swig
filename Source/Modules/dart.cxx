/* -----------------------------------------------------------------------------
 * This file is part of SWIG, which is licensed as a whole under version 3
 * (or any later version) of the GNU General Public License. Some additional
 * terms also apply to certain portions of SWIG. The full details of the SWIG
 * license and copyrights can be found in the LICENSE and COPYRIGHT files
 * included with the SWIG source code as distributed by the SWIG developers
 * and at https://www.swig.org/legal.html.
 *
 * dart.cxx
 *
 * Dart language module for SWIG.
 *
 * The generated Dart code uses dart:ffi to call C wrapper functions exported
 * from the native library. One Dart library file is generated per SWIG module
 * containing:
 *   - the intermediary class, which binds the exported C wrapper functions using dart:ffi,
 *   - the module class, which wraps global functions, variables and constants,
 *   - the proxy classes, enums and type wrapper classes.
 * The design of this module follows the C# module.
 * ----------------------------------------------------------------------------- */

#include "swigmod.h"
#include "cparse.h"
#include <ctype.h>
#include <errno.h>
#include <stdlib.h>

class DART : public Language {
  static const char *usage;
  const String *empty_string;

  Hash *swig_types_hash;
  File *f_begin;
  File *f_runtime;
  File *f_runtime_h;
  File *f_header;
  File *f_wrappers;
  File *f_init;
  File *f_directors;
  File *f_directors_h;

  bool native_function_flag;   // Flag for when wrapping a native function
  bool enum_constant_flag;     // Flag for when wrapping an enum or constant
  bool static_flag;            // Flag for when wrapping a static functions or member variables
  bool variable_wrapper_flag;  // Flag for when wrapping a nonstatic member variable
  bool wrapping_member_flag;   // Flag for when wrapping a member variable/enum/const
  bool global_variable_flag;   // Flag for when wrapping a global variable

  String *imclass_name;                 // intermediary class name
  String *module_class_name;            // module class name
  String *imclass_class_code;           // intermediary class code
  String *proxy_class_def;              // proxy class definition
  String *proxy_class_code;             // proxy class body
  String *module_class_code;            // module class body
  String *proxy_class_name;             // proxy class name
  String *variable_name;                // name of a variable being wrapped
  String *proxy_class_constants_code;   // constants in the proxy class
  String *module_class_constants_code;  // constants in the module class
  String *library_code;                 // proxy classes, enums and type wrapper classes
  String *library_pragma_code;          // top level code from %pragma(dart) librarycode
  String *common_begin_code;            // code from the dartbegin module option
  String *enum_code;                    // code for the enum being wrapped
  String *enum_values;                  // comma separated list of the values of the enum being wrapped
  bool enum_next_value_known;           // whether the value of the next enum item without an initializer is known
  long long enum_next_value;            // value of the next enum item without an initializer
  String *libname;                      // base name of the native library to load
  String *module_imports;               // import directives from %pragma(dart) moduleimports
  String *imported_modules;             // import directives for the modules imported with %import
  String *imclass_baseclass;            // base class for the intermediary class from %pragma
  String *module_baseclass;             // base class for the module class from %pragma
  String *imclass_interfaces;           // interfaces for the intermediary class from %pragma
  String *module_interfaces;            // interfaces for the module class from %pragma
  String *imclass_class_modifiers;      // class modifiers for the intermediary class from %pragma
  String *module_class_modifiers;       // class modifiers for the module class from %pragma
  String *upcasts_code;                 // C++ casts for inheritance hierarchies C++ code
  String *destructor_call;              // Dart code calling the C++ destructor wrapper, if any
  String *destructor_wname;             // name of the exported C++ destructor wrapper, if any

  enum EnumFeature { SimpleEnum, ProperEnum };

public:
  /* -----------------------------------------------------------------------------
   * DART()
   * ----------------------------------------------------------------------------- */

  DART() :
    empty_string(NewString("")),
    swig_types_hash(NULL),
    f_begin(NULL),
    f_runtime(NULL),
    f_runtime_h(NULL),
    f_header(NULL),
    f_wrappers(NULL),
    f_init(NULL),
    f_directors(NULL),
    f_directors_h(NULL),
    native_function_flag(false),
    enum_constant_flag(false),
    static_flag(false),
    variable_wrapper_flag(false),
    wrapping_member_flag(false),
    global_variable_flag(false),
    imclass_name(NULL),
    module_class_name(NULL),
    imclass_class_code(NULL),
    proxy_class_def(NULL),
    proxy_class_code(NULL),
    module_class_code(NULL),
    proxy_class_name(NULL),
    variable_name(NULL),
    proxy_class_constants_code(NULL),
    module_class_constants_code(NULL),
    library_code(NULL),
    library_pragma_code(NULL),
    common_begin_code(NULL),
    enum_code(NULL),
    enum_values(NULL),
    enum_next_value_known(false),
    enum_next_value(0),
    libname(NULL),
    module_imports(NULL),
    imported_modules(NULL),
    imclass_baseclass(NULL),
    module_baseclass(NULL),
    imclass_interfaces(NULL),
    module_interfaces(NULL),
    imclass_class_modifiers(NULL),
    module_class_modifiers(NULL),
    upcasts_code(NULL),
    destructor_call(NULL),
    destructor_wname(NULL) {
  }

  /* -----------------------------------------------------------------------------
   * getProxyName()
   *
   * Test to see if a type corresponds to something wrapped with a proxy class.
   * Return NULL if not otherwise the proxy class name.
   * ----------------------------------------------------------------------------- */

  String *getProxyName(SwigType *t) {
    Node *n = classLookup(t);
    return n ? Getattr(n, "sym:name") : NULL;
  }

  /* ------------------------------------------------------------
   * main()
   * ------------------------------------------------------------ */

  virtual void main(int argc, char *argv[]) {

    SWIG_library_directory("dart");

    // Look for certain command line options
    for (int i = 1; i < argc; i++) {
      if (argv[i]) {
        if (strcmp(argv[i], "-libname") == 0) {
          if (argv[i + 1]) {
            libname = NewString(argv[i + 1]);
            Swig_mark_arg(i);
            Swig_mark_arg(i + 1);
            i++;
          } else {
            Swig_arg_error();
          }
        } else if (strcmp(argv[i], "-help") == 0) {
          Printf(stdout, "%s\n", usage);
        }
      }
    }

    // Add a symbol to the parser for conditional compilation
    Preprocessor_define("SWIGDART 1", 0);

    SWIG_config_file("dart.swg");

    allow_overloading();
  }

  /* ---------------------------------------------------------------------
   * top()
   * --------------------------------------------------------------------- */

  virtual int top(Node *n) {

    // Get any options set in the module directive
    Node *module = Getattr(n, "module");
    Node *optionsnode = Getattr(module, "options");

    if (optionsnode) {
      if (Getattr(optionsnode, "imclassname"))
        imclass_name = Copy(Getattr(optionsnode, "imclassname"));
      common_begin_code = Getattr(optionsnode, "dartbegin");
      if (common_begin_code)
        Printf(common_begin_code, "\n");
    }

    /* Initialize all of the output files */
    String *outfile = Getattr(n, "outfile");

    if (!outfile) {
      Printf(stderr, "Unable to determine outfile\n");
      Exit(EXIT_FAILURE);
    }

    f_begin = NewFile(outfile, "w", SWIG_output_files());
    if (!f_begin) {
      FileErrorDisplay(outfile);
      Exit(EXIT_FAILURE);
    }

    f_runtime = NewString("");
    f_init = NewString("");
    f_header = NewString("");
    f_wrappers = NewString("");
    f_directors_h = NewString("");
    f_directors = NewString("");

    /* Register file targets with the SWIG file handler */
    Swig_register_filebyname("header", f_header);
    Swig_register_filebyname("wrapper", f_wrappers);
    Swig_register_filebyname("begin", f_begin);
    Swig_register_filebyname("runtime", f_runtime);
    Swig_register_filebyname("init", f_init);
    Swig_register_filebyname("director", f_directors);
    Swig_register_filebyname("director_h", f_directors_h);

    swig_types_hash = NewHash();

    // Make the intermediary class and module class names. The intermediary class name can be set in the module directive.
    module_class_name = Copy(Getattr(n, "name"));
    if (!imclass_name)
      imclass_name = NewStringf("%sFFI", module_class_name);
    if (Cmp(imclass_name, module_class_name) == 0) {
      Printf(stderr, "The intermediary class name cannot be the same as the module name: %s\n", imclass_name);
      Exit(EXIT_FAILURE);
    }

    // module class and intermediary classes are always created
    if (!addSymbol(imclass_name, module))
      return SWIG_ERROR;
    if (!addSymbol(module_class_name, module))
      return SWIG_ERROR;

    imclass_class_code = NewString("");
    proxy_class_def = NewString("");
    proxy_class_code = NewString("");
    module_class_constants_code = NewString("");
    imclass_baseclass = NewString("");
    imclass_interfaces = NewString("");
    imclass_class_modifiers = NewString("");
    module_class_code = NewString("");
    module_baseclass = NewString("");
    module_interfaces = NewString("");
    module_imports = NewString("");
    module_class_modifiers = NewString("");
    library_code = NewString("");
    library_pragma_code = NewString("");
    imported_modules = NewString("");
    upcasts_code = NewString("");
    if (!libname)
      libname = Copy(module_class_name);

    Swig_banner(f_begin);

    Swig_obligatory_macros(f_runtime, "DART");

    Printf(f_runtime, "\n");

    // The wrapper functions are prefixed with the module name so that several modules can be linked into the same library
    String *wrapper_name = NewStringf("Dart_%s_%%f", module_class_name);
    Swig_name_register("wrapper", wrapper_name);
    Delete(wrapper_name);

    Printf(f_wrappers, "\n#ifdef __cplusplus\n");
    Printf(f_wrappers, "extern \"C\" {\n");
    Printf(f_wrappers, "#endif\n\n");

    /* Emit code */
    Language::top(n);

    Printv(f_wrappers, upcasts_code, NIL);

    Printf(f_wrappers, "#ifdef __cplusplus\n");
    Printf(f_wrappers, "}\n");
    Printf(f_wrappers, "#endif\n");

    // Output a Dart type wrapper class for each SWIG type
    for (Iterator swig_type = First(swig_types_hash); swig_type.key; swig_type = Next(swig_type)) {
      emitTypeWrapperClass(swig_type.key, swig_type.item);
    }

    emitDartLibrary();

    Delete(swig_types_hash);
    swig_types_hash = NULL;
    Delete(imclass_name);
    imclass_name = NULL;
    Delete(imclass_class_code);
    imclass_class_code = NULL;
    Delete(proxy_class_def);
    proxy_class_def = NULL;
    Delete(proxy_class_code);
    proxy_class_code = NULL;
    Delete(module_class_constants_code);
    module_class_constants_code = NULL;
    Delete(imclass_baseclass);
    imclass_baseclass = NULL;
    Delete(imclass_interfaces);
    imclass_interfaces = NULL;
    Delete(imclass_class_modifiers);
    imclass_class_modifiers = NULL;
    Delete(module_class_name);
    module_class_name = NULL;
    Delete(module_class_code);
    module_class_code = NULL;
    Delete(module_baseclass);
    module_baseclass = NULL;
    Delete(module_interfaces);
    module_interfaces = NULL;
    Delete(module_imports);
    module_imports = NULL;
    Delete(module_class_modifiers);
    module_class_modifiers = NULL;
    Delete(library_code);
    library_code = NULL;
    Delete(library_pragma_code);
    library_pragma_code = NULL;
    Delete(imported_modules);
    imported_modules = NULL;
    Delete(upcasts_code);
    upcasts_code = NULL;
    Delete(libname);
    libname = NULL;

    /* Close all of the files */
    Dump(f_runtime, f_begin);
    Dump(f_header, f_begin);
    Dump(f_wrappers, f_begin);
    Wrapper_pretty_print(f_init, f_begin);
    Delete(f_header);
    Delete(f_wrappers);
    Delete(f_init);
    Delete(f_directors);
    Delete(f_directors_h);
    Delete(f_runtime);
    Delete(f_begin);
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * emitDartLibrary()
   *
   * Write the Dart library file containing all the generated Dart code.
   * ----------------------------------------------------------------------------- */

  void emitDartLibrary() {
    String *filen = NewStringf("%s%s.dart", SWIG_output_directory(), module_class_name);
    File *f_dart = NewFile(filen, "w", SWIG_output_files());
    if (!f_dart) {
      FileErrorDisplay(filen);
      Exit(EXIT_FAILURE);
    }
    Delete(filen);

    Printf(f_dart, "//------------------------------------------------------------------------------\n");
    Printf(f_dart, "// <auto-generated />\n");
    Printf(f_dart, "//\n");
    Swig_banner_target_lang(f_dart, "//");
    Printf(f_dart, "//------------------------------------------------------------------------------\n\n");
    Printv(f_dart, common_begin_code, NIL);

    // The generated names follow the C/C++ names rather than the Dart naming conventions
    Printf(f_dart, "// ignore_for_file: camel_case_types, constant_identifier_names, non_constant_identifier_names\n");
    Printf(f_dart, "// ignore_for_file: unused_element, unused_field, unused_import, unnecessary_this\n\n");

    Printf(f_dart, "import 'dart:collection' as swig_collection;\n");
    Printf(f_dart, "import 'dart:convert' as swig_convert;\n");
    Printf(f_dart, "import 'dart:ffi' as ffi;\n");
    Printf(f_dart, "import 'dart:io' as swig_io;\n");
    Printv(f_dart, imported_modules, NIL);
    if (Len(module_imports) > 0)
      Printf(f_dart, "%s\n", module_imports);
    Printf(f_dart, "\n");

    if (Len(library_pragma_code) > 0) {
      Replaceall(library_pragma_code, "$module", module_class_name);
      Replaceall(library_pragma_code, "$imclassname", imclass_name);
      Printv(f_dart, library_pragma_code, "\n", NIL);
    }

    // The intermediary class
    Printf(f_dart, "%s%s%s", imclass_class_modifiers, Len(imclass_class_modifiers) > 0 ? " " : "", imclass_name);
    if (Len(imclass_baseclass) > 0)
      Printf(f_dart, " extends %s", imclass_baseclass);
    if (Len(imclass_interfaces) > 0)
      Printf(f_dart, " implements %s", imclass_interfaces);
    Printf(f_dart, " {\n");
    Replaceall(imclass_class_code, "$module", module_class_name);
    Replaceall(imclass_class_code, "$imclassname", imclass_name);
    Replaceall(imclass_class_code, "$dllimport", libname);
    Printv(f_dart, imclass_class_code, "}\n\n", NIL);

    // The module class
    Printf(f_dart, "%s%s%s", module_class_modifiers, Len(module_class_modifiers) > 0 ? " " : "", module_class_name);
    if (Len(module_baseclass) > 0)
      Printf(f_dart, " extends %s", module_baseclass);
    if (Len(module_interfaces) > 0)
      Printf(f_dart, " implements %s", module_interfaces);
    Printf(f_dart, " {\n");
    Replaceall(module_class_code, "$module", module_class_name);
    Replaceall(module_class_code, "$imclassname", imclass_name);
    Replaceall(module_class_code, "$dllimport", libname);
    Replaceall(module_class_constants_code, "$module", module_class_name);
    Replaceall(module_class_constants_code, "$imclassname", imclass_name);
    Replaceall(module_class_constants_code, "$dllimport", libname);
    Printv(f_dart, module_class_code, module_class_constants_code, "}\n", NIL);

    // Proxy classes, enums and type wrapper classes
    Printv(f_dart, library_code, NIL);

    Delete(f_dart);
  }

  /* ----------------------------------------------------------------------
   * importDirective()
   *
   * The Dart library generated for an imported module is imported by this library.
   * ---------------------------------------------------------------------- */

  virtual int importDirective(Node *n) {
    String *modname = Getattr(n, "module");
    if (modname) {
      String *import = NewStringf("import '%s.dart';\n", modname);
      if (!Strstr(imported_modules, import))
        Append(imported_modules, import);
      Delete(import);
    }
    return Language::importDirective(n);
  }

  /* ----------------------------------------------------------------------
   * nativeWrapper()
   * ---------------------------------------------------------------------- */

  virtual int nativeWrapper(Node *n) {
    String *wrapname = Getattr(n, "wrap:name");

    if (!addSymbol(wrapname, n, imclass_name))
      return SWIG_ERROR;

    if (Getattr(n, "type")) {
      Swig_save("nativeWrapper", n, "name", NIL);
      Setattr(n, "name", wrapname);
      native_function_flag = true;
      functionWrapper(n);
      Swig_restore(n);
      native_function_flag = false;
    } else {
      Swig_error(input_file, line_number, "No return type for %%native method %s.\n", Getattr(n, "wrap:name"));
    }

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * functionWrapper()
   *
   * Generates the exported C wrapper function and the dart:ffi binding of it
   * in the intermediary class.
   * ---------------------------------------------------------------------- */

  virtual int functionWrapper(Node *n) {
    String *symname = Getattr(n, "sym:name");
    SwigType *returntype = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    String *tm;
    Parm *p;
    int i;
    String *c_return_type = NewString("");
    String *im_return_type = NewString("");
    String *ffi_return_type = NewString("");
    String *im_param_types = NewString("");
    String *ffi_param_types = NewString("");
    String *cleanup = NewString("");
    String *outarg = NewString("");
    int num_arguments = 0;
    bool is_void_return;
    String *overloaded_name = getOverloadedName(n);

    if (!Getattr(n, "sym:overloaded")) {
      if (!addSymbol(symname, n, imclass_name))
        return SWIG_ERROR;
    }

    // A new wrapper function object
    Wrapper *f = NewWrapper();

    // Make a wrapper name for this function
    String *wname = Swig_name_wrapper(overloaded_name);

    /* Attach the non-standard typemaps to the parameter list. */
    Swig_typemap_attach_parms("ctype", l, f);
    Swig_typemap_attach_parms("ffitype", l, f);
    Swig_typemap_attach_parms("imtype", l, f);

    /* Get return types */
    if ((tm = Swig_typemap_lookup("ctype", n, "", 0))) {
      String *ctypeout = Getattr(n, "tmap:ctype:out");  // the type in the ctype typemap's out attribute overrides the type in the typemap
      if (ctypeout)
        tm = ctypeout;
      Printf(c_return_type, "%s", tm);
    } else {
      Swig_warning(WARN_DART_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No ctype typemap defined for %s\n", SwigType_str(returntype, 0));
    }

    if ((tm = Swig_typemap_lookup("ffitype", n, "", 0))) {
      String *ffitypeout = Getattr(n, "tmap:ffitype:out");  // the type in the ffitype typemap's out attribute overrides the type in the typemap
      if (ffitypeout)
        tm = ffitypeout;
      Printf(ffi_return_type, "%s", tm);
    } else {
      Swig_warning(WARN_DART_TYPEMAP_FFITYPE_UNDEF, input_file, line_number, "No ffitype typemap defined for %s\n", SwigType_str(returntype, 0));
    }

    if ((tm = Swig_typemap_lookup("imtype", n, "", 0))) {
      String *imtypeout = Getattr(n, "tmap:imtype:out");  // the type in the imtype typemap's out attribute overrides the type in the typemap
      if (imtypeout)
        tm = imtypeout;
      Printf(im_return_type, "%s", tm);
    } else {
      Swig_warning(WARN_DART_TYPEMAP_IMTYPE_UNDEF, input_file, line_number, "No imtype typemap defined for %s\n", SwigType_str(returntype, 0));
    }

    is_void_return = Cmp(c_return_type, "void") == 0;
    if (!is_void_return)
      Wrapper_add_localv(f, "jresult", c_return_type, "jresult = $null", NIL);

    Printv(f->def, "SWIGEXPORT ", c_return_type, " SWIGSTDCALL ", wname, "(", NIL);

    // Emit all of the local variables for holding arguments.
    emit_parameter_variables(l, f);

    /* Attach the standard typemaps */
    emit_attach_parmmaps(l, f);

    // Parameter overloading
    Setattr(n, "wrap:parms", l);
    Setattr(n, "wrap:name", wname);

    // Wrappers not wanted for some methods where the parameters cannot be overloaded in Dart
    if (Getattr(n, "sym:overloaded")) {
      // Emit warnings for the few cases that can't be overloaded in Dart and give up on generating wrapper
      Swig_overload_check(n);
      if (Getattr(n, "overload:ignore")) {
        DelWrapper(f);
        return SWIG_OK;
      }
    }

    /* Get number of required and total arguments */
    num_arguments = emit_num_arguments(l);
    int gencomma = 0;

    // Now walk the function parameter list and generate code to get arguments
    for (i = 0, p = l; i < num_arguments; i++) {

      while (checkAttribute(p, "tmap:in:numinputs", "0")) {
        p = Getattr(p, "tmap:in:next");
      }

      SwigType *pt = Getattr(p, "type");
      String *ln = Getattr(p, "lname");
      String *c_param_type = NewString("");
      String *arg = NewStringf("j%s", ln);

      /* Get the ctype types of the parameter */
      if ((tm = Getattr(p, "tmap:ctype"))) {
        Printv(c_param_type, tm, NIL);
      } else {
        Swig_warning(WARN_DART_TYPEMAP_CTYPE_UNDEF, input_file, line_number, "No ctype typemap defined for %s\n", SwigType_str(pt, 0));
      }

      /* Get the dart:ffi types of the parameter */
      if (gencomma) {
        Printf(ffi_param_types, ", ");
        Printf(im_param_types, ", ");
      }
      if ((tm = Getattr(p, "tmap:ffitype"))) {
        Printv(ffi_param_types, tm, NIL);
      } else {
        Swig_warning(WARN_DART_TYPEMAP_FFITYPE_UNDEF, input_file, line_number, "No ffitype typemap defined for %s\n", SwigType_str(pt, 0));
      }
      if ((tm = Getattr(p, "tmap:imtype"))) {
        Printv(im_param_types, tm, NIL);
      } else {
        Swig_warning(WARN_DART_TYPEMAP_IMTYPE_UNDEF, input_file, line_number, "No imtype typemap defined for %s\n", SwigType_str(pt, 0));
      }

      // Add parameter to C function
      Printv(f->def, gencomma ? ", " : "", c_param_type, " ", arg, NIL);

      gencomma = 1;

      // Get typemap for this argument
      if ((tm = Getattr(p, "tmap:in"))) {
        canThrow(n, "in", p);
        Replaceall(tm, "$arg", arg); /* deprecated? */
        Replaceall(tm, "$input", arg);
        Setattr(p, "emit:input", arg);
        Printf(f->code, "%s\n", tm);
        p = Getattr(p, "tmap:in:next");
      } else {
        Swig_warning(WARN_TYPEMAP_IN_UNDEF, input_file, line_number, "Unable to use type %s as a function argument.\n", SwigType_str(pt, 0));
        p = nextSibling(p);
      }
      Delete(c_param_type);
      Delete(arg);
    }

    /* Insert constraint checking code */
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:check"))) {
        canThrow(n, "check", p);
        Replaceall(tm, "$arg", Getattr(p, "emit:input")); /* deprecated? */
        Replaceall(tm, "$input", Getattr(p, "emit:input"));
        Printv(f->code, tm, "\n", NIL);
        p = Getattr(p, "tmap:check:next");
      } else {
        p = nextSibling(p);
      }
    }

    /* Insert cleanup code */
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:freearg"))) {
        canThrow(n, "freearg", p);
        Replaceall(tm, "$arg", Getattr(p, "emit:input")); /* deprecated? */
        Replaceall(tm, "$input", Getattr(p, "emit:input"));
        Printv(cleanup, tm, "\n", NIL);
        p = Getattr(p, "tmap:freearg:next");
      } else {
        p = nextSibling(p);
      }
    }

    /* Insert argument output code */
    for (p = l; p;) {
      if ((tm = Getattr(p, "tmap:argout"))) {
        canThrow(n, "argout", p);
        Replaceall(tm, "$arg", Getattr(p, "emit:input")); /* deprecated? */
        Replaceall(tm, "$result", "jresult");
        Replaceall(tm, "$input", Getattr(p, "emit:input"));
        Printv(outarg, tm, "\n", NIL);
        p = Getattr(p, "tmap:argout:next");
      } else {
        p = nextSibling(p);
      }
    }

    // Look for usage of throws typemap and the canthrow flag
    ParmList *throw_parm_list = NULL;
    if ((throw_parm_list = Getattr(n, "catchlist"))) {
      Swig_typemap_attach_parms("throws", throw_parm_list, f);
      for (p = throw_parm_list; p; p = nextSibling(p)) {
        if (Getattr(p, "tmap:throws")) {
          canThrow(n, "throws", p);
        }
      }
    }

    String *null_attribute = 0;
    // Now write code to make the function call
    if (!native_function_flag) {

      String *actioncode = emit_action(n);

      /* Return value if necessary  */
      if ((tm = Swig_typemap_lookup_out("out", n, Swig_cresult_name(), f, actioncode))) {
        canThrow(n, "out", n);
        Replaceall(tm, "$result", "jresult");

        if (GetFlag(n, "feature:new"))
          Replaceall(tm, "$owner", "1");
        else
          Replaceall(tm, "$owner", "0");

        Printf(f->code, "%s", tm);
        null_attribute = Getattr(n, "tmap:out:null");
        if (Len(tm))
          Printf(f->code, "\n");
      } else {
        Swig_warning(
          WARN_TYPEMAP_OUT_UNDEF, input_file, line_number, "Unable to use return type %s in function %s.\n", SwigType_str(returntype, 0), Getattr(n, "name"));
      }
      emit_return_variable(n, returntype, f);
    }

    /* Output argument output code */
    Printv(f->code, outarg, NIL);

    /* Output cleanup code */
    Printv(f->code, cleanup, NIL);

    /* Look to see if there is any newfree cleanup code */
    if (GetFlag(n, "feature:new")) {
      if ((tm = Swig_typemap_lookup("newfree", n, Swig_cresult_name(), 0))) {
        canThrow(n, "newfree", n);
        Printf(f->code, "%s\n", tm);
      }
    }

    /* See if there is any return cleanup code */
    if (!native_function_flag) {
      if ((tm = Swig_typemap_lookup("ret", n, Swig_cresult_name(), 0))) {
        canThrow(n, "ret", n);
        Printf(f->code, "%s\n", tm);
      }
    }

    /* Finish C function */
    Printf(f->def, ") {");

    if (!is_void_return)
      Printv(f->code, "    return jresult;\n", NIL);
    Printf(f->code, "}\n");

    /* Substitute the cleanup code */
    Replaceall(f->code, "$cleanup", cleanup);

    emit_isvoid_special_variables(n, f->code, is_void_return);

    /* Substitute the function name */
    Replaceall(f->code, "$symname", symname);

    /* Contract macro modification */
    if (Replaceall(f->code, "SWIG_contract_assert(", "SWIG_contract_assert($null, ") > 0) {
      Setattr(n, "dart:canthrow", "1");
    }

    if (!null_attribute) {
      Replaceall(f->code, "$null", "0");
      Replaceall(f->locals, "$null", "0");
    } else {
      Replaceall(f->code, "$null", null_attribute);
      Replaceall(f->locals, "$null", null_attribute);
    }

    /* Dump the function out */
    if (!native_function_flag) {
      Wrapper_print(f, f_wrappers);

      // Handle %exception which sets the canthrow attribute
      if (Getattr(n, "feature:except:canthrow"))
        Setattr(n, "dart:canthrow", "1");

      // A very simple check (it is not foolproof) to help typemap/feature writers for
      // throwing Dart exceptions from C/C++ code. It checks for the common methods which
      // set a pending Dart exception... the 'canthrow' typemap/feature attribute must be set
      // so that code which checks for pending exceptions is added in the Dart proxy method.
      if (!Getattr(n, "dart:canthrow")) {
        if (Strstr(f->code, "SWIG_exception")) {
          Swig_warning(WARN_DART_CANTHROW,
                       input_file,
                       line_number,
                       "C/C++ code contains a call to SWIG_exception and Dart code does not handle pending exceptions via the canthrow attribute.\n");
        } else if (Strstr(f->code, "SWIG_DartSetPendingException")) {
          Swig_warning(WARN_DART_CANTHROW,
                       input_file,
                       line_number,
                       "C/C++ code contains a call to SWIG_DartSetPendingException and Dart code does not handle pending exceptions via the canthrow "
                       "attribute.\n");
        }
      }
    }

    /* The dart:ffi binding in the intermediary class */
    Printf(imclass_class_code,
           "  late final %s = _library.lookupFunction<%s Function(%s), %s Function(%s)>('%s');\n",
           overloaded_name,
           ffi_return_type,
           ffi_param_types,
           im_return_type,
           im_param_types,
           wname);

    if (!(is_wrapping_class()) && !enum_constant_flag) {
      moduleClassFunctionHandler(n);
    }

    /*
     * Generate the proxy class getters and setters for public member variables.
     * Not for enums and constants.
     */
    if (wrapping_member_flag && !enum_constant_flag) {
      bool getter_flag = Cmp(symname, Swig_name_set(getNSpace(), Swig_name_member(0, getClassPrefix(), variable_name))) != 0;
      Setattr(n, "proxyfuncname", variable_name);
      Setattr(n, "imfuncname", symname);
      Setattr(n, "dart:accessor", getter_flag ? "get" : "set");
      proxyClassFunctionHandler(n);
    }

    Delete(c_return_type);
    Delete(im_return_type);
    Delete(ffi_return_type);
    Delete(im_param_types);
    Delete(ffi_param_types);
    Delete(cleanup);
    Delete(outarg);
    Delete(overloaded_name);
    DelWrapper(f);
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * variableWrapper()
   * ----------------------------------------------------------------------- */

  virtual int variableWrapper(Node *n) {
    Language::variableWrapper(n);
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * globalvariableHandler()
   * ------------------------------------------------------------------------ */

  virtual int globalvariableHandler(Node *n) {
    variable_name = Getattr(n, "sym:name");
    global_variable_flag = true;
    Setattr(n, "dart:vartype", Getattr(n, "type"));
    int ret = Language::globalvariableHandler(n);
    Delattr(n, "dart:vartype");
    global_variable_flag = false;
    return ret;
  }

  /* ----------------------------------------------------------------------
   * enumDeclaration()
   *
   * C/C++ enums can be mapped in one of 2 ways, depending on the dart:enum feature specified:
   * 1) Simple enums - integer constants within the proxy class or module class
   * 2) Proper enums - Dart enum (named after the C/C++ enum name)
   * Anonymous enums always default to 1)
   * ---------------------------------------------------------------------- */

  virtual int enumDeclaration(Node *n) {

    if (!ImportMode) {
      if (getCurrentClass() && (cplus_mode != PUBLIC))
        return SWIG_NOWRAP;

      String *symname = Getattr(n, "sym:name");
      String *constants_code = is_wrapping_class() ? proxy_class_constants_code : module_class_constants_code;
      EnumFeature enum_feature = decodeEnumFeature(n);
      String *typemap_lookup_type = Getattr(n, "name");
      bool proper_enum = (enum_feature == ProperEnum) && symname && typemap_lookup_type;

      enum_code = NewString("");
      enum_values = NewString("");
      enum_next_value_known = true;
      enum_next_value = 0;

      String *enum_name = NULL;
      if (proper_enum) {
        // Wrap (non-anonymous) C/C++ enum within a Dart enum
        enum_name = getEnumName(Getattr(n, "enumtype"));
        if (!enum_name)
          enum_name = symname;
        enum_name = Copy(enum_name);
        if (!addSymbol(enum_name, n))
          return SWIG_ERROR;

        Printv(enum_code, typemapLookup(n, "dartimports", typemap_lookup_type, WARN_NONE), NIL);
        const String *interfaces = typemapLookup(n, "dartinterfaces", typemap_lookup_type, WARN_NONE);
        Printv(enum_code,
               typemapLookup(n, "dartclassmodifiers", typemap_lookup_type, WARN_DART_TYPEMAP_CLASSMOD_UNDEF),  // Class modifiers (enum)
               " ",
               enum_name,
               *Char(interfaces) ? " implements " : "",
               interfaces,
               " {\n",
               NIL);
      } else {
        // Wrap C++ enum with integers - just indicate start of enum with a comment, no comment for anonymous enums of any sort
        if (symname && !Getattr(n, "unnamedinstance"))
          Printf(constants_code, "  // %s\n", symname);
      }

      // Emit each enum item
      Language::enumDeclaration(n);

      if (proper_enum) {
        // Finish the enum declaration
        if (Len(enum_values) == 0) {
          // A Dart enum must have at least one value
          Printf(enum_code, "  swigNoValue");
          Printf(enum_values, "0");
        }
        Printv(enum_code,
               ";\n",
               typemapLookup(n, "dartbody", typemap_lookup_type, WARN_DART_TYPEMAP_DARTBODY_UNDEF),  // main body of enum
               typemapLookup(n, "dartcode", typemap_lookup_type, WARN_NONE),                         // extra Dart code
               "}\n\n",
               NIL);

        Replaceall(enum_code, "$dartclassname", enum_name);
        Replaceall(enum_code, "$enumvalues", enum_values);
        Replaceall(enum_code, "$module", module_class_name);
        Replaceall(enum_code, "$imclassname", imclass_name);
        Printv(library_code, enum_code, NIL);
      } else {
        // Wrap C++ enum with simple constant
        Printf(enum_code, "\n");
        if (is_wrapping_class())
          Printv(proxy_class_constants_code, enum_code, NIL);
        else
          Printv(module_class_constants_code, enum_code, NIL);
      }

      Delete(enum_name);
      Delete(enum_code);
      enum_code = NULL;
      Delete(enum_values);
      enum_values = NULL;
    }
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * enumvalueDeclaration()
   * ---------------------------------------------------------------------- */

  virtual int enumvalueDeclaration(Node *n) {
    if (getCurrentClass() && (cplus_mode != PUBLIC))
      return SWIG_NOWRAP;

    Swig_require("enumvalueDeclaration", n, "*name", "?value", NIL);
    String *symname = Getattr(n, "sym:name");
    String *value = Getattr(n, "value");
    String *name = Getattr(n, "name");
    Node *parent = parentNode(n);
    int unnamedinstance = GetFlag(parent, "unnamedinstance");
    String *parent_name = Getattr(parent, "name");
    String *newsymname = 0;
    String *tmpValue;

    // Strange hack from parent method
    if (value)
      tmpValue = NewString(value);
    else
      tmpValue = NewString(name);
    // Note that this is used in enumValue() amongst other places
    Setattr(n, "value", tmpValue);

    // Deal with enum values that are not int
    int swigtype = SwigType_type(Getattr(n, "type"));
    if (swigtype == T_CHAR) {
      String *enumstringval = Getattr(n, "enumstringval");
      if (enumstringval && Len(enumstringval) == 1 && isprint((unsigned char)*Char(enumstringval)) && *Char(enumstringval) != '\\' &&
          *Char(enumstringval) != '\'') {
        // A character literal is used as its character code
        String *val = NewStringf("%d", (int)(unsigned char)*Char(enumstringval));
        Setattr(n, "enumvalue", val);
        Delete(val);
      } else {
        Delattr(n, "enumvalue");
      }
    } else {
      String *numval = Getattr(n, "enumnumval");
      if (numval)
        Setattr(n, "enumvalue", numval);
    }

    {
      EnumFeature enum_feature = decodeEnumFeature(parent);

      if ((enum_feature == SimpleEnum) && GetFlag(parent, "scopedenum")) {
        newsymname = Swig_name_member(0, Getattr(parent, "sym:name"), symname);
        symname = newsymname;
      }

      // Add to language symbol table
      String *scope = 0;
      if (unnamedinstance || !parent_name || enum_feature == SimpleEnum) {
        String *enumClassPrefix = getEnumClassPrefix();
        if (enumClassPrefix) {
          scope = NewString(enumClassPrefix);
        } else {
          scope = Copy(module_class_name);
        }
      } else {
        scope = Copy(Getattr(parent, "sym:name"));
        if (getCurrentClass())
          Insert(scope, 0, NewStringf("%s.", proxy_class_name));
      }
      if (!addSymbol(symname, n, scope))
        return SWIG_ERROR;

      if ((enum_feature == ProperEnum) && parent_name && !unnamedinstance) {
        // Wrap (non-anonymous) C/C++ enum with a Dart enum
        if (Len(enum_values) > 0) {
          Printf(enum_code, ",\n");
          Printf(enum_values, ", ");
        }
        Printf(enum_code, "  %s", symname);
        String *item_value = enumValue(n);
        Printv(enum_values, item_value, NIL);
        Delete(item_value);
      } else {
        // Wrap C/C++ enums with integer constants
        SwigType *typemap_lookup_type = parent_name ? parent_name : NewString("enum ");
        Setattr(n, "type", typemap_lookup_type);
        const String *tm = typemapLookup(n, "darttype", typemap_lookup_type, WARN_DART_TYPEMAP_DARTTYPE_UNDEF);

        String *return_type = Copy(tm);
        substituteClassname(typemap_lookup_type, return_type);

        String *item_value = enumValue(n);
        Printf(enum_code, "  static %s %s %s = %s;\n", isDartIntLiteral(item_value) ? "const" : "final", return_type, symname, item_value);
        Delete(item_value);
        Delete(return_type);
      }

      Delete(scope);
    }

    Delete(newsymname);
    Delete(tmpValue);
    Swig_restore(n);
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------
   * constantWrapper()
   *
   * Used for wrapping constants - #define or %constant.
   * Also for inline initialised const static primitive type member variables (short, int, double, enums etc).
   * Dart static final variables are generated for these, which are initialised using a call to a C wrapper
   * function returning the C constant value.
   * If the %dartconst(1) feature is used then the C constant value is used to initialise a Dart const variable.
   * However, if the %dartconstvalue feature is used, it overrides all other ways to generate the initialisation.
   * Also note that this method might be called for wrapping enum items (when the enum value is not known).
   * ------------------------------------------------------------------------ */

  virtual int constantWrapper(Node *n) {
    String *symname = Getattr(n, "sym:name");
    SwigType *t = Getattr(n, "type");
    String *tm;
    String *return_type = NewString("");
    String *constants_code = NewString("");
    Swig_save("constantWrapper", n, "tmap:ctype:out", "tmap:imtype:out", "tmap:darttype:out", "tmap:out:null", NIL);

    bool is_enum_item = (Cmp(nodeType(n), "enumitem") == 0);

    const String *itemname = wrapping_member_flag ? variable_name : symname;
    if (!is_enum_item) {
      String *scope = Copy(proxy_class_name ? proxy_class_name : module_class_name);
      if (!addSymbol(itemname, n, scope))
        return SWIG_ERROR;
      Delete(scope);
    }

    // The %dartconst feature determines how the constant value is obtained
    int const_feature_flag = GetFlag(n, "feature:dart:const");

    /* Adjust the enum type for the Swig_typemap_lookup.
     * We want the same darttype typemap for all the enum items so we use the enum type (parent node). */
    if (is_enum_item) {
      t = Getattr(parentNode(n), "enumtype");
      Setattr(n, "type", t);
    }

    /* Get Dart return types */
    if ((tm = Swig_typemap_lookup("darttype", n, "", 0))) {
      String *darttypeout = Getattr(n, "tmap:darttype:out");  // the type in the darttype typemap's out attribute overrides the type in the typemap
      if (darttypeout)
        tm = darttypeout;
      substituteClassname(t, tm);
      Printf(return_type, "%s", tm);
    } else {
      Swig_warning(WARN_DART_TYPEMAP_DARTTYPE_UNDEF, input_file, line_number, "No darttype typemap defined for %s\n", SwigType_str(t, 0));
    }

    // Check for the %dartconstvalue feature
    String *value = Getattr(n, "feature:dart:constvalue");

    if (value) {
      Printf(constants_code, "  static const %s %s = %s;\n", return_type, itemname, value);
    } else if (!const_feature_flag) {
      // Default constant handling will work with any type of C constant and initialises the Dart variable from C through a C wrapper call.
      // The intermediary class function is generated by variableWrapper, the Dart conversion code is generated from the dartout typemap
      // into an immediately invoked function expression, which is lazily evaluated on first access of the static final variable.
      SetFlag(n, "feature:immutable");
      enum_constant_flag = true;
      variableWrapper(n);
      enum_constant_flag = false;

      if (!is_enum_item) {
        // The getter has no parameters, a constant of function pointer type has the function parameters in its parms attribute
        Swig_save("constantWrapperGetter", n, "parms", NIL);
        Delattr(n, "parms");
        String *getter_name = Swig_name_get(getNSpace(), symname);
        String *body = proxyFunctionBody(n, getter_name, NULL, NULL);
        Swig_restore(n);
        Printf(constants_code, "  static final %s %s = (() %s)();\n", return_type, itemname, body);
        Delete(body);
        Delete(getter_name);
      }
    } else {
      // Alternative constant handling will use the C syntax to make a true Dart constant and hope that it compiles as Dart code
      String *dartvalue = NULL;
      if (Getattr(n, "stringval")) {
        switch (SwigType_type(t)) {
        case T_STRING:
        case T_CHAR:
          {
            String *escaped = dartEscapedString(Getattr(n, "stringval"));
            dartvalue = NewStringf("'%s'", escaped);
            Delete(escaped);
            break;
          }
        default:
          break;
        }
      }
      if (!dartvalue) {
        if (Getattr(n, "wrappedasconstant"))
          dartvalue = Copy(Getattr(n, "staticmembervariableHandler:value"));
        else
          dartvalue = Copy(Getattr(n, "value"));
      }
      Printf(constants_code, "  static const %s %s = %s;\n", return_type, itemname, dartvalue);
      Delete(dartvalue);
    }

    // Emit the generated code to appropriate place
    // Enums only emit the intermediate class method, so no proxy or module class wrapper methods needed
    if (!is_enum_item) {
      if (wrapping_member_flag)
        Printv(proxy_class_constants_code, constants_code, NIL);
      else
        Printv(module_class_constants_code, constants_code, NIL);
    }
    // Cleanup
    Swig_restore(n);
    Delete(return_type);
    Delete(constants_code);
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * insertDirective()
   * ----------------------------------------------------------------------------- */

  virtual int insertDirective(Node *n) {
    int ret = SWIG_OK;
    String *code = Getattr(n, "code");
    String *section = Getattr(n, "section");
    Replaceall(code, "$module", module_class_name);
    Replaceall(code, "$imclassname", imclass_name);
    Replaceall(code, "$dllimport", libname);

    if (!ImportMode && (Cmp(section, "proxycode") == 0)) {
      if (proxy_class_code) {
        Swig_typemap_replace_embedded_typemap(code, n);
        int offset = Len(code) > 0 && *Char(code) == '\n' ? 1 : 0;
        Printv(proxy_class_code, Char(code) + offset, "\n", NIL);
      }
    } else {
      ret = Language::insertDirective(n);
    }
    return ret;
  }

  /* -----------------------------------------------------------------------------
   * pragmaDirective()
   *
   * Valid Pragmas:
   * imclassbase            - base (extends) for the intermediary class
   * imclassclassmodifiers  - class modifiers for the intermediary class
   * imclasscode            - text (Dart code) is copied verbatim to the intermediary class
   * imclassinterfaces      - interfaces (implements) for the intermediary class
   *
   * modulebase              - base (extends) for the module class
   * moduleclassmodifiers    - class modifiers for the module class
   * modulecode              - text (Dart code) is copied verbatim to the module class
   * moduleimports           - import directives for the generated Dart library
   * moduleinterfaces        - interfaces (implements) for the module class
   *
   * librarycode             - text (Dart code) is copied verbatim to the top level of the generated Dart library
   * ----------------------------------------------------------------------------- */

  virtual int pragmaDirective(Node *n) {
    if (!ImportMode) {
      String *lang = Getattr(n, "lang");
      String *code = Getattr(n, "name");
      String *value = Getattr(n, "value");

      if (Strcmp(lang, "dart") == 0) {

        String *strvalue = NewString(value);
        Replaceall(strvalue, "\\\"", "\"");

        if (Strcmp(code, "imclassbase") == 0) {
          Delete(imclass_baseclass);
          imclass_baseclass = Copy(strvalue);
        } else if (Strcmp(code, "imclassclassmodifiers") == 0) {
          Delete(imclass_class_modifiers);
          imclass_class_modifiers = Copy(strvalue);
        } else if (Strcmp(code, "imclasscode") == 0) {
          Printf(imclass_class_code, "%s\n", strvalue);
        } else if (Strcmp(code, "imclassinterfaces") == 0) {
          Delete(imclass_interfaces);
          imclass_interfaces = Copy(strvalue);
        } else if (Strcmp(code, "modulebase") == 0) {
          Delete(module_baseclass);
          module_baseclass = Copy(strvalue);
        } else if (Strcmp(code, "moduleclassmodifiers") == 0) {
          Delete(module_class_modifiers);
          module_class_modifiers = Copy(strvalue);
        } else if (Strcmp(code, "modulecode") == 0) {
          Printf(module_class_code, "%s\n", strvalue);
        } else if (Strcmp(code, "moduleimports") == 0) {
          Delete(module_imports);
          module_imports = Copy(strvalue);
        } else if (Strcmp(code, "moduleinterfaces") == 0) {
          Delete(module_interfaces);
          module_interfaces = Copy(strvalue);
        } else if (Strcmp(code, "librarycode") == 0) {
          Printf(library_pragma_code, "%s\n", strvalue);
        } else {
          Swig_error(input_file, line_number, "Unrecognized pragma.\n");
        }
        Delete(strvalue);
      }
    }
    return Language::pragmaDirective(n);
  }

  /* -----------------------------------------------------------------------------
   * upcastsCode()
   *
   * Add code for C++ casting to base class
   * ----------------------------------------------------------------------------- */

  void upcastsCode(SwigType *smart, SwigType *bsmart, String *upcast_method_name, SwigType *c_classname, SwigType *c_baseclassname) {
    String *wname = Swig_name_wrapper(upcast_method_name);

    Printf(imclass_class_code,
           "  late final %s = _library.lookupFunction<ffi.Pointer<ffi.Void> Function(ffi.Pointer<ffi.Void>), ffi.Pointer<ffi.Void> "
           "Function(ffi.Pointer<ffi.Void>)>('%s', isLeaf: true);\n",
           upcast_method_name,
           wname);

    if (smart) {
      if (bsmart) {
        String *smartnamestr = SwigType_namestr(smart);
        String *bsmartnamestr = SwigType_namestr(bsmart);

        Printv(upcasts_code,
               "SWIGEXPORT ",
               bsmartnamestr,
               " * SWIGSTDCALL ",
               wname,
               "(",
               smartnamestr,
               " *jarg1) {\n",
               "    return jarg1 ? new ",
               bsmartnamestr,
               "(*jarg1) : 0;\n"
               "}\n",
               "\n",
               NIL);

        Delete(bsmartnamestr);
        Delete(smartnamestr);
      }
    } else {
      String *classname = SwigType_namestr(c_classname);
      String *baseclassname = SwigType_namestr(c_baseclassname);

      Printv(upcasts_code,
             "SWIGEXPORT ",
             baseclassname,
             " * SWIGSTDCALL ",
             wname,
             "(",
             classname,
             " *jarg1) {\n",
             "    return (",
             baseclassname,
             " *)jarg1;\n"
             "}\n",
             "\n",
             NIL);

      Delete(baseclassname);
      Delete(classname);
    }

    Delete(wname);
  }

  /* -----------------------------------------------------------------------------
   * emitProxyClassDefAndCPPCasts()
   * ----------------------------------------------------------------------------- */

  void emitProxyClassDefAndCPPCasts(Node *n) {
    SwigType *c_classname = Getattr(n, "name");
    SwigType *c_baseclassname = NULL;
    String *baseclass = NULL;
    SwigType *typemap_lookup_type = Getattr(n, "classtypeobj");
    SwigType *smart = Getattr(n, "smart");
    SwigType *bsmart = 0;

    // Inheritance from pure Dart classes
    Node *attributes = NewHash();
    const String *pure_baseclass = typemapLookup(n, "dartbase", typemap_lookup_type, WARN_NONE, attributes);
    bool purebase_replace = GetFlag(attributes, "tmap:dartbase:replace") ? true : false;
    bool purebase_notderived = GetFlag(attributes, "tmap:dartbase:notderived") ? true : false;
    Delete(attributes);

    // C++ inheritance
    if (!purebase_replace) {
      List *baselist = Getattr(n, "bases");
      if (baselist) {
        Iterator base = First(baselist);
        while (base.item) {
          if (!GetFlag(base.item, "feature:ignore")) {
            SwigType *baseclassname = Getattr(base.item, "name");
            if (!c_baseclassname) {
              String *name = getProxyName(baseclassname);
              if (name) {
                c_baseclassname = baseclassname;
                baseclass = name;
                bsmart = Getattr(base.item, "smart");
              }
            } else {
              /* Warn about multiple inheritance for additional base class(es) */
              String *proxyclassname = Getattr(n, "classtypeobj");
              Swig_warning(WARN_DART_MULTIPLE_INHERITANCE,
                           Getfile(n),
                           Getline(n),
                           "Warning for %s, base %s ignored. Multiple inheritance is not supported in Dart.\n",
                           SwigType_namestr(proxyclassname),
                           SwigType_namestr(baseclassname));
            }
          }
          base = Next(base);
        }
      }
    }

    bool derived = baseclass != 0;
    if (derived && purebase_notderived)
      pure_baseclass = empty_string;
    const String *wanted_base = baseclass ? baseclass : pure_baseclass;

    if (purebase_replace) {
      wanted_base = pure_baseclass;
      derived = false;
      baseclass = NULL;
      if (purebase_notderived)
        Swig_error(Getfile(n),
                   Getline(n),
                   "The dartbase typemap for proxy %s must contain just one of the 'replace' or 'notderived' attributes.\n",
                   typemap_lookup_type);
    } else if (Len(pure_baseclass) > 0 && Len(baseclass) > 0) {
      Swig_warning(WARN_DART_MULTIPLE_INHERITANCE,
                   Getfile(n),
                   Getline(n),
                   "Warning for %s, base %s ignored. Multiple inheritance is not supported in Dart. "
                   "Perhaps you need one of the 'replace' or 'notderived' attributes in the dartbase typemap?\n",
                   typemap_lookup_type,
                   pure_baseclass);
    }

    // Pure Dart interfaces
    const String *interfaces = typemapLookup(n, derived ? "dartinterfaces_derived" : "dartinterfaces", typemap_lookup_type, WARN_NONE);

    // Start writing the proxy class
    Printv(proxy_class_def,
           typemapLookup(n, "dartimports", typemap_lookup_type, WARN_NONE),                                // Import statements
           typemapLookup(n, "dartclassmodifiers", typemap_lookup_type, WARN_DART_TYPEMAP_CLASSMOD_UNDEF),  // Class modifiers
           " $dartclassname",                                                                              // Class name and base class
           *Char(wanted_base) ? " extends " : "",
           wanted_base,
           *Char(interfaces) ? " implements " : "",  // Interfaces
           interfaces,
           " {",
           derived ? typemapLookup(n, "dartbody_derived", typemap_lookup_type, WARN_DART_TYPEMAP_DARTBODY_UNDEF) :  // main body of class
             typemapLookup(n, "dartbody", typemap_lookup_type, WARN_DART_TYPEMAP_DARTBODY_UNDEF),                   // main body of class
           NIL);

    // The C++ destructor is called by the NativeFinalizer and by the dispose method
    String *finalizer = destructor_wname ? NewStringf("ffi.NativeFinalizer(%s().swigLookupDeleter('%s'))", imclass_name, destructor_wname) : NewString("null");
    Replaceall(proxy_class_def, "$finalizer", finalizer);
    Delete(finalizer);
    Replaceall(proxy_class_def, "$directorconnect", "");

    String *dispose = Copy(typemapLookup(n, derived ? "dartdispose_derived" : "dartdispose", typemap_lookup_type, WARN_NONE));
    if (*Char(destructor_call))
      Replaceall(dispose, "$imcall", destructor_call);
    else
      Replaceall(dispose, "$imcall", "throw UnsupportedError('C++ destructor does not have public access')");
    Printv(proxy_class_def, dispose, NIL);
    Delete(dispose);

    // Emit extra user code
    Printv(proxy_class_def,
           typemapLookup(n, "dartcode", typemap_lookup_type, WARN_NONE),  // extra Dart code
           "\n",
           NIL);

    if (derived) {
      String *upcast_method_name = Swig_name_member(getNSpace(), getClassPrefix(), smart != 0 ? "SWIGSmartPtrUpcast" : "SWIGUpcast");
      upcastsCode(smart, bsmart, upcast_method_name, c_classname, c_baseclassname);
      Delete(upcast_method_name);
    }
  }

  /* ----------------------------------------------------------------------
   * classHandler()
   * ---------------------------------------------------------------------- */

  virtual int classHandler(Node *n) {
    // save class local variables
    String *old_proxy_class_name = proxy_class_name;
    String *old_destructor_call = destructor_call;
    String *old_destructor_wname = destructor_wname;
    String *old_proxy_class_constants_code = proxy_class_constants_code;
    String *old_proxy_class_def = proxy_class_def;
    String *old_proxy_class_code = proxy_class_code;

    proxy_class_name = NewString(Getattr(n, "sym:name"));
    if (!addSymbol(proxy_class_name, n))
      return SWIG_ERROR;

    if (Cmp(proxy_class_name, imclass_name) == 0) {
      Printf(stderr, "Class name cannot be equal to intermediary class name: %s\n", proxy_class_name);
      Exit(EXIT_FAILURE);
    }

    if (Cmp(proxy_class_name, module_class_name) == 0) {
      Printf(stderr, "Class name cannot be equal to module class name: %s\n", proxy_class_name);
      Exit(EXIT_FAILURE);
    }

    proxy_class_def = NewString("");
    proxy_class_code = NewString("");
    destructor_call = NewString("");
    destructor_wname = NULL;
    proxy_class_constants_code = NewString("");

    Language::classHandler(n);

    emitProxyClassDefAndCPPCasts(n);

    String *dartclazzname = Swig_name_member(getNSpace(), getClassPrefix(), "");  // mangled full proxy class name

    Replaceall(proxy_class_def, "$dartclassname", proxy_class_name);
    Replaceall(proxy_class_code, "$dartclassname", proxy_class_name);
    Replaceall(proxy_class_constants_code, "$dartclassname", proxy_class_name);

    Replaceall(proxy_class_def, "$dartclazzname", dartclazzname);
    Replaceall(proxy_class_code, "$dartclazzname", dartclazzname);
    Replaceall(proxy_class_constants_code, "$dartclazzname", dartclazzname);

    Replaceall(proxy_class_def, "$module", module_class_name);
    Replaceall(proxy_class_code, "$module", module_class_name);
    Replaceall(proxy_class_constants_code, "$module", module_class_name);

    Replaceall(proxy_class_def, "$imclassname", imclass_name);
    Replaceall(proxy_class_code, "$imclassname", imclass_name);
    Replaceall(proxy_class_constants_code, "$imclassname", imclass_name);

    Replaceall(proxy_class_def, "$dllimport", libname);
    Replaceall(proxy_class_code, "$dllimport", libname);
    Replaceall(proxy_class_constants_code, "$dllimport", libname);

    Printv(library_code, proxy_class_def, proxy_class_code, NIL);

    // Write out all the constants
    if (Len(proxy_class_constants_code) != 0)
      Printv(library_code, proxy_class_constants_code, NIL);

    Printf(library_code, "}\n\n");

    Delete(dartclazzname);
    Delete(proxy_class_name);
    proxy_class_name = old_proxy_class_name;
    Delete(destructor_call);
    destructor_call = old_destructor_call;
    Delete(destructor_wname);
    destructor_wname = old_destructor_wname;
    Delete(proxy_class_constants_code);
    proxy_class_constants_code = old_proxy_class_constants_code;
    Delete(proxy_class_def);
    proxy_class_def = old_proxy_class_def;
    Delete(proxy_class_code);
    proxy_class_code = old_proxy_class_code;

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * memberfunctionHandler()
   * ---------------------------------------------------------------------- */

  virtual int memberfunctionHandler(Node *n) {
    Language::memberfunctionHandler(n);

    String *overloaded_name = getOverloadedName(n);
    String *intermediary_function_name = Swig_name_member(getNSpace(), getClassPrefix(), overloaded_name);
    Setattr(n, "proxyfuncname", Getattr(n, "sym:name"));
    Setattr(n, "imfuncname", intermediary_function_name);
    proxyClassFunctionHandler(n);
    Delete(overloaded_name);
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * staticmemberfunctionHandler()
   * ---------------------------------------------------------------------- */

  virtual int staticmemberfunctionHandler(Node *n) {

    static_flag = true;
    Language::staticmemberfunctionHandler(n);

    String *overloaded_name = getOverloadedName(n);
    String *intermediary_function_name = Swig_name_member(getNSpace(), getClassPrefix(), overloaded_name);
    Setattr(n, "proxyfuncname", Getattr(n, "sym:name"));
    Setattr(n, "imfuncname", intermediary_function_name);
    proxyClassFunctionHandler(n);
    Delete(overloaded_name);
    static_flag = false;

    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * proxyFunctionBody()
   *
   * Generates the body of a Dart function calling the intermediary class function
   * 'imfuncname' using the dartin typemaps for the parameters and the dartout
   * typemap for the return value. The Dart parameter declarations are added
   * to 'param_decls' and the Dart parameter types are added to the list
   * 'param_types' if these are not NULL. The first parameter is the C++ 'this'
   * pointer when wrapping a non-static member function.
   * Returns the body as a new string.
   * ----------------------------------------------------------------------------- */

  String *proxyFunctionBody(Node *n, const String *imfuncname, String *param_decls, List *param_types, bool member_function = false,
                            bool single_param_name_value = false) {
    SwigType *t = Getattr(n, "type");
    ParmList *l = Getattr(n, "parms");
    String *tm;
    Parm *p;
    int i;
    String *imcall = NewString("");
    String *pre_code = NewString("");
    String *post_code = NewString("");
    String *terminator_code = NewString("");

    if (l) {
      if (SwigType_type(Getattr(l, "type")) == T_VOID) {
        l = nextSibling(l);
      }
    }

    /* Attach the non-standard typemaps to the parameter list */
    Swig_typemap_attach_parms("in", l, NULL);
    Swig_typemap_attach_parms("darttype", l, NULL);
    Swig_typemap_attach_parms("dartin", l, NULL);

    Printv(imcall, imclass_name, "().", imfuncname, "(", NIL);
    if (member_function)
      Printf(imcall, "_swigCPtr_%s", proxy_class_name);

    emit_mark_varargs(l);
    int gencomma = member_function ? 1 : 0;
    int param_count = 0;

    /* Output each parameter */
    for (i = 0, p = l; p; i++) {

      /* Ignored varargs */
      if (checkAttribute(p, "varargs:ignore", "1")) {
        p = nextSibling(p);
        continue;
      }

      /* Ignored parameters */
      if (checkAttribute(p, "tmap:in:numinputs", "0")) {
        p = Getattr(p, "tmap:in:next");
        continue;
      }

      /* Ignore the 'this' argument for variable wrappers */
      if (variable_wrapper_flag && i == 0) {
        p = Getattr(p, "tmap:in:next");
        continue;
      }

      SwigType *pt = Getattr(p, "type");
      String *param_type = NewString("");

      /* Get the Dart parameter type */
      if ((tm = Getattr(p, "tmap:darttype"))) {
        substituteClassname(pt, tm);
        Printf(param_type, "%s", tm);
      } else {
        Swig_warning(WARN_DART_TYPEMAP_DARTTYPE_UNDEF, input_file, line_number, "No darttype typemap defined for %s\n", SwigType_str(pt, 0));
      }

      if (gencomma)
        Printf(imcall, ", ");
      gencomma = 1;

      String *arg = single_param_name_value ? NewString("value") : makeParameterName(n, p, i, false);

      // Use typemaps to transform type used in Dart proxy function to type used in the intermediary class function
      if ((tm = Getattr(p, "tmap:dartin"))) {
        substituteClassname(pt, tm);
        Replaceall(tm, "$dartinput", arg);
        String *pre = Getattr(p, "tmap:dartin:pre");
        if (pre) {
          substituteClassname(pt, pre);
          Replaceall(pre, "$dartinput", arg);
          if (Len(pre_code) > 0)
            Printf(pre_code, "\n");
          Printv(pre_code, pre, NIL);
        }
        String *post = Getattr(p, "tmap:dartin:post");
        if (post) {
          substituteClassname(pt, post);
          Replaceall(post, "$dartinput", arg);
          if (Len(post_code) > 0)
            Printf(post_code, "\n");
          Printv(post_code, post, NIL);
        }
        String *terminator = Getattr(p, "tmap:dartin:terminator");
        if (terminator) {
          substituteClassname(pt, terminator);
          Replaceall(terminator, "$dartinput", arg);
          if (Len(terminator_code) > 0)
            Insert(terminator_code, 0, "\n");
          Insert(terminator_code, 0, terminator);
        }
        Printv(imcall, tm, NIL);
      } else {
        Swig_warning(WARN_DART_TYPEMAP_DARTIN_UNDEF, input_file, line_number, "No dartin typemap defined for %s\n", SwigType_str(pt, 0));
      }

      /* Add parameter to proxy function */
      if (param_decls)
        Printf(param_decls, "%s%s %s", param_count ? ", " : "", param_type, arg);
      if (param_types)
        Append(param_types, param_type);
      param_count++;

      Delete(arg);
      Delete(param_type);
      p = Getattr(p, "tmap:in:next");
    }

    Printf(imcall, ")");

    // Transform return type used in the intermediary class function to type used in the Dart proxy function
    String *body = NULL;
    SwigType *reftype = getterByReferenceType(n);
    if (reftype) {
      Swig_save("proxyFunctionBody", n, "type", "tmap:dartout", "tmap:dartout:excode", NIL);
      Setattr(n, "type", reftype);
      t = reftype;
    }
    if ((tm = Swig_typemap_lookup("dartout", n, "", 0))) {
      body = Copy(tm);
      excodeSubstitute(n, body, "dartout", n);
      bool is_pre_code = Len(pre_code) > 0;
      bool is_post_code = Len(post_code) > 0;
      bool is_terminator_code = Len(terminator_code) > 0;
      if (is_pre_code || is_post_code || is_terminator_code) {
        Replaceall(body, "\n ", "\n   ");  // add extra indentation to code in typemap
        if (is_post_code) {
          Insert(body, 0, "\n    try ");
          Printv(body, " finally {\n", post_code, "\n    }", NIL);
        } else {
          Insert(body, 0, "\n    ");
        }
        if (is_pre_code) {
          Insert(body, 0, pre_code);
          Insert(body, 0, "\n");
        }
        if (is_terminator_code) {
          Printv(body, "\n", terminator_code, NIL);
        }
        Insert(body, 0, "{");
        Printf(body, "\n  }");
      }
      if (GetFlag(n, "feature:new"))
        Replaceall(body, "$owner", "true");
      else
        Replaceall(body, "$owner", "false");
      substituteClassname(t, body);
      Replaceall(body, "$imfuncname", imfuncname);
      Replaceall(body, "$imcall", imcall);
    } else {
      Swig_warning(WARN_DART_TYPEMAP_DARTOUT_UNDEF, input_file, line_number, "No dartout typemap defined for %s\n", SwigType_str(t, 0));
      body = NewString("{}");
    }
    if (reftype) {
      Swig_restore(n);
      Delete(reftype);
    }

    Delete(pre_code);
    Delete(post_code);
    Delete(terminator_code);
    Delete(imcall);
    return body;
  }

  /* -----------------------------------------------------------------------------
   * getterByReferenceType()
   *
   * The getter for a variable of class type held by value returns a pointer to the variable.
   * The Dart typemaps for a reference are used instead of the ones for a pointer so that the
   * Dart getter is not nullable. Returns the reference type to use for the Dart typemaps or NULL.
   * ----------------------------------------------------------------------------- */

  SwigType *getterByReferenceType(Node *n) {
    String *accessor = Getattr(n, "dart:accessor");
    SwigType *vartype = Getattr(n, "dart:vartype");
    SwigType *t = Getattr(n, "type");
    if (!accessor || !Equal(accessor, "get") || !vartype || !t)
      return NULL;
    SwigType *resolved_vartype = SwigType_typedef_resolve_all(vartype);
    bool by_value = !SwigType_ispointer(resolved_vartype) && !SwigType_isreference(resolved_vartype) && !SwigType_isrvalue_reference(resolved_vartype) &&
                    !SwigType_isarray(resolved_vartype);
    Delete(resolved_vartype);
    if (!by_value || !SwigType_ispointer(t))
      return NULL;
    SwigType *reftype = Copy(t);
    Delete(SwigType_pop(reftype));
    SwigType_add_reference(reftype);
    return reftype;
  }

  /* -----------------------------------------------------------------------------
   * returnType()
   *
   * Returns the Dart return type of a function as a new string.
   * ----------------------------------------------------------------------------- */

  String *returnType(Node *n) {
    SwigType *reftype = getterByReferenceType(n);
    if (reftype) {
      Swig_save("returnType", n, "type", NIL);
      Setattr(n, "type", reftype);
    }
    SwigType *t = Getattr(n, "type");
    String *return_type = NewString("");
    String *tm;
    if ((tm = Swig_typemap_lookup("darttype", n, "", 0))) {
      // Polymorphic (covariant) return types are supported in Dart
      String *darttypeout = Getattr(n, "tmap:darttype:out");  // the type in the darttype typemap's out attribute overrides the type in the typemap
      if (darttypeout)
        tm = darttypeout;
      substituteClassname(t, tm);
      Printf(return_type, "%s", tm);
    } else {
      Swig_warning(WARN_DART_TYPEMAP_DARTTYPE_UNDEF, input_file, line_number, "No darttype typemap defined for %s\n", SwigType_str(t, 0));
    }
    if (reftype) {
      Swig_restore(n);
      Delete(reftype);
    }
    return return_type;
  }

  /* -----------------------------------------------------------------------------
   * emitDartFunction()
   *
   * Emit a Dart function, getter or setter into 'code'. For overloaded functions,
   * a private implementation function is emitted for each overload and a function
   * dispatching to the implementation functions is emitted after the last overload.
   * ----------------------------------------------------------------------------- */

  void emitDartFunction(Node *n, String *code, const String *function_name, const String *imfuncname, bool is_static, bool member_function) {
    String *accessor = Getattr(n, "dart:accessor");
    String *param_decls = NewString("");
    List *param_types = NewList();
    String *return_type = returnType(n);
    bool overloaded = !accessor && Getattr(n, "sym:overloaded");
    String *methodmods = Getattr(n, "feature:dart:methodmodifiers");

    String *body = proxyFunctionBody(n, imfuncname, param_decls, param_types, member_function, accessor && Equal(accessor, "set"));

    if (methodmods)
      Printf(code, "  %s", methodmods);
    else
      Printf(code, "  ");
    if (is_static)
      Printf(code, "static ");

    if (accessor && Equal(accessor, "get")) {
      Printf(code, "%s get %s %s\n\n", return_type, function_name, body);
    } else if (accessor && Equal(accessor, "set")) {
      Printf(code, "set %s(%s) %s\n\n", function_name, param_decls, body);
    } else if (overloaded) {
      String *impl_name = overloadImplName(n, function_name);
      Printf(code, "%s %s(%s) %s\n\n", return_type, impl_name, param_decls, body);
      Setattr(n, "dart:implname", impl_name);
      Setattr(n, "dart:paramtypes", param_types);
      Setattr(n, "dart:returntype", return_type);
      Delete(impl_name);
      if (!Getattr(n, "sym:nextSibling"))
        emitOverloadDispatcher(n, code, function_name, is_static);
    } else {
      Printf(code, "%s %s(%s) %s\n\n", return_type, function_name, param_decls, body);
    }

    Delete(body);
    Delete(return_type);
    Delete(param_types);
    Delete(param_decls);
  }

  /* -----------------------------------------------------------------------------
   * overloadImplName()
   *
   * Name of the private Dart function implementing one of the overloads of a function.
   * ----------------------------------------------------------------------------- */

  String *overloadImplName(Node *n, const String *function_name) {
    String *impl_name = NewStringf("_swig_%s%s", function_name, Getattr(n, "sym:overname"));
    if (proxy_class_name && !static_flag && !Equal(nodeType(n), "constructor")) {
      // Private instance methods with the same name override each other in a class hierarchy within a Dart library
      Printf(impl_name, "_%s", proxy_class_name);
    }
    return impl_name;
  }

  /* -----------------------------------------------------------------------------
   * emitOverloadDispatcher()
   *
   * Emit a Dart function dispatching to the overloaded C++ functions.
   * Dart does not support overloading so the dispatch is done at runtime by
   * checking the type of each argument using the Dart parameter types of each
   * overload. The overloads are checked in the order of precedence of the C++
   * overload resolution rules approximated by SWIG.
   * If the overloads only differ by trailing parameters with default values,
   * a function with optional nullable parameters is generated instead.
   * ----------------------------------------------------------------------------- */

  void emitOverloadDispatcher(Node *n, String *code, const String *function_name, bool is_static) {
    List *overloads = NewList();
    for (Node *o = Getattr(n, "sym:overloaded"); o; o = Getattr(o, "sym:nextSibling")) {
      if (Getattr(o, "dart:implname"))
        Append(overloads, o);
    }

    // Return type of the dispatcher, dynamic unless all the overloads return the same type
    int max_params = 0;
    String *return_type = NULL;
    bool same_return_type = true;
    bool default_args_only = true;
    Node *defaultargs_origin = NULL;
    for (Iterator it = First(overloads); it.item; it = Next(it)) {
      Node *o = it.item;
      List *types = Getattr(o, "dart:paramtypes");
      if (Len(types) > max_params)
        max_params = Len(types);
      String *rt = Getattr(o, "dart:returntype");
      if (!return_type)
        return_type = rt;
      else if (!Equal(return_type, rt))
        same_return_type = false;
      Node *origin = Getattr(o, "defaultargs") ? Getattr(o, "defaultargs") : o;
      if (!defaultargs_origin)
        defaultargs_origin = origin;
      else if (defaultargs_origin != origin)
        default_args_only = false;
    }
    String *dispatcher_return_type = same_return_type && return_type ? Copy(return_type) : NewString("dynamic");
    bool is_void = Equal(dispatcher_return_type, "void");
    int min_params = max_params;
    for (Iterator it = First(overloads); it.item; it = Next(it)) {
      int nparams = Len(Getattr(it.item, "dart:paramtypes"));
      if (nparams < min_params)
        min_params = nparams;
    }

    Printf(code, "  %s%s %s(", is_static ? "static " : "", dispatcher_return_type, function_name);

    if (default_args_only) {
      // Optional nullable parameters, using the types of the overload with all the parameters
      Node *longest = NULL;
      for (Iterator it = First(overloads); it.item; it = Next(it)) {
        if (Len(Getattr(it.item, "dart:paramtypes")) == max_params)
          longest = it.item;
      }
      List *types = Getattr(longest, "dart:paramtypes");
      for (int i = 0; i < max_params; i++) {
        String *type = Getitem(types, i);
        Printf(code, "%s%s%s%s arg%d", i > 0 ? ", " : "", i == min_params ? "[" : "", type, (i >= min_params && !isNullableType(type)) ? "?" : "", i);
      }
      Printf(code, "%s) {\n", min_params < max_params ? "]" : "");

      // Call the overload with the most arguments which are all non-null
      for (int nargs = min_params; nargs <= max_params; nargs++) {
        Node *o = NULL;
        for (Iterator it = First(overloads); it.item; it = Next(it)) {
          if (Len(Getattr(it.item, "dart:paramtypes")) == nargs)
            o = it.item;
        }
        if (!o)
          continue;
        String *call = NewStringf("%s(", Getattr(o, "dart:implname"));
        for (int i = 0; i < nargs; i++) {
          String *type = Getitem(types, i);
          Printf(call, "%sarg%d%s", i > 0 ? ", " : "", i, (i >= min_params && !isNullableType(type)) ? "!" : "");
        }
        Printf(call, ")");
        if (nargs < max_params)
          Printf(code, "    if (arg%d == null) {\n  ", nargs);
        if (is_void)
          Printf(code, "    %s;\n    %sreturn;\n", call, nargs < max_params ? "  " : "");
        else
          Printf(code, "    return %s;\n", call);
        if (nargs < max_params)
          Printf(code, "    }\n");
        Delete(call);
      }
      Printf(code, "  }\n\n");
    } else {
      // Dispatch based on the runtime types of the arguments, the parameters not used by all the overloads are optional
      for (int i = 0; i < max_params; i++) {
        if (i == min_params)
          Printf(code, "%s[", i > 0 ? ", " : "");
        else if (i > 0)
          Printf(code, ", ");
        Printf(code, "Object? arg%d%s", i, i >= min_params ? " = _swigNoArg" : "");
      }
      Printf(code, "%s) {\n", min_params < max_params ? "]" : "");

      List *ranked = Swig_overload_rank(n, false);
      for (Iterator it = First(ranked ? ranked : overloads); it.item; it = Next(it)) {
        Node *o = it.item;
        if (!Getattr(o, "dart:implname"))
          continue;
        List *types = Getattr(o, "dart:paramtypes");
        String *condition = NewString("");
        String *call = NewStringf("%s(", Getattr(o, "dart:implname"));
        for (int i = 0; i < max_params; i++) {
          if (i < Len(types)) {
            String *type = Getitem(types, i);
            if (Len(condition) > 0)
              Printf(condition, " && ");
            if (Equal(type, "double")) {
              // Allow passing a Dart int when a double is expected
              Printf(condition, "(arg%d is double || arg%d is int)", i, i);
              Printf(call, "%s(arg%d is int ? arg%d.toDouble() : arg%d as double)", i > 0 ? ", " : "", i, i, i);
            } else {
              Printf(condition, "arg%d is %s", i, type);
              Printf(call, "%sarg%d as %s", i > 0 ? ", " : "", i, type);
            }
          } else {
            if (Len(condition) > 0)
              Printf(condition, " && ");
            Printf(condition, "_swigNoArg == arg%d", i);
          }
        }
        Printf(call, ")");
        if (Len(condition) == 0)
          Printf(condition, "true");
        Printf(code, "    if (%s) {\n", condition);
        if (is_void)
          Printf(code, "      %s;\n      return;\n", call);
        else
          Printf(code, "      return %s;\n", call);
        Printf(code, "    }\n");
        Delete(call);
        Delete(condition);
      }
      Delete(ranked);
      Printf(code, "    throw ArgumentError('No matching function for overloaded \\'%s\\'');\n", function_name);
      Printf(code, "  }\n\n");
    }

    Delete(dispatcher_return_type);
    Delete(overloads);
  }

  /* -----------------------------------------------------------------------------
   * proxyClassFunctionHandler()
   *
   * Function called for creating a Dart wrapper function around a C++ function in the
   * proxy class. Used for both static and non-static C++ class functions and for the
   * getters and setters of member variables.
   * Two extra attributes in the Node must be available. These are "proxyfuncname" -
   * the name of the Dart class proxy function, which in turn will call "imfuncname" -
   * the intermediary function name in the intermediary class.
   * ----------------------------------------------------------------------------- */

  void proxyClassFunctionHandler(Node *n) {
    // Wrappers not wanted for some methods where the parameters cannot be overloaded in Dart
    if (Getattr(n, "overload:ignore"))
      return;

    // Don't generate proxy method for additional explicitcall method used in directors
    if (GetFlag(n, "explicitcall"))
      return;

    emitDartFunction(n, proxy_class_code, Getattr(n, "proxyfuncname"), Getattr(n, "imfuncname"), static_flag, !static_flag);
  }

  /* ----------------------------------------------------------------------
   * constructorHandler()
   * ---------------------------------------------------------------------- */

  virtual int constructorHandler(Node *n) {

    String *function_code = NewString("");

    Language::constructorHandler(n);

    // Wrappers not wanted for some methods where the parameters cannot be overloaded in Dart
    if (Getattr(n, "overload:ignore"))
      return SWIG_OK;

    String *overloaded_name = getOverloadedName(n);
    String *mangled_overname = Swig_name_construct(getNSpace(), overloaded_name);
    String *param_decls = NewString("");
    List *param_types = NewList();

    // The body creating the C++ object, the C++ object pointer is passed to the swigFromPtr constructor
    String *helper_body = constructorBody(n, mangled_overname, param_decls, param_types);

    Hash *attributes = NewHash();
    String *typemap_lookup_type = Getattr(getCurrentClass(), "classtypeobj");
    String *construct_tm = Copy(typemapLookup(n, "dartconstruct", typemap_lookup_type, WARN_DART_TYPEMAP_DARTCONSTRUCT_UNDEF, attributes));

    // A constructor renamed in the interface file is a named constructor as Dart has a single unnamed constructor
    String *symname = Getattr(n, "sym:name");
    bool named_constructor = !Equal(symname, proxy_class_name);
    String *constructor_name = named_constructor ? NewStringf("%s.%s", proxy_class_name, symname) : Copy(proxy_class_name);

    // The constructor helper function returning the pointer to the new C++ object
    String *helper_name = NewStringf("_swigConstruct%s%s", named_constructor ? symname : "", Getattr(n, "sym:overname") ? Getattr(n, "sym:overname") : "");
    Printf(proxy_class_code, "  static ffi.Pointer<ffi.Void> %s(%s) %s\n\n", helper_name, param_decls, helper_body);

    String *helper_call = NewStringf("%s(", helper_name);
    for (int i = 0; i < Len(param_types); i++)
      Printf(helper_call, "%sarg%d", i > 0 ? ", " : "", i);
    Printf(helper_call, ")");
    // Any pending exception is checked in the helper function
    Replaceall(construct_tm, "$imcall", helper_call);
    Replaceall(construct_tm, "$excode", "");

    // Constructor parameters are named arg0, arg1 etc to match the helper call
    String *ctor_params = NewString("");
    for (int i = 0; i < Len(param_types); i++)
      Printf(ctor_params, "%s%s arg%d", i > 0 ? ", " : "", Getitem(param_types, i), i);

    const String *methodmods = Getattr(n, "feature:dart:methodmodifiers");
    if (Getattr(n, "sym:overloaded")) {
      // Dart does not support overloaded constructors, each overload is a named constructor and a factory constructor dispatches to them
      String *impl_name = NewStringf("%s._swigCreate%s%s", proxy_class_name, named_constructor ? symname : "", Getattr(n, "sym:overname"));
      Printf(function_code, "  %s%s(%s) : %s;\n\n", methodmods ? methodmods : "", impl_name, ctor_params, construct_tm);
      Setattr(n, "dart:implname", impl_name);
      Setattr(n, "dart:paramtypes", param_types);
      Setattr(n, "dart:returntype", proxy_class_name);
      Delete(impl_name);
      Printv(proxy_class_code, function_code, NIL);
      if (!Getattr(n, "sym:nextSibling")) {
        String *dispatcher = NewString("");
        emitOverloadDispatcher(n, dispatcher, constructor_name, false);
        // The dispatcher is a factory constructor
        String *dispatcher_start = NewStringf("  %s %s(", proxy_class_name, constructor_name);
        String *factory_start = NewStringf("  factory %s(", constructor_name);
        Replace(dispatcher, dispatcher_start, factory_start, DOH_REPLACE_FIRST);
        Printv(proxy_class_code, dispatcher, NIL);
        Delete(factory_start);
        Delete(dispatcher_start);
        Delete(dispatcher);
      }
    } else {
      Printf(function_code, "  %s%s(%s) : %s;\n\n", methodmods ? methodmods : "", constructor_name, ctor_params, construct_tm);
      Printv(proxy_class_code, function_code, NIL);
    }

    Delete(constructor_name);
    Delete(ctor_params);
    Delete(helper_call);
    Delete(helper_name);
    Delete(construct_tm);
    Delete(attributes);
    Delete(helper_body);
    Delete(param_types);
    Delete(param_decls);
    Delete(mangled_overname);
    Delete(overloaded_name);
    Delete(function_code);
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * constructorBody()
   *
   * Generates the body of the static helper function for a constructor which
   * returns the pointer to the new C++ object. The helper parameters are named
   * arg0, arg1 etc.
   * ----------------------------------------------------------------------------- */

  String *constructorBody(Node *n, const String *imfuncname, String *param_decls, List *param_types) {
    ParmList *l = Getattr(n, "parms");
    String *tm;
    Parm *p;
    int i;
    String *imcall = NewString("");
    String *pre_code = NewString("");
    String *post_code = NewString("");
    String *terminator_code = NewString("");

    /* Attach the non-standard typemaps to the parameter list */
    Swig_typemap_attach_parms("in", l, NULL);
    Swig_typemap_attach_parms("darttype", l, NULL);
    Swig_typemap_attach_parms("dartin", l, NULL);

    emit_mark_varargs(l);

    Printv(imcall, imclass_name, "().", imfuncname, "(", NIL);
    int gencomma = 0;
    int param_count = 0;

    for (i = 0, p = l; p; i++) {
      if (checkAttribute(p, "varargs:ignore", "1")) {
        p = nextSibling(p);
        continue;
      }
      if (checkAttribute(p, "tmap:in:numinputs", "0")) {
        p = Getattr(p, "tmap:in:next");
        continue;
      }

      SwigType *pt = Getattr(p, "type");
      String *param_type = NewString("");
      if ((tm = Getattr(p, "tmap:darttype"))) {
        substituteClassname(pt, tm);
        Printf(param_type, "%s", tm);
      } else {
        Swig_warning(WARN_DART_TYPEMAP_DARTTYPE_UNDEF, input_file, line_number, "No darttype typemap defined for %s\n", SwigType_str(pt, 0));
      }

      if (gencomma)
        Printf(imcall, ", ");
      gencomma = 1;

      String *arg = NewStringf("arg%d", param_count);

      if ((tm = Getattr(p, "tmap:dartin"))) {
        substituteClassname(pt, tm);
        Replaceall(tm, "$dartinput", arg);
        String *pre = Getattr(p, "tmap:dartin:pre");
        if (pre) {
          substituteClassname(pt, pre);
          Replaceall(pre, "$dartinput", arg);
          if (Len(pre_code) > 0)
            Printf(pre_code, "\n");
          Printv(pre_code, pre, NIL);
        }
        String *post = Getattr(p, "tmap:dartin:post");
        if (post) {
          substituteClassname(pt, post);
          Replaceall(post, "$dartinput", arg);
          if (Len(post_code) > 0)
            Printf(post_code, "\n");
          Printv(post_code, post, NIL);
        }
        String *terminator = Getattr(p, "tmap:dartin:terminator");
        if (terminator) {
          substituteClassname(pt, terminator);
          Replaceall(terminator, "$dartinput", arg);
          if (Len(terminator_code) > 0)
            Insert(terminator_code, 0, "\n");
          Insert(terminator_code, 0, terminator);
        }
        Printv(imcall, tm, NIL);
      } else {
        Swig_warning(WARN_DART_TYPEMAP_DARTIN_UNDEF, input_file, line_number, "No dartin typemap defined for %s\n", SwigType_str(pt, 0));
      }

      Printf(param_decls, "%s%s %s", param_count ? ", " : "", param_type, arg);
      Append(param_types, param_type);
      param_count++;

      Delete(arg);
      Delete(param_type);
      p = Getattr(p, "tmap:in:next");
    }
    Printf(imcall, ")");

    String *excode = NewString("");
    if (Getattr(n, "dart:canthrow"))
      Printf(excode, "\n    if (%s.swigPendingException) throw %s.swigTakePendingException();", imclass_name, imclass_name);

    String *body = NewString("{\n");
    if (Len(pre_code) > 0)
      Printv(body, pre_code, "\n", NIL);
    if (Len(post_code) > 0)
      Printf(body, "    try {\n      final ffi.Pointer<ffi.Void> cPtr = %s;%s\n      return cPtr;\n    } finally {\n%s\n    }\n", imcall, excode, post_code);
    else
      Printf(body, "    final ffi.Pointer<ffi.Void> cPtr = %s;%s\n    return cPtr;\n", imcall, excode);
    if (Len(terminator_code) > 0)
      Printv(body, terminator_code, "\n", NIL);
    Printf(body, "  }");

    Delete(excode);
    Delete(pre_code);
    Delete(post_code);
    Delete(terminator_code);
    Delete(imcall);
    return body;
  }

  /* ----------------------------------------------------------------------
   * destructorHandler()
   * ---------------------------------------------------------------------- */

  virtual int destructorHandler(Node *n) {
    Language::destructorHandler(n);
    String *symname = Getattr(n, "sym:name");

    String *destroy_name = Swig_name_destroy(getNSpace(), symname);
    Printv(destructor_call, imclass_name, "().", destroy_name, "(_swigCPtr_", proxy_class_name, ")", NIL);
    Delete(destructor_wname);
    destructor_wname = Swig_name_wrapper(destroy_name);
    Delete(destroy_name);

    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * membervariableHandler()
   * ---------------------------------------------------------------------- */

  virtual int membervariableHandler(Node *n) {
    variable_name = Getattr(n, "sym:name");
    wrapping_member_flag = true;
    variable_wrapper_flag = true;
    Setattr(n, "dart:vartype", Getattr(n, "type"));
    Language::membervariableHandler(n);
    Delattr(n, "dart:vartype");
    wrapping_member_flag = false;
    variable_wrapper_flag = false;
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * staticmembervariableHandler()
   * ---------------------------------------------------------------------- */

  virtual int staticmembervariableHandler(Node *n) {
    variable_name = Getattr(n, "sym:name");
    wrapping_member_flag = true;
    static_flag = true;
    Setattr(n, "dart:vartype", Getattr(n, "type"));
    Language::staticmembervariableHandler(n);
    Delattr(n, "dart:vartype");
    wrapping_member_flag = false;
    static_flag = false;
    return SWIG_OK;
  }

  /* ----------------------------------------------------------------------
   * memberconstantHandler()
   * ---------------------------------------------------------------------- */

  virtual int memberconstantHandler(Node *n) {
    variable_name = Getattr(n, "sym:name");
    wrapping_member_flag = true;
    Language::memberconstantHandler(n);
    wrapping_member_flag = false;
    return SWIG_OK;
  }

  /* -----------------------------------------------------------------------------
   * getOverloadedName()
   * ----------------------------------------------------------------------------- */

  String *getOverloadedName(Node *n) {

    /* The intermediary class methods are mangled when overloaded to give a unique name. */
    String *overloaded_name = Copy(Getattr(n, "sym:name"));

    if (Getattr(n, "sym:overloaded")) {
      Printv(overloaded_name, Getattr(n, "sym:overname"), NIL);
    }

    return overloaded_name;
  }

  /* -----------------------------------------------------------------------------
   * moduleClassFunctionHandler()
   * ----------------------------------------------------------------------------- */

  void moduleClassFunctionHandler(Node *n) {
    String *overloaded_name = getOverloadedName(n);
    String *func_name = NULL;

    /* Change function name for global variables */
    if (global_variable_flag) {
      bool setter_flag = (Cmp(Getattr(n, "sym:name"), Swig_name_set(getNSpace(), variable_name)) == 0);
      Setattr(n, "dart:accessor", setter_flag ? "set" : "get");
      func_name = Copy(variable_name);
    } else {
      func_name = Copy(Getattr(n, "sym:name"));
    }

    emitDartFunction(n, module_class_code, func_name, overloaded_name, true, false);

    Delete(func_name);
    Delete(overloaded_name);
  }

  /*----------------------------------------------------------------------
   * replaceSpecialVariables()
   *--------------------------------------------------------------------*/

  virtual void replaceSpecialVariables(String *method, String *tm, Parm *parm) {
    (void)method;
    SwigType *type = Getattr(parm, "type");
    substituteClassname(type, tm);
  }

  /*----------------------------------------------------------------------
   * decodeEnumFeature()
   * Decode the possible enum features, which are one of:
   *   %dartenum(simple)
   *   %dartenum(proper) - default
   *--------------------------------------------------------------------*/

  EnumFeature decodeEnumFeature(Node *n) {
    EnumFeature enum_feature = ProperEnum;
    String *feature = Getattr(n, "feature:dart:enum");
    if (feature) {
      if (Cmp(feature, "simple") == 0)
        enum_feature = SimpleEnum;
    }
    return enum_feature;
  }

  /* -----------------------------------------------------------------------
   * isNullableType()
   *
   * Returns true if the Dart type is nullable.
   * ------------------------------------------------------------------------ */

  static bool isNullableType(const String *type) {
    return Len(type) > 0 && (*(Char(type) + Len(type) - 1) == '?' || Equal(type, "dynamic") || Equal(type, "Object?"));
  }

  /* -----------------------------------------------------------------------
   * isDartIntLiteral()
   *
   * Returns true if the string is a decimal or hexadecimal integer literal
   * that is valid in both C and Dart.
   * ------------------------------------------------------------------------ */

  static bool isDartIntLiteral(const String *s) {
    if (!s)
      return false;
    const char *c = Char(s);
    if (*c == '-')
      c++;
    if (c[0] == '0' && (c[1] == 'x' || c[1] == 'X')) {
      c += 2;
      if (!*c)
        return false;
      for (; *c; c++) {
        if (!isxdigit((unsigned char)*c))
          return false;
      }
      return true;
    }
    if (!*c)
      return false;
    for (; *c; c++) {
      if (!isdigit((unsigned char)*c))
        return false;
    }
    return true;
  }

  /* -----------------------------------------------------------------------
   * enumValue()
   *
   * This method will return a string with an enum value to use in Dart generated
   * code. If the value is known, an integer literal is used. Otherwise the string
   * will contain the intermediary class call to obtain the enum value and the
   * intermediary class and C wrapper functions to obtain the enum value will be generated.
   * The %dartconstvalue feature overrides all other ways to generate the constant value.
   * The caller must delete memory allocated for the returned string.
   * ------------------------------------------------------------------------ */

  String *enumValue(Node *n) {
    String *symname = Getattr(n, "sym:name");

    // Check for the %dartconstvalue feature
    String *value = Getattr(n, "feature:dart:constvalue");
    if (value) {
      enum_next_value_known = false;
      return Copy(value);
    }

    String *enumvalue = Getattr(n, "enumvalue");
    if (enumvalue && isDartIntLiteral(enumvalue)) {
      errno = 0;
      long long v = strtoll(Char(enumvalue), NULL, 0);
      enum_next_value_known = errno == 0;
      enum_next_value = v + 1;
      return Copy(enumvalue);
    }
    if (!enumvalue && enum_next_value_known) {
      String *v = NewStringf("%lld", enum_next_value);
      enum_next_value++;
      return v;
    }
    enum_next_value_known = false;

    // The %dartconst feature uses the C/C++ value and hopes that it compiles as Dart code
    if (GetFlag(n, "feature:dart:const")) {
      return Getattr(n, "enumvalue") ? Copy(Getattr(n, "enumvalue")) : Copy(Getattr(n, "enumvalueex"));
    }

    String *newsymname = 0;
    if (!getCurrentClass()) {
      String *enumClassPrefix = getEnumClassPrefix();
      if (enumClassPrefix) {
        // A global scoped enum
        newsymname = Swig_name_member(0, enumClassPrefix, symname);
        symname = newsymname;
      }
    }

    // Get the enumvalue from a C wrapper call
    if (!getCurrentClass() || !cparse_cplusplus) {
      // Strange hack to change the name
      Setattr(n, "name", Getattr(n, "value")); /* for wrapping of enums in a namespace when emit_action is used */
      constantWrapper(n);
      value = NewStringf("%s().%s()", imclass_name, Swig_name_get(getNSpace(), symname));
    } else {
      memberconstantHandler(n);
      value = NewStringf("%s().%s()", imclass_name, Swig_name_get(getNSpace(), Swig_name_member(0, getEnumClassPrefix(), symname)));
    }
    Delete(newsymname);
    return value;
  }

  /* -----------------------------------------------------------------------------
   * getEnumName()
   *
   * Name of the Dart enum for an enum type. Dart does not support nested types
   * so an enum declared within a class is named after the class and the enum,
   * separated by an underscore.
   * ----------------------------------------------------------------------------- */

  String *getEnumName(SwigType *t) {
    Node *enumname = NULL;
    Node *n = enumLookup(t);
    if (n) {
      enumname = Getattr(n, "enumname");
      if (!enumname) {
        String *symname = Getattr(n, "sym:name");
        if (symname) {
          // Add in class scope when referencing enum if not a global enum
          String *scopename_prefix = Swig_scopename_prefix(Getattr(n, "name"));
          String *proxyname = 0;
          if (scopename_prefix) {
            proxyname = getProxyName(scopename_prefix);
          }
          if (proxyname) {
            enumname = NewStringf("%s_%s", proxyname, symname);
          } else {
            enumname = Copy(symname);
          }
          Setattr(n, "enumname", enumname);
          Delete(enumname);
          Delete(scopename_prefix);
        }
      }
    }

    return enumname;
  }

  /* -----------------------------------------------------------------------------
   * substituteClassname()
   *
   * Substitute the special variable $dartclassname with the proxy class name for classes/structs/unions
   * that SWIG knows about. Also substitutes enums with enum name.
   * Otherwise use the $descriptor name for the Dart class name. Note that the $&dartclassname substitution
   * is the same as a $&descriptor substitution, ie one pointer added to descriptor name.
   * Inputs:
   *   pt - parameter type
   *   tm - typemap contents that might contain the special variable to be replaced
   * Outputs:
   *   tm - typemap contents complete with the special variable substitution
   * Return:
   *   substitution_performed - flag indicating if a substitution was performed
   * ----------------------------------------------------------------------------- */

  bool substituteClassname(SwigType *pt, String *tm) {
    bool substitution_performed = false;
    SwigType *type = Copy(SwigType_typedef_resolve_all(pt));
    SwigType *strippedtype = SwigType_strip_qualifiers(type);

    if (Strstr(tm, "$dartclassname")) {
      SwigType *classnametype = Copy(strippedtype);
      substituteClassnameSpecialVariable(classnametype, tm, "$dartclassname");
      substitution_performed = true;
      Delete(classnametype);
    }
    if (Strstr(tm, "$*dartclassname")) {
      SwigType *classnametype = Copy(strippedtype);
      Delete(SwigType_pop(classnametype));
      if (Len(classnametype) > 0) {
        substituteClassnameSpecialVariable(classnametype, tm, "$*dartclassname");
        substitution_performed = true;
      }
      Delete(classnametype);
    }
    if (Strstr(tm, "$&dartclassname")) {
      SwigType *classnametype = Copy(strippedtype);
      SwigType_add_pointer(classnametype);
      substituteClassnameSpecialVariable(classnametype, tm, "$&dartclassname");
      substitution_performed = true;
      Delete(classnametype);
    }

    Delete(strippedtype);
    Delete(type);

    return substitution_performed;
  }

  /* -----------------------------------------------------------------------------
   * substituteClassnameSpecialVariable()
   * ----------------------------------------------------------------------------- */

  void substituteClassnameSpecialVariable(SwigType *classnametype, String *tm, const char *classnamespecialvariable) {
    String *replacementname;
    if (SwigType_isenum(classnametype)) {
      String *enumname = getEnumName(classnametype);
      if (enumname) {
        replacementname = Copy(enumname);
      } else {
        // Anonymous enums and unknown enums - ones that have not been parsed (neither a C enum forward reference nor a
        // definition) or ignored enums - are wrapped as integers, the enum conversion functions are not needed
        {
          String *toenum = NewStringf("%s.swigToEnum", classnamespecialvariable);
          String *tovalue = NewStringf("%s.swigToValue", classnamespecialvariable);
          Replaceall(tm, toenum, "");
          Replaceall(tm, tovalue, "");
          Delete(tovalue);
          Delete(toenum);
          replacementname = NewString("int");
        }
      }
    } else {
      String *classname = getProxyName(classnametype);  // getProxyName() works for pointers to classes too
      if (classname) {
        replacementname = Copy(classname);
      } else {
        // use $descriptor if SWIG does not know anything about this type. Note that any typedefs are resolved.
        replacementname = NewStringf("SWIGTYPE%s", SwigType_manglestr(classnametype));

        // Add to hash table so that the type wrapper classes can be created later
        Setattr(swig_types_hash, replacementname, classnametype);
      }
    }
    Replaceall(tm, classnamespecialvariable, replacementname);

    Delete(replacementname);
  }

  /* -----------------------------------------------------------------------------
   * emitTypeWrapperClass()
   * ----------------------------------------------------------------------------- */

  void emitTypeWrapperClass(String *classname, SwigType *type) {
    Node *n = NewHash();
    Setfile(n, input_file);
    Setline(n, line_number);

    String *swigtype = NewString("");

    // Pure Dart baseclass and interfaces
    const String *pure_baseclass = typemapLookup(n, "dartbase", type, WARN_NONE);
    const String *pure_interfaces = typemapLookup(n, "dartinterfaces", type, WARN_NONE);

    // Emit the class
    Printv(swigtype,
           typemapLookup(n, "dartimports", type, WARN_NONE),                                // Import statements
           typemapLookup(n, "dartclassmodifiers", type, WARN_DART_TYPEMAP_CLASSMOD_UNDEF),  // Class modifiers
           " $dartclassname",                                                               // Class name and base class
           *Char(pure_baseclass) ? " extends " : "",
           pure_baseclass,
           *Char(pure_interfaces) ? " implements " : "",
           pure_interfaces,
           " {",
           typemapLookup(n, "dartbody", type, WARN_DART_TYPEMAP_DARTBODY_UNDEF),  // main body of class
           typemapLookup(n, "dartcode", type, WARN_NONE),                         // extra Dart code
           "}\n\n",
           NIL);

    Replaceall(swigtype, "$dartclassname", classname);
    Replaceall(swigtype, "$module", module_class_name);
    Replaceall(swigtype, "$imclassname", imclass_name);
    Replaceall(swigtype, "$dllimport", libname);

    // For unknown enums
    Replaceall(swigtype, "$enumvalues", "");

    Printv(library_code, swigtype, NIL);

    Delete(swigtype);
    Delete(n);
  }

  /* -----------------------------------------------------------------------------
   * typemapLookup()
   * n - for input only and must contain info for Getfile(n) and Getline(n) to work
   * tmap_method - typemap method name
   * type - typemap type to lookup
   * warning - warning number to issue if no typemaps found
   * typemap_attributes - the typemap attributes are attached to this node and will
   *   also be used for temporary storage if non null
   * return is never NULL, unlike Swig_typemap_lookup()
   * ----------------------------------------------------------------------------- */

  const String *typemapLookup(Node *n, const_String_or_char_ptr tmap_method, SwigType *type, int warning, Node *typemap_attributes = 0) {
    Node *node = !typemap_attributes ? NewHash() : typemap_attributes;
    Setattr(node, "type", type);
    Setfile(node, Getfile(n));
    Setline(node, Getline(n));
    const String *tm = Swig_typemap_lookup(tmap_method, node, "", 0);
    if (!tm) {
      tm = empty_string;
      if (warning != WARN_NONE)
        Swig_warning(warning, Getfile(n), Getline(n), "No %s typemap defined for %s\n", tmap_method, SwigType_str(type, 0));
    }
    if (!typemap_attributes)
      Delete(node);
    return tm;
  }

  /* -----------------------------------------------------------------------------
   * canThrow()
   * Determine whether the code in the typemap can throw a Dart exception.
   * If so, note it for later when excodeSubstitute() is called.
   * ----------------------------------------------------------------------------- */

  void canThrow(Node *n, const String *typemap, Node *parameter) {
    String *canthrow_attribute = NewStringf("tmap:%s:canthrow", typemap);
    String *canthrow = Getattr(parameter, canthrow_attribute);
    if (canthrow)
      Setattr(n, "dart:canthrow", "1");
    Delete(canthrow_attribute);
  }

  /* -----------------------------------------------------------------------------
   * excodeSubstitute()
   * If a method can throw a Dart exception, additional exception code is added to
   * check for the pending exception so that it can then throw the exception. The
   * $excode special variable is replaced by the exception code in the excode
   * typemap attribute.
   * ----------------------------------------------------------------------------- */

  void excodeSubstitute(Node *n, String *code, const String *typemap, Node *parameter) {
    String *excode_attribute = NewStringf("tmap:%s:excode", typemap);
    String *excode = Getattr(parameter, excode_attribute);
    if (Getattr(n, "dart:canthrow")) {
      int count = Replaceall(code, "$excode", excode);
      if (count < 1 || !excode) {
        Swig_warning(
          WARN_DART_EXCODE, input_file, line_number, "Dart exception may not be thrown - no $excode or excode attribute in '%s' typemap.\n", typemap);
      }
    } else {
      Replaceall(code, "$excode", empty_string);
    }
    Delete(excode_attribute);
  }

  /* -----------------------------------------------------------------------------
   * dartEscapedString()
   *
   * Escape a C string literal value for use in a single quoted Dart string literal.
   * Returns a new string.
   * ----------------------------------------------------------------------------- */

  String *dartEscapedString(const String *s) {
    String *escaped = NewString("");
    for (const char *c = Char(s); *c; c++) {
      if (*c == '$')
        Append(escaped, "\\$");
      else if (*c == '\'')
        Append(escaped, "\\'");
      else
        Putc(*c, escaped);
    }
    return escaped;
  }

  /* ----------------------------------------------------------------------
   * nestedClassesSupport()
   *
   * Dart does not have nested classes, nested classes are flattened.
   * ---------------------------------------------------------------------- */

  NestedClassSupport nestedClassesSupport() const {
    return NCS_None;
  }
};

/* -----------------------------------------------------------------------------
 * swig_dart()    - Instantiate module
 * ----------------------------------------------------------------------------- */

static Language *new_swig_dart() {
  return new DART();
}
extern "C" Language *swig_dart(void) {
  return new_swig_dart();
}

/* -----------------------------------------------------------------------------
 * Static member variables
 * ----------------------------------------------------------------------------- */

const char *DART::usage = "\
Dart Options (available with -dart)\n\
     -libname <name> - Set the base name of the native library to load, the default is the module name\n\
\n";
