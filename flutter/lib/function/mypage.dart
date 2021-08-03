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

  TextStyle tsItem = const TextStyle(
      color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.bold);
  TextStyle tsContent = const TextStyle(color: Colors.blueGrey, fontSize: 12);

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();

    double propertyWith = 130;
    if (fp.getUser() == null) {
      return CircularProgressIndicator();
    } else {
      return Scaffold(
        appBar: AppBar(title: Text("로그인 완료 페이지")),
        body: ListView(
          children: <Widget>[
            // Container(
            //   margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
            //   child: Column(
            //     children: <Widget>[
            //       //헤더
            //       Container(
            //         height: 50,
            //         decoration: BoxDecoration(color: Colors.amber),
            //         child: Center(
            //           child: Text(
            //             "포트폴리오 테스트",
            //             style: TextStyle(
            //                 fontSize: 16, fontWeight: FontWeight.bold),
            //           ),
            //         ),
            //       ),

            //       // 정보 영역
            //       Container(
            //         decoration: BoxDecoration(
            //           border: Border.all(color: Colors.amber, width: 1),
            //         ),
            //         child: Column(
            //           children: <Widget>[
            //             Row(
            //               children: <Widget>[
            //                 Container(
            //                   width: propertyWith,
            //                   child: Text("포트폴리오 자기소개", style: tsItem),
            //                 ),
            //                 Expanded(
            //                   child: Text(fp.getInfo()['portfolio'][0],
            //                       style: tsContent),
            //                 )
            //               ],
            //             ),
            //             Divider(height: 1),
            //             Row(
            //               children: <Widget>[
            //                 Container(
            //                   width: propertyWith,
            //                   child: Text("포트폴리오 자기스펙", style: tsItem),
            //                 ),
            //                 Expanded(
            //                   child: Text(fp.getInfo()['portfolio'][1],
            //                       style: tsContent),
            //                 )
            //               ],
            //             ),
            //             Divider(height: 1),
            //             Row(
            //               children: <Widget>[
            //                 Container(
            //                   width: propertyWith,
            //                   child: Text("포트폴리오 태그", style: tsItem),
            //                 ),
            //                 Expanded(
            //                   child: Text(fp.getInfo()['portfolio'][2],
            //                       style: tsContent),
            //                 )
            //               ],
            //             ),
            //           ].map((c) {
            //             return Padding(
            //               padding: const EdgeInsets.symmetric(
            //                   vertical: 10, horizontal: 10),
            //               child: c,
            //             );
            //           }).toList(),
            //         ),
            //       )
            //     ],
            //   ),
            // ),
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
                  "포트폴리오 작성하기",
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => Portfolio()));
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
