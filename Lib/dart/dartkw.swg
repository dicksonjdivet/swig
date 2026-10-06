#ifndef DART_DARTKW_SWG_
#define DART_DARTKW_SWG_

/* Warnings for Dart keywords */
#define DARTKW(x) %keywordwarn("'" `x` "' is a Dart keyword or a name used by the generated Dart code",rename="%s_")  `x`

#define DARTBUILTINKW(x) %keywordwarn("'" `x` "' is a Dart built-in identifier, which cannot be used as a type name",%$isclass,rename="%s_")  `x`

#define DARTCORETYPE(x) %keywordwarn("'" `x` "' is a Dart core library type",%$isclass,rename="%s_") `x`

#define DARTENUMKW(x) %keywordwarn("'" `x` "' is a member of all Dart enums",%$isenumitem,rename="%s_") `x`

#define DARTCLASSKW(x) %keywordwarn("'" `x` "' is a special method name used in the Dart wrapper classes",%$ismember,rename="%s_") `x`

/*
   Reserved words, from
   https://dart.dev/language/keywords
*/

DARTKW(assert);
DARTKW(break);
DARTKW(case);
DARTKW(catch);
DARTKW(class);
DARTKW(const);
DARTKW(continue);
DARTKW(default);
DARTKW(do);
DARTKW(else);
DARTKW(enum);
DARTKW(extends);
DARTKW(false);
DARTKW(final);
DARTKW(finally);
DARTKW(for);
DARTKW(if);
DARTKW(in);
DARTKW(is);
DARTKW(new);
DARTKW(null);
DARTKW(rethrow);
DARTKW(return);
DARTKW(super);
DARTKW(switch);
DARTKW(this);
DARTKW(throw);
DARTKW(true);
DARTKW(try);
DARTKW(var);
DARTKW(void);
DARTKW(while);
DARTKW(with);

/* Built-in identifiers, these cannot be used as type names */
DARTBUILTINKW(abstract);
DARTBUILTINKW(as);
DARTBUILTINKW(covariant);
DARTBUILTINKW(deferred);
DARTBUILTINKW(dynamic);
DARTBUILTINKW(export);
DARTBUILTINKW(extension);
DARTBUILTINKW(external);
DARTBUILTINKW(factory);
DARTBUILTINKW(Function);
DARTBUILTINKW(get);
DARTBUILTINKW(implements);
DARTBUILTINKW(import);
DARTBUILTINKW(interface);
DARTBUILTINKW(late);
DARTBUILTINKW(library);
DARTBUILTINKW(mixin);
DARTBUILTINKW(operator);
DARTBUILTINKW(part);
DARTBUILTINKW(required);
DARTBUILTINKW(set);
DARTBUILTINKW(static);
DARTBUILTINKW(typedef);

/* dart:core types used in the generated code, which a wrapped class must not hide */
DARTCORETYPE(ArgumentError);
DARTCORETYPE(Exception);
DARTCORETYPE(List);
DARTCORETYPE(Map);
DARTCORETYPE(Object);
DARTCORETYPE(RangeError);
DARTCORETYPE(StateError);
DARTCORETYPE(String);
DARTCORETYPE(UnsupportedError);
DARTCORETYPE(bool);
DARTCORETYPE(double);
DARTCORETYPE(int);
DARTCORETYPE(num);

/* Import prefixes and functions used in the generated code */
DARTKW(collection);
DARTKW(convert);
DARTKW(ffi);
DARTKW(identical);
DARTKW(io);

/* Members of Dart enums */
DARTENUMKW(index);
DARTENUMKW(name);
DARTENUMKW(swigValue);
DARTENUMKW(values);

/* Members of Object and members used in the generated proxy classes */
DARTCLASSKW(dispose);
DARTCLASSKW(hashCode);
DARTCLASSKW(noSuchMethod);
DARTCLASSKW(runtimeType);
DARTCLASSKW(swigCMemOwn);
DARTCLASSKW(toString);

#undef DARTKW
#undef DARTBUILTINKW
#undef DARTCORETYPE
#undef DARTENUMKW
#undef DARTCLASSKW

#endif //DART_DARTKW_SWG_
