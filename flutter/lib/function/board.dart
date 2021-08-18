import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:usdh/login/firebase_provider.dart';
import 'package:usdh/chat/home.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

late WriteBoardState pageState;
late ListBoardState pageState2;
late ShowBoardState pageState3;
late ModifyBoardState pageState4;

/* ---------------------- Write Board ---------------------- */

class WriteBoard extends StatefulWidget {
  @override
  WriteBoardState createState() {
    pageState = WriteBoardState();
    return pageState;
  }
}

class WriteBoardState extends State<WriteBoard> {
  late File img;
  late FirebaseProvider fp;
  TextEditingController titleInput = TextEditingController();
  TextEditingController contentInput = TextEditingController();
  TextEditingController limitedMember = TextEditingController();
  final _picker = ImagePicker();
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseFirestore fs = FirebaseFirestore.instance;
  List urlList = [];

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    titleInput.dispose();
    contentInput.dispose();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                      child: Text("갤러리에서 불러오기"),
                      onPressed: () {
                        uploadImage();
                      }),
                ],
              ),
              Divider(
                color: Colors.black,
              ),
              urlList.isEmpty
                  ? Container()
                  : Container(
                      height: 300,
                      child: ListView.builder(
                          itemCount: urlList.length,
                          itemBuilder: (BuildContext context, int idx) {
                            return Image.network(urlList[idx]);
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
                        uploadOnFS(titleInput.text, contentInput.text);
                        Navigator.pop(context);
                      }
                    },
                  ))
            ],
          ),
        )));
  }

  void uploadImage() async {
    final pickedImgList = await _picker.pickMultiImage();

    List<String> pickUrlList = [];

    var tmp = fp.getInfo();

    late Reference ref;
    for (int i = 0; i < pickedImgList!.length; i++) {
      ref = storage.ref().child('board/${tmp['nick'] + tmp['piccount'].toString()}');
      await ref.putFile(File(pickedImgList[i].path));
      fp.updateIntInfo('piccount', 1);
      String url = await ref.getDownloadURL();
      pickUrlList.add(url);
    }

    setState(() {
      urlList = pickUrlList;
    });
  }

  void uploadOnFS(String txt1, String txt2) async {
    var tmp = fp.getInfo();
    await fs.collection('posts').doc(tmp['nick'] + tmp['postcount'].toString()).set({
      'title': txt1,
      'writer': tmp['nick'],
      'contents': txt2,
      'pic': urlList,
      'currentMember': 1,
      'limitedMember': int.parse(limitedMember.text),
      'email': tmp['email'],
      'photoUrl': tmp['photoUrl'],
      'postName': tmp['nick'] + tmp['postcount'].toString(),
      'views': 0,
    });
    fp.updateIntInfo('postcount', 1);
  }
}

/* ---------------------- Board List ---------------------- */

class ListBoard extends StatefulWidget {
  @override
  ListBoardState createState() {
    pageState2 = ListBoardState();
    return pageState2;
  }
}

