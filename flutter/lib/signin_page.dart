import 'package:flutter/material.dart';
import 'firebase_provider.dart';
import 'signup_page.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

late SignInPageState pageState;
late findPWPageState pageState2;

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
      body: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height,
            maxWidth: MediaQuery.of(context).size.width,
          ),
          decoration: BoxDecoration(
            image: DecorationImage(
              fit: BoxFit.fill,
              image: AssetImage("assets/images/2.png"),
            )
          ),
          child: Column(
            children: [
                Container(
                  width: double.infinity,
                  height: 487,
                  margin: const EdgeInsets.only(left: 28, right: 28, top: 250),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    )
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(left: 20, right: 20, top: 60),
                    child: Column(
                      children: [
                        // E-mail
                        Container(
                          padding: EdgeInsets.all(10.0),
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
                          padding: EdgeInsets.all(10.0),
                          child: TextField(
                            controller: pwdInput,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.lock),
                              hintText: "비밀번호",
                            ),
                            obscureText: true,
                          ),
                        ),

                        // Auto Login(Remember Me)
                        Container(
                          padding: EdgeInsets.only(right: 20),
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                SizedBox(
                                  width: 25,
                                  height: 30, // 비밀번호- 자동 로그인 간격 조절
                                  child: Transform.scale(
                                      scale: 0.8,
                                      child: Theme(
                                      data: ThemeData(unselectedWidgetColor: Color(0xff7FA6C2)),
                                      child: Checkbox(
                                        value: remember,
                                        shape: CircleBorder(),
                                        activeColor: Color(0xff7FA6C2),
                                        onChanged: (newValue) {
                                          setState(() {
                                            remember = newValue ?? false;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 2,
                                ),
                                Text("자동 로그인",
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xff7FA6C2),
                                  ),),
                              ]
                          ),
                        ),
                        SizedBox(
                          height: 35.0,
                        ),

                        // Sign In Button
                        Container(
                          width: 270,
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: new RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(30.0),
                              ),
                              primary: Color.fromRGBO(59, 119, 163, 1),
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
                        SizedBox(
                          height: 10.0,
                        ),

                        // Sign Up Button
                        Container(
                          padding: EdgeInsets.only(right: 20),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: <Widget>[
                              TextButton(
                                child: Text(
                                  "비밀번호 찾기",
                                  style: TextStyle(
                                    color: Color(0xff326487), fontSize: 15,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) => findPWPage()));
                                },
                              ),
                              SizedBox(
                                width: 85,
                              ),
                              TextButton(
                                child: Text(
                                  "회원가입",
                                  style: TextStyle(
                                    color: Color(0xff326487), fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(context,
                                      MaterialPageRoute(builder: (context) => SignUpPage()));
                                },
                              ),
                            ],
                          ),
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
                      ],
                    ),
                  ),
                )
            ]
          )
        )
      )
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


class findPWPage extends StatefulWidget {
  @override
  findPWPageState createState() {
    pageState2 = findPWPageState();
    return pageState2;
  }
}

class findPWPageState extends State<findPWPage>{
  late FirebaseProvider fp;
  TextEditingController emailInput = TextEditingController();
  TextEditingController nameInput = TextEditingController();

  void dispose() {
    emailInput.dispose();
    nameInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    return Scaffold(
        appBar: AppBar(title: Text("비밀번호 찾기 페이지")),
        body: ListView(
            children: <Widget>[
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
                child: Column(
                  children: <Widget>[
                    Container(
                      height: 50,
                      child: Center(
                        child: Text(
                          "이메일과 이름을 입력하면 해당 이메일로 비밀번호 재설정 메세지를 보내드립니다.",
                          style: TextStyle(
                              color: Colors.blueGrey,
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
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
                            controller: nameInput,
                            decoration: InputDecoration(
                              prefixIcon: Icon(Icons.people),
                              hintText: "이름",
                            ),
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
              TextButton(
                child: Text(
                  "비밀번호 변경 이메일 보내기",
                  style: TextStyle(color: Colors.blue, fontSize: 16),
                ),
                onPressed: () {
                  FocusScope.of(context).requestFocus(new FocusNode());
                  sendPWReset();
                },
              ),
            ]
        )
    );
  }
  sendPWReset(){
    fp.setInfo2(emailInput.text);

    if(fp.getInfo()['name'] == nameInput.text && fp.getInfo()['email'] == emailInput.text){
      fp.PWReset2(emailInput.text);
      fp.setMessage("reset-pw");
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      showMessage();
      Navigator.pop(context);
    }
    else{
      fp.setMessage("not-match");
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      showErrorMessage();
    }
  }

  showErrorMessage() {
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
  showMessage(){
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.blue[400],
      duration: Duration(seconds: 10),
      content: Text(fp.getMessage()),
      action: SnackBarAction(
        label: "확인",
        textColor: Colors.black,
        onPressed: () {},
      ),
    ));
  }
}