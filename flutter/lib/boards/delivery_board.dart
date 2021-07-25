import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:login_test/login/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';

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
  TextEditingController timeInput = TextEditingController();
  TextEditingController memberInput = TextEditingController();
  TextEditingController foodInput = TextEditingController();
  TextEditingController locationInput = TextEditingController();
  final _picker = ImagePicker();
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseFirestore fs = FirebaseFirestore.instance;
  List urlList = [];
  String gender = "";

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    setState(() {
      gender = "여자";
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
            child: 
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                      height: 30,
                      child: TextFormField(
                            controller: titleInput,
                            decoration: InputDecoration(hintText: "제목을 입력하세요."),
                            validator : (text){
                            if(text == null || text.isEmpty){
                              return "제목은 필수 입력 사항입니다.";
                            }
                            return null;
                            }
                            ),
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
                            controller: titleInput,
                            decoration: InputDecoration(hintText: "마감 시간 입력 : xx:xx (ex 21:32 형태)"),
                            validator : (text){
                            if(text == null || text.isEmpty){
                              return "마감 시간은 필수 입력 사항입니다.";
                            }
                            return null;
                            }
                        ),
                        TextFormField(
                            controller: titleInput,
                            decoration: InputDecoration(hintText: "인원을 입력하세요. (숫자 형태)"),
                            validator : (text){
                            if(text == null || text.isEmpty){
                              return "인원은 필수 입력 사항입니다.";
                            }
                            return null;
                            }
                        ),
                        TextFormField(
                            controller: titleInput,
                            decoration: InputDecoration(hintText: "음식 종류를 입력하세요."),
                            validator : (text){
                            if(text == null || text.isEmpty){
                              return "음식 종류는 필수 입력 사항입니다.";
                            }
                            return null;
                            }
                        ),
                        TextFormField(
                            controller: titleInput,
                            decoration: InputDecoration(hintText: "위치를 입력하세요."),
                            validator : (text){
                            if(text == null || text.isEmpty){
                              return "위치는 필수 입력 사항입니다.";
                            }
                            return null;
                            }
                        ),
                        Row(
                          children: [
                            Padding(padding: EdgeInsets.fromLTRB(0, 60, 0, 0)),
                            Radio(
                                value: "여자만",
                                groupValue: gender,
                                onChanged: (String? value){
                                  setState(() {
                                    gender = value!;
                                  });
                                }
                            ),
                            Text("여자만"),
                            Radio(
                                value: "남자만",
                                groupValue: gender,
                                onChanged: (String? value){
                                  setState(() {
                                    gender = value!;
                                  });
                                }
                            ),
                            Text("남자만"),
                            Radio(
                                value: "상관없음",
                                groupValue: gender,
                                onChanged: (String? value){
                                  setState(() {
                                    gender = value!;
                                  });
                                }
                            ),
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
                      child:
                        TextFormField(
                            controller: contentInput,
                            decoration: InputDecoration(hintText: "내용을 입력하세요."),
                            validator : (text){
                            if(text == null || text.isEmpty){
                              return "내용은 필수 입력 사항입니다.";
                            }
                            return null;
                          }
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
                          if(_formKey.currentState!.validate()){
                            uploadOnFS();
                            Navigator.pop(context);
                          }
                        },
                    )
                  )
                ],
              ),
          )
        ));
  }

  void uploadOnFS() async {
    var tmp = fp.getInfo();
    await fs
        .collection('delivery_board')
        .doc(tmp['name'] + tmp['postcount'].toString())
        .set({'title' : titleInput.text, 'writer': tmp['name'], 'contents': contentInput.text, 'time' : formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd])+" "+timeInput.text+":00",
        'now' : 0, 'limit' : int.parse(memberInput.text), 'food' : foodInput.text, 'location' : locationInput.text, 'gender' : gender});
    fp.updateIntInfo('postcount', 1);
  }
}


class ListBoard extends StatefulWidget{
  @override
  ListBoardState createState() {
    pageState2 = ListBoardState();
    return pageState2;
  }
}

