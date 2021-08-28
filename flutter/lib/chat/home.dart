import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usdh/Widget/widget.dart';
import 'package:usdh/chat/chatting.dart';
import 'package:usdh/chat/const.dart';
import 'package:usdh/login/firebase_provider.dart';

bool isTomorrow(String time) {
  String now = formatDate(DateTime.now(), [HH, ':', nn, ':', ss]);
  if (time.compareTo(now) == -1) {
    return true;
  } else {
    return false;
  }
}

// 현재 내가 포함된 채팅방 목록
class HomeScreen extends StatefulWidget {
  final String myId;

  HomeScreen({Key? key, required this.myId}) : super(key: key);

  @override
  State createState() => HomeScreenState(myId: myId);
}

class HomeScreenState extends State<HomeScreen> {
  final String myId;

  HomeScreenState({Key? key, required this.myId});

  late FirebaseProvider fp;
  final ScrollController listScrollController = ScrollController();

  int _limit = 20; // 한 번에 불러오는 채팅 방 수
  int _limitIncrement = 20; // _limit을 넘길 경우 _limitIncrement만큼 추가
  bool isLoading = false;

  // Choice class: 버튼 생성 클래스(title, icon)
  List<Choice> choices = const <Choice>[
    const Choice(title: 'Settings', icon: Icons.settings),
    const Choice(title: 'Log out', icon: Icons.exit_to_app),
  ];

  @override
  void initState() {
    super.initState();
    listScrollController.addListener(scrollListener);
  }

