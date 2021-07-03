import 'package:flutter/material.dart';

void main() {
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget buttonSection = Container(
      child: Row(
        // Row에서 Main은 Row지, spaceEvenly: 동일 공간 할당
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BuildMakingRoomButton(),
          BuildHomeButton(),
          BuildMenuButton(),
        ],
      ),
    );

    return MaterialApp(
      title: 'USODHA',
      home: Scaffold(
        appBar: AppBar(
          title: Text('USODHA'),
        ),
        body: ListView(
          children: [
            buttonSection,
          ],
        ),
      ),
    );
  }
}

class BuildMakingRoomButton extends StatefulWidget {
  @override
  _MakeRoomList createState() => _MakeRoomList();
}

class _MakeRoomList extends State<BuildMakingRoomButton> {
  List<Widget> roomList = <Widget>[];

  @override
  void initState() {
    super.initState();
    print('초기화...');
  }

  void _makeRoom() {
    print('방만들기 성공');
    MakeRoom();
  }

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(0),
          child: IconButton(
            padding: EdgeInsets.all(0),
            alignment: Alignment.centerRight,
            icon: Icon(Icons.upcoming_rounded),
            color: color,
            onPressed: _makeRoom,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          margin: const EdgeInsets.only(top: 8),
          child: Text(
            '새 방 만들기',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
  // #docregion _FavoriteWidgetState-fields
}

class MakeRoom extends StatefulWidget {
  @override
  _MakeRoomState createState() => _MakeRoomState();
}

class _MakeRoomState extends State<MakeRoom> {
  int _memberNumber = 0;
  int _limitNumber = 4;
  bool _isJoinIn = true;
  // 방에 참가
  void _joinIn() {
    setState(() {
      if (_memberNumber < _limitNumber) {
        _isJoinIn = true;
        _memberNumber++;
      } else {
        Text('방이 꽉 찼습니다.');
      }
    });
  }

  // 방에서 나가기 - 참가 상태에만 보임
  void _joinOut() {
    setState(() {
      _isJoinIn = false;
      _memberNumber--;
    });
  }

  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;
    print('hello world');
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(0),
          child: Text(
            '[주제] [제목]',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: color,
            ),
          ),
        ),
        Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            margin: const EdgeInsets.only(top: 8),
            child: Row(
              children: [
                ElevatedButton(onPressed: _joinIn, child: const Text('참가')),
                const SizedBox(width: 8),
                if (_isJoinIn)
                  ElevatedButton(onPressed: _joinOut, child: const Text('나가기')),
              ],
            )),
      ],
    );
  }
  // #docregion _FavoriteWidgetState-fields
}

class BuildMenuButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(0),
          child: IconButton(
            padding: EdgeInsets.all(0),
            alignment: Alignment.centerRight,
            icon: Icon(Icons.menu),
            color: color,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Menu()),
              );
            },
          ),
        ),
      ],
    );
  }
}

class Menu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("메뉴"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}

class BuildHomeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Color color = Theme.of(context).primaryColor;

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Container(
          padding: EdgeInsets.all(0),
          child: IconButton(
            padding: EdgeInsets.all(0),
            alignment: Alignment.centerRight,
            icon: Icon(Icons.home),
            color: color,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home()),
              );
            },
          ),
        ),
      ],
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("홈"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text('Go back!'),
        ),
      ),
    );
  }
}
