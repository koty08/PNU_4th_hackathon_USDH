import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'findpw_page.dart';
import 'package:page_transition/page_transition.dart';
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

    return Scaffold(
      key: _scaffoldKey,
      body: SingleChildScrollView(
        // background
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width,
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage("assets/images/belogin.png"),
            )
          ),
          child: Column(
            children: [
              // white container
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(top: 250),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(60),
                    topRight: Radius.circular(60),
                  )
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 30, right: 30, top: 60),
                  child: Column(
                    children: [
                      // E-mail
                      Container(
                        padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
                        child: TextField(
                          controller: emailInput,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.mail),
                            hintText: "이메일",
                          ),
                        ),
                      ),

                      // Password
                      Container(
                        padding: EdgeInsets.only(left: 30, right: 30, top: 10, bottom: 10),
                        child: TextField(
                          controller: pwdInput,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock),
                            hintText: "비밀번호",
                          ),
                          obscureText: true,
                        ),
                      ),

                      // Remember Me
                      Container(
                        padding: EdgeInsets.only(right: 30),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 25,
                                height: 30, // PW - RM 간격 조절
                                child: Transform.scale(
                                    scale: 0.8,
                                    child: Theme(
                                    data: ThemeData(unselectedWidgetColor: Colors.indigo.shade300),
                                    child: Checkbox(
                                      value: remember,
                                      shape: CircleBorder(),
                                      activeColor: Colors.indigo.shade300,
                                      onChanged: (newValue) {
                                        setState(() {
                                          remember = newValue ?? false;
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              cSizedBox(2, 0),
                              Text("계정 저장",
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.indigo.shade300,
                                ),),
                            ]
                        ),
                      ),
                      cSizedBox(25, 0),

                      // Sign In Button
                      Container(
                        width: 270,
                        height: 50,
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black26, offset: Offset(0, 3), blurRadius: 5.0)
                          ],
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            stops: [0.0, 1.0],
                            colors: [
                              Colors.blue.shade200,
                              Colors.deepPurple.shade200,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            primary: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text(
                            "로그인",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          onPressed: () {
                            FocusScope.of(context).requestFocus(new FocusNode()); // 키보드 감춤
                            _signIn();
                          },
                        ),
                      ),
                      cSizedBox(10, 0),

                      // Find PW & Sign Up Button
                      Wrap(
                        direction: Axis.horizontal,
                        alignment: WrapAlignment.center,
                        spacing: 75,
                        children: <Widget>[
                          // Find PW
                          TextButton(
                            child: Text(
                              "비밀번호 찾기",
                              style: TextStyle(
                                color: Colors.indigo.shade300, fontSize: 15,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) => FindPWPage()));
                            },
                          ),

                          // Sign Up Button
                          TextButton(
                            child: Text(
                              "회원가입",
                              style: TextStyle(
                                color: Colors.indigo.shade400, fontSize: 15,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            onPressed: () {
                              Navigator.push(context,
                                  PageTransition(type: PageTransitionType.bottomToTop,
                                      child: SignUpPage()));
                            },
                          ),
                        ],
                      ),


                  // Alert Box
                  (fp.getUser() != null && fp.getUser()?.emailVerified == false)
                      ? Container(
                    margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    decoration: BoxDecoration(color: Colors.red[300]),
                    child: Column(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(
                            "이메일 인증이 완료되지 않았습니다."
                                "\n이메일을 확인하여 주시기 바랍니다.",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.lightBlue[400],
                            onPrimary: Colors.white,
                          ),
                          child: Text("이메일 인증 다시 보내기"),
                          onPressed: () {
                            FocusScope.of(context)
                                .requestFocus(new FocusNode()); // 키보드 감춤
                            fp.getUser()?.sendEmailVerification();
                          },
                        )
                      ],
                    ),
                  )
                      : Container(),
                    ]
                  ),
                ),
              )
            ]
          ),
        )
      )
    );
  }

  Widget cSizedBox(double h, double w){
    return SizedBox(
      height: h,
      width: w,
    );
  }

  void _signIn() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.indigo.shade200,
        duration: Duration(seconds: 10),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
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
              Text("로그인 중..."),
            ],
          ),
        )),
    );
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