import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:usdh/chat/chatting.dart';
import 'package:usdh/chat/const.dart';
import 'package:usdh/chat/widget/loading.dart';

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
  //final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  // final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  //     FlutterLocalNotificationsPlugin();
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
    //registerNotification();
    //configLocalNotification();
    listScrollController.addListener(scrollListener);
  }

  // void registerNotification() {
  //   firebaseMessaging.requestPermission();
  //   FirebaseMessaging.onMessage.listen((RemoteMessage message) {
  //     print('onMessage: $message');
  //     if (message.notification != null) {
  //       showNotification(message.notification!);
  //     }
  //     return;
  //   });
  //   firebaseMessaging.getToken().then((token) {
  //     print('token: $token');
  //     FirebaseFirestore.instance
  //         .collection('users')
  //         .doc(currentUserId)
  //         .update({'pushToken': token});
  //   }).catchError((err) {
  //     Fluttertoast.showToast(msg: err.message.toString());
  //   });
  // }
  // android, ios 초기화
  // void configLocalNotification() {
  //   AndroidInitializationSettings initializationSettingsAndroid =
  //       AndroidInitializationSettings('app_icon');
  //   IOSInitializationSettings initializationSettingsIOS =
  //       IOSInitializationSettings();
  //   InitializationSettings initializationSettings = InitializationSettings(
  //       android: initializationSettingsAndroid, iOS: initializationSettingsIOS);
  //   flutterLocalNotificationsPlugin.initialize(initializationSettings);
  // }

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

  // 앱 푸쉬 알람 기능
  // void showNotification(RemoteNotification remoteNotification) async {
  //   AndroidNotificationDetails androidPlatformChannelSpecifics =
  //       AndroidNotificationDetails(
  //     Platform.isAndroid
  //         ? 'com.dfa.flutterchatdemo'
  //         : 'com.duytq.flutterchatdemo',
  //     'Flutter chat demo',
  //     'your channel description',
  //     playSound: true,
  //     enableVibration: true,
  //     importance: Importance.max,
  //     priority: Priority.high,
  //   );
  //   IOSNotificationDetails iOSPlatformChannelSpecifics =
  //       IOSNotificationDetails();
  //   NotificationDetails platformChannelSpecifics = NotificationDetails(
  //       android: androidPlatformChannelSpecifics,
  //       iOS: iOSPlatformChannelSpecifics);
  //   print(remoteNotification);
  //   await flutterLocalNotificationsPlugin.show(
  //     0,
  //     remoteNotification.title,
  //     remoteNotification.body,
  //     platformChannelSpecifics,
  //     payload: null,
  //   );
  // }

  // 앱 종료 (뒤로 가기를 누르면 종료 확인 팝업창이 뜸)
  // Future<bool> onBackPress() {
  //   openDialog();
  //   return Future.value(false);
  // }
  // Future<Null> openDialog() async {
  //   switch (await showDialog(
  //       context: context,
  //       builder: (BuildContext context) {
  //         return SimpleDialog(
  //           contentPadding:
  //               EdgeInsets.only(left: 0.0, right: 0.0, top: 0.0, bottom: 0.0),
  //           children: <Widget>[
  //             Container(
  //               color: themeColor,
  //               margin: EdgeInsets.all(0.0),
  //               padding: EdgeInsets.only(bottom: 10.0, top: 10.0),
  //               height: 100.0,
  //               child: Column(
  //                 children: <Widget>[
  //                   Container(
  //                     child: Icon(
  //                       Icons.exit_to_app,
  //                       size: 30.0,
  //                       color: Colors.white,
  //                     ),
  //                     margin: EdgeInsets.only(bottom: 10.0),
  //                   ),
  //                   Text(
  //                     'Exit app',
  //                     style: TextStyle(
  //                         color: Colors.white,
  //                         fontSize: 18.0,
  //                         fontWeight: FontWeight.bold),
  //                   ),
  //                   Text(
  //                     'Are you sure to exit app?',
  //                     style: TextStyle(color: Colors.white70, fontSize: 14.0),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //             SimpleDialogOption(
  //               onPressed: () {
  //                 Navigator.pop(context, 0);
  //               },
  //               child: Row(
  //                 children: <Widget>[
  //                   Container(
  //                     child: Icon(
  //                       Icons.cancel,
  //                       color: primaryColor,
  //                     ),
  //                     margin: EdgeInsets.only(right: 10.0),
  //                   ),
  //                   Text(
  //                     'CANCEL',
  //                     style: TextStyle(
  //                         color: primaryColor, fontWeight: FontWeight.bold),
  //                   )
  //                 ],
  //               ),
  //             ),
  //             SimpleDialogOption(
  //               onPressed: () {
  //                 Navigator.pop(context);
  //               },
  //               child: Row(
  //                 children: <Widget>[
  //                   Container(
  //                     child: Icon(
  //                       Icons.check_circle,
  //                       color: primaryColor,
  //                     ),
  //                     margin: EdgeInsets.only(right: 10.0),
  //                   ),
  //                   Text(
  //                     'YES',
  //                     style: TextStyle(
  //                         color: primaryColor, fontWeight: FontWeight.bold),
  //                   )
  //                 ],
  //               ),
  //             ),
  //           ],
  //         );
  //       })) {
  //     case 0:
  //       break;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '채팅방',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // Appbar의 로그아웃, 설정 버튼
        actions: <Widget>[
          PopupMenuButton<Choice>(
            onSelected: onItemMenuPress,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                    value: choice,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          choice.icon,
                          color: primaryColor,
                        ),
                        Container(
                          width: 10.0,
                        ),
                        Text(
                          choice.title,
                          style: TextStyle(color: primaryColor),
                        ),
                      ],
                    ));
              }).toList();
            },
          ),
        ],
      ),
      // 채팅 기록 불러오기
      body: Stack(
        children: <Widget>[
          // firebase에서 limits만큼의 users 정보 가져옴
          Container(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(myId).collection('messageWith').limit(_limit).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) => buildItem(context, snapshot.data?.docs[index]),
                    itemCount: snapshot.data?.docs.length,
                    controller: listScrollController,
                  );
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

          // Loading
          Positioned(
            child: isLoading ? const Loading() : Container(),
          )
        ],
      ),
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
