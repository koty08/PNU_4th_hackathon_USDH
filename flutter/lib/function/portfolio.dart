import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usdh/login/firebase_provider.dart';

late PortfolioState pageState;

class Portfolio extends StatefulWidget {
  @override
  PortfolioState createState() {
    pageState = PortfolioState();
    return pageState;
  }
}

class PortfolioState extends State<Portfolio> {
  late FirebaseProvider fp;
  final _formKey = GlobalKey<FormState>();
  TextEditingController introInput = TextEditingController();
  TextEditingController specInput = TextEditingController();
  TextEditingController tagInput = TextEditingController();
  final FirebaseFirestore fs = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();
    return Scaffold(
      appBar: AppBar(
        title: Text("포트폴리오 작성 칸"),
      ),
      body: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 30,
                child: TextFormField(
                    controller: introInput,
                    decoration:
                        InputDecoration(hintText: "여기에 자기소개 글을 작성해주세요."),
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "자기소개를 입력하지 않으셨습니다.";
                      }
                      return null;
                    }),
              ),
              Container(
                height: 50,
                child: TextFormField(
                  controller: specInput,
                  decoration:
                      InputDecoration(hintText: "어필할 경력 혹은 스펙들을 입력하세요."),
                ),
              ),
              Container(
                height: 30,
                child: TextFormField(
                    controller: tagInput,
                    decoration:
                        InputDecoration(hintText: "자신을 나타낼 수 있는 태그를 입력해주세요."),
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "태그를 입력하지 않으셨습니다.";
                      }
                      return null;
                    }),
              ),
              Container(
                  height: 30,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blueAccent[200],
                    ),
                    child: Text(
                      "포트폴리오 쓰기",
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      if (_formKey.currentState!.validate()) {
                        uploadOnFS();
                        Navigator.pop(context);
                      }
                    },
                  )),
            ],
          )),
    );
  }

  void uploadOnFS() async {
    List<String> list = [introInput.text, specInput.text, tagInput.text];

    await fs.collection('users').doc(fp.getUser()!.email).update({
      'portfolio': list,
    });
  }
}
