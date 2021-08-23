import 'package:flutter/material.dart';
import 'package:usdh/Widget/widget.dart';

class ChatInfo extends StatefulWidget {
  @override
  State createState() => ChatInfoState();
}

class ChatInfoState extends State<ChatInfo> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Container(
          child: Column(
            children: [

              topbar2(context, "채팅"),
              Padding(
                padding: EdgeInsets.fromLTRB(30, 20, 0, 10),
              ),

              imageProfile(), //TODO: 게시글제목 가져오기, 방장 프로필 불러오기(?)

              Text(
                '게시물 제목',
                style: TextStyle(fontFamily: "SCDream",color: Color(0xff000000) , fontWeight: FontWeight.w500, fontSize: 20),),

              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
              ),

              Text(
                '방장 이름',
                style: TextStyle(fontFamily: "SCDream",color: Color(0xff000000) , fontWeight: FontWeight.w500, fontSize: 15),),

              Padding(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
              ),

              Divider(
                color: Color(0xffe9e9e9),
                thickness: 17,
              ),

              Padding(
                padding: EdgeInsets.fromLTRB(30, 5, 0, 10),

              ),

              Text(
                '참여자 명단',
                style: TextStyle(fontFamily: "SCDream",color: Color(0xff4E94EC) , fontWeight: FontWeight.w500, fontSize: 13),
                textAlign: TextAlign.left,)
            ],
          ),
        )
    );
  }
}