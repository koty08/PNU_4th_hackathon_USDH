import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:usdh/Widget/widget.dart';
import 'package:usdh/boards/delivery_board.dart';
import 'package:usdh/boards/roommate_board.dart';
import 'package:usdh/boards/sgroup_board.dart';
import 'package:usdh/boards/teambuild_board.dart';
import 'package:usdh/login/firebase_provider.dart';
import 'package:usdh/chat/chatting.dart';
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
        body: RefreshIndicator(
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
                  } else if (snapshot.hasData) {
                    return Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                      topbar2(context, "내가 쓴 글"),
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10)),
                      Text('아이콘을 클릭하면 게시물로 이동합니다.', style: TextStyle(fontFamily: "SCDream", color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 13.5)),
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10)),
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

                                  Map<String, dynamic> dataMap = doc.data() as Map<String, dynamic>;
                                  List<dynamic> rejectedMembers = [];
                                  List<dynamic> members = [];

                                  bool hasrejected = false;
                                  if (dataMap.containsKey('rejectedMembers')) {
                                    hasrejected = true;
                                    rejectedMembers = doc.get('rejectedMembers');
                                  }
                                  if (dataMap.containsKey('members')) {
                                    hasrejected = true;
                                    members = doc.get('members');
                                  }
                                  //if (doc['isFineForMembers'].length != 0) {
                                  return Column(children: [
                                    Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                                    InkWell(
                                        onTap: () {
                                          if (doc['isFineForMembers'].length != 0 || rejectedMembers.length != 0 || members.length != 0)
                                            Navigator.push(context, MaterialPageRoute(builder: (context) => ShowApplicantList(doc.id)));
                                        },
                                        child: Card(
                                            margin: EdgeInsets.fromLTRB(30, 10, 30, 10),
                                            child: Padding(
                                                padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                                                child: Row(children: [
                                                  if (where == 'delivery_board') showBoard('assets/images/icon/iconmotorcycle.png', DeliveryShow(id: doc.id)),
                                                  if (where == 'teambuild_board') showBoard('assets/images/icon/iconteam.png', TeambuildShow(doc.id)),
                                                  if (where == 'sgroup_board') showBoard('assets/images/icon/iconplay.png', SgroupShow(doc.id)),
                                                  if (where == 'roommate_board') showBoard('assets/images/icon/iconroom.png', RoommateShow(doc.id)),
                                                  cSizedBox(0, 20),
                                                  Wrap(
                                                    direction: Axis.vertical,
                                                    spacing: 10,
                                                    children: [
                                                      Container(
                                                        width: width * 0.6,
                                                        child: smallText(doc['title'], 15, Colors.black87),
                                                      ),
                                                      /*if (doc['isFineForMembers'].length != 0)
                                                          Container(
                                                            width: width * 0.6,
                                                            child: smallText('신청자 : ' + doc['isFineForMembers'].join(', '), 11, Color(0xffa9aaaf)),
                                                          )
                                                        else
                                                          Container(
                                                            width: width * 0.6,
                                                            child: */
                                                      smallText('신청 : ' + doc['isFineForMembers'].length.toString() + ',  참여 : ' + members.length.toString() + ',  거절 : ' + rejectedMembers.length.toString(), 11, Color(0xffa9aaaf)),
                                                      //)
                                                      //smallText(doc['isFineForMembers'].length.toString(), 11, Color(0xffa9aaaf))
                                                    ],
                                                  )
                                                ]))))
                                  ]);
                                  //} else {
                                  //  return SizedBox.shrink();
                                  //}
                                },
                              )))
                    ]);
                  }
                  return CircularProgressIndicator();
                })));
  }

  Widget showBoard(String text, Widget route) {
    return IconButton(
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => route));
        },
        icon: Image.asset(
          text,
          height: 30,
          width: 30,
        ));
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
                Map<String, dynamic> dataMap = snapshot.data!.data() as Map<String, dynamic>;
                final List<dynamic> isFineForMembers = snapshot.data!.get('isFineForMembers');
                final List<dynamic> members = snapshot.data!.get('members');
                String where = snapshot.data!.get('where');
                List<dynamic> rejectedMembers = [];
                List<dynamic> allMembers = isFineForMembers;
                bool hasrejected = false;

                if (dataMap.containsKey('rejectedMembers')) {
                  hasrejected = true;
                  rejectedMembers = snapshot.data!.get('rejectedMembers');
                  allMembers += rejectedMembers;
                }
                if (members.length != 0) {
                  allMembers += members;
                }
                return Column(
                  children: [
                    topbar2(context, snapshot.data!.get('title')),
                    Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10)),
                    if (where == 'teambuild_board' || where == 'sgroup_board') ...[
                      Text('아이콘을 누르면 프로필을 확인할 수 있습니다.', style: TextStyle(fontFamily: "SCDream", color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 13.5)),
                      Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 5)),
                    ],
                    Text('[요청중] 을 누르면 승인/거절할 수 있습니다.', style: TextStyle(fontFamily: "SCDream", color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 13.5)),
                    Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 10)),
                    Expanded(
                      child: MediaQuery.removePadding(
                      context: context,
                      removeTop: true,
                      child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: allMembers.length,
                          itemBuilder: (context, index) {
                            bool wasrejected = false;
                            bool ismember = false;
                            if (hasrejected && rejectedMembers.contains(allMembers[index])) wasrejected = true;
                            if (members.length != 0 && members.contains(allMembers[index])) ismember = true;
                            return Column(children: [
                              Container(
                                  height: height * 0.12,
                                  width: width * 0.85,
                                  child: Card(
                                    margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        if (!wasrejected) ...[
                                          cSizedBox(0, width * 0.05),
                                          // 팀빌딩, 소모임 -> 프로필 보기
                                          if (where == "teambuild_board") showProfile(allMembers[index], "portfolio", "portfolio_tag", "포트폴리오"),
                                          if (where == "sgroup_board") showProfile(allMembers[index], "coverletter", "coverletter_tag", "자기소개서"),
                                          if (where != 'teambuild_board' && where != 'sgroup_board') Image(image: AssetImage('assets/images/icon/profile.png'), width: 18, height: 18),
                                          cSizedBox(0, width * 0.05),
                                          if (!ismember) ...[
                                            Wrap(
                                              direction: Axis.vertical,
                                              spacing: height*0.005,
                                              children: [
                                                Container(
                                                  width: width * 0.45,
                                                  child: smallText(allMembers[index], 15, Colors.black87),
                                                ),
                                                Container(
                                                  width: width * 0.55,
                                                  child: (snapshot.data!['messages'].length != 0)?
                                                  smallText("> " + snapshot.data!['messages'][index], 12, Colors.black45):
                                                  smallText("[요청 메세지가 없어요!]", 12, Colors.black45)
                                                ),
                                              ],
                                            ),
                                            GestureDetector(
                                              onTap: () {
                                                select(snapshot, index, where, members);
                                              },
                                              child: smallText('요청중', 13, Color(0xff548ee0))
                                            ),
                                          ] else ...[
                                            Container(
                                              width: width * 0.52,
                                              child: smallText(allMembers[index], 15, Colors.black87),
                                            ),
                                            smallText(' 승인', 13, Color(0xff548ee0))
                                          ]
                                        ] else if (wasrejected) ...[
                                          cSizedBox(0, width * 0.05),
                                          // 팀빌딩, 소모임 -> 프로필 보기
                                          if (where == "teambuild_board") showProfile(allMembers[index], "portfolio", "portfolio_tag", "포트폴리오"),
                                          if (where == "sgroup_board") showProfile(allMembers[index], "coverletter", "coverletter_tag", "자기소개서"),
                                          if (where != 'teambuild_board' && where != 'sgroup_board') Image(image: AssetImage('assets/images/icon/profile.png'), width: 18, height: 18),
                                          cSizedBox(0, width * 0.05),
                                          Container(
                                            width: width * 0.52,
                                            child: smallText(allMembers[index], 15, Colors.black87),
                                          ),
                                          smallText(' 거절', 13, Colors.grey),
                                        ]
                                      ],
                                    ),
                                  ))
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
    FirebaseFirestore.instance.runTransaction((transaction) async {
      transaction.set(
        myDocumentReference,
        {'idFrom': myId, 'idTo': peerIds, 'timestamp': DateTime.now().millisecondsSinceEpoch.toString(), 'content': content, 'type': 0},
      );
      for (var peerDocumentReference in peersDocumentReference) {
        transaction.set(
          peerDocumentReference,
          {'idFrom': myId, 'idTo': peerIds, 'timestamp': DateTime.now().millisecondsSinceEpoch.toString(), 'content': content, 'type': 0},
        );
      }
    });
  }

  void select(AsyncSnapshot<DocumentSnapshot> snapshot, int index, String where, List<dynamic> members) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    final list = ["제가 맘에 드시나요?", "저를 받아주세요!"];
    final list2 = [
      'assets/images/icon/pleadingapple.png',
      'assets/images/icon/pleadinggoogle.png',
      'assets/images/icon/pleadingtwitter.png',
    ];
    String text = list[new Random().nextInt(list.length)];
    String icon = list2[new Random().nextInt(list2.length)];

    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          FirebaseProvider fp = Provider.of<FirebaseProvider>(context);
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
            content: Container(
                height: height * 0.17,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Column(children: [
                      cSizedBox(height * 0.05, 0),
                      Text(text, style: TextStyle(fontFamily: "SCDream", color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 18)),
                      cSizedBox(height * 0.01, 0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 승인
                          IconButton(
                            icon: Image.asset('assets/images/icon/iconcheck.png', width: 18, height: 18),
                            onPressed: () async {
                              var myInfo = fp.getInfo();
                              int currentMember = 0;
                              int limitedMember = 0;
                              String title = widget.id;
                              String board = snapshot.data!.get('where');
                              String peerNick = await fs.collection('users').doc(myInfo['email']).collection('applicants').doc(title).get().then((value) => value.get('isFineForMembers')[index]);
                              String peerMsg = await fs.collection('users').doc(myInfo['email']).collection('applicants').doc(title).get().then((value) => value.get('messages')[index]);
                              String peerId = await fs.collection('users').where('nick', isEqualTo: peerNick).get().then((value) => value.docs[0].get('email'));

                              await fs.collection(board).doc(title).get().then((value) {
                                currentMember = value['currentMember'];
                                limitedMember = value['limitedMember'];
                              });

                              if (currentMember < limitedMember) {
                                await fs.collection(board).doc(title).update({
                                  'currentMember': currentMember + 1,
                                });
                                // 내 정보 수정(대기에서 제거, 멤버에 추가)
                                await fs.collection('users').doc(myInfo['email']).collection('applicants').doc(title).update({
                                  'isFineForMembers': FieldValue.arrayRemove([peerNick]),
                                  'members': FieldValue.arrayUnion([peerNick]),
                                  'messages': FieldValue.arrayRemove([peerMsg]),
                                });
                                // peer의 정보 수정(참가 신청 제거)
                                await fs.collection('users').doc(peerId).collection('myApplication').doc(title).update({'isJoined': true});

                                currentMember += 1;
                                members.add(peerNick);

                                Navigator.pop(context);

                                String content = myInfo['nick'] + '님의 채팅방입니다.';
                                List<dynamic> peerIds = [];
                                for (String member in members) {
                                  await fs.collection('users').where('nick', isEqualTo: member).get().then((value) {
                                    DocumentSnapshot snapshot = value.docs[0];
                                    peerIds.add(snapshot.get('email'));
                                  });
                                }
                                onSendMessage(content, myInfo['email'], peerIds, title);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Chat(
                                          myId: myInfo['email'],
                                          peerIds: peerIds,
                                          groupChatId: title,
                                          where: where,
                                        ))
                                );

                                print(peerNick + '(' + peerId + ')를 ' + title + '에 추가합니다.');
                              } else {
                                print('인원이 다 찼습니다!');
                              }
                            },
                          ),
                          // 거절
                          IconButton(
                            icon: Image.asset('assets/images/icon/iconx.png', width: 18, height: 18),
                            onPressed: () async {
                              var myId = fp.getInfo()['email'];
                              String title = widget.id;
                              String peerNick = await fs.collection('users').doc(myId).collection('applicants').doc(title).get().then((snapshot) => snapshot['isFineForMembers'][index]);
                              String peerId = await fs.collection('users').where('nick', isEqualTo: peerNick).get().then((snapshot) => snapshot.docs[0].get('email'));

                              //내 정보 수정(대기자 제거, 거절한 사람 추가)
                              await fs.collection('users').doc(myId).collection('applicants').doc(title).update({
                                'isFineForMembers': FieldValue.arrayRemove([peerNick]),
                                'rejectedMembers': FieldValue.arrayUnion([peerNick]),
                              });
                              //신청자 정보 수정(신청 목록 제거)
                              await fs.collection('users').doc(peerId).collection('myApplication').doc(title).update({'isRejected': true});

                              Navigator.pop(context);
                            },
                          ),
                        ],
                      ),
                    ]),
                    Positioned(top: -50, child: Image.asset(icon, width: 80, height: 80))
                  ],
                )),
          );
        });
  }

  // 프로필(포폴, 자소서) 띄움 // 디자인 수정중
  Widget showProfile(String applicant, String info, String tag, String profile) {
    return IconButton(
        icon: Image.asset('assets/images/icon/profile.png', width: 18, height: 18),
        padding: EdgeInsets.zero,
        constraints: BoxConstraints(),
        onPressed: () {
          showDialog(
            context: context,
            barrierColor: null,
            builder: (BuildContext context) {
              final width = MediaQuery.of(context).size.width;
              final height = MediaQuery.of(context).size.height;
              return AlertDialog(
                titlePadding: EdgeInsets.zero,
                contentPadding: EdgeInsets.zero,
                elevation: 0,
                content: Container(
                  height: height*0.77,
                  width: width*0.8,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Color(0xff639ee1),
                      width: 1.3
                    )
                  ),
                  child: FutureBuilder<QuerySnapshot>(
                    future: fs.collection('users').where('nick', isEqualTo: applicant).get(),
                    builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snap) {
                      if (snap.hasData) {
                        DocumentSnapshot doc = snap.data!.docs[0];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            profilebar2(context, doc['nick'], profile),
                            cSizedBox(height*0.03, 0),
                            Row(
                              children: [
                                cSizedBox(0, width*0.1),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(60),
                                  child: Image.network(
                                    doc['photoUrl'],
                                    width: 55,
                                    height: 55,
                                  ),
                                ),
                                cSizedBox(0, width*0.07),
                                middleText(doc['nick'] + "(" + doc['num'].toString() + ")", 15, Colors.black87),
                              ],
                            ),
                            cSizedBox(height*0.04, 0),
                            Column(
                              children: [
                                inputNav2('assets/images/icon/iconme.png', "  자기소개"),
                                Container(
                                  width: width*0.67,
                                  height: height*0.12,
                                  padding: EdgeInsets.fromLTRB(width*0.03, height*0.02, width*0.03, height*0.02),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.5,), borderRadius: BorderRadius.circular(10)),
                                  child: SingleChildScrollView(
                                    child: (doc[info].length == 0)? Text("작성 X"):
                                    condText(doc[info][0]),),
                                ),
                                cSizedBox(height*0.04, 0),
                                inputNav2('assets/images/icon/iconwin.png', "  경력"),
                                Container(
                                  width: width*0.67,
                                  height: height*0.12,
                                  padding: EdgeInsets.fromLTRB(width*0.03, height*0.02, width*0.03, height*0.02),
                                  decoration: BoxDecoration(border: Border.all(color: Colors.grey, width: 0.5,), borderRadius: BorderRadius.circular(10)),
                                  child: SingleChildScrollView(
                                    child: (doc[info].length == 0)? Text("작성 X"):
                                    condText(doc[info][1]),),
                                ),
                                cSizedBox(height*0.04, 0),
                                inputNav2('assets/images/icon/icontag.png', "  태그"),
                                SingleChildScrollView(
                                  scrollDirection: Axis.horizontal,
                                  child: (doc[tag].length == 0)? tagText("태그없음"):
                                  tagText(doc[tag].join(', ')),
                                ),
                              ],
                            ),
                          ],
                        );
                      } else {
                        return CircularProgressIndicator();
                      }
                    }
                  ),
                ),
              );
            });
        });
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
              Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 15)),
              Text('클릭하면 해당 게시물로 이동합니다.', style: TextStyle(fontFamily: "SCDream", color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 13.5)),
              Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 5)),
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

                      return Column(children: [
                        Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                          InkWell(
                            onTap: () {
                              if (where == 'delivery_board') navigate2Board(where, DeliveryShow(id: doc.id), doc);
                              if (where == 'teambuild_board') navigate2Board(where, TeambuildShow(doc.id), doc);
                              if (where == 'sgroup_board') navigate2Board(where, SgroupShow(doc.id), doc);
                              if (where == 'roommate_board') navigate2Board(where, RoommateShow(doc.id), doc);
                            },
                            child: Card(
                                margin: EdgeInsets.fromLTRB(width * 0.07, 20, width * 0.07, 0),
                                child: Padding(
                                    padding: EdgeInsets.fromLTRB(width * 0.05, 15, width * 0.05, 15),
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        if (where == 'deleted') Image(image: AssetImage('assets/images/icon/iconx.png'), height: 30, width: 30,),
                                        if (where == 'delivery_board') Image(image: AssetImage('assets/images/icon/iconmotorcycle.png'), height: 30, width: 30,),
                                        if (where == 'teambuild_board') Image(image: AssetImage('assets/images/icon/iconteam.png'), height: 30, width: 30,),
                                        if (where == 'sgroup_board') Image(image: AssetImage('assets/images/icon/iconplay.png'), height: 30, width: 30,),
                                        if (where == 'roommate_board') Image(image: AssetImage('assets/images/icon/iconroom.png'), height: 30, width: 30,),

                                        cSizedBox(0, 20),
                                        FutureBuilder(
                                          future: getApplicantInfo(where, doc.id),
                                          builder: (BuildContext context, AsyncSnapshot snapshot) {
                                            if (snapshot.hasData) {
                                              return Row(
                                                children: [
                                                  Wrap(
                                                    direction: Axis.vertical,
                                                    spacing: 8,
                                                    children: [
                                                      Container(
                                                        width: MediaQuery.of(context).size.width * 0.52,
                                                        child: smallText(snapshot.data[0], 15, Colors.black87),
                                                      ),
                                                      smallText(snapshot.data[1] + snapshot.data[2] + snapshot.data[3], 10, Color(0xffa9aaaf)),
                                                    ],
                                                  ),
                                                  if(!doc['isJoined'] && !doc['isRejected'])
                                                    smallText('요청중', 13, Color(0xff548ee0)),
                                                  if (doc['isJoined'])
                                                    smallText('승인됨', 13, Color(0xff548ee0)),
                                                  if (doc['isRejected'])
                                                    smallText('거절됨', 13, Colors.grey),
                                                ],
                                              );
                                            } else {
                                              return Container(
                                                width: MediaQuery.of(context).size.width * 0.6,
                                                child: smallText("삭제된 글입니다.", 15, Colors.grey),
                                              );
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
