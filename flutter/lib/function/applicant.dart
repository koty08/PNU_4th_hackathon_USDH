import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:usdh/Widget/widget.dart';
import 'package:usdh/login/firebase_provider.dart';
import 'package:usdh/chat/chatting.dart';
import 'package:usdh/chat/home.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

late ApplicantListBoardState pageState5;
late ShowApplicantListState pageState6;
late MyApplicationListBoardState pageState7;
late ShowMyApplicationListState pageState8;

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
  String title = '';

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();
    colstream = FirebaseFirestore.instance.collection('users').doc(myId).collection('applicants').snapshots();
    return Scaffold(
      body: RefreshIndicator(
        //당겨서 새로고침
        onRefresh: () async {
          setState(() {
            colstream = FirebaseFirestore.instance.collection('users').doc(myId).collection('applicants').snapshots();
          });
        },
        child: StreamBuilder<QuerySnapshot>(
          stream: colstream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              cSizedBox(35, 0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  cSizedBox(0, 5),
                  IconButton(
                    icon: Image.asset('assets/images/icon/iconback.png', width: 22, height: 22),
                    onPressed: () {Navigator.pop(context);},
                  ),
                  cSizedBox(0, 15),
                  headerText("신청자 목록"),
                  cSizedBox(0, 215),
                ],
              ),
              headerDivider(),
              Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
              Expanded(
                // 아래 간격 두고 싶으면 Container, height 사용
                //height: MediaQuery.of(context).size.height * 0.8,
                child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final DocumentSnapshot doc = snapshot.data!.docs[index];
                      String where = doc['where'];
                      String id = doc.id;
                      //if(doc['isFineForMembers'].length!=0){
                        return Column(children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ShowApplicantList(doc.id)));
                            },
                            child: Card(
                              margin : EdgeInsets.fromLTRB(30, 20, 30, 0),
                              child: Padding(padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                                child: Row(children: [
                                  if(where == 'delivery_board') Image(image: AssetImage('assets/images/icon/iconmotorcycle.png'), height: 30, width: 30,),
                                  if(where == 'sgroup_board') Image(image: AssetImage('assets/images/icon/iconplay.png'), height: 30, width: 30,),
                                  cSizedBox(0, 20),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      smallText(doc['title'], 15, Colors.black87),
                                      smallText(doc['isFineForMembers'].join(''), 11, Color(0xffa9aaaf)),
                                      //smallText(doc['isFineForMembers'].length.toString(), 11, Color(0xffa9aaaf))
                                    ],
                                  )
                                ])
                              )
                            )
                          )
                        ]);
                      /*}
                      else{
                        return Container(child: Text('없음'),);
                      }*/
                    },
                  )
                )
              )
            ]
          );
          }
        )
      )
    );
  }

  Widget cSizedBox(double h, double w) {
    return SizedBox(
      height: h,
      width: w,
    );
  }

  void getBoardInfo(String where, String id) async {
    await FirebaseFirestore.instance.collection(where).doc(id).get().then((value) {
      title = value['title'];
    });
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


/* ----------------- My Applicant Board List -------------------- */

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

/* ------------------ Show My Applicant Board ------------------ */

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