import 'package:flutter/material.dart';
import 'board.dart';
import 'mypage.dart';

late SignedInPageState pageState;

class SignedInPage extends StatefulWidget {
  @override
  SignedInPageState createState() {
    pageState = SignedInPageState();
    return pageState;
  }
}

class SignedInPageState extends State<SignedInPage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            centerTitle: true,
            title: Text("유소더하"),
            leading: IconButton(
              icon: Icon(Icons.person),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage()));
              },
            ),
            actions: [
              IconButton(icon: Icon(Icons.message), onPressed: () => { print("Icons.message") },),
            ]
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,

          children: [
            Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 50)),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                iconAndText(Icons.local_taxi, "택시", ListBoard()),
                iconAndText(Icons.motorcycle, "배달", ListBoard()),
                iconAndText(Icons.shopping_basket, "공구", ListBoard()),
                iconAndText(Icons.clean_hands, "팀빌딩", ListBoard()),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,

              children: [
                iconAndText(Icons.videogame_asset, "소모임", ListBoard()),
                iconAndText(Icons.house_rounded, "룸메이트", ListBoard()),
                iconAndText(Icons.people, "커뮤니티", ListBoard()),
              ],
            ),

            Padding(padding: EdgeInsets.fromLTRB(20, 0, 0, 0), //마감임박 전체 패딩
              child:messageBoard(Icons.timer, "마감 임박 게시글", ["[택시] 택시 게시글", "[배달] 배달 게시글", "[공구] 공구 게시물","1","2","3","4"]),),

            Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 50)),

            messageBoard(Icons.fireplace, "실시간 인기 게시글", ["[123] 456", "[11] 22", "[33] 44"]),
          ],
        )
    );
  }

  Widget iconAndText(IconData data, String text, Widget route) {
    return TextButton(
      onPressed: (){
        Navigator.push(context, MaterialPageRoute(builder: (context) => route));
      },

      child: SizedBox(
        width: 70,
        height: 70,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [
            Icon(data, size: 40,),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget messageBoard(IconData iconData, String title, List<String> data) { // 태그에 따른 분류는 알아서
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.only(left: 20, right: 20, top: 20, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(iconData),
                  Text(title),
                ],
              ),

              IconButton(onPressed: () { print("icon Plus"); }, icon: Icon(Icons.add_box)),


            ],
          ),
        ),

        Padding(
          padding: EdgeInsets.only(left: 10),
          child: SizedBox(
            height: 80,

            child: ListView.builder(
                itemCount: data.length,
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                      padding: EdgeInsets.all(8),
                      child: Text(data[index])
                  );
                }
            ),
          ),
        ),
      ],
    );
  }
}