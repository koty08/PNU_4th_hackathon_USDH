import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:usdh/Widget/widget.dart';
import 'package:usdh/function/portfolio.dart';
import '../login/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'board.dart';

late MyPageState pageState;

class MyPage extends StatefulWidget {
  @override
  MyPageState createState() {
    pageState = MyPageState();
    return pageState;
  }
}

class MyPageState extends State<MyPage> {
  late FirebaseProvider fp;
  final FirebaseFirestore fs = FirebaseFirestore.instance;
  final _picker = ImagePicker();
  FirebaseStorage storage = FirebaseStorage.instance;

  TextStyle tsItem = const TextStyle(
      color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.bold);
  TextStyle tsContent = const TextStyle(color: Colors.blueGrey, fontSize: 12);
  final _formKey = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  TextEditingController myIntroInput = TextEditingController();
  TextEditingController nickInput = TextEditingController();
  TextEditingController emailInput = TextEditingController();
  TextEditingController pwdInput = TextEditingController();

  @override
  void dispose() {
    myIntroInput.dispose();
    nickInput.dispose();
    emailInput.dispose();
    pwdInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();

    // double propertyWith = 130;
    return Scaffold(
        body: StreamBuilder(
        stream: fs.collection('users').doc(fp.getInfo()['email']).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData) {
            return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cSizedBox(35, 0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        cSizedBox(0, 5),
                        IconButton(
                          icon: Image.asset('assets/images/icon/iconback.png', width: 22, height: 22),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        cSizedBox(0, 10),
                        headerText("마이페이지"),
                        cSizedBox(0, 220),
                      ],
                    ),
                    headerDivider(),
                    Row(
                      children: [
                        Padding(padding: EdgeInsets.fromLTRB(60, 100, 0, 10)),
                        InkWell(
                          onTap: () {
                            uploadImage();
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Image.network(
                              snapshot.data!['photoUrl'],
                              width: 60, height: 60,
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                cSizedBox(0, 30),
                                Text(snapshot.data!['nick']+"("+snapshot.data!['num'].toString()+")", style: TextStyle(fontFamily: "SCDream", color: Colors.black, fontWeight: FontWeight.w600, fontSize: 15),),
                                IconButton(onPressed: () {
                                  nickInput = TextEditingController(text: fp.getInfo()['nick']);
                                  showDialog(context: context,
                                      builder: (BuildContext con){
                                        return Form(
                                            key: _formKey,
                                            child:
                                            AlertDialog(
                                              title: Text("닉네임 변경"),
                                              content: TextFormField(
                                                  controller: nickInput,
                                                  decoration: InputDecoration(hintText: "닉네임을 입력하세요."),
                                                  validator: (text) {
                                                    if (text == null || text.isEmpty) {
                                                      return "닉네임을 입력하지 않으셨습니다.";
                                                    }
                                                    return null;
                                                  }
                                              ),
                                              actions: <Widget>[
                                                TextButton(onPressed: () {
                                                  if(_formKey.currentState!.validate()){
                                                    setState(() {
                                                      fs.collection('users').doc(fp.getUser()!.email).update({
                                                        'nick' : nickInput.text
                                                      });
                                                    });
                                                    Navigator.pop(con);
                                                    fp.setMessage("nick");
                                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                    showMessage();
                                                  }
                                                },
                                                    child: Text("입력")
                                                ),
                                                TextButton(onPressed: (){
                                                  Navigator.pop(con);
                                                },
                                                    child: Text("취소")
                                                ),
                                              ],
                                            )
                                        );
                                      }
                                  );
                                },
                                    icon: Icon(Icons.edit)),
                              ],
                            ),
                            Text(snapshot.data!['name']),
                          ],
                        ),
                      ]
                    ),
                    middleDivider(),
                    Container(
                      padding: EdgeInsets.fromLTRB(60, 0, 0, 20),
                      child: Wrap(
                        direction: Axis.vertical,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        spacing: 10,
                        children: [
                          cSizedBox(5, 0),
                          Container(padding: EdgeInsets.fromLTRB(5, 10, 0, 20), child: infoText("내 정보")),
                          touchableText(() {
                            fp.PWReset();
                            fp.setMessage("reset-pw");
                            ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            showMessage();
                          }, "비밀번호 변경"),

                          touchableText(() {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Portfolio()));
                          }, "포트폴리오 변경"),

                          touchableText(() {
                            if(fp.getInfo()['myintro'] == ""){
                              myIntroInput = TextEditingController();
                            }
                            else{
                              myIntroInput = TextEditingController(text: fp.getInfo()['myintro']);
                            }
                            showDialog(context: context,
                                builder: (BuildContext con){
                                  return AlertDialog(
                                    title: Text("자기소개 변경"),
                                    content: TextField(
                                      controller: myIntroInput,
                                      decoration: InputDecoration(hintText: "자기소개를 입력하세요."),
                                    ),
                                    actions: <Widget>[
                                      TextButton(onPressed: () {
                                        setState(() {
                                          fs.collection('users').doc(fp.getUser()!.email).update({
                                            'myintro' : myIntroInput.text
                                          });
                                        });
                                        Navigator.pop(con);
                                        fp.setMessage("intro");
                                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                        showMessage();
                                      },
                                          child: Text("입력")
                                      ),
                                      TextButton(onPressed: (){
                                        Navigator.pop(con);
                                      },
                                          child: Text("취소")
                                      ),
                                    ],
                                  );
                                });
                          }, "자기소개 변경"),
                        ],
                      ),
                    ),

