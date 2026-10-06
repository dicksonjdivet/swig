/* -----------------------------------------------------------------------------
 * std_vector.i
 *
 * SWIG typemaps for std::vector<T>
 * Dart implementation
 * The Dart wrapper is made to look and feel like a Dart List<> collection.
 *
 * Note that Iterable<> is implemented in the proxy class which is useful for using
 * Dart's collection methods with C++ std::vector wrappers. Additional list functionality
 * is provided whenever we are confident that the required C++ operator== is available.
 * This is the case for when T is a primitive type or a pointer. If T does define an
 * operator==, then use the SWIG_STD_VECTOR_ENHANCED macro to obtain this enhanced
 * functionality, for example:
 *
 *   SWIG_STD_VECTOR_ENHANCED(SomeNamespace::Klass)
 *   %template(VectKlass) std::vector<SomeNamespace::Klass>;
 * ----------------------------------------------------------------------------- */

%include <std_common.i>

// MACRO for use within the std::vector class body
%define SWIG_STD_VECTOR_MINIMUM_INTERNAL(CONST_REFERENCE, CTYPE...)
%typemap(csinterfaces) std::vector< CTYPE > ""
%proxycode %{
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

    %rename(clear) clear;
    void clear();
    %rename(add) push_back;
    void push_back(CTYPE const& x);
    size_type size() const;
    bool empty() const;
    size_type capacity() const;
    void reserve(size_type n);
    %newobject getRange(int start, int end);
    %newobject filled(CTYPE const& value, int count);

    %extend {
      vector(int capacity) throw (std::out_of_range) {
        std::vector< CTYPE >* pv = 0;
        if (capacity >= 0) {
          pv = new std::vector< CTYPE >();
          pv->reserve(capacity);
       } else {
          throw std::out_of_range("capacity");
       }
       return pv;
      }
      CTYPE getitemcopy(int index) throw (std::out_of_range) {
        if (index>=0 && index<(int)$self->size())
          return (*$self)[index];
        else
          throw std::out_of_range("index");
      }
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
      // Adds all elements from [values] to the end of the vector.
      void addAll(const std::vector< CTYPE >& values) {
        $self->insert($self->end(), values.begin(), values.end());
      }
      // Returns a new vector containing elements from [start] to [end] (exclusive).
      std::vector< CTYPE > *getRange(int start, int end) throw (std::out_of_range, std::invalid_argument) {
        if (start < 0)
          throw std::out_of_range("start");
        if (end < start)
          throw std::invalid_argument("end must be >= start");
        if (end > (int)$self->size())
          throw std::out_of_range("end");
        return new std::vector< CTYPE >($self->begin()+start, $self->begin()+end);
      }
      // Inserts [element] at [index].
      void insert(int index, CTYPE const& element) throw (std::out_of_range) {
        if (index>=0 && index<(int)$self->size()+1)
          $self->insert($self->begin()+index, element);
        else
          throw std::out_of_range("index");
      }
      // Inserts all elements from [iterable] at [index].
      void insertAll(int index, const std::vector< CTYPE >& iterable) throw (std::out_of_range) {
        if (index>=0 && index<(int)$self->size()+1)
          $self->insert($self->begin()+index, iterable.begin(), iterable.end());
        else
          throw std::out_of_range("index");
      }
      // Removes and returns the element at [index].
      CTYPE removeAt(int index) throw (std::out_of_range) {
        if (index>=0 && index<(int)$self->size()) {
          CTYPE result = (*$self)[index];
          $self->erase($self->begin() + index);
          return result;
        } else {
          throw std::out_of_range("index");
        }
      }
      // Removes elements from [start] to [end] (exclusive).
      void removeRange(int start, int end) throw (std::out_of_range, std::invalid_argument) {
        if (start < 0)
          throw std::out_of_range("start");
        if (end < start)
          throw std::invalid_argument("end must be >= start");
        if (end > (int)$self->size())
          throw std::out_of_range("end");
        $self->erase($self->begin()+start, $self->begin()+end);
      }
      // Removes and returns the last element.
      CTYPE removeLast() throw (std::out_of_range) {
        if ($self->empty())
          throw std::out_of_range("vector is empty");
        CTYPE result = $self->back();
        $self->pop_back();
        return result;
      }
      // Creates a new vector filled with [count] copies of [value].
      static std::vector< CTYPE > *filled(int count, CTYPE const& value) throw (std::out_of_range) {
        if (count < 0)
          throw std::out_of_range("count");
        return new std::vector< CTYPE >(count, value);
      }
      // Reverses the order of elements in the vector.
      void reverse() {
        std::reverse($self->begin(), $self->end());
      }
      // Shuffles the elements randomly.
      void shuffle() {
        std::random_shuffle($self->begin(), $self->end());
      }
      // Sets elements from [start] to [start + iterable.length] to values from [iterable].
      void setRange(int start, int end, const std::vector< CTYPE >& iterable, int skipCount = 0) throw (std::out_of_range, std::invalid_argument) {
        if (start < 0)
          throw std::out_of_range("start");
        if (end < start)
          throw std::invalid_argument("end must be >= start");
        if (end > (int)$self->size())
          throw std::out_of_range("end");
        int count = end - start;
        if (skipCount + count > (int)iterable.size())
          throw std::invalid_argument("not enough elements in iterable");
        std::copy(iterable.begin() + skipCount, iterable.begin() + skipCount + count, $self->begin() + start);
      }
      // Fills range [start] to [end] with [fillValue].
      void fillRange(int start, int end, CTYPE const& fillValue) throw (std::out_of_range, std::invalid_argument) {
        if (start < 0)
          throw std::out_of_range("start");
        if (end < start)
          throw std::invalid_argument("end must be >= start");
        if (end > (int)$self->size())
          throw std::out_of_range("end");
        std::fill($self->begin() + start, $self->begin() + end, fillValue);
      }
    }
%enddef

// Extra methods added to the collection class if operator== is defined for the class being wrapped
// This adds extra functionality like contains, indexOf, remove, etc.
%define SWIG_STD_VECTOR_EXTRA_OP_EQUALS_EQUALS(CTYPE...)
    %extend {
      // Returns `true` if the vector contains [element].
      bool contains(CTYPE const& element) {
        return std::find($self->begin(), $self->end(), element) != $self->end();
      }
      // Returns the first index of [element], or -1 if not found.
      int indexOf(CTYPE const& element, int start = 0) {
        if (start < 0) start = 0;
        if (start >= (int)$self->size()) return -1;
        std::vector< CTYPE >::iterator it = std::find($self->begin() + start, $self->end(), element);
        if (it != $self->end())
          return (int)(it - $self->begin());
        return -1;
      }
      // Returns the last index of [element], or -1 if not found.
      int lastIndexOf(CTYPE const& element, int start = -1) {
        if (start < 0 || start >= (int)$self->size()) start = (int)$self->size() - 1;
        for (int i = start; i >= 0; i--) {
          if ((*$self)[i] == element) return i;
        }
        return -1;
      }
      // Removes the first occurrence of [element]. Returns `true` if removed.
      bool remove(CTYPE const& element) {
        std::vector< CTYPE >::iterator it = std::find($self->begin(), $self->end(), element);
        if (it != $self->end()) {
          $self->erase(it);
          return true;
        }
        return false;
      }
    }
%enddef

// Macros for std::vector class specializations/enhancements
%define SWIG_STD_VECTOR_ENHANCED(CTYPE...)
namespace std {
  template<> class vector< CTYPE > {
    SWIG_STD_VECTOR_MINIMUM_INTERNAL(const value_type&, %arg(CTYPE))
    SWIG_STD_VECTOR_EXTRA_OP_EQUALS_EQUALS(CTYPE)
  };
}
%enddef

%{
#include <vector>
#include <algorithm>
#include <stdexcept>
%}

// %csmethodmodifiers std::vector::empty "_"
// %csmethodmodifiers std::vector::getitemcopy "int _"
// %csmethodmodifiers std::vector::getitem "int _"
// %csmethodmodifiers std::vector::setitem "int _"
// %csmethodmodifiers std::vector::size "int _"
// %csmethodmodifiers std::vector::capacity "int _"
// %csmethodmodifiers std::vector::reserve "int _"

namespace std {
  // primary (unspecialized) class template for std::vector
  // does not require operator== to be defined
  template<class T> class vector {
    SWIG_STD_VECTOR_MINIMUM_INTERNAL(const value_type&, T)
  };
  // specialization for pointers
  template<class T> class vector<T *> {
    SWIG_STD_VECTOR_MINIMUM_INTERNAL(const value_type&, T *)
    SWIG_STD_VECTOR_EXTRA_OP_EQUALS_EQUALS(T *)
  };
  // bool is specialized in the C++ standard - const_reference in particular
  template<> class vector<bool> {
    SWIG_STD_VECTOR_MINIMUM_INTERNAL(bool, bool)
    SWIG_STD_VECTOR_EXTRA_OP_EQUALS_EQUALS(bool)
  };
}

// template specializations for std::vector
// these provide extra collections methods as operator== is defined
SWIG_STD_VECTOR_ENHANCED(char)
SWIG_STD_VECTOR_ENHANCED(signed char)
SWIG_STD_VECTOR_ENHANCED(unsigned char)
SWIG_STD_VECTOR_ENHANCED(short)
SWIG_STD_VECTOR_ENHANCED(unsigned short)
SWIG_STD_VECTOR_ENHANCED(int)
SWIG_STD_VECTOR_ENHANCED(unsigned int)
SWIG_STD_VECTOR_ENHANCED(long)
SWIG_STD_VECTOR_ENHANCED(unsigned long)
SWIG_STD_VECTOR_ENHANCED(long long)
SWIG_STD_VECTOR_ENHANCED(unsigned long long)
SWIG_STD_VECTOR_ENHANCED(float)
SWIG_STD_VECTOR_ENHANCED(double)
SWIG_STD_VECTOR_ENHANCED(std::string) // also requires a %include <std_string.i>
SWIG_STD_VECTOR_ENHANCED(std::wstring) // also requires a %include <std_wstring.i>
