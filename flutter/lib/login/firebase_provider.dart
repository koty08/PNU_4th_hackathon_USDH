import 'package:flutter/cupertino.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';

Logger logger = Logger();

class FirebaseProvider with ChangeNotifier {
  final FirebaseAuth authIns = FirebaseAuth.instance; // Firebase 인증 플러그인의 인스턴스
  FirebaseFirestore fs = FirebaseFirestore.instance; // 파이어베이스 db 인스턴스 생성

  late User? _user; // Firebase에 로그인 된 사용자
  String fbMsg = ""; // 오류 띄워줄 메세지

  Map<String, dynamic> info = {};

  // 생성자
  FirebaseProvider() {
    logger.d("initializing...");
    setUser(authIns.currentUser);
  }

  // 현재 접속한 사용자 가져오기
  User? getUser() {
    return _user;
  }

  // 사용자 바꾸기
  void setUser(User? value) {
    _user = value;
    notifyListeners();
  }

  void setInfo() async {
    await fs
        .collection('users')
        .doc(getUser()?.email)
        .get()
        .then((DocumentSnapshot snap) {
      info = snap.data() as Map<String, dynamic>;
    });
  }
  void setInfo2(String email) async {
    await fs
        .collection('users')
        .doc(email)
        .get()
        .then((DocumentSnapshot snap) {
      info = snap.data() as Map<String, dynamic>;
    });
  }

  void updateIntInfo(String target, int value) async {
    await fs
        .collection('users')
        .doc(getUser()?.email)
        .update({target: getInfo()[target] += value});
  }

  Map<String, dynamic> getInfo() {
    return info;
  }

  // 회원가입
  Future<bool> signUp(String email, String password) async {
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
  Future<bool> signIn(String email, String password) async {
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
  PWReset() async {
    await authIns.setLanguageCode("ko");
    authIns.sendPasswordResetEmail(email: getUser()!.email.toString());
  }

  PWReset2(String email) async{
    await authIns.setLanguageCode("ko");
    authIns.sendPasswordResetEmail(email: email);
  }

  // 회원 탈퇴
  withdraw() async {
    // print(getUser()?.email);
    await fs.collection('users').doc(getUser()?.email).delete();
    await getUser()?.delete();
    setUser(null);
  }

  // 수신한 메시지 설정
  setMessage(String msg) {
    fbMsg = msg;
  }

  // 수신한 메시지를 반환
  getMessage() {
    String tmp = fbMsg.split(" ")[0];
    fbMsg = "";
    switch (tmp) {
      case "[firebase_auth/user-not-found]":
        return "해당 이메일로 가입한 사용자가 존재하지 않습니다.";
      case "[firebase_auth/wrong-password]":
        return "비밀번호가 틀렸습니다.";
      case "[firebase_auth/weak-password]":
        return "비밀번호 강도가 너무 낮습니다.";
      case "[firebase_auth/email-already-in-use]":
        return "이미 가입한 이메일입니다.";
      case "not-agree":
        return "필수 항목을 동의하지 않으셨습니다.";
      case "reset-pw":
        return "비밀번호 변경 링크를 이메일을 통해 보내드렸습니다. \n 이메일을 확인해주세요.";
      case "not-match":
        return "해당 입력한 정보를 가진 사용자를 찾을 수 없습니다. 이메일과 이름을 다시 한번 확인해주세요.";
      case "not-submit":
        return "필수 입력란을 전부 입력하지 않으셨습니다. 다시 한번 확인해주세요.";
      default:
        return tmp;
    }
  }
}
