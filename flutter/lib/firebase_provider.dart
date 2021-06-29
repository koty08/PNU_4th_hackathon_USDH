import 'package:flutter/cupertino.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';

Logger logger = Logger();

class FirebaseProvider with ChangeNotifier {
  final FirebaseAuth authIns = FirebaseAuth.instance; // Firebase 인증 플러그인의 인스턴스
  FirebaseFirestore fs = FirebaseFirestore.instance; // 파이어베이스 db 인스턴스 생성

  late User? _user; // Firebase에 로그인 된 사용자
  String fbMsg = ""; // 

  FirebaseProvider() {
    logger.d("initializing...");
    setUser(authIns.currentUser);
  }

  User? getUser() {
    return _user;
  }

  void setUser(User? value) {
    _user = value;
    notifyListeners();
  }

  // 회원가입
  Future<bool> signUpWithEmail(String email, String password) async {
    try {
      UserCredential result = await authIns.createUserWithEmailAndPassword(
          email: email, password: password);
      if (result.user != null) {
        result.user!.sendEmailVerification();
        signOut();
        return true;
      }
    } on Exception catch (e) {
      logger.e(e.toString());
      List<String> result = e.toString().split(", ");
      setMessage(result[0]);
      return false;
    }
    return false;
  }

  // 로그인
  Future<bool> signInWithEmail(String email, String password) async {
    try {
      authIns.setLanguageCode("ko");
      var result = await authIns.signInWithEmailAndPassword(
          email: email, password: password);
        setUser(result.user);
        logger.d(getUser());
        return true;
    } on Exception catch (e) {
      logger.e(e.toString());
      List<String> result = e.toString().split(", ");
      setMessage(result[0]);
    }
    return false;
  }

  // 로그아웃
  signOut() async {
    await authIns.signOut();
    setUser(null);
  }

  // 비밀번호 재설정 메일 발송.
  sendPWResetEmail() async {
    await authIns.setLanguageCode("ko");
    authIns.sendPasswordResetEmail(email: getUser()?.email);
  }

  // 회원 탈퇴
  withdrawalAccount() async {
    // print(getUser()?.email);
    await fs.collection('users').doc(getUser()?.email).delete();
    await getUser()?.delete();
    setUser(null);
  }

  // Firebase로부터 수신한 메시지 설정
  setMessage(String msg) {
    fbMsg = msg;
  }

  // Firebase로부터 수신한 메시지를 반환
  getMessage() {
    String returnValue = fbMsg;
    fbMsg = "";
    return returnValue;
  }
}