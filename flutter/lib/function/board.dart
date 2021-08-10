import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:usdh/login/firebase_provider.dart';
import 'package:usdh/chat/chatting.dart';
import 'package:usdh/chat/home.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

late WriteBoardState pageState;
late ListBoardState pageState2;
late ShowBoardState pageState3;
late ModifyBoardState pageState4;
late ApplicantListBoardState pageState5;
late ShowApplicantListState pageState6;
late MyApplicationListBoardState pageState7;
late ShowMyApplicationListState pageState8;

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
                child: TextField(
                  controller: limitedMember,
                  decoration: InputDecoration(hintText: "인원을 선택하세요."),
                ),
              ),
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
      ref = storage.ref().child('board/${tmp['name'] + tmp['piccount'].toString()}');
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
    await fs.collection('posts').doc(tmp['name'] + tmp['postcount'].toString()).set({
      'title': txt1,
      'writer': tmp['name'],
      'contents': txt2,
      'pic': urlList,
      'currentMember': 1,
      'limitedMember': int.parse(limitedMember.text),
      'email': tmp['email'],
      'photoUrl': tmp['photoUrl'],
      'postName': tmp['name'] + tmp['postcount'].toString(),
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
                if (fp.getInfo()['name'] == snapshot.data!['writer']) {
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

/* -----------------Applicant Board List -------------------- */

class ApplicantListBoard extends StatefulWidget {
  final String myId;

  ApplicantListBoard({Key? key, required this.myId}) : super(key: key);

  @override
  ApplicantListBoardState createState() {
    pageState5 = ApplicantListBoardState(myId: myId);
    return pageState5;
  }
}

class ApplicantListBoardState extends State<ApplicantListBoard> {
  ApplicantListBoardState({Key? key, required this.myId});

  String myId;

  Stream<QuerySnapshot>? colstream;
  late FirebaseProvider fp;
  final _formKey = GlobalKey<FormState>();
  TextEditingController searchInput = TextEditingController();
  String search = "";
  bool status = false;

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();
    colstream = FirebaseFirestore.instance.collection('users').doc(myId).collection('applicants').snapshots();
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
                      "신청자 목록",
                      style: TextStyle(color: Colors.blueGrey, fontSize: 21, fontFamily: "SCDream", fontWeight: FontWeight.w500),
                    ),
                    cSizedBox(0, 50),
                    Wrap(
                      spacing: -5,
                      children: [
                        IconButton(
                          icon: Image.asset('assets/images/icon/iconmap.png', width: 22, height: 22),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        //새로고침 기능
                        IconButton(
                          icon: Image.asset('assets/images/icon/iconrefresh.png', width: 22, height: 22),
                          onPressed: () {
                            setState(() {
                              colstream = FirebaseFirestore.instance.collection('users').doc(myId).collection('applicants').snapshots();
                              ;
                            });
                          },
                        ),
                        //검색 기능 팝업
                        IconButton(
                          icon: Image.asset('assets/images/icon/iconsearch.png', width: 22, height: 22),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext con) {
                                  return StatefulBuilder(builder: (con, setState) {
                                    return Form(
                                        key: _formKey,
                                        child: AlertDialog(
                                          title: Row(
                                            children: [
                                              Theme(
                                                data: ThemeData(unselectedWidgetColor: Colors.black38),
                                                child: Radio(
                                                    value: "제목",
                                                    activeColor: Colors.black38,
                                                    groupValue: search,
                                                    onChanged: (String? value) {
                                                      setState(() {
                                                        search = value!;
                                                      });
                                                    }),
                                              ),
                                              Text(
                                                "제목 검색",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                ),
                                              ),
                                              Theme(
                                                data: ThemeData(unselectedWidgetColor: Colors.black38),
                                                child: Radio(
                                                    value: "태그",
                                                    activeColor: Colors.black38,
                                                    groupValue: search,
                                                    onChanged: (String? value) {
                                                      setState(() {
                                                        search = value!;
                                                      });
                                                    }),
                                              ),
                                              Text(
                                                "태그 검색",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: TextFormField(
                                              controller: searchInput,
                                              decoration: (search == "제목") ? InputDecoration(hintText: "검색할 제목을 입력하세요.") : InputDecoration(hintText: "검색할 태그를 입력하세요."),
                                              validator: (text) {
                                                if (text == null || text.isEmpty) {
                                                  return "검색어를 입력하지 않으셨습니다.";
                                                }
                                                return null;
                                              }),
                                          actions: <Widget>[
                                            TextButton(
                                                onPressed: () {
                                                  if (_formKey.currentState!.validate()) {
                                                    if (search == "제목") {
                                                      setState(() {
                                                        colstream = FirebaseFirestore.instance.collection('delivery_board').orderBy('title').startAt([searchInput.text]).endAt([searchInput.text + '\uf8ff']).snapshots();
                                                      });
                                                      searchInput.clear();
                                                      Navigator.pop(con);
                                                    } else {
                                                      setState(() {
                                                        colstream = FirebaseFirestore.instance.collection('delivery_board').where('tags_parse', arrayContains: searchInput.text).snapshots();
                                                      });
                                                      searchInput.clear();
                                                      Navigator.pop(con);
                                                    }
                                                  }
                                                },
                                                child: Text("검색")),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(con);
                                                  searchInput.clear();
                                                },
                                                child: Text("취소")),
                                          ],
                                        ));
                                  });
                                });
                          },
                        ),
                        //채팅 기능
                        IconButton(
                          icon: Image.asset('assets/images/icon/iconmessage.png', width: 22, height: 22),
                          onPressed: () {
                            var myInfo = fp.getInfo();
                            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(myId: myInfo['email'])));
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
              // Container or Expanded or Flexible 사용
              Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 25, 0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    FlutterSwitch(
                      width: 50.0,
                      height: 20.0,
                      valueFontSize: 10.0,
                      toggleSize: 15.0,
                      value: status,
                      onToggle: (val) {
                        setState(() {
                          status = val;
                          if (status) {
                            colstream = FirebaseFirestore.instance.collection('delivery_board').where('time', isGreaterThan: formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss])).orderBy("time").snapshots();
                          } else {
                            colstream = FirebaseFirestore.instance.collection('delivery_board').orderBy("write_time", descending: true).snapshots();
                          }
                        });
                      },
                    ),
                    cSizedBox(2, 0),
                    Text(
                      "모집중만 표시",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.indigo.shade300,
                      ),
                    ),
                  ])),
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
                      String where = doc['where'];
                      String id = doc.id;
                      //String title = '';
                      //String tags = doc['tags'];
                      return FutureBuilder(
                          future: getBoardInfo(where, id),
                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                            if (!snapshot.hasData) {
                              return CircularProgressIndicator();
                            } else if (snapshot.hasError) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  'Error: ${snapshot.error}',
                                  style: TextStyle(fontSize: 15),
                                ),
                              );
                            } else {
                              return Column(children: [
                                Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                                InkWell(
                                    onTap: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => ShowApplicantList(doc.id)));
                                    },
                                    child: Container(
                                        margin: EdgeInsets.fromLTRB(50, 17, 10, 0),
                                        child: Column(children: [
                                          Row(children: [
                                            Text(where.toString(), style: TextStyle(fontSize: 19, color: Colors.blueGrey)),
                                            cSizedBox(0, 20),
                                            Text(snapshot.data.toString(), style: TextStyle(fontSize: 19, color: Colors.blueGrey)),
                                          ])
                                        ]))),
                              ]);
                            }
                          });
                    }),
              )),
            ]);
          }),
    );
  }

  Widget cSizedBox(double h, double w) {
    return SizedBox(
      height: h,
      width: w,
    );
  }

  Future<String> getBoardInfo(String where, String id) async {
    String title = '';
    await FirebaseFirestore.instance.collection(where).doc(id).get().then((value) {
      title = value['title'];
    });
    return title;
  }
}

