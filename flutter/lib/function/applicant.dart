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
                  cSizedBox(0, 10),
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
                      if(doc['isFineForMembers'].length!=0){
                        return Column(children: [
                          Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                          InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => ShowApplicantList(doc.id)));
                            },
                            child: Card(
                              margin : EdgeInsets.fromLTRB(30, 10, 30, 10),
                              child: Padding(padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                                child: Row(children: [
                                  if(where == 'delivery_board') Image(image: AssetImage('assets/images/icon/iconmotorcycle.png'), height: 30, width: 30,),
                                  if(where == 'sgroup_board') Image(image: AssetImage('assets/images/icon/iconplay.png'), height: 30, width: 30,),
                                  cSizedBox(0, 20),
                                  Wrap(
                                    direction: Axis.vertical,
                                    spacing: 8,
                                    children: [
                                      smallText(doc['title'], 15, Colors.black87),
                                      if(doc['isFineForMembers'].length!=0) smallText('신청자 : ' + doc['isFineForMembers'].join(', '), 11, Color(0xffa9aaaf)),
                                      //smallText(doc['isFineForMembers'].length.toString(), 11, Color(0xffa9aaaf))
                                    ],
                                  )
                                ])
                              )
                            )
                          )
                        ]);
                      }
                      else{
                        return SizedBox.shrink();
                      }
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
                        cSizedBox(0, 10),
                        headerText(snapshot.data!.get('title')),
                        headerText(") 신청자 목록"),
                        cSizedBox(0, 180),
                      ],
                    ),
                    headerDivider(),
                    Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, 20)),
                    Expanded(
                      child: MediaQuery.removePadding(
                        context: context,
                        removeTop: true,
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: snapshot.data!.get('isFineForMembers').length,
                          itemBuilder: (context, index) {
                            final List<dynamic> isFineForMembers = snapshot.data!.get('isFineForMembers');
                            final List<dynamic> members = snapshot.data!.get('members');
                            return Column(children: [
                              Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                              InkWell(
                                onTap: () {
                                  /*showDialog(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                    elevation: 0,
                                    backgroundColor: Colors.transparent,
                                    //child: contentBox(context),
                                  );*/
                                  //Navigator.push(context, MaterialPageRoute(builder: (context) => )));
                                },
                                child: Card(
                                  margin : EdgeInsets.fromLTRB(30, 10, 30, 10),
                                  child: Row(
                                    children: [
                                      cSizedBox(0, 50),
                                      smallText(isFineForMembers[index], 15, Colors.black87),
                                      // 승인
                                      Container(
                                        margin: EdgeInsets.fromLTRB(140, 10, 0, 10),
                                        child: IconButton(
                                          icon: Image.asset('assets/images/icon/iconback.png', width: 22, height: 22),
                                          onPressed: () async {
                                            var myId = fp.getInfo()['email'];
                                            int currentMember = 0;
                                            int limitedMember = 0;
                                            String peerId = isFineForMembers[index].toString();
                                            String title = widget.id;
                                            String board = snapshot.data!.get('where');

                                            await fs.collection(board).doc(title).get().then((value) {
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
                                      // 거절
                                      Container(
                                        margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                        child: IconButton(
                                          icon: Image.asset('assets/images/icon/iconback.png', width: 22, height: 22),
                                          onPressed: () async {
                                            var myId = fp.getInfo()['email'];
                                            String peerId = isFineForMembers[index].toString();
                                            String title = widget.id;

                                            await FirebaseFirestore.instance.collection('users').doc(myId).collection('applicants').doc(title).update({
                                              'isFineForMembers': FieldValue.arrayRemove([peerId]),
                                              'rejectedMembers': FieldValue.arrayUnion([peerId]),
                                            });
                                            await FirebaseFirestore.instance.collection('users').doc(peerId).update({
                                              'myApplication': FieldValue.arrayRemove([title]),
                                              'rejected': FieldValue.arrayUnion([title]),
                                            });
                                            print(peerId);
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
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
                cSizedBox(0, 10),
                headerText("신청한 글"),
                cSizedBox(0, 230),
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
                    //String info = doc['time'].substring(5, 7) + "/" + doc['time'].substring(8, 10) + doc['write_time'].substring(10, 16);
                    //String time = ' | ' + '마감' + doc['time'].substring(10, 16) + ' | ';
                    //String writer = doc['writer'];
                    return Column(children: [
                      Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                      InkWell(
                        onTap: () {
                          if(where == 'delivery_board') Navigate(where, DeliveryShow(doc.id), doc);
                          if(where == 'sgroup_board') Navigate(where, SgroupShow(doc.id), doc);
                        },
                        child: Card(
                          margin : EdgeInsets.fromLTRB(30, 20, 30, 0),
                          child: Padding(padding: EdgeInsets.fromLTRB(20, 15, 20, 15),
                            child: Row(children: [
                              if(where == 'delivery_board') Image(image: AssetImage('assets/images/icon/iconmotorcycle.png'), height: 30, width: 30,),
                              if(where == 'sgroup_board') Image(image: AssetImage('assets/images/icon/iconplay.png'), height: 30, width: 30,),
                              cSizedBox(0, 20),
                              FutureBuilder(
                                future: getApplicantInfo(where, doc.id),
                                builder: (BuildContext context, AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    return Wrap(
                                      direction: Axis.vertical,
                                      spacing: 8,
                                      children: [
                                        smallText(snapshot.data[0], 15, Colors.black87),
                                        smallText(snapshot.data[1]+snapshot.data[2]+snapshot.data[3], 10, Color(0xffa9aaaf)),
                                      ],
                                    );
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                }
                              ),
                            ])
                          )
                        )
                      )
                    ]);
                  }
                ),
              )
            ),
          ]);
        }),
      )
    );
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
  void Navigate(String where, Widget route, DocumentSnapshot doc) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => route));
    fs.collection(where).doc(doc.id).update({"views": doc["views"] + 1});
  }
}