class ListBoardState extends State<ListBoard>{
  final Stream<QuerySnapshot> colstream = FirebaseFirestore.instance.collection('delivery_board').snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("게시글 목록")),
      body: 
        StreamBuilder<QuerySnapshot>(
          stream: colstream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
        
            return new ListView(
              children: snapshot.data!.docs.map((doc) => new ListTile(
                title: new Text(doc['title']),
                // subtitle: new Text(doc['writer']),
                onTap: () => Navigator.push(context,
                  MaterialPageRoute(builder: (context) => showBoard(doc.id))),
                trailing: is_available(doc['time'], doc['now'], doc['limit']) ? Text("모집중") : Text("모집완료"),
              )).toList()
            );
        })
    );
  }

  bool is_available(String time, int n1, int n2){
    if(n1 < n2){
      return true;
    }

    String now = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
    DateTime d1 = DateTime.parse(now);
    DateTime d2 = DateTime.parse(time);
    Duration diff = d1.difference(d2);
    if(diff.isNegative){
      return true;
    }
    else{
      return false;
    }
  }
}

class showBoard extends StatefulWidget{
  showBoard(this.id);
  final String id;

  @override
  showBoardState createState(){
    pageState3 = showBoardState();
    return pageState3;
  }
}

class showBoardState extends State<showBoard>{
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
      appBar: AppBar(title: Text("게시글 내용"),),
      body:
        StreamBuilder(
          stream : fs.collection('delivery_board').doc(widget.id).snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot>snapshot){
            fp.setInfo();

            if (snapshot.hasData && !snapshot.data!.exists) {
              return CircularProgressIndicator();
            }

            else if(snapshot.hasData){
              fp.setInfo();
              if(fp.getInfo()['name'] == snapshot.data!['writer']){
                return Column(
                  children: [
                  Text(snapshot.data!['title']),
                  Divider(color: Colors.black,),
                  Text(snapshot.data!['time']),
                  Text(snapshot.data!['time']),
                  Text(snapshot.data!['time']),
                  Text(snapshot.data!['time']), //07-25 20:16
                  Divider(color: Colors.black,),
                  Text(snapshot.data!['contents']),
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
                          Navigator.push(context, MaterialPageRoute(builder: (context) => modifyBoard(widget.id)));
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
                          for(int i = 0; i < snapshot.data!['pic'].length; i++){
                            await storage.refFromURL(snapshot.data!['pic'][i]).delete();
                          }
                          await fs.collection('delivery_board').doc(widget.id).delete();
                        },
                      ),
                    ),
                  ],
                  )
                  ],
                );
              }

              else{
                return Column(
                  children: [
                  Text(snapshot.data!['title']),
                  Divider(color: Colors.black,),

                  Divider(color: Colors.black,),
                  Text(snapshot.data!['contents']),
                  ],
                );
              }
            }
            return CircularProgressIndicator();
          }
        )
    );
  }

}

class modifyBoard extends StatefulWidget{
  modifyBoard(this.id);
  final String id;
  @override
  State<StatefulWidget> createState() {
    pageState4 = modifyBoardState();
    return pageState4;
  }
}

class modifyBoardState extends State<modifyBoard>{
  final FirebaseFirestore fs = FirebaseFirestore.instance;
  late TextEditingController titleInput;
  late TextEditingController contentInput;

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(title: Text("게시물 수정")),
      body:
        StreamBuilder(
        stream : fs.collection('delivery_board').doc(widget.id).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot>snapshot) {
          if (snapshot.hasData && !snapshot.data!.exists) {
            return CircularProgressIndicator();
          }
          if(snapshot.hasData){
            titleInput = TextEditingController(text: snapshot.data!['title']);
            contentInput = TextEditingController(text: snapshot.data!['contents']);
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                    height: 30,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                    child: TextField(
                          controller: titleInput,
                        ),
                    ),
                Container(
                    height: 50,
                    margin:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                    child:
                      TextField(
                          controller: contentInput,
                      ),
                    ),
                Divider(
                  color: Colors.black,
                ),
                snapshot.data!['pic'].isEmpty ? 
                  Container():
                  Container(
                    height : 300,
                    child:
                      ListView.builder(
                      itemCount: snapshot.data!['pic'].length,
                      itemBuilder: (BuildContext context, int idx){
                        return Image.network(snapshot.data!['pic'][idx]);
                      }
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
                        "게시물 수정",
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        updateOnFS(titleInput.text, contentInput.text);
                        Navigator.pop(context);
                      },
                    )
                ),
              ],
            );
          }
          return CircularProgressIndicator();
        }
    ));
  }

  void updateOnFS(String txt1, String txt2) async {
    await fs.collection('delivery_board').doc(widget.id).update({'title' : txt1,
    'contents' : txt2});
  }
}