/* ------------------ Show Applicant Board ------------------ */

class ShowApplicantList extends StatefulWidget {
  ShowApplicantList(this.id);
  final String id;

  @override
  ShowApplicantListState createState() {
    pageState6 = ShowApplicantListState();
    return pageState6;
  }
}

class ShowApplicantListState extends State<ShowApplicantList> {
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
          title: Text(widget.id),
        ),
        body: StreamBuilder(
            stream: fs.collection('users').doc(fp.getInfo()['email']).collection('applicants').doc(widget.id).snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              fp.setInfo();
              if (snapshot.hasData && !snapshot.data!.exists) {
                return CircularProgressIndicator();
              } else if (snapshot.hasData) {
                fp.setInfo();
                return Column(
                  children: [
                    Text('board: ' + snapshot.data!['where'].toString()),
                    Expanded(
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
                          itemCount: snapshot.data!.get('isFineForMembers').length,
                          itemBuilder: (context, index) {
                            final List<dynamic> isFineForMembers = snapshot.data!.get('isFineForMembers');
                            final List<dynamic> members = snapshot.data!.get('members');
                            return Column(children: [
                              Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                              Row(
                                children: [
                                  Text(isFineForMembers[index]),
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.purple[300],
                                      ),
                                      child: Text(
                                        "허락",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () async {
                                        var myId = fp.getInfo()['email'];
                                        int currentMember = 0;
                                        int limitedMember = 0;
                                        String peerId = isFineForMembers[index].toString();
                                        String title = widget.id;
                                        String board = snapshot.data!.get('where');

                                        await FirebaseFirestore.instance.collection(board).doc(title).get().then((value) {
                                          currentMember = value['currentMember'];
                                          limitedMember = value['limitedMember'];
                                        });

                                        // 제한 인원을 넘지 않았으면 추가
                                        if (currentMember < limitedMember) {
                                          // board의 정보 수정
                                          await FirebaseFirestore.instance.collection(board).doc(title).update({
                                            'currentMember': currentMember + 1,
                                          });
                                          await FirebaseFirestore.instance.collection('users').doc(myId).collection('applicants').doc(title).update({
                                            'members': FieldValue.arrayUnion([peerId]),
                                            'isFineForMembers': FieldValue.arrayRemove([peerId]),
                                          });
                                          // peer의 정보 수정(참가 신청 제거, 참가한 방 추가)
                                          await FirebaseFirestore.instance.collection('users').doc(peerId).update({
                                            'joiningIn': FieldValue.arrayUnion([title]),
                                            'myApplication': FieldValue.arrayRemove([title]),
                                          });

                                          currentMember += 1;
                                          members.add(peerId);
                                          // 채팅 시작
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Chat(
                                                        myId: myId,
                                                        peerIds: members,
                                                        groupChatId: title,
                                                      )));
                                          print(peerId + '를 ' + title + '에 추가합니다.');
                                        } else {
                                          print('인원이 다 찼습니다!');
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
                                        "거절",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () async {
                                        var myId = fp.getInfo()['email'];
                                        String peerId = isFineForMembers[index].toString();
                                        String title = widget.id;

                                        await FirebaseFirestore.instance.collection('users').doc(myId).collection('applicants').doc(title).update({
                                          'isFineForMembers': FieldValue.arrayRemove([peerId])
                                        });
                                        await FirebaseFirestore.instance.collection('users').doc(peerId).update({
                                          'myApplication': FieldValue.arrayRemove([title])
                                        });
                                        print(peerId);
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ]);
                          }),
                    )),
                  ],
                );
              }
              return CircularProgressIndicator();
            }));
  }
}