  void scrollListener() {
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent && !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  // 로그아웃 버튼, 설정(프로필 수정) 버튼
  void onItemMenuPress(Choice choice) {
    if (choice.title == 'Log out') {
      print('handle out');
    } else {
      print('navigate to setting');
    }
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();

    Stream<QuerySnapshot> colstream = FirebaseFirestore.instance.collection('users').doc(myId).collection('messageWith').limit(_limit).snapshots();

    return Scaffold(
      appBar: CustomAppBar('채팅', []),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() {
            colstream = FirebaseFirestore.instance.collection('users').doc(myId).collection('messageWith').limit(_limit).snapshots();
          });
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: colstream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (snapshot.hasData) {
              return Column(children: [
                Expanded(
                    child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView.builder(
                          padding: EdgeInsets.all(10.0),
                          itemBuilder: (context, index) {
                            return buildItem(context, snapshot.data?.docs[index]);
                          },
                          itemCount: snapshot.data?.docs.length,
                          controller: listScrollController,
                        )))
              ]);
            } else {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              );
            }
          },
        ),
      ),
    );
  }

  Future<String> getPeerNicks(List<dynamic> peerIds) async {
    List<dynamic> temp = [];
    for (var peerId in peerIds) {
      await fs.collection('users').doc(peerId).get().then((value) {
        String nick = value['nick'] + '(' + value['num'].toString() + ')';
        temp.add(nick);
      });
    }
    String nickForText = '';
    for (int i = 0; i < temp.length; i++) {
      if (i < temp.length - 1)
        nickForText = nickForText + temp[i] + ", ";
      else
        nickForText = nickForText + temp[i];
    }
    return nickForText;
  }

  Future<String> getPeerAvatar(List<dynamic> peerIds) async {
    final List<String> peerAvatars = [];
    for (var peerId in peerIds) {
      await fs.collection('users').doc(peerId).get().then((value) {
        peerAvatars.add(value['photoUrl']);
      });
    }
    String photoUrl = peerAvatars[0];
    return photoUrl;
  }

  // 각각의 채팅 기록( 1 block ) - '[chatRoomName]' document 를 인자로
  Widget buildItem(BuildContext context, DocumentSnapshot? document) {
    fp.setInfo();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    if (document != null) {
      List<dynamic> peerIds = document['chatMembers'];
      String where = document.get('where');
      int count = 0;

      Stream<DocumentSnapshot> streamMessageWith = FirebaseFirestore.instance.collection('users').doc(peerIds[0]).collection('messageWith').doc(document.id).snapshots();
      Stream<QuerySnapshot> streamMessages = FirebaseFirestore.instance.collection('users').doc(peerIds[0]).collection('messageWith').doc(document.id).collection('messages').snapshots();

      return Container(
        child: TextButton(
          child: Stack(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  FutureBuilder(
                      future: getPeerAvatar(peerIds),
                      builder: (BuildContext context, AsyncSnapshot snapshot) {
                        if (snapshot.hasData) {
                          return Container(
                            child: CircleAvatar(radius: 25, backgroundImage: NetworkImage(snapshot.data.toString())),
                            alignment: Alignment.centerLeft,
                          );
                        } else {
                          return CircularProgressIndicator();
                        }
                      }),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FutureBuilder(
                          future: getPeerNicks(peerIds),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                width: width*0.6,
                                child: smallText(snapshot.data.toString(), 12.5, Colors.black87),
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, height*0.015),
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          }
                      ),
                      StreamBuilder<DocumentSnapshot>(
                          stream: streamMessageWith,
                          builder: (context, AsyncSnapshot<DocumentSnapshot> docSnapshotMW) {
                            return StreamBuilder<QuerySnapshot>(
                                stream: streamMessages,
                                builder: (context, AsyncSnapshot<QuerySnapshot> colSnapshotM) {
                                  if (!docSnapshotMW.hasData || !colSnapshotM.hasData) {
                                    return CircularProgressIndicator();
                                  }
                                  var myInfo = fp.getInfo();
                                  QueryDocumentSnapshot lastMessageSnapshot = colSnapshotM.data!.docs[colSnapshotM.data!.docs.length - 1];
                                  String lastTime;
                                  String lastMessage = lastMessageSnapshot.get('content').toString();
                                  String lastTimeSeen = docSnapshotMW.data!.get('lastTimeSeen');
                                  int unSeenCount;
                                  var temp = colSnapshotM.data!.docs[colSnapshotM.data!.docs.length - 1].get('timestamp').toString();
                                  Timestamp timestamp = Timestamp.fromMillisecondsSinceEpoch(int.parse(temp));
                                  DateTime dateTime = timestamp.toDate();
                                  String formatedTime = formatDate(dateTime, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
                                  if (isTomorrow(formatedTime)) {
                                    lastTime = formatedTime.substring(11, 16);
                                  } else {
                                    lastTime = formatedTime.substring(5, 7) + '.' + formatedTime.substring(8, 10);
                                  }
                                  Iterable<QueryDocumentSnapshot<Object?>> messages = colSnapshotM.data!.docs.where((element) {
                                    if (int.parse(element.get('timestamp')) > int.parse(lastTimeSeen) && element.get('idFrom') != myInfo['email']) {
                                      return true;
                                    } else {
                                      return false;
                                    }
                                  });
                                  unSeenCount = messages.length;
                                  count = unSeenCount;

                                  return Row(
                                    children: <Widget>[
                                      Container(
                                        width: width * 0.45,
                                        child:
                                          (unSeenCount>0)
                                          ? smallText(lastMessage, 11.5, Color(0xff639ee1))
                                          : smallText(lastMessage, 11.5, Colors.grey),
                                        alignment: Alignment.centerLeft,
                                        margin: EdgeInsets.fromLTRB(20.0, 0.0, 0.0, 0),
                                      ),
                                      cSizedBox(0, width*0.15),
                                      Container(
                                        width: width * 0.1,
                                        child: smallText(lastTime, 11.5, Colors.grey.shade600),
                                      ),
                                    ],
                                  );
                                });
                          }),
                  ]),
                ],
              ),
              Positioned(
                right: 0,
                top: -10,
                child: RawMaterialButton(
                  onPressed: () {},
                  elevation: 0,
                  fillColor:
                  (count>0)
                    ? Color(0xff639ee1)
                    : Colors.grey.shade400,
                  child: smallText(count.toString(), 11, Colors.white),
                  shape: CircleBorder(),
                  constraints: BoxConstraints.expand(width: width*0.05, height: height*0.05),
                )
              )
            ]
          ),
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Chat(
                  myId: myId,
                  peerIds: peerIds,
                  groupChatId: document.id,
                  where: where,
                ),
              ),
            );
          },
        ),
        margin: EdgeInsets.fromLTRB(5, height*0.02, 5, 0),
      );
    } else {
      return SizedBox.shrink();
    }
  }
}

class Choice {
  const Choice({required this.title, required this.icon});

  final String title;
  final IconData icon;
}
