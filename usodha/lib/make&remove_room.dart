// 방 만들기 / 방 목록 보여주기
import 'package:flutter/material.dart';
import 'appbar/appbar.dart';

void main() {
  runApp(MaterialApp(
    title: 'USODHA', // used by the OS task switcher
    home: App(),
  ));
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // 방 만들기 / 주제 / 등등
    Widget buttonSection = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BuildNewRoomButton(),
          BuildDeleteRoomButton(),
        ],
      ),
    );

    // 생성된 방 목록들
    Widget roomSection = Container(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          RoomListPage(title: 'Room List'),
        ],
      ),
    );

    return Material(
      child: Column(
        children: <Widget>[
          MyAppBar(
            title: Text(
              'USODHA',
              style: Theme.of(context).primaryTextTheme.headline5,
            ),
          ),
          buttonSection,
          roomSection,
        ],
      ),
    );
  }
}

List<Room> roomList = <Room>[];

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
    // 이 부분 firebase로 대체
    for (int i = 0; i < 10; i++) {
      roomList.add(new Room('방 $i'));
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
