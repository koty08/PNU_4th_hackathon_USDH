import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:usdh/Widget/widget.dart';
import 'package:usdh/login/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:usdh/chat/chatting.dart';
import 'package:usdh/chat/home.dart';

late deliveryWriteState pageState;
late deliveryMapState pageState1;
late deliveryListState pageState2;
late deliveryShowState pageState3;
late deliveryModifyState pageState4;

bool is_available(String time, int n1, int n2) {
  if (n1 >= n2) {
    return false;
  }
  String now = formatDate(
      DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
  DateTime d1 = DateTime.parse(now);
  DateTime d2 = DateTime.parse(time);
  Duration diff = d1.difference(d2);
  if (diff.isNegative) {
    return true;
  } else {
    return false;
  }
}

/* ---------------------- Write Board (Delivery) ---------------------- */

class deliveryWrite extends StatefulWidget {
  @override
  deliveryWriteState createState() {
    pageState = deliveryWriteState();
    return pageState;
  }
}

class deliveryWriteState extends State<deliveryWrite> {
  late File img;
  late FirebaseProvider fp;
  TextEditingController titleInput = TextEditingController();
  TextEditingController contentInput = TextEditingController();
  TextEditingController timeInput = TextEditingController();
  TextEditingController memberInput = TextEditingController();
  TextEditingController foodInput = TextEditingController();
  TextEditingController locationInput = TextEditingController();
  TextEditingController tagInput = TextEditingController();
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseFirestore fs = FirebaseFirestore.instance;
  List urlList = [];
  String gender = "";

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    setState(() {
      gender = "상관없음";
    });
    super.initState();
  }

  @override
  void dispose() {
    titleInput.dispose();
    contentInput.dispose();
    timeInput.dispose();
    memberInput.dispose();
    foodInput.dispose();
    locationInput.dispose();
    tagInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();

    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Text("게시판 글쓰기")),
        body: Center(
            child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                height: 30,
                child: TextFormField(
                    controller: titleInput,
                    decoration: InputDecoration(hintText: "제목을 입력하세요."),
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "제목은 필수 입력 사항입니다.";
                      }
                      return null;
                    }),
              ),
              Divider(
                color: Colors.black,
              ),
              Container(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("모집조건"),
                    TextFormField(
                        controller: timeInput,
                        decoration: InputDecoration(
                            hintText: "마감 시간 입력 : xx:xx (ex 21:32 형태)"),
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return "마감 시간은 필수 입력 사항입니다.";
                          }
                          return null;
                        }),
                    TextFormField(
                        controller: memberInput,
                        decoration:
                            InputDecoration(hintText: "인원을 입력하세요. (숫자 형태)"),
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return "인원은 필수 입력 사항입니다.";
                          }
                          return null;
                        }),
                    TextFormField(
                        controller: foodInput,
                        decoration: InputDecoration(hintText: "음식 종류를 입력하세요."),
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return "음식 종류는 필수 입력 사항입니다.";
                          }
                          return null;
                        }),
                    TextFormField(
                        controller: locationInput,
                        decoration: InputDecoration(hintText: "위치를 입력하세요."),
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return "위치는 필수 입력 사항입니다.";
                          }
                          return null;
                        }),
                    TextFormField(
                        controller: tagInput,
                        decoration: InputDecoration(hintText: "태그를 입력하세요."),
                        validator: (text) {
                          if (text == null || text.isEmpty) {
                            return "태그는 필수 입력 사항입니다.";
                          }
                          return null;
                        }),
                    Row(
                      children: [
                        Padding(padding: EdgeInsets.fromLTRB(0, 60, 0, 0)),
                        Radio(
                            value: "여자만",
                            groupValue: gender,
                            onChanged: (String? value) {
                              setState(() {
                                gender = value!;
                              });
                            }),
                        Text("여자만"),
                        Radio(
                            value: "남자만",
                            groupValue: gender,
                            onChanged: (String? value) {
                              setState(() {
                                gender = value!;
                              });
                            }),
                        Text("남자만"),
                        Radio(
                            value: "상관없음",
                            groupValue: gender,
                            onChanged: (String? value) {
                              setState(() {
                                gender = value!;
                              });
                            }),
                        Text("상관없음"),
                      ],
                    ),
                  ],
                ),
              ),
              Divider(
                color: Colors.black,
              ),
              Container(
                height: 50,
                child: TextFormField(
                    controller: contentInput,
                    decoration: InputDecoration(hintText: "내용을 입력하세요."),
                    validator: (text) {
                      if (text == null || text.isEmpty) {
                        return "내용은 필수 입력 사항입니다.";
                      }
                      return null;
                    }),
              ),
              Container(
                  height: 30,
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.blueAccent[200],
                    ),
                    child: Text(
                      "게시글 쓰기",
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () {
                      FocusScope.of(context).requestFocus(new FocusNode());
                      if (_formKey.currentState!.validate()) {
                        uploadOnFS();
                        Navigator.pop(context);
                      }
                    },
                  ))
            ],
          ),
        )));
  }

  void uploadOnFS() async {
    var tmp = fp.getInfo();
    await fs
        .collection('delivery_board')
        .doc(tmp['name'] + tmp['postcount'].toString())
        .set({
      'title': titleInput.text,
      'writer': tmp['name'],
      'contents': contentInput.text,
      'time': formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]) +
          " " +
          timeInput.text +
          ":00",
      'currentMember': 1,
      'limitedMember': int.parse(memberInput.text),
      'food': foodInput.text,
      'location': locationInput.text,
      'tags': tagInput.text,
      'gender': gender,
    });
    fp.updateIntInfo('postcount', 1);
  }
}

