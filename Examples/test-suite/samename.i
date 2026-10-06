%module samename

#if !(defined(SWIGCSHARP) || defined(SWIGJAVA) || defined(SWIGD) || defined(SWIGDART))
class samename {
 public:
  void do_something() {
    // ...
  }
};
#endif

%{

class samename {
 public:
  void do_something() {
    // ...
  }
};

%}