/* -----------------Applicant Board List -------------------- */

class MyApplicationListBoard extends StatefulWidget {
  @override
  MyApplicationListBoardState createState() {
    pageState7 = MyApplicationListBoardState();
    return pageState7;
  }
}

class MyApplicationListBoardState extends State<MyApplicationListBoard> {
  Stream<QuerySnapshot> colstream = FirebaseFirestore.instance.collection('delivery_board').snapshots();
  late FirebaseProvider fp;
  final _formKey = GlobalKey<FormState>();
  TextEditingController searchInput = TextEditingController();
  String search = "";
  bool status = false;

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
                      "신청한 글",
                      style: TextStyle(color: Colors.blueGrey, fontSize: 21, fontFamily: "SCDream", fontWeight: FontWeight.w500),
                    ),
                    cSizedBox(0, 50),
                    Wrap(
                      spacing: -5,
                      children: [
                        IconButton(
                          icon: Image.asset('assets/images/icon/iconmap.png', width: 22, height: 22),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                        //새로고침 기능
                        IconButton(
                          icon: Image.asset('assets/images/icon/iconrefresh.png', width: 22, height: 22),
                          onPressed: () {
                            setState(() {
                              colstream = FirebaseFirestore.instance.collection('delivery_board').snapshots();
                            });
                          },
                        ),
                        //검색 기능 팝업
                        IconButton(
                          icon: Image.asset('assets/images/icon/iconsearch.png', width: 22, height: 22),
                          onPressed: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext con) {
                                  return StatefulBuilder(builder: (con, setState) {
                                    return Form(
                                        key: _formKey,
                                        child: AlertDialog(
                                          title: Row(
                                            children: [
                                              Theme(
                                                data: ThemeData(unselectedWidgetColor: Colors.black38),
                                                child: Radio(
                                                    value: "제목",
                                                    activeColor: Colors.black38,
                                                    groupValue: search,
                                                    onChanged: (String? value) {
                                                      setState(() {
                                                        search = value!;
                                                      });
                                                    }),
                                              ),
                                              Text(
                                                "제목 검색",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                ),
                                              ),
                                              Theme(
                                                data: ThemeData(unselectedWidgetColor: Colors.black38),
                                                child: Radio(
                                                    value: "태그",
                                                    activeColor: Colors.black38,
                                                    groupValue: search,
                                                    onChanged: (String? value) {
                                                      setState(() {
                                                        search = value!;
                                                      });
                                                    }),
                                              ),
                                              Text(
                                                "태그 검색",
                                                style: TextStyle(
                                                  fontSize: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                          content: TextFormField(
                                              controller: searchInput,
                                              decoration: (search == "제목") ? InputDecoration(hintText: "검색할 제목을 입력하세요.") : InputDecoration(hintText: "검색할 태그를 입력하세요."),
                                              validator: (text) {
                                                if (text == null || text.isEmpty) {
                                                  return "검색어를 입력하지 않으셨습니다.";
                                                }
                                                return null;
                                              }),
                                          actions: <Widget>[
                                            TextButton(
                                                onPressed: () {
                                                  if (_formKey.currentState!.validate()) {
                                                    if (search == "제목") {
                                                      setState(() {
                                                        colstream = FirebaseFirestore.instance.collection('delivery_board').orderBy('title').startAt([searchInput.text]).endAt([searchInput.text + '\uf8ff']).snapshots();
                                                      });
                                                      searchInput.clear();
                                                      Navigator.pop(con);
                                                    } else {
                                                      setState(() {
                                                        colstream = FirebaseFirestore.instance.collection('delivery_board').where('tags_parse', arrayContains: searchInput.text).snapshots();
                                                      });
                                                      searchInput.clear();
                                                      Navigator.pop(con);
                                                    }
                                                  }
                                                },
                                                child: Text("검색")),
                                            TextButton(
                                                onPressed: () {
                                                  Navigator.pop(con);
                                                  searchInput.clear();
                                                },
                                                child: Text("취소")),
                                          ],
                                        ));
                                  });
                                });
                          },
                        ),
                        IconButton(
                          icon: Image.asset('assets/images/icon/iconmessage.png', width: 22, height: 22),
                          onPressed: () {
                            var myInfo = fp.getInfo();
                            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(myId: myInfo['email'])));
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
              // Container or Expanded or Flexible 사용
              Container(
                  padding: EdgeInsets.fromLTRB(0, 0, 25, 0),
                  child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                    FlutterSwitch(
                      width: 50.0,
                      height: 20.0,
                      valueFontSize: 10.0,
                      toggleSize: 15.0,
                      value: status,
                      onToggle: (val) {
                        setState(() {
                          status = val;
                          if (status) {
                            colstream = FirebaseFirestore.instance.collection('delivery_board').where('time', isGreaterThan: formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss])).orderBy("time").snapshots();
                          } else {
                            colstream = FirebaseFirestore.instance.collection('delivery_board').orderBy("write_time", descending: true).snapshots();
                          }
                        });
                      },
                    ),
                    cSizedBox(2, 0),
                    Text(
                      "모집중만 표시",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.indigo.shade300,
                      ),
                    ),
                  ])),
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
                      if (fp.getInfo()['myApplication'].contains(doc.id)) {
                        String title = doc['title'] + '[' + doc['currentMember'].toString() + '/' + doc['limitedMember'].toString() + ']';
                        String writer = doc['writer'];
                        //String tags = doc['tags'];
                        return Column(children: [
                          Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                          InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => ShowApplicantList(doc.id)));
                              },
                              child: Container(
                                  margin: EdgeInsets.fromLTRB(50, 17, 10, 0),
                                  child: Column(children: [
                                    Row(children: [
                                      Text(title.toString(), style: TextStyle(fontFamily: "SCDream", fontWeight: FontWeight.w600, fontSize: 18)),
                                      cSizedBox(70, 20),
                                      Text(writer.toString(), style: TextStyle(fontSize: 19, color: Colors.blueGrey)),
                                    ])
                                  ])))
                        ]);
                      } else {
                        return Container();
                      }
                    }),
              )),
            ]);
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

