import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:usdh/login/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:usdh/chat/chatting.dart';

late deliveryWriteState pageState;
late deliveryListState pageState2;
late deliveryShowState pageState3;
late deliveryModifyState pageState4;

bool is_available(String time, int n1, int n2){
    if(n1 >= n2){
      return false;
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
                            controller: timeInput,
                            decoration: InputDecoration(hintText: "마감 시간 입력 : xx:xx (ex 21:32 형태)"),
                            validator : (text){
                            if(text == null || text.isEmpty){
                              return "마감 시간은 필수 입력 사항입니다.";
                            }
                            return null;
                            }
                        ),
                        TextFormField(
                            controller: memberInput,
                            decoration: InputDecoration(hintText: "인원을 입력하세요. (숫자 형태)"),
                            validator : (text){
                            if(text == null || text.isEmpty){
                              return "인원은 필수 입력 사항입니다.";
                            }
                            return null;
                            }
                        ),
                        TextFormField(
                            controller: foodInput,
                            decoration: InputDecoration(hintText: "음식 종류를 입력하세요."),
                            validator : (text){
                            if(text == null || text.isEmpty){
                              return "음식 종류는 필수 입력 사항입니다.";
                            }
                            return null;
                            }
                        ),
                        TextFormField(
                            controller: locationInput,
                            decoration: InputDecoration(hintText: "위치를 입력하세요."),
                            validator : (text){
                            if(text == null || text.isEmpty){
                              return "위치는 필수 입력 사항입니다.";
                            }
                            return null;
                            }
                        ),
                        TextFormField(
                            controller: tagInput,
                            decoration: InputDecoration(hintText: "태그를 입력하세요."),
                            validator : (text){
                            if(text == null || text.isEmpty){
                              return "태그는 필수 입력 사항입니다.";
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
        'currentMember' : 1, 'limitedMember' : int.parse(memberInput.text), 'food' : foodInput.text, 'location' : locationInput.text, 'tags' : tagInput.text, 'gender' : gender});
    fp.updateIntInfo('postcount', 1);
  }
}


class deliveryList extends StatefulWidget{
  @override
  deliveryListState createState() {
    pageState2 = deliveryListState();
    return pageState2;
  }
}

class deliveryListState extends State<deliveryList>{
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
        
            return ListView(
              children: snapshot.data!.docs.map((doc) {
                String title = doc['title'];
                String tags = doc['tags'];
                return Column(children: [
                  Padding(padding: EdgeInsets.fromLTRB(10, 15, 10, 15)),
                  InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => deliveryShow(doc.id)));
                    },
                    child: Container(
                      margin: EdgeInsets.fromLTRB(50, 10, 10, 10),
                      child: Row(
                        children: [
                          //제목
                          Text(title.toString(),
                              style: TextStyle(
                                  fontFamily: "SCDream",
                                  fontWeight: FontWeight.w600,
                                  fontSize: 20)),
                          SizedBox(
                            width: 20,
                          ),

                          //모집중, 모집완료 표시
                          is_available(doc['time'], doc['currentMember'], doc['limitedMember']) ? Text("모집중") : Text("모집완료"),

                          PopupMenuButton(
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
                                                  peerAvatar:
                                                      doc['photoUrl'],
                                            )));
                                  },
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  //태그
                  Text(tags.toString(),
                    style: TextStyle(
                    fontSize: 19, color: Colors.blueGrey)),
                  Divider(
                    thickness: 2,
                    color: Colors.blue[200],
                  ),
                ]);
              }).toList()
            );
        }),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => deliveryWrite()));
          }),
    );
  }
}

class deliveryShow extends StatefulWidget{
  deliveryShow(this.id);
  final String id;

  @override
  deliveryShowState createState(){
    pageState3 = deliveryShowState();
    return pageState3;
  }
}

