import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:usodha/firebase_provider.dart';
import 'package:provider/provider.dart';

late WriteBoardState pageState;

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
  TextEditingController input = TextEditingController();
  String imageurl = "";
  final _picker = ImagePicker();
  FirebaseStorage storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);

    return Scaffold(
        appBar: AppBar(title: Text("게시판 글쓰기")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              TextField(
                controller: input,
                decoration: InputDecoration(hintText: "내용을 입력하세요."),
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
                    },
                  )
                ],
              ),
              Divider(
                color: Colors.black,
              ),
              SizedBox(
                height: 250,
                width: 250,
                child: Image.network(imageurl),
              )
            ],
          ),
        ));
  }

  void uploadImage(ImageSource src) async {
    PickedFile? pickimg = await _picker.getImage(source: src);

    if (pickimg == null) return;
    setState(() {
      img = File(pickimg.path);
    });

    Reference ref = storage.ref().child('board/${fp.getUser()!.uid}');
    await ref.putFile(img);

    String URL = await ref.getDownloadURL();

    setState(() {
      imageurl = URL;
    });
  }
}
