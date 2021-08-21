import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:date_format/date_format.dart';
import 'package:usdh/chat/const.dart';
import 'package:usdh/chat/widget/loading.dart';
import 'package:usdh/chat/widget/full_photo.dart';

FirebaseFirestore fs = FirebaseFirestore.instance;

class Chat extends StatefulWidget {
  final String myId;
  final List<dynamic> peerIds; // chat에 참가한 유저의 email들
  final String groupChatId;
  final String where;

  Chat({Key? key, required this.myId, required this.peerIds, required this.groupChatId, required this.where}) : super(key: key);

  @override
  State createState() => ChatState(myId: myId, peerIds: peerIds, groupChatId: groupChatId, where: where);
}

// 채팅방 내부
class ChatState extends State<Chat> {
  final String myId;
  final List<dynamic> peerIds; // chat에 참가한 유저의 email들
  final String groupChatId;
  final String where;

  ChatState({Key? key, required this.myId, required this.peerIds, required this.groupChatId, required this.where});

  // 설정, 퇴장 버튼 생성(버튼이름, 아이콘)
  List<Choice> choices = const <Choice>[
    const Choice(title: '설정', icon: Icons.settings),
    const Choice(title: '퇴장', icon: Icons.exit_to_app),
  ];

  // 로그아웃 버튼, 설정(프로필 수정) 버튼
  void onItemMenuPress(Choice choice) {
    if (choice.title == '퇴장') {
      exitChat();
      print('채팅방 퇴장');
    } else {
      print('프로필 설정');
    }
  }

  // 채팅방 나가기
  Future<Null> exitChat() async {
    Navigator.of(context).pop();

    //본인
    await FirebaseFirestore.instance.collection('users').doc(myId).update({
      'joiningIn': FieldValue.arrayRemove([groupChatId])
    });
    await FirebaseFirestore.instance.collection('users').doc(myId).collection('messageWith').doc(groupChatId).collection('messages').get().then((value) {
      if (value.docs.isNotEmpty) {
        for (DocumentSnapshot ds in value.docs) {
          ds.reference.delete();
        }
      }
    });
    await FirebaseFirestore.instance.collection('users').doc(myId).collection('messageWith').doc(groupChatId).delete();
    //다른 멤버
    for (String peerId in peerIds) {
      await FirebaseFirestore.instance.collection('users').doc(peerId).collection('messageWith').doc(groupChatId).update({
        'chatMembers': FieldValue.arrayRemove([myId])
      });
    }
    // post의 currentMember - 1, 방장의 applicants의 members에서 삭제
    await FirebaseFirestore.instance.collection(where).doc(groupChatId).update({'currentMember': FieldValue.increment(-1)});

    String writer = '';
    String writerId = '';
    await fs.collection(where).doc(groupChatId).get().then((value) {
      writer = value.get('writer');
    });
    await fs.collection('users').where('nick', isEqualTo: writer).get().then((snap) {
      writerId = snap.docs[0].get('email');
    });
    await fs.collection('users').doc(writerId).collection('applicants').doc(groupChatId).update({
      'members': FieldValue.arrayRemove([myId])
    });
  }

  // 참가한 유저들의 프로필 사진 정보를 얻어옴
  Future<List<String>> getPeerAvatar() async {
    final List<String> peerAvatars = []; // peerIds로 얻어
    for (var peerId in peerIds) {
      await FirebaseFirestore.instance.collection('users').doc(peerId).get().then((value) {
        peerAvatars.add(value['photoUrl']);
      });
    }
    return peerAvatars;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
            IconButton(
              icon: Image.asset('assets/images/icon/iconback.png', width: 22, height: 22),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
            Text(
              '채팅',
              style: TextStyle(fontFamily: "SCDream", color: Color(0xff548ee0), fontWeight: FontWeight.w500, fontSize: 18),
            ),
          ],
        ),
        titleSpacing: 0.0,
        automaticallyImplyLeading: false,

