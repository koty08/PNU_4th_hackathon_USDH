import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
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
  
  TextStyle tsItem = const TextStyle(
      color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.bold);
  TextStyle tsContent = const TextStyle(color: Colors.blueGrey, fontSize: 12);

  late TextEditingController myIntroInput;

  @override
  void dispose() {
    myIntroInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();

    double propertyWith = 130;
    if (fp.getUser() == null) {
      return CircularProgressIndicator();
    } else {
      return Scaffold(
        appBar: AppBar(title: Text("개인정보 페이지")),
        body: ListView(
          children: <Widget>[
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: Column(
                children: <Widget>[
                  // 정보 영역
                  (fp.getInfo()['portfolio'] == List.empty())?
                  Container(
                    child:
                      Text("포트폴리오 미작성"),
                  ):
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.amber, width: 1),
                    ),
                    child: Column(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            CircleAvatar(
                              radius: 20.0,
                              backgroundImage: NetworkImage(fp.getInfo()['photoUrl']),
                            ),
                            Container(
                              width: propertyWith,
                              child: Text(fp.getInfo()['nick'] +'('+ fp.getInfo()['num'].toString() + ')', style: tsItem),
                            ),
                          ],
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                              width: propertyWith,
                              child: Text(fp.getInfo()['name'], style: tsItem),
                            ),
                          ],
                        ),
                      ].map((c) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 10),
                          child: c,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.indigo[300],
                ),
                child: Text(
                  "로그아웃",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () async {
                  Navigator.popUntil(context, (route) => route.isFirst);
                  fp.signOut();
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange[300],
                ),
                child: Text(
                  "포트폴리오 변경",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Portfolio()));
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.orange[300],
                ),
                child: Text(
                  "자기소개 변경",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
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
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.red[300],
                ),
                child: Text(
                  "계정 삭제",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  fp.withdraw();
                },
              ),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 5),
              child: ElevatedButton(
                  child: Text(
                    "게시판 글쓰기",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => WriteBoard()));
                  }),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 5),
              child: ElevatedButton(
                  child: Text(
                    "게시글 목록",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: () {
                    Navigator.push(context,
                        MaterialPageRoute(builder: (context) => ListBoard()));
                  }),
            ),
            Container(
              margin: const EdgeInsets.only(left: 20, right: 20, top: 5),
              child: ElevatedButton(
                  child: Text(
                    "신청자 목록",
                    style: TextStyle(color: Colors.black),
                  ),
                  onPressed: (){
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ApplicantListBoard()));
                  }),
            )
          ],
        ),
      );
    }
  }
}
