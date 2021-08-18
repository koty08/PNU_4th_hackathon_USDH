import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:usdh/Widget/widget.dart';
import 'package:usdh/boards/delivery_board.dart';
import 'package:usdh/boards/sgroup_board.dart';
import 'package:usdh/login/firebase_provider.dart';
import 'package:usdh/chat/chatting.dart';
import 'package:usdh/chat/home.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

late ApplicantListBoardState pageState5;
late ShowApplicantListState pageState6;
late MyApplicationListBoardState pageState7;

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
  final FirebaseFirestore fs = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();
    colstream = fs.collection('users').doc(myId).collection('applicants').snapshots();
    return Scaffold(
        body: RefreshIndicator(
            //당겨서 새로고침
            onRefresh: () async {
              setState(() {
                colstream = fs.collection('users').doc(myId).collection('applicants').snapshots();
              });
            },
            child: StreamBuilder<QuerySnapshot>(
                stream: colstream,
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (!snapshot.hasData) {
                    return CircularProgressIndicator();
                  }
                  return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    topbar2(context, "신청자 목록"),
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
                                if (doc['isFineForMembers'].length != 0) {
                                  return Column(children: [
                                    Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                                    InkWell(
                                        onTap: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => ShowApplicantList(doc.id)));
                                        },
                                        child: Card(
                                            margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                                            child: Padding(
                                                padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                                                child: Row(children: [
                                                  if (where == 'delivery_board') Image(image: AssetImage('assets/images/icon/iconmotorcycle.png'), height: 30, width: 30,),
                                                  if (where == 'sgroup_board') Image(image: AssetImage('assets/images/icon/iconplay.png'), height: 30, width: 30,),
                                                  if (where == 'teambuild_board') Image(image: AssetImage('assets/images/icon/iconteam.png'), height: 30, width: 30,),
                                                  if (where == 'roommate_board') Image(image: AssetImage('assets/images/icon/iconroom.png'), height: 30, width: 30,),
                                                  cSizedBox(0, 20),
                                                  Wrap(
                                                    direction: Axis.vertical,
                                                    spacing: 8,
                                                    children: [
                                                      Container(width: MediaQuery.of(context).size.width * 0.6,
                                                        child: smallText(doc['title'], 15, Colors.black87),),
                                                      if (doc['isFineForMembers'].length != 0) smallText('신청자 : ' + doc['isFineForMembers'].join(', '), 11, Color(0xffa9aaaf)),
                                                      //smallText(doc['isFineForMembers'].length.toString(), 11, Color(0xffa9aaaf))
                                                    ],
                                                  )
                                                ]))))
                                  ]);
                                } else {
                                  return SizedBox.shrink();
                                }
                              },
                            )))
                  ]);
                })));
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
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
                    topbar2(context, snapshot.data!.get('title')),
                    Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
                    Expanded(
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.get('isFineForMembers').length,// + snapshot.data!.get('rejectedMembers').length,
                          itemBuilder: (context, index) {
                            final List<dynamic> isFineForMembers = snapshot.data!.get('isFineForMembers');
                            final List<dynamic> members = snapshot.data!.get('members');
                            String where = snapshot.data!.get('where');

                            /*if(snapshot.data!.get('rejectedMembers') === undefined) {
                              final List<dynamic> rejectedMembers = snapshot.data!.get('rejectedMembers');
                              final List<dynamic> allMembers = [];
                              allMembers.add(isFineForMembers);
                              allMembers.add(rejectedMembers);
                              print(allMembers);
                            } 무언가 시도한 흔적.....
                            */
                            return Column(children: [
                              Card(
                                margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    cSizedBox(0, width * 0.1),
                                    Wrap(
                                      spacing: - width * 0.02,
                                      crossAxisAlignment: WrapCrossAlignment.center,
                                      children: [
                                        (where == "teambuild_board" || where == "sgroup_board")?
                                        Container(width: width * 0.35,
                                          child: smallText(isFineForMembers[index], 15, Colors.black87),):
                                        Container(width: width * 0.45,
                                          child: smallText(isFineForMembers[index], 15, Colors.black87),),
                                        // 팀빌딩, 소모임 -> 프로필 보기
                                        if(where == "teambuild_board") showProfile(isFineForMembers[index], "portfolio", "portfolio_tag"),
                                        if(where == "sgroup_board") showProfile(isFineForMembers[index], "coverletter", "coverletter_tag"),

                                        // 승인
                                        Container(
                                          margin: EdgeInsets.fromLTRB(0, height*0.015, 0, height*0.015),
                                          child: IconButton(
                                            icon: Image.asset('assets/images/icon/iconcheck.png', width: 18, height: 18),
                                            onPressed: () async {
                                              var myInfo = fp.getInfo();
                                              int currentMember = 0;
                                              int limitedMember = 0;
                                              String peerNick = '';
                                              String peerId = '';
                                              String title = widget.id;
                                              String board = snapshot.data!.get('where');

                                              await fs.collection(board).doc(title).get().then((value) {
                                                currentMember = value['currentMember'];
                                                limitedMember = value['limitedMember'];
                                              });
                                              await fs.collection('users').doc(myInfo['email']).collection('applicants').doc(title).get().then((value) {
                                                peerNick = value['isFineForMembers'][index];
                                              });
                                              await fs.collection('users').where('nick', isEqualTo: peerNick).get().then((value) {
                                                DocumentSnapshot snapshot = value.docs[0];
                                                peerId = snapshot.get('email');
                                              });

                                              // 제한 인원을 넘지 않았으면 추가
                                              if (currentMember < limitedMember) {
                                                // board의 정보 수정(현재 멤버 수)
                                                await fs.collection(board).doc(title).update({
                                                  'currentMember': currentMember + 1,
                                                });
                                                // 내 정보 수정(대기에서 제거, 멤버에 추가)
                                                await fs.collection('users').doc(myInfo['email']).collection('applicants').doc(title).update({
                                                  'isFineForMembers': FieldValue.arrayRemove([peerNick]),
                                                  'members': FieldValue.arrayUnion([peerNick])
                                                });
                                                // peer의 정보 수정(참가 신청 제거, 참가한 방 추가)
                                                await fs.collection('users').doc(peerId).collection('myApplication').doc(title).delete();
                                                await fs.collection('users').doc(peerId).update({
                                                  'joiningIn': FieldValue.arrayUnion([title])
                                                });

                                                currentMember += 1;
                                                members.add(peerNick);

                                                String content = myInfo['nick'] + '님의 채팅방입니다.';
                                                List<dynamic> peerIds = [];
                                                for (String member in members) {
                                                  await fs.collection('users').where('nick', isEqualTo: member).get().then((value) {
                                                    DocumentSnapshot snapshot = value.docs[0];
                                                    peerIds.add(snapshot.get('email'));
                                                  });
                                                }

                                                onSendMessage(content, myInfo['email'], peerIds, title);
                                                // 채팅 시작
                                                Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                        builder: (context) => Chat(
                                                          myId: myInfo['email'],
                                                          peerIds: peerIds,
                                                          groupChatId: title,
                                                        )));

                                                print(peerNick + '(' + peerId + ')를 ' + title + '에 추가합니다.');
                                              } else {
                                                print('인원이 다 찼습니다!');
                                              }
                                            },
                                          ),
                                        ),
                                        // 거절
                                        Container(
                                          margin: EdgeInsets.fromLTRB(0, height*0.015, 0, height*0.015),
                                          child: IconButton(
                                            icon: Image.asset('assets/images/icon/iconx.png', width: 18, height: 18),
                                            onPressed: () async {
                                              var myId = fp.getInfo()['email'];
                                              String peerNick = '';
                                              String peerId = '';
                                              String title = widget.id;

                                              await fs.collection('users').doc(myId).collection('applicants').doc(title).get().then((value) {
                                                peerNick = value['isFineForMembers'][index];
                                              });
                                              await fs.collection('users').where('nick', isEqualTo: peerNick).get().then((value) {
                                                DocumentSnapshot snapshot = value.docs[0];
                                                peerId = snapshot.get('email');
                                              });

                                              //내 정보 수정(대기자 제거, 거절한 사람 추가)
                                              await FirebaseFirestore.instance.collection('users').doc(myId).collection('applicants').doc(title).update({
                                                'isFineForMembers': FieldValue.arrayRemove([peerNick]),
                                                'rejectedMembers': FieldValue.arrayUnion([peerNick]),
                                              });
                                              //신청자 정보 수정(거절된 게시물 추가, 신청 목록 제거)
                                              await FirebaseFirestore.instance.collection('users').doc(peerId).update({
                                                'rejected': FieldValue.arrayUnion([title]),
                                              });
                                              await FirebaseFirestore.instance.collection('users').doc(peerId).collection('myApplication').doc(title).delete();
                                            },
                                          ),
                                        ),
                                      ]
                                    ),
                                  ],
                                ),
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

  // 방 초기화 메세지
  void onSendMessage(String content, String myId, List<dynamic> peerIds, String groupChatId) {
    DocumentReference myDocumentReference = FirebaseFirestore.instance.collection('users').doc(myId).collection('messageWith').doc(groupChatId).collection('messages').doc(DateTime.now().millisecondsSinceEpoch.toString());

    List<DocumentReference> peersDocumentReference = [];
    for (var peerId in peerIds) {
      peersDocumentReference.add(FirebaseFirestore.instance.collection('users').doc(peerId).collection('messageWith').doc(groupChatId).collection('messages').doc(DateTime.now().millisecondsSinceEpoch.toString()));
    }

    // 나와 상대의 메세지를 firestore에 동시에 저장
    FirebaseFirestore.instance.runTransaction((transaction) async {
      // 내 messages에 기록
      transaction.set(
        myDocumentReference,
        {'idFrom': myId, 'idTo': peerIds, 'timestamp': DateTime.now().millisecondsSinceEpoch.toString(), 'content': content, 'type': 0},
      );
      // 상대 messages에 기록
      for (var peerDocumentReference in peersDocumentReference) {
        transaction.set(
          peerDocumentReference,
          {'idFrom': myId, 'idTo': peerIds, 'timestamp': DateTime.now().millisecondsSinceEpoch.toString(), 'content': content, 'type': 0},
        );
      }
    });
  }

  // 프로필(포폴, 자소서) 띄움 // 디자인 수정중
  Widget showProfile(String applicant, String info, String tag) {
    return IconButton(icon: Image.asset('assets/images/icon/profile.png', width: 18, height: 18),
      onPressed: () {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
              content: FutureBuilder<QuerySnapshot>(
                future: fs.collection('users').where('nick', isEqualTo: applicant).get(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap){
                  if(snap.hasData){
                    DocumentSnapshot doc = snap.data!.docs[0];
                    return Column(children: [
                      Row(children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.network(
                            doc['photoUrl'],
                            width: 60, height: 60,
                          ),
                        ),
                        cSizedBox(10, 20),
                        cond2Text(doc['nick'] + "(" + doc['num'].toString() + ")"),
                      ],),
                      Column(children: [
                        (doc[tag] != List.empty())?
                        tagText(doc[tag].join('')):
                        Text("태그없음"),
                        (doc[info] == List.empty())? Text("작성 X"):
                        Text("자기소개", style: TextStyle(fontFamily: "SCDream", color: Color(0xff639ee1), fontWeight: FontWeight.w600, fontSize: 12)),
                        cond2Text(doc[info][0]),
                        (doc[info] == List.empty())? Text("작성 X"):
                        Text("경력", style: TextStyle(fontFamily: "SCDream", color: Color(0xff639ee1), fontWeight: FontWeight.w600, fontSize: 12)),
                        cond2Text(doc[info][1]),
                      ],)
                    ],);
                  } else{
                    return CircularProgressIndicator();
                  }
                }
              ),
              actions: <Widget>[
                new TextButton(
                  child: Text("확인"),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            );
          }
        );
      }
    );
  }
}

