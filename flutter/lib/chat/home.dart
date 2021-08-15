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
      // 채팅 기록 불러오기
      body: RefreshIndicator(
        //당겨서 새로고침
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
                cSizedBox(35, 0),
                Row(mainAxisAlignment: MainAxisAlignment.spaceAround, crossAxisAlignment: CrossAxisAlignment.center, children: [
                  IconButton(
                    icon: Image.asset('assets/images/icon/iconback.png', width: 22, height: 22),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  headerText("채팅"),
                  cSizedBox(0, 50),
                ]),
                headerDivider(),
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
            }
            else {
              return Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                ),
              );
            }
          },
        ),
      ),

      // Loading
      /*Positioned(
            child: isLoading ? const Loading() : Container(),
          )*/
    );
  }

  Future<String> getPeerNicks(List<dynamic> peerIds) async {
    List<dynamic> temp = [];
    for (var peerId in peerIds) {
      await FirebaseFirestore.instance.collection('users').doc(peerId).get().then((value) {
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
      await FirebaseFirestore.instance.collection('users').doc(peerId).get().then((value) {
        peerAvatars.add(value['photoUrl']);
      });
    }
    String photoUrl = peerAvatars[0];
    return photoUrl;
  }

  Future<String> getLastTime(List<dynamic> peerIds, DocumentSnapshot doc) async {
    var temp = '';

    var snapshot = await FirebaseFirestore.instance.collection('users').doc(peerIds[0]).collection('messageWith').doc(doc.id).collection('messages').get();
    temp = snapshot.docs[snapshot.docs.length - 1].get('timestamp').toString();

    Timestamp timestamp = Timestamp.fromMillisecondsSinceEpoch(int.parse(temp));
    DateTime dateTime = timestamp.toDate();
    String formatedTime = formatDate(dateTime, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);

    String lastTime = '';
    if (isTomorrow(formatedTime)) {
      lastTime = formatedTime.substring(11, 16);
    } else {
      lastTime = formatedTime.substring(0, 4) + '.' + formatedTime.substring(5, 7) + '.' + formatedTime.substring(8, 10);
    }

    return lastTime;
  }

  Future<String> getLastMessage(List<dynamic> peerIds, DocumentSnapshot doc) async {
    String lastMessage = '';

    var snapshot = await FirebaseFirestore.instance.collection('users').doc(peerIds[0]).collection('messageWith').doc(doc.id).collection('messages').get();
    lastMessage = snapshot.docs[snapshot.docs.length - 1].get('content').toString();

    return lastMessage;
  }

  Future<int> getUnSeenCount(List<dynamic> peerIds, DocumentSnapshot doc) async {
    var myId = fp.getInfo()['email'];
    int unSeenCount = 0;

    String lastTimeSeen = '';
    await FirebaseFirestore.instance.collection('users').doc(myId).collection('messageWith').doc(doc.id).get().then((value) {
      lastTimeSeen = value['lastTimeSeen'];
    });

    var tmp = await FirebaseFirestore.instance.collection('users').doc(peerIds[0]).collection('messageWith').doc(doc.id).collection('messages').where('timestamp', isGreaterThan: lastTimeSeen).get().then((value) {
      unSeenCount = value.docs.length;
    });

    return unSeenCount;
  }

  // 각각의 채팅 기록( 1 block ) - '[chatRoomName]' document 를 인자로
  Widget buildItem(BuildContext context, DocumentSnapshot? document) {
    fp.setInfo();

    if (document != null) {
      List<dynamic> peerIds = document['chatMembers'];

      Stream<DocumentSnapshot> streamMessageWith = FirebaseFirestore.instance.collection('users').doc(peerIds[0]).collection('messageWith').doc(document.id).snapshots();
      Stream<QuerySnapshot> streamMessages = FirebaseFirestore.instance.collection('users').doc(peerIds[0]).collection('messageWith').doc(document.id).collection('messages').snapshots();
      
      return Container(
        child: TextButton(
          child: Column(children: [
            Row(children: <Widget>[
              // 프로필 사진
              FutureBuilder(
                future: getPeerAvatar(peerIds),
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return Container(
                      child: CircleAvatar(radius: 20, backgroundImage: NetworkImage(snapshot.data.toString())),
                      alignment: Alignment.centerLeft,
                      margin: EdgeInsets.fromLTRB(5.0, 0.0, 0.0, 5.0),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                }
              ),
              // 닉네임
              Flexible(
                child: Container(
                  margin: EdgeInsets.only(left: 20.0),
                  child: Column(
                    children: <Widget>[
                      FutureBuilder(
                        future: getPeerNicks(peerIds),
                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            return Container(
                              child: Text(
                                snapshot.data.toString(),
                                maxLines: 1,
                                style: TextStyle(color: primaryColor),
                              ),
                              alignment: Alignment.centerLeft,
                              margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        }),
                    ],
                  ),
                ),
              ),
              ]
            ),

            // 막 메세지, 막 메세지 시간, 안 본 메세지
            StreamBuilder<DocumentSnapshot>(
              stream: streamMessageWith,
              builder: (context, AsyncSnapshot<DocumentSnapshot> docSnapshotMW) {
                return StreamBuilder<QuerySnapshot>(
                  stream: streamMessages,
                  builder: (context, AsyncSnapshot<QuerySnapshot> colSnapshotM) {
                    if (!docSnapshotMW.hasData || !colSnapshotM.hasData) {
                      return CircularProgressIndicator();
                    }

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
                      lastTime = formatedTime.substring(0, 4) + '.' + formatedTime.substring(5, 7) + '.' + formatedTime.substring(8, 10);
                    }

                    Iterable<QueryDocumentSnapshot<Object?>> messages = colSnapshotM.data!.docs.where((element) {
                      if (int.parse(element.get('timestamp')) > int.parse(lastTimeSeen)) {
                        print('#####################');
                        print(element.get('content'));
                        print(int.parse(element.get('timestamp')));
                        print(int.parse(lastTimeSeen));
                        return true;
                      } else {
                        print(element.get('content'));
                        print('@@@@@@@@@@@@@@@@@@@@');
                        print(int.parse(element.get('timestamp')));
                        print(int.parse(lastTimeSeen));
                        return false;
                      }
                    });

                    unSeenCount = messages.length;

                    return Row(
                      children: <Widget>[
                        Container(
                          child: Text(
                            lastTime,
                            maxLines: 1,
                            style: TextStyle(color: primaryColor),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                        ),
                        Container(
                          child: Text(
                            lastMessage,
                            maxLines: 1,
                            style: TextStyle(color: primaryColor),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                        ),
                        Container(
                          child: Text(
                            unSeenCount.toString(),
                            maxLines: 1,
                            style: TextStyle(color: primaryColor),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                        ),
                      ],
                    );
                  });
                }),
            ],
          ),
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Chat(
                  myId: myId,
                  peerIds: peerIds,
                  groupChatId: document.id,
                ),
              ),
            );
          },
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color>(greyColor2),
            shape: MaterialStateProperty.all<OutlinedBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
        ),
        margin: EdgeInsets.only(bottom: 10.0, left: 5.0, right: 5.0),
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

// class ChattingRoomInfo {
//   final String? myId;
//   final List<dynamic>? peerIds;
//   final DocumentSnapshot? doc;

//   ChattingRoomInfo({this.myId, this.peerIds, this.doc});

//   Stream<List<String>> get lastInfo async* {
//     List<String?> lastInfo;

//     String? lastTime;
//     String? lastContent;
//     String? unSeenCount;

//     String? lastTimeSeen;
    

//     await FirebaseFirestore.instance.collection('users').doc(peerIds?[0]).collection('messageWith').doc(doc?.id).collection('messages').get().then((snapshot) {
//       var temp = snapshot.docs[snapshot.docs.length - 1].get('timestamp').toString();
//       Timestamp timestamp = Timestamp.fromMillisecondsSinceEpoch(int.parse(temp));
//       DateTime dateTime = timestamp.toDate();
//       String formatedTime = formatDate(dateTime, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
//       if (isTomorrow(formatedTime)) {
//         lastTime = formatedTime.substring(11, 16);
//       } else {
//         lastTime = formatedTime.substring(0, 4) + '.' + formatedTime.substring(5, 7) + '.' + formatedTime.substring(8, 10);
//       }

//       lastContent = snapshot.docs[snapshot.docs.length - 1].get('content').toString();
//     });

//     await FirebaseFirestore.instance.collection('users').doc(myId).collection('messageWith').doc(doc?.id).get().then((snapshot) {
//       lastTimeSeen = snapshot['lastTimeSeen'];
//     });

//     await FirebaseFirestore.instance.collection('users').doc(peerIds?[0]).collection('messageWith').doc(doc?.id).collection('messages').where('timestamp', isGreaterThan: lastTimeSeen).get().then((snapshot) {
//       unSeenCount = snapshot.docs.length.toS;
//     });

//     lastInfo = [lastTime, lastContent, unSeenCount]
    
//   }
// }