/* ---------------------- Board Map (Delivery) ---------------------- */
/* ----------------------    지우지 말아주세요    ---------------------- */

class deliveryMap extends StatefulWidget {
  @override
  deliveryMapState createState() {
    pageState1 = deliveryMapState();
    return pageState1;
  }
}

class deliveryMapState extends State<deliveryMap> {
  late FirebaseProvider fp;
  TextEditingController searchInput = TextEditingController();

  @override
  void dispose() {
    searchInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();

    return Scaffold(body: Container());
  }
}

/* ---------------------- Board List (Delivery) ---------------------- */

class deliveryList extends StatefulWidget {
  @override
  deliveryListState createState() {
    pageState2 = deliveryListState();
    return pageState2;
  }
}

class deliveryListState extends State<deliveryList> {
  Stream<QuerySnapshot> colstream =
      FirebaseFirestore.instance.collection('delivery_board').snapshots();
  late FirebaseProvider fp;
  TextEditingController searchInput = TextEditingController();

  @override
  void dispose() {
    searchInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();

    return Scaffold(
      body: RefreshIndicator(
        //당겨서 새로고침
        onRefresh: () async {
          colstream = await FirebaseFirestore.instance
              .collection('delivery_board')
              .snapshots();
        },
        child: StreamBuilder<QuerySnapshot>(
            stream: colstream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              return Column(children: [
                cSizedBox(35, 0),
                Container(
                  //decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 3, color: Colors.blueGrey))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Image.asset('assets/images/icon/iconback.png',
                            width: 22, height: 22),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      headerText("배달"),
                      cSizedBox(0, 50),
                      Wrap(
                        spacing: -5,
                        children: [
                          IconButton(
                            icon: Image.asset('assets/images/icon/iconmap.png',
                                width: 22, height: 22),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          //새로고침 기능
                          IconButton(
                            icon: Image.asset(
                                'assets/images/icon/iconrefresh.png',
                                width: 22,
                                height: 22),
                            onPressed: () async {
                              colstream = await FirebaseFirestore.instance
                                  .collection('delivery_board')
                                  .snapshots();
                            },
                          ),
                          //검색 기능 팝업
                          IconButton(
                            icon: Image.asset(
                                'assets/images/icon/iconsearch.png',
                                width: 22,
                                height: 22),
                            onPressed: () {
                              showDialog(
                                  context: context,
                                  builder: (BuildContext con) {
                                    return AlertDialog(
                                      title: Text("검색 ㄱ"),
                                      content: TextField(
                                        controller: searchInput,
                                        decoration: InputDecoration(
                                            hintText: "검색할 제목을 입력하세요."),
                                      ),
                                      actions: <Widget>[
                                        TextButton(
                                            onPressed: () {
                                              setState(() {
                                                colstream = FirebaseFirestore
                                                    .instance
                                                    .collection(
                                                        'delivery_board')
                                                    .orderBy('title')
                                                    .startAt([
                                                  searchInput.text
                                                ]).endAt([
                                                  searchInput.text + '\uf8ff'
                                                ]).snapshots();
                                              });
                                              Navigator.pop(con);
                                            },
                                            child: Text("검색")),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(con);
                                            },
                                            child: Text("취소")),
                                      ],
                                    );
                                  });
                            },
                          ),
                          IconButton(
                            icon: Image.asset(
                                'assets/images/icon/iconmessage.png',
                                width: 22,
                                height: 22),
                            onPressed: () {
                              var tmp = fp.getInfo();
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => HomeScreen(
                                          currentUserId: tmp['email'])));
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                /*CustomPaint(
                    size: Size(400, 4),
                    painter: CurvePainter(),
                  ),*/
                Divider(
                  color: Colors.blueAccent,
                  thickness: 3,
                ),
                Container(
                    padding: EdgeInsets.fromLTRB(0, 0, 25, 0),
                    child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          IconButton(
                            icon: Icon(Icons.check_box_outlined),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          cSizedBox(2, 0),
                          Text(
                            "모집완료 보기",
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.indigo.shade300,
                            ),
                          ),
                        ])),
                // Container or Expanded or Flexible 사용
                Expanded(
                    // 아래 간격 두고 싶으면 Container, height 사용
                    //height: MediaQuery.of(context).size.height * 0.8,
                    child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.separated(
                      separatorBuilder: (context, index) => Divider(
                            height: 10,
                            thickness: 2,
                            color: Colors.blue[100],
                          ),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final DocumentSnapshot doc = snapshot.data!.docs[index];
                        String title = doc['title'] +
                            ' [' +
                            doc['currentMember'].toString() +
                            '/' +
                            doc['limitedMember'].toString() +
                            ']';
                        String writer = doc['writer'];
                        return Column(children: [
                          Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                          InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            deliveryShow(doc.id)));
                              },
                              child: Container(
                                  margin: EdgeInsets.fromLTRB(30, 17, 10, 0),
                                  child: Column(children: [
                                    Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.7,
                                              child: Text(doc['tags'],
                                                  style: TextStyle(
                                                      fontFamily: "SCDream",
                                                      color: Colors.grey[600],
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontSize: 13))),
                                          cSizedBox(0, 10),
                                          is_available(
                                                  doc['time'],
                                                  doc['currentMember'],
                                                  doc['limitedMember'])
                                              ? sText("모집중")
                                              : sText("모집완료"),
                                          //Text("모집상태", style: TextStyle(fontFamily: "SCDream", color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: 12)),
                                        ]),
                                    Row(children: [
                                      Container(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.5,
                                        child: Text(title.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontFamily: "SCDream",
                                                fontWeight: FontWeight.w700,
                                                fontSize: 15)),
                                      ),
                                      cSizedBox(70, 40),
                                      Container(
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.15,
                                          child: Text(writer.toString(),
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontSize: 13,
                                                  color: Colors.blueGrey))),
                                      PopupMenuButton(
                                          itemBuilder: (BuildContext context) =>
                                              [
                                                PopupMenuItem(
                                                    child: TextButton(
                                                  child: Text(
                                                    "채팅시작",
                                                    style: TextStyle(
                                                        color: Colors.black),
                                                  ),
                                                  onPressed: () async {
                                                    var tmp = fp.getInfo();
                                                    List<dynamic> peerIds = [];
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection('users')
                                                        .doc(tmp['email'])
                                                        .collection(
                                                            'messageWith')
                                                        .doc('test_group_name')
                                                        .get()
                                                        .then((value) {
                                                      peerIds =
                                                          value['chatMembers'];
                                                    });
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder:
                                                                (context) =>
                                                                    Chat(
                                                                      // 수정필요
                                                                      peerIds:
                                                                          peerIds,
                                                                    )));
                                                  },
                                                ))
                                              ])
                                    ])
                                  ])))
                        ]);
                      }),
                )),
              ]);
            }),
      ),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => deliveryWrite()));
          }),
    );
  }

  Widget sText(String text) {
    return Container(
        width: MediaQuery.of(context).size.width * 0.15,
        child: Text(text,
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: "SCDream",
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
                fontSize: 12)));
  }
}

