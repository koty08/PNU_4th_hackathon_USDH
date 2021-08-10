import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:usdh/Widget/widget.dart';
import 'package:usdh/chat/chatting.dart';
import 'package:usdh/chat/const.dart';

// 현재 내가 포함된 채팅방 목록
class HomeScreen extends StatefulWidget {
  final String myId;

  HomeScreen({Key? key, required this.myId}) : super(key: key);

  @override
  State createState() => HomeScreenState(myId: myId);
}

class HomeScreenState extends State<HomeScreen> {
  // currentUserId : 현재 접속한 user Email
  HomeScreenState({Key? key, required this.myId});

  final String myId;
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Image.asset('assets/images/icon/iconback.png', width: 22, height: 22),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      headerText("채팅"),
                      cSizedBox(0, 50),
                    ]
                  ),
                  headerDivider(),
                  Expanded(
                    child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: ListView.builder(
                        padding: EdgeInsets.all(10.0),
                        itemBuilder: (context, index) => buildItem(context, snapshot.data?.docs[index]),
                        itemCount: snapshot.data?.docs.length,
                        controller: listScrollController,
                      )
                    )
                  )
                ]);
              }

                /*
              }*/ else {
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
        temp.add(value['nick']);
      });
    }
    nickForText = '';
    for (int i = 0; i < temp.length; i++) {
      if (i < temp.length - 1)
        nickForText = nickForText + temp[i] + ", ";
      else
        nickForText = nickForText + temp[i];
    }
    return nickForText;
  }

  String nickForText = '';
  // 각각의 채팅 기록( 1 block ) - '[chatRoomName]' document 를 인자로
  Widget buildItem(BuildContext context, DocumentSnapshot? document) {
    if (document != null) {
      // 다수의 프로필 사진을 어케 처리하지
      List<dynamic> peerIds = document['chatMembers'];
      String photoUrl = 'https://firebasestorage.googleapis.com/v0/b/example-18d75.appspot.com/o/%ED%99%94%EB%A9%B4%20%EC%BA%A1%EC%B2%98%202021-07-21%20113022.png?alt=media&token=b9b9dfb3-ac59-430c-b35b-04d9fad08ae6';

      return Container(
        child: TextButton(
          child: Row(
            children: <Widget>[
              // 프로필 사진
              Material(
                child: photoUrl.isNotEmpty
                    ? Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                        width: 50.0,
                        height: 50.0,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 50,
                            height: 50,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: primaryColor,
                                value: loadingProgress.expectedTotalBytes != null && loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, object, stackTrace) {
                          return Icon(
                            Icons.account_circle,
                            size: 50.0,
                            color: greyColor,
                          );
                        },
                      )
                    : Icon(
                        Icons.account_circle,
                        size: 50.0,
                        color: greyColor,
                      ),
                borderRadius: BorderRadius.all(Radius.circular(25.0)),
                clipBehavior: Clip.hardEdge,
              ),
              // 닉네임
              Flexible(
                child: Container(
                  child: Column(
                    children: <Widget>[
                      FutureBuilder(
                          future: getPeerNicks(peerIds),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return Container(
                                child: Text(
                                  'Nickname: $nickForText',
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
                  margin: EdgeInsets.only(left: 20.0),
                ),
              ),
            ],
          ),
          onPressed: () {
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
