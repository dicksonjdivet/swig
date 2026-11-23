/* -----------------------------------------------------------------------------
 * std_array.i
 *
 * SWIG typemaps for std::array<T, N>
 * Dart implementation
 * The Dart proxy class extends ListBase<T> from dart:collection, so a wrapped
 * std::array is a fixed-length Dart List and all the List methods that do not
 * change the length can be used on it. The C++ std::array is accessed directly,
 * the elements are not copied into Dart. For example:
 *
 *   %template(ArrayInt6) std::array<int, 6>;
 *
 * can be used from Dart as:
 *
 *   final a = ArrayInt6();
 *   a.setAll(0, [1, 2, 3, 4, 5, 6]);
 *   print(a.where((i) => i > 3).toList());
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

%define SWIG_STD_ARRAY_INTERNAL(CTYPE, N)
%typemap(dartbase) std::array< CTYPE, N > "swig_collection.ListBase<$typemap(darttype, CTYPE)>"
%proxycode %{
  @override
  int get length => size();

  @override
  set length(int newLength) {
    throw UnsupportedError('Cannot change the length of a wrapped std::array');
  }

  @override
  $typemap(darttype, CTYPE) operator [](int index) => getitem(index);

  @override
  void operator []=(int index, $typemap(darttype, CTYPE) value) => setitem(index, value);
%}

  public:
    typedef size_t size_type;
    typedef ptrdiff_t difference_type;
    typedef CTYPE value_type;
    typedef value_type* pointer;
    typedef const value_type* const_pointer;
    typedef value_type& reference;
    typedef const value_type& const_reference;

    array();
    array(const array &other);

    size_type size() const;
    bool empty() const;
    void fill(const value_type& value);
    void swap(array& other);

    %extend {
      const_reference getitem(int index) throw (std::out_of_range) {
        if (index>=0 && index<(int)$self->size())
          return (*$self)[index];
        else
          throw std::out_of_range("index");
      }
      void setitem(int index, const_reference val) throw (std::out_of_range) {
        if (index>=0 && index<(int)$self->size())
          (*$self)[index] = val;
        else
          throw std::out_of_range("index");
      }
    }
%enddef

%{
#include <array>
#include <stdexcept>
%}

namespace std {
  template<class T, size_t N> class array {
    SWIG_STD_ARRAY_INTERNAL(T, N)
  };
}
