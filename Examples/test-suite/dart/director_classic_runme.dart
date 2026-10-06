import 'director_classic.dart';

void check(Person person, String expected) {
  // Normal target language polymorphic call
  var ret = person.id();
  if (ret != expected) {
    throw Exception('Failed. Received: $ret Expected: $expected');
  }

  // Polymorphic call from C++
  final caller = Caller();
  caller.setCallback(person);
  ret = caller.call();
  if (ret != expected) {
    throw Exception('Failed. Received: $ret Expected: $expected');
  }

  // Polymorphic call of object created in target language and passed to C++ and back again
  final baseclass = caller.baseClass()!;
  ret = baseclass.id();
  if (ret != expected) {
    throw Exception('Failed. Received: $ret Expected: $expected');
  }

  caller.resetCallback();
}

class TargetLangPerson extends Person {
  @override
  String id() => 'TargetLangPerson';
}

class TargetLangChild extends Child {
  @override
  String id() => 'TargetLangChild';
}

class TargetLangGrandChild extends GrandChild {
  @override
  String id() => 'TargetLangGrandChild';
}

// Semis - don't override id() in target language
class TargetLangSemiPerson extends Person {}

class TargetLangSemiChild extends Child {}

class TargetLangSemiGrandChild extends GrandChild {}

// Orphans - don't override id() in C++
class TargetLangOrphanPerson extends OrphanPerson {
  @override
  String id() => 'TargetLangOrphanPerson';
}

class TargetLangOrphanChild extends OrphanChild {
  @override
  String id() => 'TargetLangOrphanChild';
}

// Duals - id() makes an upcall to the base id()
class TargetLangDualPerson extends Person {
  @override
  String id() => 'TargetLangDualPerson + ' + super.id();
}

class TargetLangDualChild extends Child {
  @override
  String id() => 'TargetLangDualChild + ' + super.id();
}

class TargetLangDualGrandChild extends GrandChild {
  @override
  String id() => 'TargetLangDualGrandChild + ' + super.id();
}

// Mix Orphans and Duals
class TargetLangDualOrphanPerson extends OrphanPerson {
  @override
  String id() => 'TargetLangDualOrphanPerson + ' + super.id();
}

class TargetLangDualOrphanChild extends OrphanChild {
  @override
  String id() => 'TargetLangDualOrphanChild + ' + super.id();
}

void checkAndDispose(Person person, String expected) {
  check(person, expected);
  person.dispose();
}

void main() {
  checkAndDispose(Person(), 'Person');
  checkAndDispose(Child(), 'Child');
  checkAndDispose(GrandChild(), 'GrandChild');
  checkAndDispose(TargetLangPerson(), 'TargetLangPerson');
  checkAndDispose(TargetLangChild(), 'TargetLangChild');
  checkAndDispose(TargetLangGrandChild(), 'TargetLangGrandChild');

  // Semis - don't override id() in target language
  checkAndDispose(TargetLangSemiPerson(), 'Person');
  checkAndDispose(TargetLangSemiChild(), 'Child');
  checkAndDispose(TargetLangSemiGrandChild(), 'GrandChild');

  // Orphans - don't override id() in C++
  checkAndDispose(OrphanPerson(), 'Person');
  checkAndDispose(OrphanChild(), 'Child');
  checkAndDispose(TargetLangOrphanPerson(), 'TargetLangOrphanPerson');
  checkAndDispose(TargetLangOrphanChild(), 'TargetLangOrphanChild');

  // Duals - id() makes an upcall to the base id()
  checkAndDispose(TargetLangDualPerson(), 'TargetLangDualPerson + Person');
  checkAndDispose(TargetLangDualChild(), 'TargetLangDualChild + Child');
  checkAndDispose(TargetLangDualGrandChild(), 'TargetLangDualGrandChild + GrandChild');

  // Mix Orphans and Duals
  checkAndDispose(TargetLangDualOrphanPerson(), 'TargetLangDualOrphanPerson + Person');
  checkAndDispose(TargetLangDualOrphanChild(), 'TargetLangDualOrphanChild + Child');
}
