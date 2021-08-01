import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'firebase_provider.dart';
import 'package:provider/provider.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:cloud_firestore/cloud_firestore.dart';

late SignUpPageState pageState;

class SignUpPage extends StatefulWidget {
  @override
  SignUpPageState createState() {
    pageState = SignUpPageState();
    return pageState;
  }
}

class SignUpPageState extends State<SignUpPage> {
  TextEditingController emailInput = TextEditingController();
  TextEditingController pwdInput = TextEditingController();
  TextEditingController nameInput = TextEditingController();
  TextEditingController repwdInput = TextEditingController();
  TextEditingController nickInput = TextEditingController();

  FirebaseFirestore fs = FirebaseFirestore.instance; // 파이어베이스 db 인스턴스 생성

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  late FirebaseProvider fp;

  String gender = "";
  List<bool> listBool = [false, false, false, false];
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    setState(() {
      gender = "여자";
    });
    super.initState();
  }

  @override
  void dispose() {
    emailInput.dispose();
    pwdInput.dispose();
    nameInput.dispose();
    repwdInput.dispose();
    nickInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);

    return Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        body: SingleChildScrollView(
            child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage("assets/images/belogin.png"),
                )),
                child: Column(children: [
                  Container(
                    width: double.infinity,
                    height: MediaQuery.of(context).size.height * 1.6,
                    margin: const EdgeInsets.only(top: 28, bottom: 28),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(60),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(children: [
                        // 상단
                        cSizedBox(30, 0),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: Icon(Icons.navigate_before),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                              cSizedBox(0, 0),
                              Text(
                                "회원가입",
                                style: TextStyle(
                                    color: Colors.indigo.shade400,
                                    fontSize: 25,
                                    fontWeight: FontWeight.bold),
                              ),
                              cSizedBox(0, 85)
                            ]),
                        Container(
                          margin: EdgeInsets.only(top: 15),
                          height: 5,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              stops: [0.0, 1.0],
                              colors: [
                                Colors.blue.shade200,
                                Colors.deepPurple.shade200,
                              ],
                            ),
                          ),
                        ),
                        cSizedBox(40, 0),

                        // 입력
                        // 1) email
                        inputNav(Icons.email, "  웹메일"),
                        Container(
                            padding: EdgeInsets.fromLTRB(60, 0, 60, 0),
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 15),
                            height: 68,
                            child: TextFormField(
                              controller: emailInput,
                              decoration: InputDecoration(
                                hintText: "   웹메일(학교 이메일)",
                                errorStyle:
                                    TextStyle(color: Colors.indigo.shade200),
                              ),
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return "이메일은 필수 입력 사항입니다.";
                                } else if (!text.contains("@")) {
                                  return "부산대학교 웹메일을 사용하셔야 합니다.";
                                } else if (text.contains("@") &&
                                    text.split("@")[1] != "pusan.ac.kr") {
                                  return "부산대학교 웹메일을 사용하셔야 합니다.";
                                }
                                return null;
                              },
                            )),

                        // pwd
                        inputNav(Icons.lock, "  비밀번호"),
                        Container(
                            padding: EdgeInsets.fromLTRB(60, 0, 60, 0),
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 15),
                            height: 68,
                            child: TextFormField(
                              controller: pwdInput,
                              decoration: InputDecoration(
                                hintText: "   비밀번호(6자 이상)",
                                errorStyle:
                                    TextStyle(color: Colors.indigo.shade200),
                              ),
                              obscureText: true,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return "비밀번호는 필수 입력 사항입니다.";
                                } else if (text.length < 6) {
                                  return "비밀번호는 6자 이상이어야 합니다.";
                                }
                                return null;
                              },
                            )),

                        // confirm pwd
                        inputNav(Icons.lock, "  비밀번호 확인"),
                        Container(
                            padding: EdgeInsets.fromLTRB(60, 0, 60, 0),
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 15),
                            height: 68,
                            child: TextFormField(
                              controller: repwdInput,
                              decoration: InputDecoration(
                                hintText: "   비밀번호 확인",
                                errorStyle:
                                    TextStyle(color: Colors.indigo.shade200),
                              ),
                              obscureText: true,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return "비밀번호를 한번 더 입력 해주세요.";
                                } else if (text.length < 6) {
                                  return "비밀번호가 일치하지 않습니다.";
                                }
                                return null;
                              },
                            )),

                        // name
                        inputNav(Icons.arrow_forward, "  이름(실명)"),
                        Container(
                            padding: EdgeInsets.fromLTRB(60, 0, 60, 0),
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 15),
                            height: 68,
                            child: TextFormField(
                                controller: nameInput,
                                decoration: InputDecoration(
                                  hintText: "   이름",
                                  errorStyle:
                                      TextStyle(color: Colors.indigo.shade200),
                                ),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "이름은 필수 입력 사항입니다.";
                                  }
                                  return null;
                                })),

                        // nickname
                        inputNav(Icons.arrow_forward, "  닉네임"),
                        Container(
                            padding: EdgeInsets.fromLTRB(60, 0, 60, 0),
                            margin: EdgeInsets.fromLTRB(0, 5, 0, 15),
                            height: 68,
                            child: TextFormField(
                                controller: nickInput,
                                decoration: InputDecoration(
                                  hintText: "   닉네임",
                                  errorStyle:
                                      TextStyle(color: Colors.indigo.shade200),
                                ),
                                obscureText: true,
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "닉네임은 필수 입력 사항입니다.";
                                  }
                                  return null;
                                })),

                        // gender
                        inputNav(Icons.face, "  성별"),
                        Row(
                          children: [
                            Padding(padding: EdgeInsets.fromLTRB(0, 60, 0, 0)),
                            cSizedBox(0, 50),
                            Theme(
                              data: ThemeData(
                                  unselectedWidgetColor: Colors.black38),
                              child: Radio(
                                  value: "여자",
                                  activeColor: Colors.black38,
                                  groupValue: gender,
                                  onChanged: (String? value) {
                                    setState(() {
                                      gender = value!;
                                    });
                                  }),
                            ),
                            Text(
                              "여자",
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                            Theme(
                              data: ThemeData(
                                  unselectedWidgetColor: Colors.black38),
                              child: Radio(
                                  value: "남자",
                                  activeColor: Colors.black38,
                                  groupValue: gender,
                                  onChanged: (String? value) {
                                    setState(() {
                                      gender = value!;
                                    });
                                  }),
                            ),
                            Text(
                              "남자",
                              style: TextStyle(
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        cSizedBox(10, 0),

                        // ToS
                        inputNav(Icons.task_alt, "  약관동의"),
                        cSizedBox(10, 0),
                        tos("서비스 이용 약관 동의 (필수)", 0),
                        tos("개인 정보 수집 및 이용 동의 (필수)", 1),
                        tos("위치 정보 이용 약관 동의 (선택)", 2),
                        tos("알림 수신 동의 (선택)", 3),
                        cSizedBox(10, 0),

                        // SignUp Button
                        Container(
                          width: 270,
                          height: 50,
                          margin: EdgeInsets.fromLTRB(0, 15, 0, 0),
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                primary: Color(0xff9995f9).withOpacity(0.8),
                              ),
                              child: Text(
                                "회원가입",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                              onPressed: () {
                                FocusScope.of(context)
                                    .requestFocus(new FocusNode());
                                if (_formKey.currentState!.validate()) {
                                  _signUp();
                                }
                              }),
                        ),
                      ]),
                    ),
                  ),
                ]))));
  }

  Widget inputNav(IconData data, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 30)),
        cSizedBox(0, 45),
        Icon(data, color: Color(0xffFF576FBA), size: 19),
        Container(
          height: 25,
          child: Text(
            text,
            style: TextStyle(
              color: Colors.indigo.shade300,
              fontSize: 17,
            ),
            textAlign: TextAlign.left,
          ),
        ),
      ],
    );
  }

  Widget tos(String text, int num) {
    return Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
      cSizedBox(0, 50),
      Theme(
        data: ThemeData(unselectedWidgetColor: Colors.black26),
        child: Checkbox(
            activeColor: Colors.black26,
            value: listBool[num],
            onChanged: (bool? value) {
              setState(() {
                listBool[num] = value!;
              });
            }),
      ),
      Text(
        text,
        style: TextStyle(
          fontSize: 16,
        ),
      ),
    ]);
  }

  Widget cSizedBox(double h, double w) {
    return SizedBox(
      height: h,
      width: w,
    );
  }

  void _signUp() async {
    QuerySnapshot tmp = await fs.collection('users').get();
    int num = tmp.size;

    if (!(listBool[0] && listBool[1])) {
      fp.setMessage("not-agree");
      showMessage();
      return;
    }

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          backgroundColor: Colors.indigo.shade200,
          duration: Duration(seconds: 10),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          content: Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 17,
                  width: 17,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation(Colors.white),
                    backgroundColor: Colors.indigo.shade200,
                  ),
                ),
                SizedBox(width: 15),
                Text("계정생성 중..."),
              ],
            ),
          )),
    );
    bool result = await fp.signUp(emailInput.text, pwdInput.text);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (result) {
      Navigator.pop(context);
      fs.collection('users').doc(emailInput.text).set({
        'name': nameInput.text,
        'num': num,
        'nick': nickInput.text,
        'gender': gender,
        'email': emailInput.text,
        'postcount': 0,
        'piccount': 0,
        // 프로필사진, 내가 참가한 방 목록
        'photoUrl':
            'https://firebasestorage.googleapis.com/v0/b/example-18d75.appspot.com/o/%ED%99%94%EB%A9%B4%20%EC%BA%A1%EC%B2%98%202021-07-21%20113022.png?alt=media&token=b9b9dfb3-ac59-430c-b35b-04d9fad08ae6',
        'joiningIn': null,
        'portfolio': [],
      });
    } else {
      showMessage();
    }
  }

  showMessage() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.indigo.shade200,
      duration: Duration(seconds: 10),
      content: Text(fp.getMessage()),
      action: SnackBarAction(
        label: "확인",
        textColor: Colors.white,
        onPressed: () {},
      ),
    ));
  }
}
