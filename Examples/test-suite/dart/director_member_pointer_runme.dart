import 'director_member_pointer.dart';

void check(int got, int expected, String what) {
  if (got != expected) {
    throw Exception('$what got $got expected $expected');
  }
}

class MyMemberPtrDirector extends MemberPtrDirector {
  bool returnNull = false;

  @override
  int useMemberPtr(SWIGTYPE_m_MemberPtrFuncs__f_int__int? m, int x) {
    return (m == null) ? -1 : MemberPtrDirector.callMemberPtr(m, x + 10);
  }

  @override
  int useMemberPtrCref(SWIGTYPE_m_MemberPtrFuncs__f_int__int? m, int x) {
    return MemberPtrDirector.callMemberPtr(m, x + 20);
  }

  @override
  SWIGTYPE_m_MemberPtrFuncs__f_int__int? getMemberPtr() {
    return returnNull ? null : MemberPtrDirector.addPtr();
  }

  @override
  SWIGTYPE_m_MemberPtrFuncs__f_int__int? getMemberPtrCref() {
    return returnNull ? null : MemberPtrDirector.addPtr();
  }
}

void main() {
  final d = MemberPtrDirector();
  check(d.callUseMemberPtr(5), 7, 'Base useMemberPtr');
  check(d.callUseMemberPtrCref(5), 7, 'Base useMemberPtrCref');
  check(d.callGetMemberPtr(5), 6, 'Base getMemberPtr');
  check(d.callGetMemberPtrCref(5), 6, 'Base getMemberPtrCref');
  d.dispose();

  final md = MyMemberPtrDirector();
  check(md.callUseMemberPtr(5), 17, 'Director useMemberPtr');
  check(md.callUseMemberPtrCref(5), 27, 'Director useMemberPtrCref');
  check(md.callGetMemberPtr(5), 7, 'Director getMemberPtr');
  check(md.callGetMemberPtrCref(5), 7, 'Director getMemberPtrCref');

  // NULL member pointers
  check(md.callUseNullMemberPtr(5), -1, 'Director useMemberPtr with a null member pointer');
  md.returnNull = true;
  if (!md.callGetMemberPtrIsNull()) {
    throw Exception('Director getMemberPtr returning null failed');
  }
  if (!md.callGetMemberPtrCrefIsNull()) {
    throw Exception('Director getMemberPtrCref returning null failed');
  }
  md.dispose();
}
