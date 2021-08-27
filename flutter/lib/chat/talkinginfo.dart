import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:usdh/Widget/widget.dart';

FirebaseFirestore fs = FirebaseFirestore.instance;

class ChatInfo extends StatefulWidget {
  final List<dynamic> allMemberIds;
  final String groupChatId;
  final String where;

  ChatInfo({Key? key, required this.allMemberIds, required this.groupChatId, required this.where}) : super(key: key);

  @override
  State createState() => ChatInfoState(allMemberIds: allMemberIds, groupChatId: groupChatId, where: where);
}

class ChatInfoState extends State<ChatInfo> {
  final List<dynamic> allMemberIds;
  final String groupChatId;
  final String where;

  ChatInfoState({Key? key, required this.allMemberIds, required this.groupChatId, required this.where});

  Future<String> getHostAvatar() async {
    String hostNick = await fs.collection(where).doc(groupChatId).get().then((value) => value.get('writer'));
    return await fs.collection('users').where('nick', isEqualTo: hostNick).get().then((value) => value.docs[0].get('photoUrl'));
  }

  Future<String> getHostNick() async {
    return await fs.collection(where).doc(groupChatId).get().then((value) => value.get('writer'));
  }

  Future<String> getRoomName() async {
    return await fs.collection(where).doc(groupChatId).get().then((value) => value.get('title'));
  }

  Future<List<String>> getOtherNicks() async {
    List<String> otherNicks = [];
    String hostNick = await fs.collection(where).doc(groupChatId).get().then((value) => value.get('writer'));
    String hostId = await fs.collection('users').where('nick', isEqualTo: hostNick).get().then((value) => value.docs[0].get('email'));
    for (int i = 0; i < allMemberIds.length; i++) {
      if (allMemberIds[i] != hostId) {
        otherNicks.add(await fs.collection('users').doc(allMemberIds[i]).get().then((value) => value.get('nick')));
      }
    }
    return otherNicks;
  }

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

          //imageProfile(), //TODO: 게시글제목 가져오기, 방장 프로필 불러오기(?) -> 이거 그냥 이 페이지에서 처리해도 되나요. .
          FutureBuilder(
              future: getHostAvatar(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return Stack(children: [Padding(padding: EdgeInsets.fromLTRB(30, 100, 0, 0)), CircleAvatar(radius: 40.0, backgroundImage: NetworkImage(snapshot.data.toString()))]);
                } else {
                  return CircularProgressIndicator();
                }
              }),

         //게시물제목
          FutureBuilder(
              future: getRoomName(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data,
                    style: TextStyle(fontFamily: "SCDream", color: Color(0xff000000), fontWeight: FontWeight.w500, fontSize: 20),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              }),

          Padding(
            padding: EdgeInsets.fromLTRB(0, 0, 0, 5),
          ),

          //방장이름
          FutureBuilder(
              future: getHostNick(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  return Text(
                    snapshot.data,
                    style: TextStyle(fontFamily: "SCDream", color: Color(0xff000000), fontWeight: FontWeight.w500, fontSize: 15),
                  );
                } else {
                  return CircularProgressIndicator();
                }
              }),

          Padding(
            padding: EdgeInsets.fromLTRB(0, 5, 0, 10),
          ),

          Divider(
            color: Color(0xffe9e9e9),
            thickness: 17,
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(60, 5, 0, 20),
          ),

          Text(
            '참가자 명단',
            style: TextStyle(fontFamily: "SCDream", color: Color(0xff4E94EC), fontWeight: FontWeight.w500, fontSize: 17),
          ),

          Padding(
            padding: EdgeInsets.fromLTRB(30, 5, 0, 10),
          ),

          middleDivider(),

          Padding(
            padding: EdgeInsets.fromLTRB(30, 5, 0, 10),
          ),

          FutureBuilder(
              future: getHostNick(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {



                return Column
                  (children: [


                    Text(
                      snapshot.data,
                      style: TextStyle(fontFamily: "SCDream", color: Color(0xff000000), fontWeight: FontWeight.w500, fontSize: 15),
                      textAlign: TextAlign.left,
                    ),



                    Text(
                      '방장',
                      style: TextStyle(fontFamily: "SCDream", color: Color(0xff000000), fontWeight: FontWeight.w500, fontSize: 15),
                      textAlign: TextAlign.left,
                    ),
                  ]);
                } else {
                  return CircularProgressIndicator();
                }
              }),


          FutureBuilder(
              future: getOtherNicks(),
              builder: (context, AsyncSnapshot snapshot) {
                if (snapshot.hasData) {
                  List<Widget> otherNicksList = [];
                  for (String oneNick in snapshot.data) {
                    otherNicksList.add(Text(
                      oneNick,
                      style: TextStyle(fontFamily: "SCDream", color: Color(0xff000000), fontWeight: FontWeight.w500, fontSize: 15),
                      textAlign: TextAlign.left,
                    ));
                  }
                  return Column(children: otherNicksList);
                } else {
                  return CircularProgressIndicator();
                }
              }),
        ],
      ),
    ));
  }
}
