import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:login_test/login/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:login_test/chatting.dart';

late WriteBoardState pageState;
late ListBoardState pageState2;
late showBoardState pageState3;
late modifyBoardState pageState4;

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
                child: TextField(
                  controller: titleInput,
                  decoration: InputDecoration(hintText: "제목을 입력하세요."),
                ),
              ),
              Container(
                height: 50,
                child: TextField(
                  controller: contentInput,
                  decoration: InputDecoration(hintText: "내용을 입력하세요."),
                ),
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
                      uploadOnFS(titleInput.text, contentInput.text);
                      Navigator.pop(context);
                    },
                  ))
            ],
          ),
        ));
  }

  void uploadImage() async {
    final pickedImgList = await _picker.pickMultiImage();

    List<String> pickUrlList = [];

    var tmp = fp.getInfo();

    late Reference ref;
    for (int i = 0; i < pickedImgList!.length; i++) {
      ref = storage
          .ref()
          .child('board/${tmp['name'] + tmp['piccount'].toString()}');
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
    await fs
        .collection('posts')
        .doc(tmp['name'] + tmp['postcount'].toString())
        .set({
      'title': txt1,
      'writer': tmp['name'],
      'contents': txt2,
      'pic': urlList,
      // 수정 - currentMember, limitedMeber, email, photoUrl, postName 추가
      'currentMember': 1,
      'limitedMember': int.parse(limitedMember.text),
      'email': tmp['email'],
      'photoUrl': tmp['photoUrl'],
      'postName': tmp['name'] + tmp['postcount'].toString(),
    });
    fp.updateIntInfo('postcount', 1);
  }
}

class ListBoard extends StatefulWidget {
  @override
  ListBoardState createState() {
    pageState2 = ListBoardState();
    return pageState2;
  }
}

class ListBoardState extends State<ListBoard> {
  final Stream<QuerySnapshot> colstream =
      FirebaseFirestore.instance.collection('posts').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(title: Text("게시글 목록")),
        body: StreamBuilder<QuerySnapshot>(
            stream: colstream,
            builder:
                (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }

              return new ListView(
                  children: snapshot.data!.docs.map((doc) {
                String _title = doc['title'] +
                    '[' +
                    doc['currentMember'].toString() +
                    '/' +
                    doc['limitedMember'].toString() +
                    ']';
                String _subtitle = doc['writer'];
                return new ListTile(
                  title: new Text(_title),
                  subtitle: new Text(_subtitle),
                  trailing: PopupMenuButton(
                    itemBuilder: (BuildContext context) => [
                      PopupMenuItem(
                        child: TextButton(
                          child: Text(
                            "채팅시작",
                            style: TextStyle(color: Colors.black),
                          ),
                          onPressed: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => Chat(
                                          peerId: doc['email'],
                                          peerAvatar: doc['photoUrl'],
                                        )));
                          },
                        ),
                      ),
                    ],
                  ),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => showBoard(doc.id))),
                );
              }).toList());
            }));
  }
}

class showBoard extends StatefulWidget {
  showBoard(this.id);
  final String id;

  @override
  showBoardState createState() {
    pageState3 = showBoardState();
    return pageState3;
  }
}

class showBoardState extends State<showBoard> {
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
              }

              if (snapshot.hasData) {
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
                                    return Image.network(
                                        snapshot.data!['pic'][idx]);
                                  }),
                            ),
                      // 글 수정, 삭제 버튼
                      Row(
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
                                            modifyBoard(widget.id)));
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
                              onPressed: () {
                                Navigator.pop(context);
                                fs.collection('posts').doc(widget.id).delete();
                              },
                            ),
                          ),
                        ],
                      ),
                      // 모임 참가, 손절 버튼
                      Row(
                        children: [
                          // 참가 버튼을 누르면 현재 인원+1, 제한 넘으면 불가
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
                                int _currentMember =
                                    snapshot.data!['currentMember'];
                                int _limitedMember =
                                    snapshot.data!['limitedMember'];

                                // 제한 인원 꽉 찰 경우
                                if (_currentMember >= _limitedMember) {
                                  print('This room is full');
                                }
                                // 인원이 남을 경우
                                else {
                                  await FirebaseFirestore.instance
                                      .collection('posts')
                                      .doc(snapshot.data!['postName'])
                                      .update({
                                    'currentMember': _currentMember + 1
                                  });
                                  print('참가!!');
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
                                int _currentMember =
                                    snapshot.data!['currentMember'];
                                int _limitedMember =
                                    snapshot.data!['limitedMember'];

                                // 모임에 2명 이상, 제한 인원 이하로 남을 경우
                                if (_currentMember >= 2 &&
                                    _currentMember <= _limitedMember) {
                                  await FirebaseFirestore.instance
                                      .collection('posts')
                                      .doc(snapshot.data!['postName'])
                                      .update({
                                    'currentMember': _currentMember - 1
                                  });
                                  print('손절!!');
                                }
                                // 남은 인원이 1명일 경우
                                else if (_currentMember == 1) {
                                  Navigator.pop(context);
                                  fs
                                      .collection('posts')
                                      .doc(widget.id)
                                      .delete();
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
                      )
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
                                    return Image.network(
                                        snapshot.data!['pic'][idx]);
                                  }),
                            ),
                    ],
                  );
                }
              }
              return CircularProgressIndicator();
            }));
  }
}

class modifyBoard extends StatefulWidget {
  modifyBoard(this.id);
  final String id;
  @override
  State<StatefulWidget> createState() {
    pageState4 = modifyBoardState();
    return pageState4;
  }
}

class modifyBoardState extends State<modifyBoard> {
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
                titleInput =
                    TextEditingController(text: snapshot.data!['title']);
                contentInput =
                    TextEditingController(text: snapshot.data!['contents']);
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: 30,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 50),
                      child: TextField(
                        controller: titleInput,
                      ),
                    ),
                    Container(
                      height: 50,
                      margin: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 50),
                      child: TextField(
                        controller: contentInput,
                      ),
                    ),
                    Divider(
                      color: Colors.black,
                    ),
                    Container(
                        height: 30,
                        margin:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                            updateOnFS(titleInput.text, contentInput.text);
                            Navigator.pop(context);
                          },
                        ))
                  ],
                );
              }
              return CircularProgressIndicator();
            }));
  }

  void updateOnFS(String txt1, String txt2) async {
    await fs
        .collection('posts')
        .doc(widget.id)
        .update({'title': txt1, 'contents': txt2});
  }
}
