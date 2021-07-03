import 'package:flutter/material.dart';
import 'appbar/appbar.dart';

void main() {
  runApp(MaterialApp(
    title: 'USODHA', // used by the OS task switcher
    home: HomePage(),
  ));
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'USODHA',
      home: HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget buttonSection = Container(
      child: Row(
        // Row에서 Main은 Row지, spaceEvenly: 동일 공간 할당
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      ),
    );

    Widget roomSection = Container(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          BuildNewRoomButton(),
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

class BuildNewRoomButton extends StatefulWidget {
  @override
  _MakeRoomList createState() => _MakeRoomList();
}

class _MakeRoomList extends State<BuildNewRoomButton> {
  List<Widget> roomList = <Widget>[];

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
            onPressed: null,
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
}
