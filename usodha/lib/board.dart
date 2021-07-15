import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:login_test/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

late WriteBoardState pageState;
late ListBoardState pageState2;
late showBoardState pageState3;

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
  String imageurl = "";
  final _picker = ImagePicker();
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseFirestore fs = FirebaseFirestore.instance;

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
                margin:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                child: TextField(
                  controller: titleInput,
                  decoration: InputDecoration(hintText: "제목을 입력하세요."),
                ),
              ),
              Container(
                height: 50,
                margin:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                child: TextField(
                  controller: contentInput,
                  decoration: InputDecoration(hintText: "내용을 입력하세요."),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                      child: Text("카메라로 촬영하기"),
                      onPressed: () {
                        uploadImage(ImageSource.camera);
                      }),
                  ElevatedButton(
                      child: Text("갤러리에서 불러오기"),
                      onPressed: () {
                        uploadImage(ImageSource.gallery);
                      }),
                ],
              ),
              Divider(
                color: Colors.black,
              ),
              Container(
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 200,
                      width: 200,
                      child: Image.network(imageurl),
                    ),
                  ],
                ),
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

  void uploadImage(ImageSource src) async {
    PickedFile? pickimg = await _picker.getImage(source: src);

    var tmp = fp.getInfo();

    if (pickimg == null) return;
    setState(() {
      img = File(pickimg.path);
    });

    Reference ref =
        storage.ref().child('board/${fp.getUser()!.uid + tmp['piccount']}');
    await ref.putFile(img);

    fp.updateIntInfo('piccount', 1);

    String url = await ref.getDownloadURL();

    setState(() {
      imageurl = url;
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
      'pic': imageurl
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
                  children: snapshot.data!.docs
                      .map((doc) => new ListTile(
                            title: new Text(doc['title']),
                            subtitle: new Text(doc['writer']),
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => showBoard(doc.id))),
                          ))
                      .toList());
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
  late FirebaseProvider fp;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore fs = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();

    return Scaffold(
        appBar: AppBar(
          title: Text("게시글 내용"),
        ),
        body: StreamBuilder(
            stream: fs.collection('posts').doc(widget.id).snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData) {
                return Column(
                  children: [
                    Text(snapshot.data!['title']),
                    Text(snapshot.data!['contents']),
                    Text(snapshot.data!['writer']),
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
                          FocusScope.of(context).requestFocus(new FocusNode());
                          fs
                              .collection('posts')
                              .doc(widget.id)
                              .delete()
                              .then((value) => Navigator.pop(context));
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                );
              }
              return CircularProgressIndicator();
            }));
  }
}
