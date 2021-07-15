import 'package:flutter/material.dart';
import 'board.dart';
import 'room_list.dart';

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

  searchSmallGroup() {
    print('검색중...');
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
                          onPressed: () {
                            searchSmallGroup();
                          },
                        ),
                        BuildNewRoomButton(),
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
          icon: Icon(Icons.house_siding),
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
            '새 방',
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