        // 채팅방 내의 퇴장, 설정 버튼
        actions: <Widget>[
          PopupMenuButton<Choice>(
            icon: Image.asset('assets/images/icon/iconthreedot.png', width: 20, height: 20),
            onSelected: onItemMenuPress,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                    value: choice,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          choice.icon,
                          color: Color(0xff000000),
                        ),
                        Container(
                          width: 10.0,
                        ),
                        Text(
                          choice.title,
                          style: TextStyle(color: primaryColor),
                        ),
                      ],
                    ));
              }).toList();
            },
          ),
          Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
        ],
        backgroundColor: Color(0xffffffff),
      ),
      body: ChatScreen(
          myId: myId,
          peerIds: peerIds, // 채팅방 멤버들의 emails
          peerAvatars: getPeerAvatar(), // 채팅방 멤버들의 photoUrls
          groupChatId: groupChatId,
          where: where),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String myId;
  final List<dynamic> peerIds;
  final Future<List<String>> peerAvatars;
  final String groupChatId;
  final String where;

  ChatScreen({Key? key, required this.myId, required this.peerIds, required this.peerAvatars, required this.groupChatId, required this.where}) : super(key: key);

  @override
  State createState() => ChatScreenState(myId: myId, peerIds: peerIds, peerAvatars: peerAvatars, groupChatId: groupChatId, where: where);
}

class ChatScreenState extends State<ChatScreen> {
  final String myId;
  final List<dynamic> peerIds;
  final Future<List<String>> peerAvatars;
  final String groupChatId;
  final String where;

  ChatScreenState({Key? key, required this.myId, required this.peerIds, required this.peerAvatars, required this.groupChatId, required this.where});

  List<QueryDocumentSnapshot> listMessage = new List.from([]);
  int _limit = 20;
  int _limitIncrement = 20;

  File? imageFile;
  bool isLoading = false;
  bool isShowSticker = false;
  String imageUrl = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  _scrollListener() {
    if (listScrollController.offset >= listScrollController.position.maxScrollExtent && !listScrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    focusNode.addListener(onFocusChange);
    listScrollController.addListener(_scrollListener);
    readLocal();
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      // Hide sticker when keyboard appear
      setState(() {
        isShowSticker = false;
      });
    }
  }

