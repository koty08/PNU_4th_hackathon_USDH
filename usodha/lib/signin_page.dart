import 'package:flutter/material.dart';
import 'firebase_provider.dart';
import 'signup_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SignInPageState pageState;

class SignInPage extends StatefulWidget {
  @override
  SignInPageState createState() {
    pageState = SignInPageState();
    return pageState;
  }
}

class SignInPageState extends State<SignInPage> {
  TextEditingController emailInput = TextEditingController();
  TextEditingController pwdInput = TextEditingController();
  bool remember = false;

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  late FirebaseProvider fp;

  @override
  void initState() {
    super.initState();
    getRememberInfo();
  }

  @override
  void dispose() {
    setRememberInfo();
    emailInput.dispose();
    pwdInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);

    logger.d(fp.getUser());
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(title: Text("로그인 페이지")),
      body: ListView(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Column(
              children: <Widget>[
                //Header
                Container(
                  height: 50,
                  decoration: BoxDecoration(color: Colors.amber),
                  child: Center(
                    child: Text(
                      "로그인",
                      style: TextStyle(
                          color: Colors.blueGrey,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // Input Area
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.amber, width: 1),
                  ),
                  child: Column(
                    children: <Widget>[
                      TextField(
                        controller: emailInput,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.mail),
                          hintText: "이메일",
                        ),
                      ),
                      TextField(
                        controller: pwdInput,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock),
                          hintText: "비밀번호",
                        ),
                        obscureText: true,
                      ),
                    ].map((c) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        child: c,
                      );
                    }).toList(),
                  ),
                )
              ],
            ),
          ),
          // Remember Me
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: <Widget>[
                Checkbox(
                  value: remember,
                  onChanged: (newValue) {
                    setState(() {
                      remember = newValue ?? false;
                    });
                  },
                ),
                Text("계정 저장")
              ],
            ),
          ),

          // // Alert Box
          // (fp.getUser() != null && fp.getUser()?.emailVerified == false)
          //     ? Container(
          //         margin:
          //             const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
          //         decoration: BoxDecoration(color: Colors.red[300]),
          //         child: Column(
          //           children: <Widget>[
          //             Padding(
          //               padding: const EdgeInsets.all(10.0),
          //               child: Text(
          //                 "이메일 인증이 완료되지 않았습니다."
          //                 "\n이메일을 확인하여 주시기 바랍니다.",
          //                 style: TextStyle(color: Colors.white),
          //               ),
          //             ),
          //             ElevatedButton(
          //               style: ElevatedButton.styleFrom(
          //                 primary: Colors.lightBlue[400],
          //                 onPrimary: Colors.white,
          //               ),
          //               child: Text("이메일 인증 다시 보내기"),
          //               onPressed: () {
          //                 FocusScope.of(context)
          //                     .requestFocus(new FocusNode()); // 키보드 감춤
          //                 fp.getUser()?.sendEmailVerification();
          //               },
          //             )
          //           ],
          //         ),
          //       )
          //     : Container(),

          // Sign In Button
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                primary: Colors.indigo[300],
              ),
              child: Text(
                "로그인",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                FocusScope.of(context).requestFocus(new FocusNode()); // 키보드 감춤
                _signIn();
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            padding: const EdgeInsets.only(top: 50),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text("계정이 필요한가요?", style: TextStyle(color: Colors.blueGrey)),
                TextButton(
                  child: Text(
                    "계정 생성",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => SignUpPage()));
                  },
                )
              ],
            ),
          )
        ],
      ),
    );
  }

  void _signIn() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      duration: Duration(seconds: 10),
      content: Row(
        children: <Widget>[CircularProgressIndicator(), Text("   로그인 중...")],
      ),
    ));
    bool result = await fp.signIn(emailInput.text, pwdInput.text);
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    if (result == false) showMessage();
  }

  getRememberInfo() async {
    logger.d(remember);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      remember = (prefs.getBool("remember") ?? false);
    });
    if (remember) {
      setState(() {
        emailInput.text = (prefs.getString("userEmail") ?? "");
        pwdInput.text = (prefs.getString("userPasswd") ?? "");
      });
    }
  }

  setRememberInfo() async {
    logger.d(remember);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool("remember", remember);
    if (remember) {
      prefs.setString("userEmail", emailInput.text);
      prefs.setString("userPasswd", pwdInput.text);
    }
  }

  showMessage() {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.red[400],
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
