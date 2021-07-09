import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'write_board.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

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

searchSmallGroup() {
  print('검색중...');
}

// 방 리스트 출력을 위한 list
List<Room> roomList = <Room>[];
StreamSubscription<QuerySnapshot>? _roomSubscription;

// 각 방은 이름을 부여받음 - 수정 필요
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
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final CollectionReference roomCollection =
      FirebaseFirestore.instance.collection('posts');
  Future updatePost(
    String _contents,
  ) async {
    return await roomCollection.doc('aaa').set({
      'contents': _contents,
    });
  }

  // 생성된 방들 firebase에서 가져옴 - 초기화 한 번만 하게 어케 하지
  void initState() {
    super.initState();
    roomList = [];
    _roomSubscription =
        firestore.collection('posts').snapshots().listen((snapshot) {
      for (final document in snapshot.docs) {
        roomList.add(Room(document.data()['contents']));
      }
    });
    for (var a in roomList) {
      print(a.roomName);
    }
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
                trailing: IconButton(
                  icon: Icon(Icons.more_vert),
                  onPressed: () async {},
                ),
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
          // 방 내부 - 수정 필요
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
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => WriteBoard()));
          },
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
