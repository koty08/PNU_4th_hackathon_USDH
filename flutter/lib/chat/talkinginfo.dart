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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    String host = '';

    return Scaffold(
      appBar: CustomAppBar('채팅', []),
      body: Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(30, 20, 0, 10),
              ),
              FutureBuilder(
                future: getHostAvatar(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return Stack(children: [Padding(padding: EdgeInsets.fromLTRB(30, 100, 0, 0)), CircleAvatar(radius: 40.0, backgroundImage: NetworkImage(snapshot.data.toString()))]);
                  } else {
                    return CircularProgressIndicator();
                  }
                }
              ),
              // 게시물제목
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
                }
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 5),),
              // host 저장
              FutureBuilder(
                future: getHostNick(),
                builder: (context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    host = snapshot.data;
                    return smallText(host, 15, Colors.black87);
                  } else {
                    return CircularProgressIndicator();
                  }
                }
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 5, 0, 10),),
              Divider(color: Color(0xffe9e9e9), thickness: 17,),
            ]
          ),

          Container(
            margin: EdgeInsets.fromLTRB(30, height*0.03, 0, height*0.03),
            child: infoText("참가자 명단"),
          ),
          middleDivider(),
          Padding(padding: EdgeInsets.fromLTRB(30, 5, 0, 10),),

          FutureBuilder(
            future: getOtherNicks(),
            builder: (context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                List<Widget> otherNicksList = [Row(children: [smallText(host, 15, Colors.black87), tagText(" (방장)")])];
                for (String oneNick in snapshot.data) {
                  otherNicksList.add(
                    cSizedBox(height*0.01, 0),
                  );
                  otherNicksList.add(
                    smallText(oneNick, 15, Colors.black87),
                  );
                }
                return Container(
                  margin: EdgeInsets.fromLTRB(35, 15, 0, 0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: otherNicksList
                  ),
                );
              } else {
                return CircularProgressIndicator();
              }
            }),
        ],
      ),
    ));
  }
}
