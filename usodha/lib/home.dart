import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
//import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'chatting.dart';
import 'const.dart';
import 'model/user_chat.dart';
import 'widget/loading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'main.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  HomeScreen({Key? key, required this.currentUserId}) : super(key: key);

  @override
  State createState() => HomeScreenState(currentUserId: currentUserId);
}

class HomeScreenState extends State<HomeScreen> {
  HomeScreenState({Key? key, required this.currentUserId});

  final String currentUserId;
  //final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final ScrollController listScrollController = ScrollController();

  int _limit = 20; // 한 번에 불러오는 채팅 방 수
  int _limitIncrement = 20; // _limit을 넘길 경우 _limitIncrement만큼 추가
  bool isLoading = false;
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
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
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
          'MAIN',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        actions: <Widget>[
          // 로그아웃, 설정 버튼
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
              stream: FirebaseFirestore.instance
                  .collection('users')
                  .limit(_limit)
                  .snapshots(),
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) =>
                        buildItem(context, snapshot.data?.docs[index]),
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

  // 각각의 채팅 기록( 1 block )
  Widget buildItem(BuildContext context, DocumentSnapshot? document) {
    if (document != null) {
      UserChat userChat = UserChat.fromDocument(document);
      if (userChat.id == currentUserId) {
        return SizedBox.shrink();
      } else {
        return Container(
          child: TextButton(
            child: Row(
              children: <Widget>[
                Material(
                  child: userChat.photoUrl.isNotEmpty
                      ? Image.network(
                          userChat.photoUrl,
                          fit: BoxFit.cover,
                          width: 50.0,
                          height: 50.0,
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              width: 50,
                              height: 50,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: primaryColor,
                                  value: loadingProgress.expectedTotalBytes !=
                                              null &&
                                          loadingProgress.expectedTotalBytes !=
                                              null
                                      ? loadingProgress.cumulativeBytesLoaded /
                                          loadingProgress.expectedTotalBytes!
                                      : null,
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
                Flexible(
                  child: Container(
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Text(
                            'Nickname: ${userChat.nickname}',
                            maxLines: 1,
                            style: TextStyle(color: primaryColor),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                        ),
                        Container(
                          child: Text(
                            'About me: ${userChat.aboutMe}',
                            maxLines: 1,
                            style: TextStyle(color: primaryColor),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                        )
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
                    peerId: userChat.id,
                    peerAvatar: userChat.photoUrl,
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
      }
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