class ListBoardState extends State<ListBoard> {
  final Stream<QuerySnapshot> colstream = FirebaseFirestore.instance.collection('posts').snapshots();
  late FirebaseProvider fp;

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
          stream: colstream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            return Column(children: [
              cSizedBox(25, 0),
              Container(
                //decoration: BoxDecoration(border: Border(bottom: BorderSide(width: 3, color: Colors.blueGrey))),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: Icon(Icons.navigate_before),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                    Text(
                      "택시",
                      style: TextStyle(color: Colors.blueGrey, fontSize: 21, fontFamily: "SCDream", fontWeight: FontWeight.w500),
                    ),
                    cSizedBox(0, 50),
                    Wrap(
                      spacing: -5,
                      children: [
                        IconButton(
                          icon: Icon(Icons.map),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.refresh),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.search),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.message),
                          onPressed: () {
                            var tmp = fp.getInfo();
                            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(myId: tmp['email'])));
                          },
                        ),
                      ],
                    )
                  ],
                ),
              ),
              CustomPaint(
                size: Size(400, 4),
                painter: CurvePainter(),
              ),
              Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 25, 0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
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
                      String title = doc['title'] + '[' + doc['currentMember'].toString() + '/' + doc['limitedMember'].toString() + ']';
                      String writer = doc['writer'];
                      //String tags = doc['tags'];
                      return Column(children: [
                        Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                        InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ShowBoard(doc.id)));
                              FirebaseFirestore.instance.collection('posts').doc(doc.id).update({"views": doc["views"] + 1});
                            },
                            child: Container(
                                margin: EdgeInsets.fromLTRB(50, 17, 10, 0),
                                child: Column(children: [
                                  Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                    Text("#태그 #예시", style: TextStyle(fontFamily: "SCDream", color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: 13)),
                                    cSizedBox(0, 180),
                                    //is_available(doc['time'], doc['currentMember'], doc['limitedMember']) ? Text("모집중") : Text("모집완료"),
                                    Text("모집상태", style: TextStyle(fontFamily: "SCDream", color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: 12)),
                                  ]),
                                  Row(children: [
                                    Text(title.toString(), style: TextStyle(fontFamily: "SCDream", fontWeight: FontWeight.w600, fontSize: 18)),
                                    cSizedBox(70, 20),
                                    Text(writer.toString(), style: TextStyle(fontSize: 19, color: Colors.blueGrey)),
                                  ])
                                ])))
                      ]);
                    }),
              )),
            ]);
          }),
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => WriteBoard()));
          }),
    );
  }

  Widget cSizedBox(double h, double w) {
    return SizedBox(
      height: h,
      width: w,
    );
  }
}

/* ---------------------- Show Board ---------------------- */

class ShowBoard extends StatefulWidget {
  ShowBoard(this.id);
  final String id;

  @override
  ShowBoardState createState() {
    pageState3 = ShowBoardState();
    return pageState3;
  }
}

class ShowBoardState extends State<ShowBoard> {
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
        appBar: AppBar(
          title: Text("게시글 내용"),
        ),
        body: StreamBuilder(
            stream: fs.collection('posts').doc(widget.id).snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              fp.setInfo();
              if (snapshot.hasData && !snapshot.data!.exists) {
                return CircularProgressIndicator();
              } else if (snapshot.hasData) {
                fp.setInfo();
                if (fp.getInfo()['nick'] == snapshot.data!['writer']) {
                  return Column(
                    children: [
                      Text(snapshot.data!['title']),
                      Text(snapshot.data!['contents']),
                      Text(snapshot.data!['writer']),
                      snapshot.data!['pic'].isEmpty
                          ? Container()
                          : Container(
                              height: 300,
                              child: ListView.builder(
                                  itemCount: snapshot.data!['pic'].length,
                                  itemBuilder: (BuildContext context, int idx) {
                                    return Image.network(snapshot.data!['pic'][idx]);
                                  }),
                            ),
                      // 수정, 삭제
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.purple[300],
                              ),
                              child: Text(
                                "수정",
                                style: TextStyle(color: Colors.white),
                              ),
                              onPressed: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ModifyBoard(widget.id)));
                                setState(() {});
                              },
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                                for (int i = 0; i < snapshot.data!['pic'].length; i++) {
                                  await storage.refFromURL(snapshot.data!['pic'][i]).delete();
                                  fp.updateIntInfo('piccount', -1);
                                }
                                await fs.collection('posts').doc(widget.id).delete();
                                fp.updateIntInfo('postcount', -1);
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                } else {
                  return Column(
                    children: [
                      Text(snapshot.data!['title']),
                      Text(snapshot.data!['contents']),
                      Text(snapshot.data!['writer']),
                      snapshot.data!['pic'].isEmpty
                          ? Container()
                          : Container(
                              height: 300,
                              child: ListView.builder(
                                  itemCount: snapshot.data!['pic'].length,
                                  itemBuilder: (BuildContext context, int idx) {
                                    return Image.network(snapshot.data!['pic'][idx]);
                                  }),
                            ),
                      // 참가, 손절
                      Row(
                        children: [
                          // 참가 버튼을 누르면 currentMember+1, 제한 넘으면 불가
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                                int _currentMember = snapshot.data!['currentMember'];
                                int _limitedMember = snapshot.data!['limitedMember'];
                                String _roomName = snapshot.data!['postName'];

                                List<String> _joiningRoom = [];
                                await FirebaseFirestore.instance.collection('users').doc(tmp['email']).get().then((value) {
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
                                  await FirebaseFirestore.instance.collection('posts').doc(snapshot.data!['postName']).update({'currentMember': _currentMember + 1});
                                  List<String> roomName = [_roomName];
                                  await FirebaseFirestore.instance.collection('users').doc(tmp['email']).update({'joiningIn': FieldValue.arrayUnion(roomName)});
                                  Navigator.pop(context);
                                  print(_roomName + ' 참가!!');
                                }
                              },
                            ),
                          ),
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                                int _currentMember = snapshot.data!['currentMember'];
                                int _limitedMember = snapshot.data!['limitedMember'];
                                String _roomName = snapshot.data!['postName'];

                                List<String> _joiningRoom = [];
                                await FirebaseFirestore.instance.collection('users').doc(tmp['email']).get().then((value) {
                                  for (String room in value['joiningIn']) {
                                    _joiningRoom.add(room);
                                  }
                                });
                                // 방에 참가하지 않은 경우
                                if (!_joiningRoom.contains(_roomName)) {
                                  print('참가하지 않은 방입니다!!');
                                }
                                // 모임에 2명 이상, 제한 인원 이하로 남을 경우
                                else if (_currentMember >= 2 && _currentMember <= _limitedMember) {
                                  await FirebaseFirestore.instance.collection('posts').doc(snapshot.data!['postName']).update({'currentMember': _currentMember - 1});
                                  List<String> roomName = [_roomName];
                                  await FirebaseFirestore.instance.collection('users').doc(tmp['email']).update({'joiningIn': FieldValue.arrayRemove(roomName)});
                                  Navigator.pop(context);
                                  print(_roomName + ' 손절!!');
                                }
                                // 남은 인원이 1명일 경우
                                else if (_currentMember == 1) {
                                  Navigator.pop(context);
                                  fs.collection('posts').doc(widget.id).delete();
                                  List<String> roomName = [_roomName];
                                  await FirebaseFirestore.instance.collection('users').doc(tmp['email']).update({'joiningIn': FieldValue.arrayRemove(roomName)});
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
                  );
                }
              }
              return CircularProgressIndicator();
            }));
  }
}