/* ---------------------- Show Board (Delivery) ---------------------- */

class deliveryShow extends StatefulWidget {
  deliveryShow(this.id);
  final String id;

  @override
  deliveryShowState createState() {
    pageState3 = deliveryShowState();
    return pageState3;
  }
}

class deliveryShowState extends State<deliveryShow> {
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore fs = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    FirebaseProvider fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();

    return Scaffold(
        body: StreamBuilder(
            stream: fs.collection('delivery_board').doc(widget.id).snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              fp.setInfo();

              if (snapshot.hasData && !snapshot.data!.exists) {
                return CircularProgressIndicator();
              } else if (snapshot.hasData) {
                fp.setInfo();
                return SingleChildScrollView(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    cSizedBox(35, 0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          icon: Icon(Icons.navigate_before),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        headerText("배달"),
                        cSizedBox(0, 175),
                        IconButton(
                          icon: Icon(Icons.message),
                          onPressed: () {
                            var tmp = fp.getInfo();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => HomeScreen(
                                        currentUserId: tmp['email'])));
                          },
                        ),
                      ],
                    ),
                    Divider(
                      color: Colors.indigo[400],
                      thickness: 3,
                    ),
                    Padding(
                        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                        child: Wrap(
                            direction: Axis.vertical,
                            spacing: 15,
                            children: [
                              tagText(snapshot.data!['tags']),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.8,
                                  child: titleText(snapshot.data!['title'])),
                              condText("마감 " +
                                  formatDate(
                                      DateTime.parse(snapshot.data!['time']),
                                      [HH, ':', nn]))
                            ])),
                    Divider(
                      color: Colors.indigo[200],
                      thickness: 2,
                    ),
                    Padding(
                        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                        child: Wrap(
                          direction: Axis.vertical,
                          spacing: 15,
                          children: [
                            Text("모집조건",
                                style: TextStyle(
                                    fontFamily: "SCDream",
                                    color: Colors.blueAccent,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15)),
                            Padding(
                                padding: EdgeInsets.fromLTRB(7, 5, 20, 0),
                                child: Wrap(
                                  direction: Axis.vertical,
                                  spacing: 15,
                                  children: [
                                    Wrap(
                                      spacing: 40,
                                      children: [
                                        cond2Text("모집기간"),
                                        condText(formatDate(
                                            DateTime.parse(
                                                snapshot.data!['time']),
                                            [HH, ':', nn])),
                                      ],
                                    ),
                                    Wrap(
                                      spacing: 40,
                                      children: [
                                        cond2Text("모집인원"),
                                        condText(snapshot.data!['currentMember']
                                                .toString() +
                                            "/" +
                                            snapshot.data!['limitedMember']
                                                .toString())
                                      ],
                                    ),
                                    Wrap(
                                      spacing: 40,
                                      children: [
                                        cond2Text("음식종류"),
                                        condText(snapshot.data!['food']),
                                      ],
                                    ),
                                    Wrap(
                                      spacing: 40,
                                      children: [
                                        cond2Text("배분위치"),
                                        condText(snapshot.data!['location']),
                                      ],
                                    )
                                  ],
                                ))
                          ],
                        )),
                    Divider(
                      color: Colors.indigo[200],
                      thickness: 2,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(50, 30, 50, 30),
                      child: Text(snapshot.data!['contents'],
                          style: TextStyle(fontSize: 14)),
                    ),
                    (fp.getInfo()['name'] == snapshot.data!['writer'])
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.purple[300],
                                  ),
                                  child: Text(
                                    "수정",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                deliveryModify(widget.id)));
                                    setState(() {});
                                  },
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.indigo[300],
                                  ),
                                  child: Text(
                                    "삭제",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    Navigator.pop(context);
                                    await fs
                                        .collection('delivery_board')
                                        .doc(widget.id)
                                        .delete();
                                    fp.updateIntInfo('postcount', -1);
                                  },
                                ),
                              ),
                            ],
                          )
                        :

                        // 참가, 손절
                        Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // 참가 버튼을 누르면 currentMember+1, 제한 넘으면 불가
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.purple[300],
                                  ),
                                  child: Text(
                                    "참가",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    var tmp = fp.getInfo();
                                    int _currentMember =
                                        snapshot.data!['currentMember'];
                                    int _limitedMember =
                                        snapshot.data!['limitedMember'];
                                    String _roomName = widget.id;

                                    List<String> _joiningRoom = [];
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(tmp['email'])
                                        .get()
                                        .then((value) {
                                      for (String room in value['joiningIn']) {
                                        _joiningRoom.add(room);
                                      }
                                    });
                                    // 이미 참가한 방인 경우
                                    if (_joiningRoom.contains(_roomName)) {
                                      print('이미 참가한 방입니다!!');
                                    }
                                    // 제한 인원 꽉 찰 경우
                                    else if (_currentMember >= _limitedMember) {
                                      print('This room is full');
                                    }
                                    // 인원이 남을 경우
                                    else {
                                      await FirebaseFirestore.instance
                                          .collection('delivery_board')
                                          .doc(widget.id)
                                          .update({
                                        'currentMember': _currentMember + 1
                                      });
                                      List<String> roomName = [_roomName];
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(tmp['email'])
                                          .update({
                                        'joiningIn':
                                            FieldValue.arrayUnion(roomName)
                                      });
                                      Navigator.pop(context);
                                      print(_roomName + ' 참가!!');
                                    }
                                  },
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.indigo[300],
                                  ),
                                  child: Text(
                                    "손절",
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  onPressed: () async {
                                    var tmp = fp.getInfo();
                                    int _currentMember =
                                        snapshot.data!['currentMember'];
                                    int _limitedMember =
                                        snapshot.data!['limitedMember'];
                                    String _roomName = widget.id;

                                    List<String> _joiningRoom = [];
                                    await FirebaseFirestore.instance
                                        .collection('users')
                                        .doc(tmp['email'])
                                        .get()
                                        .then((value) {
                                      for (String room in value['joiningIn']) {
                                        _joiningRoom.add(room);
                                      }
                                    });
                                    // 방에 참가하지 않은 경우
                                    if (!_joiningRoom.contains(_roomName)) {
                                      print('참가하지 않은 방입니다!!');
                                    }
                                    // 모임에 2명 이상, 제한 인원 이하로 남을 경우
                                    else if (_currentMember >= 2 &&
                                        _currentMember <= _limitedMember) {
                                      await FirebaseFirestore.instance
                                          .collection('delivery_board')
                                          .doc(widget.id)
                                          .update({
                                        'currentMember': _currentMember - 1
                                      });
                                      List<String> roomName = [_roomName];
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(tmp['email'])
                                          .update({
                                        'joiningIn':
                                            FieldValue.arrayRemove(roomName)
                                      });
                                      Navigator.pop(context);
                                      print(_roomName + ' 손절!!');
                                    }
                                    // 남은 인원이 1명일 경우
                                    else if (_currentMember == 1) {
                                      Navigator.pop(context);
                                      fs
                                          .collection('delivery_board')
                                          .doc(widget.id)
                                          .delete();
                                      List<String> roomName = [_roomName];
                                      await FirebaseFirestore.instance
                                          .collection('users')
                                          .doc(tmp['email'])
                                          .update({
                                        'joiningIn':
                                            FieldValue.arrayRemove(roomName)
                                      });
                                      print('사람이 0명이 되어 방 파괴!!');
                                    }
                                    // 남은 인원이 제한 인원 초과 또는 0명 이하일 경우
                                    else {
                                      print('The current member has a error!!');
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                  ],
                ));
              } else {
                return CircularProgressIndicator();
              }
            }));
  }
}

