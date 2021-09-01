import 'package:flutter/material.dart';
import 'package:usdh/Widget/widget.dart';
import 'firebase_provider.dart';
import 'package:provider/provider.dart';

late FindPWPageState pageState2;

class FindPWPage extends StatefulWidget {
  @override
  FindPWPageState createState() {
    pageState2 = FindPWPageState();
    return pageState2;
  }
}

class FindPWPageState extends State<FindPWPage>{
  late FirebaseProvider fp;
  TextEditingController emailInput = TextEditingController();
  TextEditingController nameInput = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void dispose() {
    emailInput.dispose();
    nameInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    return Scaffold(
      appBar: CustomAppBar("비밀번호 찾기 페이지", []),
      body: ListView(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Column(
              children: <Widget>[
                Container(
                  height: 50,
                  child: Center(
                    child: info2Text("이메일과 이름을 입력하면\n해당 이메일로 비밀번호 재설정 메세지를 보내드립니다.",),
                  ),
                ),
                cSizedBox(10, 0),
                Divider(thickness: 2,),
                cSizedBox(20, 0),
                Form(
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
                    // name
                    inputNav(Icons.arrow_forward, "  이름(실명)"),
                    userField(context, nameInput, "이름", (text){
                      if(text == null || text.isEmpty){
                        return "이름은 필수 입력 사항입니다.";
                      }
                      return null;
                    }),
                  ]
                  ),
                )
              ],
            ),
          ),
          cSizedBox(10, 0),
          Divider(thickness: 2,),
          cSizedBox(20, 0),
          TextButton(
            child: infoText(
              "비밀번호 변경 이메일 보내기",
            ),
            onPressed: () {
              FocusScope.of(context).requestFocus(new FocusNode());
              if(_formKey.currentState!.validate()){
                sendPWReset();
              }
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