class deliveryShowState extends State<deliveryShow>{
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
                  Text(snapshot.data!['tags']),
                  Text(snapshot.data!['title']),
                  Text("마감 " + formatDate(DateTime.parse(snapshot.data!['time']), [HH, ':', nn])),
                  Divider(color: Colors.black,),
                  Text(formatDate(DateTime.parse(snapshot.data!['time']), [HH, ':', nn])),
                  Text(snapshot.data!['currentMember'].toString()+"/"+snapshot.data!['limitedMember'].toString()),
                  Text(snapshot.data!['food']),
                  Text(snapshot.data!['location']),
                  Text(snapshot.data!['gender']),
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
                          Navigator.push(context, MaterialPageRoute(builder: (context) => deliveryModify(widget.id)));
                          setState(() {
                            
                          });
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
                          await fs.collection('delivery_board').doc(widget.id).delete();
                          fp.updateIntInfo('postcount', -1);
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
                      Text(snapshot.data!['tags']),
                      Text(snapshot.data!['title']),
                      Text("마감 " + formatDate(DateTime.parse(snapshot.data!['time']), [HH, ':', nn])),
                      Divider(color: Colors.black,),
                      Text(formatDate(DateTime.parse(snapshot.data!['time']), [HH, ':', nn])),
                      Text(snapshot.data!['currentMember'].toString()+"/"+snapshot.data!['limitedMember'].toString()),
                      Text(snapshot.data!['food']),
                      Text(snapshot.data!['location']),
                      Text(snapshot.data!['gender']),
                      Divider(color: Colors.black,),
                      Text(snapshot.data!['contents']),
                      // 참가, 손절
                      Row(
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
                                    'joiningIn': FieldValue.arrayUnion(roomName)
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
                );
              }
            }
            return CircularProgressIndicator();
          }
        )
    );
  }

}

class deliveryModify extends StatefulWidget{
  deliveryModify(this.id);
  final String id;
  @override
  State<StatefulWidget> createState() {
    pageState4 = deliveryModifyState();
    return pageState4;
  }
}

class deliveryModifyState extends State<deliveryModify>{
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
            timeInput = TextEditingController(text : formatDate(DateTime.parse(snapshot.data!['time']), [HH, ':', nn]));
            memberInput = TextEditingController(text: snapshot.data!['limitedMember'].toString());
            foodInput = TextEditingController(text: snapshot.data!['food']);
            locationInput = TextEditingController(text: snapshot.data!['location']);
            tagInput = TextEditingController(text: snapshot.data!['tags']);
            return Form(key: _formKey,
              child: 
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  TextFormField(
                      controller: tagInput,
                      decoration: InputDecoration(hintText: "태그를 입력하세요."),
                      validator : (text){
                      if(text == null || text.isEmpty){
                        return "태그는 필수 입력 사항입니다.";
                      }
                      return null;
                      }
                  ),
                  TextFormField(
                      controller: titleInput,
                      decoration: InputDecoration(hintText: "제목을 입력하세요."),
                      validator : (text){
                      if(text == null || text.isEmpty){
                        return "제목은 필수 입력 사항입니다.";
                      }
                      return null;
                      }
                  ),
                  Divider(
                    color: Colors.black,
                  ),
                  TextFormField(
                      controller: timeInput,
                      decoration: InputDecoration(hintText: "마감 시간 입력 : xx:xx (ex 21:32 형태)"),
                      validator : (text){
                      if(text == null || text.isEmpty){
                        return "마감 시간은 필수 입력 사항입니다.";
                      }
                      return null;
                      }
                  ),
                  TextFormField(
                      controller: memberInput,
                      decoration: InputDecoration(hintText: "인원을 입력하세요. (숫자 형태)"),
                      validator : (text){
                      if(text == null || text.isEmpty){
                        return "인원은 필수 입력 사항입니다.";
                      }
                      return null;
                      }
                  ),
                  TextFormField(
                      controller: foodInput,
                      decoration: InputDecoration(hintText: "음식 종류를 입력하세요."),
                      validator : (text){
                      if(text == null || text.isEmpty){
                        return "음식 종류는 필수 입력 사항입니다.";
                      }
                      return null;
                      }
                  ),
                  TextFormField(
                      controller: locationInput,
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
                  //내용 수정
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
                  Divider(
                    color: Colors.black,
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
                          if(_formKey.currentState!.validate()){
                            updateOnFS();
                            Navigator.pop(context);
                          }
                        },
                      )
                  ),
                ],
              )
            );
          }
          return CircularProgressIndicator();
        }
    ));
  }

  void updateOnFS() async {
    await fs.collection('delivery_board').doc(widget.id).update({'title' : titleInput.text, 'contents': contentInput.text, 'time' : formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd])+" "+timeInput.text+":00",
      'limitedMember' : int.parse(memberInput.text), 'food' : foodInput.text, 'location' : locationInput.text, 'tags' : tagInput.text, 'gender' : gender});
  }
}