/* ----------------- My Applicant Board List -------------------- */

class MyApplicationListBoard extends StatefulWidget {
  final String myId;
  MyApplicationListBoard({Key? key, required this.myId}) : super(key: key);

  @override
  MyApplicationListBoardState createState() {
    pageState7 = MyApplicationListBoardState(myId: myId);
    return pageState7;
  }
}

class MyApplicationListBoardState extends State<MyApplicationListBoard> {
  MyApplicationListBoardState({Key? key, required this.myId});
  String myId;

  Stream<QuerySnapshot>? colstream;
  late FirebaseProvider fp;
  final FirebaseFirestore fs = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();
    colstream = fs.collection('users').doc(myId).collection('myApplication').snapshots();
    return Scaffold(
        body: RefreshIndicator(
      //당겨서 새로고침
      onRefresh: () async {
        setState(() {
          colstream = fs.collection('users').doc(myId).collection('myApplication').snapshots();
        });
      },
      child: StreamBuilder<QuerySnapshot>(
          stream: colstream,
          builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return CircularProgressIndicator();
            }
            return Column(children: [
              topbar2(context, "신청한 글"),
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
                      //String info = doc['time'].substring(5, 7) + "/" + doc['time'].substring(8, 10) + doc['write_time'].substring(10, 16);
                      //String time = ' | ' + '마감' + doc['time'].substring(10, 16) + ' | ';
                      //String writer = doc['writer'];
                      return Column(children: [
                        Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                        InkWell(
                            onTap: () {
                              if (where == 'delivery_board') navigate2Board(where, DeliveryShow(id: doc.id), doc);
                              if (where == 'sgroup_board') navigate2Board(where, SgroupShow(doc.id), doc);
                            },
                            child: Card(
                                margin: EdgeInsets.fromLTRB(30, 20, 30, 0),
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                                    child: Row(children: [
                                      if (where == 'deleted') Image(image: AssetImage('assets/images/icon/iconx.png'),height: 30,width: 30,),
                                      if (where == 'delivery_board') Image(image: AssetImage('assets/images/icon/iconmotorcycle.png'), height: 30, width: 30,),
                                      if (where == 'sgroup_board') Image(image: AssetImage('assets/images/icon/iconplay.png'), height: 30, width: 30,),

                                      cSizedBox(0, 20),
                                      FutureBuilder(
                                        future: getApplicantInfo(where, doc.id),
                                        builder: (BuildContext context, AsyncSnapshot snapshot) {
                                          if (snapshot.hasData) {
                                            return Wrap(
                                              direction: Axis.vertical,
                                              spacing: 8,
                                              children: [
                                                Container(width: MediaQuery.of(context).size.width * 0.6,
                                                  child: smallText(snapshot.data[0], 15, Colors.black87),),
                                                smallText(snapshot.data[1] + snapshot.data[2] + snapshot.data[3], 10, Color(0xffa9aaaf)),
                                              ],
                                            );
                                          } else {
                                            return Container(width: MediaQuery.of(context).size.width * 0.6,
                                              child: smallText("삭제된 글입니다.", 15, Colors.grey),);
                                          }
                                        }),
                                    ]))))
                      ]);
                    }),
              )),
            ]);
          }),
    ));
  }

  Future<List> getApplicantInfo(String where, String id) async {
    List info2 = [];
    await fs.collection(where).doc(id).get().then((value) {
      info2.add(value['title']);
      info2.add(value['time'].substring(5, 7) + "/" + value['time'].substring(8, 10) + value['write_time'].substring(10, 16));
      info2.add(' | ' + '마감' + value['time'].substring(10, 16) + ' | ');
      info2.add(value['writer']);
    });
    return info2;
  }

  void navigate2Board(String where, Widget route, DocumentSnapshot doc) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) => route));
    int views = 0;
    await fs.collection(where).doc(doc.id).get().then((value) {
      views = value['views'];
    });
    await fs.collection(where).doc(doc.id).update({"views": views + 1});
  }

}