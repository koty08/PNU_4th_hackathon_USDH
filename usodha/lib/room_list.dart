import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';
import 'firebase_provider.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;
late Map<String, dynamic> info;
final CollectionReference roomCollection =
    FirebaseFirestore.instance.collection('posts');

// 방 리스트 출력을 위한 list
List<Room> roomList = <Room>[];
StreamSubscription<QuerySnapshot>? _roomSubscription;

// 각 방은 이름을 부여받음 - 수정 필요
class Room {
  String roomName;
  Room(this.roomName);

  void printName() {
    print(this.roomName);
  }
}

class RoomListPage extends StatefulWidget {
  final String title;
  RoomListPage({Key? key, required this.title}) : super(key: key);

  @override
  _RoomListPage createState() => _RoomListPage();
}

class _RoomListPage extends State<RoomListPage> {
  // 게시물을 roomList에 초기화
  void initState() {
    super.initState();
    roomList = [];
    firestore.collection('posts').snapshots().listen((snapshot) {
      for (final document in snapshot.docs) {
        roomList.add(new Room(document.data()['contents'] +
            ' [' +
            document.data()['current member'] +
            '/' +
            document.data()['limited member'] +
            ']'));
        print('#### roomList.lenght ####');
        print(roomList.length);
      }
    });
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
    // 방 내용 수정 기능
    void modifyRoom() {
      print('modify room!');
    }

    return Expanded(
        child: ListView.builder(
            itemCount: roomList.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: Text(roomList[index].roomName),
                onTap: () {
                  for (var room in roomList) {
                    room.printName();
                  }
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RoomPage(room: roomList[index])),
                  );
                },
                trailing: PopupMenuButton(
                  itemBuilder: (BuildContext context) => [
                    PopupMenuItem(
                      child: TextButton(
                          child: Text(
                            "delete",
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () async {
                            await firestore
                                .collection('posts')
                                .doc('aaa6')
                                .delete();
                          }),
                    ),
                    PopupMenuItem(
                      child: TextButton(
                        child: Text(
                          "modify",
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
                          modifyRoom();
                        },
                      ),
                    ),
                  ],
                ),
              );
            }));
  }
}

// 각 방의 내용
class RoomPage extends StatefulWidget {
  final Room room;

  RoomPage({Key? key, required this.room}) : super(key: key);

  @override
  _RoomPageState createState() => _RoomPageState();
}

class _RoomPageState extends State<RoomPage> {
  late FirebaseProvider fp;

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();
    var tmp = fp.getInfo();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.room.roomName),
      ),
      body: Padding(
          padding: EdgeInsets.all(16.0),
          // 방 내부 - 수정 필요
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20, top: 5),
                child: ElevatedButton(
                    child: Text(
                      "join",
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () async {
                      String currentMember = '';
                      String limitedMember = '';
                      await firestore
                          .collection('posts')
                          .doc('aaa6')
                          .get()
                          .then((value) {
                        currentMember = value['current member'];
                        limitedMember = value['limited member'];
                      });
                      int _currentMember = int.parse(currentMember);
                      int _limitedMember = int.parse(limitedMember);
                      // 제한 인원 꽉 찰 경우
                      if (_currentMember >= _limitedMember) {
                        print('This room is full!!');
                      }
                      // 인원이 남을 경우
                      else {
                        firestore.collection('posts').doc('aaa6').update({
                          'current member': (_currentMember + 1).toString()
                        });
                      }
                    }),
              ),
              Container(
                margin: const EdgeInsets.only(left: 20, right: 20, top: 5),
                child: ElevatedButton(
                    child: Text(
                      "join out",
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () async {
                      String currentMember = '';
                      String limitedMember = '';
                      await firestore
                          .collection('posts')
                          .doc('aaa6')
                          .get()
                          .then((value) {
                        currentMember = value['current member'];
                        limitedMember = value['limited member'];
                      });
                      int _currentMember = int.parse(currentMember);
                      int _limitedMember = int.parse(limitedMember);

                      // 모임에 2명 이상, 제한 인원 이하로 남을 경우
                      if (_currentMember >= 2 &&
                          _currentMember <= _limitedMember) {
                        await firestore.collection('posts').doc('aaa6').update({
                          'current member': (_currentMember - 1).toString()
                        });
                      }
                      // 남은 인원이 1명일 경우
                      else if (_currentMember == 1) {
                        firestore.collection('posts').doc('aaa6').update({
                          'current member': (_currentMember - 1).toString()
                        });
                        print('delete room!');
                      }
                      // 남은 인원이 제한 인원 초과 또는 0명 이하일 경우
                      else {
                        print('The current member has a error!!');
                      }
                    }),
              ),
            ],
          )),
    );
  }
}
