import 'inherit_target_language.dart';

void main() {
  Derived1().targetLanguageBaseMethod();
  Derived2().targetLanguageBaseMethod();

  MultipleDerived1().targetLanguageBaseMethod();
  MultipleDerived2().targetLanguageBaseMethod();
  MultipleDerived3().f();
  MultipleDerived4().g();

  final baseX = BaseX();
  baseX.basex();
  baseX.targetLanguageBase2Method();

  final derivedX = DerivedX();
  derivedX.basex();
  derivedX.derivedx();
  derivedX.targetLanguageBase2Method();
}