/* ---------------------- Modify Board ---------------------- */

class ModifyBoard extends StatefulWidget {
  ModifyBoard(this.id);
  final String id;
  @override
  State<StatefulWidget> createState() {
    pageState4 = ModifyBoardState();
    return pageState4;
  }
}

class ModifyBoardState extends State<ModifyBoard> {
  final FirebaseFirestore fs = FirebaseFirestore.instance;
  late TextEditingController titleInput;
  late TextEditingController contentInput;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(title: Text("게시물 수정")),
        body: StreamBuilder(
            stream: fs.collection('posts').doc(widget.id).snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData && !snapshot.data!.exists) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasData) {
                titleInput = TextEditingController(text: snapshot.data!['title']);
                contentInput = TextEditingController(text: snapshot.data!['contents']);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 30,
                      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                      child: TextField(
                        controller: titleInput,
                      ),
                    ),
                    Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                      child: TextField(
                        controller: contentInput,
                      ),
                    ),
                    Divider(
                      color: Colors.black,
                    ),
                    snapshot.data!['pic'].isEmpty
                        ? Container()
                        : Container(
                            height: 300,
                            child: ListView.builder(
                                itemCount: snapshot.data!['pic'].length,
                                itemBuilder: (BuildContext context, int idx) {
                                  return Image.network(snapshot.data!['pic'][idx]);
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
                            "게시물 수정",
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () {
                            FocusScope.of(context).requestFocus(new FocusNode());
                            updateOnFS(titleInput.text, contentInput.text);
                            Navigator.pop(context);
                          },
                        )),
                  ],
                );
              }
              return CircularProgressIndicator();
            }));
  }

  void updateOnFS(String txt1, String txt2) async {
    await fs.collection('posts').doc(widget.id).update({'title': txt1, 'contents': txt2});
  }
}

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.shader = RadialGradient(colors: [Colors.blue.shade100, Colors.deepPurple.shade200]).createShader(Rect.fromCircle(center: Offset(160, 2), radius: 180));
    paint.style = PaintingStyle.fill; // Change this to fill

    var path = Path();

    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, size.height / 2, size.width, 0);
    path.quadraticBezierTo(size.width / 2, -size.height / 2, 0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