/* ------------------ Show Applicant Board ------------------ */

class ShowMyApplicationList extends StatefulWidget {
  ShowMyApplicationList(this.id);
  final String id;

  @override
  ShowMyApplicationListState createState() {
    pageState8 = ShowMyApplicationListState();
    return pageState8;
  }
}

class ShowMyApplicationListState extends State<ShowMyApplicationList> {
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
          title: Text(widget.id),
        ),
        body: StreamBuilder(
            stream: fs.collection('delivery_board').doc(widget.id).snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              fp.setInfo();
              if (snapshot.hasData && !snapshot.data!.exists) {
                return CircularProgressIndicator();
              } else if (snapshot.hasData) {
                fp.setInfo();
                return Column(
                  children: [
                    Text('[' + snapshot.data!['currentMember'].toString() + '/' + snapshot.data!['limitedMember'].toString() + ']'),
                    Text('현재 멤버: ' + snapshot.data!['members'].toString()),
                    Expanded(
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
                          itemCount: snapshot.data!.get('isFineForMembers').length,
                          itemBuilder: (context, index) {
                            final List<dynamic> isFineForMembers = snapshot.data!.get('isFineForMembers');
                            final List<dynamic> members = snapshot.data!.get('members');
                            return Column(children: [
                              Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                              Row(
                                children: [
                                  Text(isFineForMembers[index]),
                                  Container(
                                    margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        primary: Colors.purple[300],
                                      ),
                                      child: Text(
                                        "허락",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () async {
                                        var myId = fp.getInfo()['email'];
                                        int currentMember = snapshot.data!.get('currentMember');
                                        int limitedMember = snapshot.data!.get('limitedMember');
                                        String peerId = isFineForMembers[index].toString();
                                        String title = widget.id;
                                        print(peerId);
                                        print(title);

                                        // 제한 인원을 넘지 않았으면 추가
                                        Navigator.of(context).pop();
                                        if (currentMember < limitedMember) {
                                          // board의 정보 수정
                                          await FirebaseFirestore.instance.collection('delivery_board').doc(title).update({
                                            'members': FieldValue.arrayUnion([peerId]),
                                            'isFineForMembers': FieldValue.arrayRemove([peerId]),
                                            'currentMember': currentMember + 1,
                                          });
                                          // users의 정보 수정
                                          await FirebaseFirestore.instance.collection('users').doc(peerId).update({
                                            'joiningIn': FieldValue.arrayUnion([title]),
                                            'myApplication': FieldValue.arrayRemove([title]),
                                          });

                                          currentMember += 1;
                                          members.add(peerId);
                                          // 채팅 시작
                                          Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) => Chat(
                                                        myId: myId,
                                                        peerIds: members,
                                                        groupChatId: title,
                                                      )));
                                        } else {
                                          print('인원이 다 찼습니다!');
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
                                        "거절",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      onPressed: () async {
                                        String peerId = isFineForMembers[index].toString();
                                        String title = widget.id;

                                        Navigator.of(context).pop();
                                        await FirebaseFirestore.instance.collection('delivery_board').doc(title).update({
                                          'isFineForMembers': FieldValue.arrayRemove([peerId])
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ]);
                          }),
                    )),
                  ],
                );
              }
              return CircularProgressIndicator();
            }));
  }
}
