import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:login_test/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

late SmallGroupListState pageState;

class SmallGroupList extends StatefulWidget {
  @override
  SmallGroupListState createState() {
    pageState = SmallGroupListState();
    return pageState;
  }
}

class SmallGroupListState extends State<SmallGroupList> {
  TextEditingController input = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget roomSection = Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RoomListPage(title: 'Room List'),
        ],
      ),
    );

    return Scaffold(
        appBar: AppBar(title: Text('소모임')),
        body: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
                margin:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                child: Column(
                  children: <Widget>[
                    // 검색창
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          child: TextField(
                            controller: input,
                            decoration: InputDecoration(hintText: "내용을 입력하세요."),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.search),
                          tooltip: 'Search small group',
                          onPressed: searchSmallGroup,
                        ),
                        BuildNewRoomButton(),
                        BuildDeleteRoomButton(),
                      ],
                    ),

                    // 소모임 list 출력
                    roomSection
                  ],
                )),
          ],
        )));
  }
}

List<Room> roomList = <Room>[];
FirebaseFirestore firestore = FirebaseFirestore.instance;

class Room {
  String roomName;
  Room(this.roomName);
}

class RoomListPage extends StatefulWidget {
  final String title;
  RoomListPage({Key? key, required this.title}) : super(key: key);

  @override
  _RoomListPage createState() => _RoomListPage();
}

class _RoomListPage extends State<RoomListPage> {
  // 생성된 방들 firebase에서 가져옴
  void initState() {
    super.initState();
    Consumer<ApplicationState>(
            builder: (context, appState, _) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add from here
                if (appState.attendees >= 2)
                  Paragraph('${appState.attendees} people going')
                else if (appState.attendees == 1)
                  const Paragraph('1 person going')
                else
                  const Paragraph('No one going'),
              ],
            ),
          ),
    print('방 목록 초기화!');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      child: Column(children: [
        roomListView(context),
      ]),
    );
  }

  // 방들을 순서대로 보여줌
  Widget roomListView(BuildContext context) {
    return Expanded(
        child: ListView.builder(
            itemCount: roomList.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(roomList[index].roomName),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RoomPage(room: roomList[index])),
                  );
                },
              );
            }));
  }
}

// 각 방의 내용
class RoomPage extends StatelessWidget {
  final Room room;

  RoomPage({Key? key, required this.room}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(room.roomName),
      ),
      body: Padding(
          padding: EdgeInsets.all(16.0),
          // 방 내부 - 수정
          child: Center(
            child: Text(
              room.roomName,
              style: TextStyle(fontSize: 40),
            ),
          )),
    );
  }
}

// 새로운 방 생성 버튼
class BuildNewRoomButton extends StatefulWidget {
  @override
  _MakeNewRoom createState() => _MakeNewRoom();
}

// 새로운 방 생성 동작
class _MakeNewRoom extends State<BuildNewRoomButton> {
  void makeNewRoom() {
    // firebase에 방 추가하고 화면 새로 고침 하도록?
    print('방 추가');
    roomList.add(new Room('방 ${roomList.length}'));
  }

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.upcoming_rounded),
          color: color,
          iconSize: 36,
          onPressed: makeNewRoom,
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            'Make',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

// 방 삭제 버튼
class BuildDeleteRoomButton extends StatefulWidget {
  @override
  _DeleteRoom createState() => _DeleteRoom();
}

// 방 삭제 동작
class _DeleteRoom extends State<BuildDeleteRoomButton> {
  void deleteRoom() {
    // firebase에 방 삭제 후 새로고침
    print('방 삭제');
    roomList.remove(roomList[roomList.length - 1]);
  }

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: Icon(Icons.downhill_skiing),
          color: color,
          iconSize: 36,
          onPressed: deleteRoom,
        ),
        Container(
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            'Delete',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

searchSmallGroup() {
  print('검색중...');
}

class ApplicationState extends ChangeNotifier {
  ApplicationState() {
    init();
  }

  Future<void> init() async {
    await Firebase.initializeApp();

    // firestore 읽기
    FirebaseFirestore.instance
        .collection('attendees')
        .where('attending', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      _attendees = snapshot.docs.length;
      notifyListeners();
    });

    // 회원가입 / 로그인
    FirebaseAuth.instance.userChanges().listen((user) {
      // 기존 회원
      if (user != null) {
        _loginState = ApplicationLoginState.loggedIn;
        _guestBookSubscription = FirebaseFirestore.instance
            .collection('guestbook')
            .orderBy('timestamp', descending: true)
            .snapshots()
            .listen((snapshot) {
          _guestBookMessages = [];
          for (final document in snapshot.docs) {
            _guestBookMessages.add(
              GuestBookMessage(
                name: document.data()['name'] as String,
                message: document.data()['text'] as String,
              ),
            );
          }
          notifyListeners();
        });
        _attendingSubscription = FirebaseFirestore.instance
            .collection('attendees')
            .doc(user.uid)
            .snapshots()
            .listen((snapshot) {
          if (snapshot.data() != null) {
            if (snapshot.data()!['attending'] as bool) {
              _attending = Attending.yes;
            } else {
              _attending = Attending.no;
            }
          } else {
            _attending = Attending.unknown;
          }
          notifyListeners();
        });
      }
      // 신규 회원
      else {
        _loginState = ApplicationLoginState.loggedOut;
        _guestBookMessages = [];
        _guestBookSubscription?.cancel();
        _attendingSubscription?.cancel();
      }
      notifyListeners();
    });
  }