  void readLocal() async {
    // 본인 email is chattingWith 상대방 email
    FirebaseFirestore.instance.collection('users').doc(myId).update({'chattingWith': FieldValue.arrayUnion(peerIds)});

    // 상대방 정보를 나의 messageWith에 저장
    // 1. 상대방 정보 local에 저장
    List<String> peerPhotoUrls = [];
    List<String> peerNicknames = [];
    for (var peerId in peerIds) {
      await FirebaseFirestore.instance.collection('users').doc(peerId).get().then((value) {
        peerPhotoUrls.add(value['photoUrl'].toString());
        peerNicknames.add(value['nick'].toString());
      });
    }

    // 2. 내 messageWith에 추가
    await FirebaseFirestore.instance.collection('users').doc(myId).collection('messageWith').doc(groupChatId).set({'chatMembers': peerIds, 'lastTimeSeen': DateTime.now().millisecondsSinceEpoch.toString(), 'where': where});

    // 내 정보를 상대방 messageWith에 저장
    // 1. local에 내 정보 저장
    var myPhotoUrl;
    var myNickname;
    await FirebaseFirestore.instance.collection('users').doc(myId).get().then((value) async {
      myPhotoUrl = value['photoUrl'].toString();
      myNickname = value['nick'].toString();
    });

    // 2. 상대방 messageWith에 저장
    for (var peerId in peerIds) {
      List<String> _peerIds = [];
      for (var _peerId in peerIds) {
        if (_peerId != peerId) {
          _peerIds.add(_peerId);
        }
      }
      _peerIds.add(myId);
      await FirebaseFirestore.instance.collection('users').doc(peerId).collection('messageWith').doc(groupChatId).set({'chatMembers': _peerIds, 'lastTimeSeen': DateTime.now().millisecondsSinceEpoch.toString(), 'where': where});
    }

    setState(() {});
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    XFile? pickedFile;

    pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          isLoading = true;
        });
        uploadFile();
      }
    }
  }

  Future uploadFile() async {
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference reference = FirebaseStorage.instance.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(imageFile!);

    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: e.message ?? e.toString());
    }
  }

  //메세지 보내기
  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      DocumentReference myDocumentReference = FirebaseFirestore.instance.collection('users').doc(myId).collection('messageWith').doc(groupChatId).collection('messages').doc(DateTime.now().millisecondsSinceEpoch.toString());
      List<DocumentReference> peersDocumentReference = [];
      for (var peerId in peerIds) {
        peersDocumentReference.add(FirebaseFirestore.instance.collection('users').doc(peerId).collection('messageWith').doc(groupChatId).collection('messages').doc(DateTime.now().millisecondsSinceEpoch.toString()));
      }
      FirebaseFirestore.instance.runTransaction((transaction) async {
        transaction.set(
          myDocumentReference,
          {'idFrom': myId, 'idTo': peerIds, 'timestamp': DateTime.now().millisecondsSinceEpoch.toString(), 'content': content, 'type': type},
        );
        for (var peerDocumentReference in peersDocumentReference) {
          transaction.set(
            peerDocumentReference,
            {'idFrom': myId, 'idTo': peerIds, 'timestamp': DateTime.now().millisecondsSinceEpoch.toString(), 'content': content, 'type': type},
          );
        }
      });

      listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: '메세지를 입력하세요.', backgroundColor: Colors.black, textColor: Colors.red);
    }
  }

  Future<String> getAvatar(String peerId) async {
    String peerAvatar = '';
    await fs.collection('users').doc(peerId).get().then((value) {
      peerAvatar = value.get('photoUrl');
    });
    return peerAvatar;
  }

  //오전? 오후?
  String whatTime(DateTime dateTime) {
    String nowTime = '';
    String formatted = formatDate(dateTime, [HH, ':', nn]);

    if (int.parse(formatted.substring(0, 2)) >= 13) {
      nowTime = '오후 ' + (int.parse(formatted.substring(0, 2)) - 12).toString() + ':' + formatted.substring(3, 5);
    } else {
      nowTime = '오전 ' + int.parse(formatted.substring(0, 2)).toString() + ':' + formatted.substring(3, 5);
    }

    return nowTime;
  }

  //년,월,일
  Text whatDay(DateTime dateTime) {
    String formatted = formatDate(dateTime, [yyyy, '-', mm, '-', dd]);
    String currentDay = '-------------------------' + formatted.substring(0, 4) + '년 ' + int.parse(formatted.substring(5, 7)).toString() + '월 ' + int.parse(formatted.substring(8, 10)).toString() + '일' + '-------------------------';
    return Text(currentDay);
  }

  //시간(분 단위) 변화?
  bool isDiffTimeWithPrevious(int index) {
    if (index < listMessage.length - 1) {
      String preMessage = formatDate(DateTime.fromMillisecondsSinceEpoch(int.parse(listMessage[index + 1].get('timestamp'))), [HH, ':', nn]);
      String curMessage = formatDate(DateTime.fromMillisecondsSinceEpoch(int.parse(listMessage[index].get('timestamp'))), [HH, ':', nn]);

      if (int.parse(preMessage.substring(0, 2)) != int.parse(curMessage.substring(0, 2)) || int.parse(preMessage.substring(3, 5)) != int.parse(curMessage.substring(3, 5))) {
        return true;
      }
    }
    return false;
  }

  bool isDiffTimeWithFormer(int index) {
    if (index > 0) {
      String preMsgTime = formatDate(DateTime.fromMillisecondsSinceEpoch(int.parse(listMessage[index - 1].get('timestamp'))), [HH, ':', nn]);
      String curMsgTime = formatDate(DateTime.fromMillisecondsSinceEpoch(int.parse(listMessage[index].get('timestamp'))), [HH, ':', nn]);

      if (int.parse(preMsgTime.substring(0, 2)) != int.parse(curMsgTime.substring(0, 2)) || int.parse(preMsgTime.substring(3, 5)) != int.parse(curMsgTime.substring(3, 5))) {
        return true;
      }
    }
    return false;
  }

  //시간(하루) 변화?
  bool isDiffDay(int index) {
    if (index < listMessage.length - 1) {
      String curMsgDay = formatDate(DateTime.fromMillisecondsSinceEpoch(int.parse(listMessage[index].get('timestamp'))), [yyyy, '-', mm, '-', dd]);
      String preMsgDay = formatDate(DateTime.fromMillisecondsSinceEpoch(int.parse(listMessage[index + 1].get('timestamp'))), [yyyy, '-', mm, '-', dd]);

      if (preMsgDay != curMsgDay) {
        return true;
      } else {
        return false;
      }
    }
    return true;
  }

  //바로 전이 다른 유저 채팅?
  bool isDiffUser(int index) {
    if (listMessage[index + 1].get('idFrom') == listMessage[index].get('idFrom')) return false;
    return true;
  }

  bool isFirstMessageLeft(int index) {
    if ((index < listMessage.length - 1 && (listMessage[index + 1].get('idFrom') == myId) || isDiffTimeWithPrevious(index)) || isDiffUser(index) || index == listMessage.length - 1) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageLeft(int index) {
    if ((index > 0 && (listMessage[index - 1].get('idFrom') == myId) || isDiffTimeWithFormer(index)) || isDiffUser(index) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if ((index > 0 && (listMessage[index - 1].get('idFrom') != myId) || isDiffTimeWithFormer(index)) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  //채팅방 내부 메세지 블럭 생성
  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      if (document.get('idFrom') == myId) {
        // 내가 보낸 메세지는 오른쪽에 ( 텍스트, 사진 순서)
        return Container(
            child: Column(
          children: <Widget>[
            Row(
              children: [
                document.get('type') == 0
                    ? Container(
                        child: Text(
                          document.get('content'),
                          style: TextStyle(color: primaryColor),
                        ),
                        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                        width: 200.0,
                        decoration: BoxDecoration(color: Color(0xffc7c7c7), borderRadius: BorderRadius.circular(8.0)),
                        margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                      )
                    : Container(
                        child: OutlinedButton(
                          child: Material(
                            child: Image.network(
                              document.get("content"),
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: Color(0xffc7c7c7),
                                    borderRadius: BorderRadius.all(
                                      Radius.circular(8.0),
                                    ),
                                  ),
                                  width: 200.0,
                                  height: 200.0,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: primaryColor,
                                      value: loadingProgress.expectedTotalBytes != null && loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                                    ),
                                  ),
                                );
                              },
                              errorBuilder: (context, object, stackTrace) {
                                return Material(
                                  child: Image.asset(
                                    'images/img_not_available.jpeg',
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                );
                              },
                              width: 200.0,
                              height: 200.0,
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(8.0)),
                            clipBehavior: Clip.hardEdge,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => FullPhoto(
                                  url: document.get('content'),
                                ),
                              ),
                            );
                          },
                          style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0))),
                        ),
                        margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                      ),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),
            // 메세지 보낸 시간 표시
            isLastMessageRight(index)
                ? Container(
                    child: Text(
                      whatTime(DateTime.fromMillisecondsSinceEpoch(int.parse(document.get('timestamp')))),
                      style: TextStyle(color: greyColor, fontSize: 12.0, fontStyle: FontStyle.italic),
                    ),
                    margin: EdgeInsets.only(right: 10.0, top: 5.0, bottom: 5.0),
                  )
                : Container()
          ],
          crossAxisAlignment: CrossAxisAlignment.end,
        ));
      } else {
        // 상대방 메세지는 왼쪽에 ( 사진, 텍스트 순서)
        return Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  isFirstMessageLeft(index)
                      ? FutureBuilder(
                          future: getAvatar(document.get('idFrom')),
                          builder: (context, AsyncSnapshot snapshot) {
                            if (snapshot.hasData) {
                              return Material(
                                child: Image.network(
                                  snapshot.data,
                                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Center(
                                      child: CircularProgressIndicator(
                                        color: primaryColor,
                                        value: loadingProgress.expectedTotalBytes != null && loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, object, stackTrace) {
                                    return Icon(
                                      Icons.account_circle,
                                      size: 35,
                                      color: greyColor,
                                    );
                                  },
                                  width: 35,
                                  height: 35,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.all(
                                  Radius.circular(18.0),
                                ),
                                clipBehavior: Clip.hardEdge,
                              );
                            } else {
                              return CircularProgressIndicator();
                            }
                          })
                      : Container(width: 35.0),
                  document.get('type') == 0
                      ? Container(
                          child: Text(
                            document.get('content'),
                            style: TextStyle(color: Colors.white),
                          ),
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          width: 200.0,
                          decoration: BoxDecoration(color: Color(0xff4E94EC), borderRadius: BorderRadius.circular(8.0)),
                          margin: EdgeInsets.only(left: 10.0),
                        )
                      : Container(
                          child: TextButton(
                            child: Material(
                              child: Image.network(
                                document.get('content'),
                                loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: Color(0xff4E94EC),
                                      borderRadius: BorderRadius.all(
                                        Radius.circular(8.0),
                                      ),
                                    ),
                                    width: 200.0,
                                    height: 200.0,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: primaryColor,
                                        value: loadingProgress.expectedTotalBytes != null && loadingProgress.expectedTotalBytes != null ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes! : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, object, stackTrace) => Material(
                                  child: Image.asset(
                                    'images/img_not_available.jpeg',
                                    width: 200.0,
                                    height: 200.0,
                                    fit: BoxFit.cover,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(8.0),
                                  ),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                width: 200.0,
                                height: 200.0,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.all(Radius.circular(8.0)),
                              clipBehavior: Clip.hardEdge,
                            ),
                            onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => FullPhoto(url: document.get('content'))));
                            },
                            style: ButtonStyle(padding: MaterialStateProperty.all<EdgeInsets>(EdgeInsets.all(0))),
                          ),
                          margin: EdgeInsets.only(left: 10.0),
                        ),
                ],
              ),

              // 메세지 보낸 시간 표시
              isLastMessageLeft(index)
                  ? Container(
                      child: Text(
                        whatTime(DateTime.fromMillisecondsSinceEpoch(int.parse(document.get('timestamp')))),
                        style: TextStyle(color: greyColor, fontSize: 12.0, fontStyle: FontStyle.italic),
                      ),
                      margin: EdgeInsets.only(left: 50.0, top: 5.0, bottom: 5.0),
                    )
                  : Container()
            ],
            crossAxisAlignment: CrossAxisAlignment.start,
          ),
          margin: EdgeInsets.only(bottom: 10.0),
        );
      }
    } else {
      return SizedBox.shrink();
    }
  }

  //뒤로 가기 누르면 chattingWith를 다시 null 상태로
  Future<bool> onBackPress() {
    fs.collection('users').doc(myId).update({'chattingWith': null});
    Navigator.pop(context);

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Stack(
        children: <Widget>[
          Column(
            children: <Widget>[
              // List of messages
              buildListMessage(),

              // Input content
              buildInput(),
            ],
          ),

          // Loading
          buildLoading()
        ],
      ),
      onWillPop: onBackPress,
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: peerIds.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(myId).collection('messageWith').doc(groupChatId).collection('messages').orderBy('timestamp', descending: true).limit(_limit).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listMessage = [];
                  listMessage.addAll(snapshot.data!.docs);
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) {
                      return Column(
                        children: [isDiffDay(index) ? whatDay(DateTime.fromMillisecondsSinceEpoch(int.parse(snapshot.data?.docs[index].get('timestamp')))) : Text(''), buildItem(index, snapshot.data?.docs[index])],
                      );
                    },
                    itemCount: snapshot.data?.docs.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                } else {
                  return Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
                    ),
                  );
                }
              },
            )
          : Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
    );
  }

  // 메세지 입력 칸
  Widget buildInput() {
    return Container(
      child: Row(
        children: <Widget>[
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                onPressed: getImage,
                color: Color(0xff4E94EC),
              ),
            ),
            color: Colors.white,
          ),
          Flexible(
            child: Container(
              child: TextField(
                onSubmitted: (value) {
                  onSendMessage(textEditingController.text, 0);
                },
                style: TextStyle(color: primaryColor, fontSize: 15.0),
                controller: textEditingController,
                decoration: InputDecoration.collapsed(
                  hintText: 'Type your message...',
                  hintStyle: TextStyle(color: greyColor),
                ),
                focusNode: focusNode,
              ),
            ),
          ),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: Color(0xff4E94EC),
              ),
            ),
            color: Colors.white,
          ),
        ],
      ),
      width: double.infinity,
      height: 50.0,
      decoration: BoxDecoration(border: Border(top: BorderSide(color: greyColor2, width: 0.5)), color: Colors.white),
    );
  }

  // 로딩중 화면
  Widget buildLoading() {
    return Positioned(
      child: isLoading ? const Loading() : Container(),
    );
  }
}

class Choice {
  const Choice({required this.title, required this.icon});

  final String title;
  final IconData icon;
}
