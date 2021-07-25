import 'package:flutter/material.dart';
import 'package:login_test/login/signin_page.dart';
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

  TextStyle tsItem = const TextStyle(
      color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.bold);
  TextStyle tsContent = const TextStyle(color: Colors.blueGrey, fontSize: 12);

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);

    double propertyWith = 130;
    return Scaffold(
      appBar: AppBar(title: Text("로그인 완료 페이지")),
      body: ListView(
        children: <Widget>[
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
            child: Column(
              children: <Widget>[
                //헤더
                Container(
                  height: 50,
                  decoration: BoxDecoration(color: Colors.amber),
                  child: Center(
                    child: Text(
                      "로그인된 사용자 정보",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),

                // 정보 영역
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.amber, width: 1),
                  ),
                  child: Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: propertyWith,
                            child: Text("UID", style: tsItem),
                          ),
                          Expanded(
                            child: Text(fp.getUser()!.uid, style: tsContent),
                          )
                        ],
                      ),
                      Divider(height: 1),
                      Row(
                        children: <Widget>[
                          Container(
                            width: propertyWith,
                            child: Text("Email", style: tsItem),
                          ),
                          Expanded(
                            child: Text(fp.getUser()!.email.toString(), style: tsContent),
                          )
                        ],
                      ),
                      Divider(height: 1),
                      Row(
                        children: <Widget>[
                          Container(
                            width: propertyWith,
                            child: Text("isEmailVerified", style: tsItem),
                          ),
                          Expanded(
                            child: Text(fp.getUser()!.emailVerified.toString(),
                                style: tsContent),
                          )
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
                )
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
                await Navigator.push(context, MaterialPageRoute(builder: (context) => SignInPage()));
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
                "비밀번호 재설정 이메일 보내기",
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                fp.PWReset();
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
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => WriteBoard()));
                }),
          ),
          Container(
            margin: const EdgeInsets.only(left: 20, right: 20, top: 5),
            child: ElevatedButton(
                child: Text(
                  "게시글 목록",
                  style: TextStyle(color: Colors.black),
                ),
                onPressed: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ListBoard()));
                }),
          )
        ],
      ),
    );
  }
}