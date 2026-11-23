// Ownership of the Dart proxies of classes managed by a std::shared_ptr (Lib/dart/boost_shared_ptr.i):
// every proxy level holds its own shared_ptr, dispose() releases all of them, and the C++ object is
// deleted once, when the last shared_ptr goes.
%module dart_shared_ptr

%include <std_shared_ptr.i>
%include <std_vector.i>

%shared_ptr(Base)
%shared_ptr(Derived)
%shared_ptr(MoreDerived)

%inline %{
#include <memory>
#include <vector>

struct Base {
  static int live;
  int value;
  Base(int v = 0) : value(v) { ++live; }
  Base(const Base &other) : value(other.value) { ++live; }
  virtual ~Base() { --live; }
  virtual int get() const { return value; }
};
int Base::live = 0;

struct Derived : Base {
  Derived(int v = 0) : Base(v) {}
  int get() const { return value * 10; }
};

struct MoreDerived : Derived {
  MoreDerived(int v = 0) : Derived(v) {}
  int get() const { return value * 100; }
};

int live_count() { return Base::live; }

// shared_ptr kept on the C++ side, to look at the use count from Dart
std::shared_ptr<Base> kept;
void keep(std::shared_ptr<Base> b) { kept = b; }
void release_kept() { kept.reset(); }
long kept_use_count() { return kept.use_count(); }

std::shared_ptr<Derived> make_derived(int v) { return std::make_shared<Derived>(v); }
std::shared_ptr<MoreDerived> make_more_derived(int v) { return std::make_shared<MoreDerived>(v); }
std::shared_ptr<Base> make_as_base(int v) { return std::make_shared<Derived>(v); }
std::shared_ptr<Base> make_null() { return std::shared_ptr<Base>(); }

// The different ways to pass a class managed by a shared_ptr
int by_value(Base b) { return b.value; }
int by_ref(Base &b) { return b.get(); }
int by_const_ref(const Base &b) { return b.get(); }
int by_ptr(Base *b) { return b ? b->get() : -1; }
int by_shared_ptr(std::shared_ptr<Base> b) { return b ? b->get() : -1; }
int by_shared_ptr_ref(std::shared_ptr<Base> &b) { return b ? b->get() : -1; }
int by_shared_ptr_const_ref(const std::shared_ptr<Base> &b) { return b ? b->get() : -1; }
int by_shared_ptr_ptr(std::shared_ptr<Base> *b) { return (b && *b) ? (*b)->get() : -1; }
long use_count_of(const std::shared_ptr<Base> &b) { return b.use_count(); }

// The different ways to return one
Base ret_value() { return Base(7); }
Base &ret_ref() { static Base b(8); return b; }
Base *ret_ptr() { static Base b(9); return &b; }
Base *ret_null_ptr() { return 0; }
const std::shared_ptr<Base> &ret_shared_ptr_ref() { static std::shared_ptr<Base> b(new Base(11)); return b; }

std::vector<std::shared_ptr<Base> > make_vector() {
  std::vector<std::shared_ptr<Base> > v;
  v.push_back(std::make_shared<Base>(1));
  v.push_back(std::shared_ptr<Base>());
  v.push_back(std::make_shared<Derived>(3));
  return v;
}
%}

%template(BaseVector) std::vector<std::shared_ptr<Base> >;
