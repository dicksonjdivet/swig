/* -----------------------------------------------------------------------------
 * std_vector.i
 *
 * SWIG typemaps for std::vector<T>
 * Dart implementation
 * The Dart proxy class extends ListBase<T> from dart:collection, so a wrapped
 * std::vector is a Dart List and all the List methods can be used on it. The
 * C++ std::vector is accessed directly, the elements are not copied into Dart.
 * For example:
 *
 *   %template(VectorInt) std::vector<int>;
 *
 * can be used from Dart as:
 *
 *   final v = VectorInt();
 *   v.addAll([1, 2, 3]);
 *   print(v.where((i) => i > 1).toList());
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

// MACRO for use within the std::vector class body
%define SWIG_STD_VECTOR_MINIMUM_INTERNAL(CONST_REFERENCE, CTYPE...)
%typemap(dartbase) std::vector< CTYPE > "swig_collection.ListBase<$typemap(darttype, CTYPE)>"
%proxycode %{
  @override
  int get length => size();

  @override
  set length(int newLength) {
    if (newLength > size()) {
      throw UnsupportedError('Cannot increase the length of a wrapped std::vector, use add instead');
    }
    removeRange(newLength, size());
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
    typedef CONST_REFERENCE const_reference;

    vector();
    vector(const vector &other);

    void clear();
    %rename(add) push_back;
    void push_back(CTYPE const& x);
    size_type size() const;
    bool empty() const;
    size_type capacity() const;
    void reserve(size_type n);

    %extend {
      CONST_REFERENCE getitem(int index) throw (std::out_of_range) {
        if (index>=0 && index<(int)$self->size())
          return (*$self)[index];
        else
          throw std::out_of_range("index");
      }
      void setitem(int index, CTYPE const& val) throw (std::out_of_range) {
        if (index>=0 && index<(int)$self->size())
          (*$self)[index] = val;
        else
          throw std::out_of_range("index");
      }
      void insert(int index, CTYPE const& element) throw (std::out_of_range) {
        if (index>=0 && index<(int)$self->size()+1)
          $self->insert($self->begin()+index, element);
        else
          throw std::out_of_range("index");
      }
      CTYPE removeAt(int index) throw (std::out_of_range) {
        if (index>=0 && index<(int)$self->size()) {
          CTYPE result = (*$self)[index];
          $self->erase($self->begin() + index);
          return result;
        } else {
          throw std::out_of_range("index");
        }
      }
      void removeRange(int start, int end) throw (std::out_of_range) {
        if (start < 0 || end > (int)$self->size() || end < start)
          throw std::out_of_range("range");
        $self->erase($self->begin()+start, $self->begin()+end);
      }
    }
%enddef

// Provided for compatibility with other target languages, the Dart List methods do not need operator==
%define SWIG_STD_VECTOR_ENHANCED(CTYPE...)
namespace std {
  template<> class vector< CTYPE > {
    SWIG_STD_VECTOR_MINIMUM_INTERNAL(const value_type&, %arg(CTYPE))
  };
}
%enddef

%{
#include <vector>
#include <stdexcept>
%}

namespace std {
  // primary (unspecialized) class template for std::vector
  template<class T> class vector {
    SWIG_STD_VECTOR_MINIMUM_INTERNAL(const value_type&, T)
  };
  // specialization for pointers
  template<class T> class vector<T *> {
    SWIG_STD_VECTOR_MINIMUM_INTERNAL(const value_type&, T *)
  };
  // bool is specialized in the C++ standard - const_reference in particular
  template<> class vector<bool> {
    SWIG_STD_VECTOR_MINIMUM_INTERNAL(bool, bool)
  };
}
