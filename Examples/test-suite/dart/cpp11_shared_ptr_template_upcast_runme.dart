import 'cpp11_shared_ptr_template_upcast.dart';

// PrintableDerived_SWIGSmartPtrUpcast must return a shared_ptr<Derived> for a shared_ptr<Printable<Derived> >,
// Printable<Derived> inheriting virtually from Derived: a wrong pointer type crashes on the calls below.
void main() {
  final pd = cpp11_shared_ptr_template_upcast.MakePrintableDerived(20)!;
  if (pd.GetResult() != 40) {
    throw Exception('GetResult: ${pd.GetResult()}');
  }
  if (pd.GetFormatted() != 'The formatted result is: 40') {
    throw Exception('GetFormatted: ${pd.GetFormatted()}');
  }
  if (pd.value != 20) {
    throw Exception('value: ${pd.value}');
  }
  pd.dispose();
}
