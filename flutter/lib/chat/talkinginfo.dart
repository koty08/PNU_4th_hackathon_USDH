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
              imageProfile(),//TODO: 게시글제목 가져오기, 방장 프로필 불러오기(?)
              Padding(
                padding: EdgeInsets.fromLTRB(30, 0, 0, 10),
              ),
              middleDivider(),
              Text(
                '참여자 명단',
                style: TextStyle(fontFamily: "SCDream",color: Color(0xff4E94EC) , fontWeight: FontWeight.w500, fontSize: 13),)
            ],
          ),
        )
    );
  }
}