                    middleDivider(),

                    Container(
                      padding: EdgeInsets.fromLTRB(60, 0, 0, 20),
                      child: Wrap(
                        direction: Axis.vertical,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        spacing: 10,
                        children: [
                          cSizedBox(5, 0),
                          Container(padding: EdgeInsets.fromLTRB(5, 10, 0, 20), child: infoText("신청 이력")),
                          touchableText(() {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => ApplicantListBoard(myId: fp.getInfo()['email'])));
                          },"신청자 목록"),
                          touchableText(() {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => MyApplicationListBoard()));
                          },"신청한 글"),
                        ],
                      ),
                    ),

                    middleDivider(),

                    Container(
                      padding: EdgeInsets.fromLTRB(60, 0, 0, 0),
                      child: Wrap(
                        direction: Axis.vertical,
                        crossAxisAlignment: WrapCrossAlignment.start,
                        spacing: 10,
                        children: [
                          cSizedBox(5, 0),
                          Container(padding: EdgeInsets.fromLTRB(5, 10, 0, 20), child: infoText("이용 정보")),
                          touchableText(() async {
                            Navigator.popUntil(context, (route) => route.isFirst);
                            fp.signOut();
                          }, "로그아웃"),
                          touchableText(() {
                            showDialog(context: context,
                                builder: (BuildContext con){
                                  return Form(
                                      key: _formKey2,
                                      child:
                                      AlertDialog(
                                        title: Text("탈퇴하시려면 현재 웹메일과 비밀번호를 입력해주세요."),
                                        content: Column(
                                          children: [
                                            TextFormField(
                                                controller: emailInput,
                                                decoration: InputDecoration(hintText: "이메일을 입력하세요."),
                                                validator: (text) {
                                                  if (text == null || text.isEmpty) {
                                                    return "이메일을 입력하지 않으셨습니다.";
                                                  }
                                                  return null;
                                                }
                                            ),
                                            TextFormField(
                                                controller: pwdInput,
                                                decoration: InputDecoration(hintText: "비밀번호를 입력하세요."),
                                                validator: (text) {
                                                  if (text == null || text.isEmpty) {
                                                    return "비밀번호를 입력하지 않으셨습니다.";
                                                  }
                                                  return null;
                                                }
                                            ),
                                          ],
                                        ),
                                        actions: <Widget>[
                                          TextButton(onPressed: () {
                                            if(_formKey2.currentState!.validate()){
                                              if(fp.signIn(emailInput.text, pwdInput.text) == true){
                                                fp.withdraw();
                                                Navigator.popUntil(con, (route) => route.isFirst);
                                              }
                                              else{
                                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                showErrorMessage();
                                                Navigator.pop(con);
                                              }
                                            }
                                          },
                                              child: Text("확인")
                                          ),
                                          TextButton(onPressed: (){
                                            Navigator.pop(con);
                                          },
                                              child: Text("취소")
                                          ),
                                        ],
                                      )
                                  );
                                });
                          }, "계정 탈퇴"),
                        ],
                      ),
                    ),
                      ],
                    ),
            );
          }
          else {
            return CircularProgressIndicator();
          }
        }
        )
    );
  }
    void uploadImage() async {
      final pickedImg = await _picker.pickImage(source: ImageSource.gallery);
      var tmp = fp.getInfo();
      late Reference ref;

      ref = storage.ref().child('profile/${tmp['name'].toString()}');
      await ref.putFile(File(pickedImg!.path));
      String geturl = await ref.getDownloadURL();

      await fs.collection('users').doc(fp.getInfo()['email']).update({
        'photoUrl' : geturl,
      });
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


    Widget touchableText(onTap, text) {
      return InkWell(
        onTap: onTap,
        child: info2Text(text),
      );
    }
}

//*---------토글입니다 지금 사용 안해요----


//
//
//
//
//
// Row(
// children: [
// condText("내 포트폴리오 검색 허용"),
//
// Switch(
// value: false, //스위치는 벨류 설정해줘야 한대요1!!!!!!!
// onChanged: (value) {
// setState(() {
// // isSwitched = value;
// // print(isSwitched);
// });
// },
// activeTrackColor: Colors.lightGreenAccent,
// activeColor: Colors.green,
// ),
// ],
// ),
//
// Row(
// children: [
// condText("늦은 시간 채팅 받기"),
//
// Switch(
// value: false,
// onChanged: (value) {
// setState(() {
// // isSwitched = value;
// // print(isSwitched);
// });
// },
// activeTrackColor: Colors.lightGreenAccent,
// activeColor: Colors.green,
// ),
// ],
// ),
//
// Row(
// children: [
// condText("채팅 받기"),
//
// Switch(
// value: false,
// onChanged: (value) {
// setState(() {
// // isSwitched = value;
// // print(isSwitched);
// });
// },
// activeTrackColor: Colors.lightGreenAccent,
// activeColor: Colors.green,
// ),
// ],
// ),
