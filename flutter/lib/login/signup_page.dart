import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:usdh/Widget/widget.dart';
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
        resizeToAvoidBottomInset: false,
        key: _scaffoldKey,
        appBar: AppBar(
          leading: IconButton(
            padding: EdgeInsets.fromLTRB(width*0.05, 0, 0, 0),
            icon: Image.asset('assets/images/icon/iconback.png', width: 20, height: 20),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          centerTitle: true,
          title: Text("회원가입", style: TextStyle(color: Colors.indigo.shade400, fontSize: 20, fontWeight: FontWeight.bold),),
          backgroundColor: Colors.white,
          bottom: PreferredSize(
            child: Container(
              margin: EdgeInsets.only(top: 15),
              height: 3,
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
            preferredSize: Size.fromHeight(3),
          ),
          elevation: 0,
        ),
        body: SingleChildScrollView(
            child: Container(
                child: Column(children: [
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.only(top: height * 0.05),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      //borderRadius: BorderRadius.circular(60),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(children: [
                        // 입력
                        // 1) email
                        inputNav(Icons.email, "  웹메일"),
                        userField(context, emailInput, "웹메일(학교 이메일)", (text) {
                          if (text == null || text.isEmpty) {
                            return "이메일은 필수 입력 사항입니다.";
                          } else if (!text.contains("@")) {
                            return "부산대학교 웹메일을 사용하셔야 합니다.";
                          } else if (text.contains("@") &&
                              text.split("@")[1] != "pusan.ac.kr") {
                            return "부산대학교 웹메일을 사용하셔야 합니다.";
                          }
                          return null;
                        }),

                        // pwd
                        inputNav(Icons.lock, "  비밀번호"),
                        userField2(context, pwdInput, "비밀번호(6자 이상)", (text){
                          if(text == null || text.isEmpty){
                            return "비밀번호는 필수 입력 사항입니다.";
                          }
                          else if(text.length < 6){
                            return "비밀번호는 6자 이상이어야 합니다.";
                          }
                          return null;
                        }),

                        // confirm pwd
                        inputNav(Icons.lock, "  비밀번호 확인"),
                        userField2(context, repwdInput, "비밀번호 확인", (text){
                          if(text == null || text.isEmpty){
                            return "비밀번호를 한번 더 입력 해주세요.";
                          }
                          else if(pwdInput.text != text){
                            return "비밀번호가 일치하지 않습니다.";
                          }
                          return null;
                        }),

                        // name
                        inputNav(Icons.arrow_forward, "  이름(실명)"),
                        userField(context, nameInput, "이름", (text){
                          if(text == null || text.isEmpty){
                            return "이름은 필수 입력 사항입니다.";
                          }
                          return null;
                        }),

                        // nickname
                        inputNav(Icons.arrow_forward, "  닉네임"),
                        userField(context, nickInput, "닉네임", (text){
                          if(text == null || text.isEmpty){
                            return "닉네임은 필수 입력 사항입니다.";
                          }
                          return null;
                        }),

                        // gender
                        inputNav(Icons.face, "  성별"),
                        Row(
                          children: [
                            Padding(padding: EdgeInsets.fromLTRB(width*0.1, height*0.05, 0, height*0.05)),
                            Transform.scale(
                              scale: 0.9,
                              child: Theme(
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
                            ),
                            info2Text("여자"),
                            Transform.scale(
                              scale: 0.9,
                              child: Theme(
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
                            ),
                            info2Text("남자"),
                          ],
                        ),
                        cSizedBox(15, 0),

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
                          margin: EdgeInsets.fromLTRB(0, height*0.03, 0, height*0.08),
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

  Widget tos(String text, int num) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        cSizedBox(0, 40),
        Transform.scale(
          scale: 0.8,
          child: Theme(
            data: ThemeData(unselectedWidgetColor: Colors.black26),
            child: Checkbox(
              activeColor: Colors.black26,
              value: listBool[num],
              onChanged: (bool? value) {
                setState(() {
                  listBool[num] = value!;
                });
              }
            ),
          ),
        ),
        condText(text)
    ]);
  }

  void _signUp() async {
    QuerySnapshot tmp = await fs.collection('users').get();
    int num = tmp.size+1;

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
        'photoUrl':
            'https://firebasestorage.googleapis.com/v0/b/example-18d75.appspot.com/o/profile%2F1629181021057.png?alt=media&token=3a1a8ded-a622-4b73-af91-d5a2f09d5905',
        'portfolio': List.empty(),
        'portfolio_tag': List.empty(),
        'coverletter' : List.empty(),
        'coverletter_tag' : List.empty(),
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
