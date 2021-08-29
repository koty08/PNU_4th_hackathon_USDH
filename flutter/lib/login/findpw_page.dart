import 'package:flutter/material.dart';
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
                  child: Form(
                    key: _formKey,
                    child:
                      Column(
                      children: <Widget>[
                        TextFormField(
                          controller: emailInput,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.mail),
                            hintText: "이메일",
                          ),
                          validator : (text){
                            if(text == null || text.isEmpty){
                              return "이메일은 필수 입력 사항입니다.";
                            }
                            return null;
                          }
                        ),
                        TextFormField(
                          controller: nameInput,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.people),
                            hintText: "이름",
                          ),
                          validator : (text){
                            if(text == null || text.isEmpty){
                              return "이름은 필수 입력 사항입니다.";
                            }
                            return null;
                          }
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