/* ---------------------- Modify Board (Delivery) ---------------------- */

class deliveryModify extends StatefulWidget {
  deliveryModify(this.id);
  final String id;
  @override
  State<StatefulWidget> createState() {
    pageState4 = deliveryModifyState();
    return pageState4;
  }
}

class deliveryModifyState extends State<deliveryModify> {
  final FirebaseFirestore fs = FirebaseFirestore.instance;
  late TextEditingController titleInput;
  late TextEditingController contentInput;
  late TextEditingController timeInput;
  late TextEditingController memberInput;
  late TextEditingController foodInput;
  late TextEditingController locationInput;
  late TextEditingController tagInput;
  String gender = "";

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    setState(() {
      gender = "상관없음";
    });
    super.initState();
  }

  @override
  void dispose() {
    titleInput.dispose();
    contentInput.dispose();
    timeInput.dispose();
    memberInput.dispose();
    foodInput.dispose();
    locationInput.dispose();
    tagInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: SingleChildScrollView(
            child: StreamBuilder(
                stream:
                    fs.collection('delivery_board').doc(widget.id).snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData && !snapshot.data!.exists) {
                    return CircularProgressIndicator();
                  }
                  if (snapshot.hasData) {
                    titleInput =
                        TextEditingController(text: snapshot.data!['title']);
                    contentInput =
                        TextEditingController(text: snapshot.data!['contents']);
                    timeInput = TextEditingController(
                        text: formatDate(DateTime.parse(snapshot.data!['time']),
                            [HH, ':', nn]));
                    memberInput = TextEditingController(
                        text: snapshot.data!['limitedMember'].toString());
                    foodInput =
                        TextEditingController(text: snapshot.data!['food']);
                    locationInput =
                        TextEditingController(text: snapshot.data!['location']);
                    tagInput =
                        TextEditingController(text: snapshot.data!['tags']);
                    return Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            cSizedBox(50, 0),
                            TextFormField(
                                controller: tagInput,
                                decoration:
                                    InputDecoration(hintText: "태그를 입력하세요."),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "태그는 필수 입력 사항입니다.";
                                  }
                                  return null;
                                }),
                            TextFormField(
                                controller: titleInput,
                                decoration:
                                    InputDecoration(hintText: "제목을 입력하세요."),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "제목은 필수 입력 사항입니다.";
                                  }
                                  return null;
                                }),
                            Divider(
                              color: Colors.black,
                            ),
                            TextFormField(
                                controller: timeInput,
                                decoration: InputDecoration(
                                    hintText: "마감 시간 입력 : xx:xx (ex 21:32 형태)"),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "마감 시간은 필수 입력 사항입니다.";
                                  }
                                  return null;
                                }),
                            TextFormField(
                                controller: memberInput,
                                decoration: InputDecoration(
                                    hintText: "인원을 입력하세요. (숫자 형태)"),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "인원은 필수 입력 사항입니다.";
                                  }
                                  return null;
                                }),
                            TextFormField(
                                controller: foodInput,
                                decoration:
                                    InputDecoration(hintText: "음식 종류를 입력하세요."),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "음식 종류는 필수 입력 사항입니다.";
                                  }
                                  return null;
                                }),
                            TextFormField(
                                controller: locationInput,
                                decoration:
                                    InputDecoration(hintText: "위치를 입력하세요."),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "위치는 필수 입력 사항입니다.";
                                  }
                                  return null;
                                }),
                            Row(
                              children: [
                                Padding(
                                    padding: EdgeInsets.fromLTRB(0, 60, 0, 0)),
                                Radio(
                                    value: "여자만",
                                    groupValue: gender,
                                    onChanged: (String? value) {
                                      setState(() {
                                        gender = value!;
                                      });
                                    }),
                                Text("여자만"),
                                Radio(
                                    value: "남자만",
                                    groupValue: gender,
                                    onChanged: (String? value) {
                                      setState(() {
                                        gender = value!;
                                      });
                                    }),
                                Text("남자만"),
                                Radio(
                                    value: "상관없음",
                                    groupValue: gender,
                                    onChanged: (String? value) {
                                      setState(() {
                                        gender = value!;
                                      });
                                    }),
                                Text("상관없음"),
                              ],
                            ),
                            //내용 수정
                            TextFormField(
                                controller: contentInput,
                                keyboardType: TextInputType.multiline,
                                maxLines: null,
                                decoration: InputDecoration(
                                  hintText: "내용을 입력하세요.",
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 50, horizontal: 10.0),
                                  border: OutlineInputBorder(
                                      borderRadius:
                                          BorderRadius.circular(15.0)),
                                ),
                                validator: (text) {
                                  if (text == null || text.isEmpty) {
                                    return "내용은 필수 입력 사항입니다.";
                                  }
                                  return null;
                                }),
                            Container(
                                height: 30,
                                margin: EdgeInsets.fromLTRB(0, 50, 0, 50),
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Colors.blueAccent[200],
                                  ),
                                  child: Text(
                                    "게시물 수정",
                                    style: TextStyle(color: Colors.black),
                                  ),
                                  onPressed: () {
                                    FocusScope.of(context)
                                        .requestFocus(new FocusNode());
                                    if (_formKey.currentState!.validate()) {
                                      updateOnFS();
                                      Navigator.pop(context);
                                    }
                                  },
                                )),
                          ],
                        ));
                  }
                  return CircularProgressIndicator();
                })));
  }

  void updateOnFS() async {
    await fs.collection('delivery_board').doc(widget.id).update({
      'title': titleInput.text,
      'contents': contentInput.text,
      'time': formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]) +
          " " +
          timeInput.text +
          ":00",
      'limitedMember': int.parse(memberInput.text),
      'food': foodInput.text,
      'location': locationInput.text,
      'tags': tagInput.text,
      'gender': gender
    });
  }
}
