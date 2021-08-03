import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:usdh/chat/const.dart';
import 'package:usdh/chat/home.dart';
import 'package:usdh/function/signedin_page.dart';
import 'package:usdh/chat/widget/loading.dart';
import 'package:usdh/chat/widget/full_photo.dart';

class Chat extends StatefulWidget {
  final String myId;
  final List<dynamic> peerIds; // chat에 참가한 유저의 email들
  final String groupChatId;

  Chat({Key? key, required this.myId, required this.peerIds, required this.groupChatId}) : super(key: key);

  @override
  State createState() => ChatState(myId: myId, peerIds: peerIds, groupChatId: groupChatId);
}

// 채팅방 내부
class ChatState extends State<Chat> {
  final String myId;
  final List<dynamic> peerIds; // chat에 참가한 유저의 email들
  final String groupChatId;

  ChatState({Key? key, required this.myId, required this.peerIds, required this.groupChatId});

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
    // 참가 중인 방 목록에서 제거
    await FirebaseFirestore.instance.collection('users').doc(myId).update({
      'joiningIn': FieldValue.arrayRemove([groupChatId])
    });
    // 메세지 기록 제거 (본인, 그룹 멤버들)
    // 본인
    await FirebaseFirestore.instance.collection('users').doc(myId).collection('messageWith').doc(groupChatId).collection('messages').get().then((value) {
      if (value.docs.isNotEmpty) {
        for (DocumentSnapshot ds in value.docs) {
          ds.reference.delete();
        }
      }
    });
    await FirebaseFirestore.instance.collection('users').doc(myId).collection('messageWith').doc(groupChatId).delete();
    // 다른 멤버
    for (var peerId in peerIds) {
      await FirebaseFirestore.instance.collection('users').doc(peerId).collection('messageWith').doc(groupChatId).update({
        'chatMembers': FieldValue.arrayRemove([myId])
      });
    }
    // post의 currentMember - 1 해줌
    int currentMember = 0;
    await FirebaseFirestore.instance.collection('delivery_board').doc(groupChatId).get().then((value) {
      currentMember = value['currentMember'];
    });
    await FirebaseFirestore.instance.collection('delivery_board').doc(groupChatId).update({
      'currentMember': currentMember - 1,
      'members': FieldValue.arrayRemove([myId]),
    });

    Navigator.of(context).pop();
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
        title: Text(
          '채팅',
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        // 채팅방 내의 퇴장, 설정 버튼
        actions: <Widget>[
          PopupMenuButton<Choice>(
            onSelected: onItemMenuPress,
            itemBuilder: (BuildContext context) {
              return choices.map((Choice choice) {
                return PopupMenuItem<Choice>(
                    value: choice,
                    child: Row(
                      children: <Widget>[
                        Icon(
                          choice.icon,
                          color: primaryColor,
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
        ],
      ),
      body: ChatScreen(
        myId: myId,
        peerIds: peerIds, // 채팅방 멤버들의 emails
        peerAvatars: getPeerAvatar(), // 채팅방 멤버들의 photoUrls
        groupChatId: groupChatId,
      ),
    );
  }
}

class ChatScreen extends StatefulWidget {
  final String myId;
  final List<dynamic> peerIds;
  final Future<List<String>> peerAvatars;
  final String groupChatId;

  ChatScreen({Key? key, required this.myId, required this.peerIds, required this.peerAvatars, required this.groupChatId}) : super(key: key);

  @override
  State createState() => ChatScreenState(myId: myId, peerIds: peerIds, peerAvatars: peerAvatars, groupChatId: groupChatId);
}

class ChatScreenState extends State<ChatScreen> {
  ChatScreenState({Key? key, required this.myId, required this.peerIds, required this.peerAvatars, required this.groupChatId});

  final String myId;
  final List<dynamic> peerIds;
  final Future<List<String>> peerAvatars;
  final String groupChatId;

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

  // 어플을 껐다 켜도 데이터 유지되도록
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
    await FirebaseFirestore.instance.collection('users').doc(myId).collection('messageWith').doc(groupChatId).set({
      'chatMembers': peerIds,
    });

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
      await FirebaseFirestore.instance.collection('users').doc(peerId).collection('messageWith').doc(groupChatId).set({
        'chatMembers': _peerIds,
      });
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

  void getSticker() {
    // Hide keyboard when sticker appear
    focusNode.unfocus();
    setState(() {
      isShowSticker = !isShowSticker;
    });
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

  // 메세지 보내기
  void onSendMessage(String content, int type) {
    // type: 0 = text, 1 = image, 2 = sticker
    if (content.trim() != '') {
      textEditingController.clear();

      var myDocumentReference = FirebaseFirestore.instance.collection('users').doc(myId).collection('messageWith').doc(groupChatId).collection('messages').doc(DateTime.now().millisecondsSinceEpoch.toString());

      var peersDocumentReference = [];
      for (var peerId in peerIds) {
        peersDocumentReference.add(FirebaseFirestore.instance.collection('users').doc(peerId).collection('messageWith').doc(groupChatId).collection('messages').doc(DateTime.now().millisecondsSinceEpoch.toString()));
      }

      // 나와 상대의 메세지를 firestore에 동시에 저장
      FirebaseFirestore.instance.runTransaction((transaction) async {
        // 내 messages에 기록
        transaction.set(
          myDocumentReference,
          {'idFrom': myId, 'idTo': peerIds, 'timestamp': DateTime.now().millisecondsSinceEpoch.toString(), 'content': content, 'type': type},
        );
        // 상대 messages에 기록
        for (var peerDocumentReference in peersDocumentReference) {
          transaction.set(
            peerDocumentReference,
            {'idFrom': myId, 'idTo': peerIds, 'timestamp': DateTime.now().millisecondsSinceEpoch.toString(), 'content': content, 'type': type},
          );
        }
      });

      listScrollController.animateTo(0.0, duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Fluttertoast.showToast(msg: 'Nothing to send', backgroundColor: Colors.black, textColor: Colors.red);
    }
  }

  // 채팅방 내부 메세지 블럭 생성
  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      if (document.get('idFrom') == myId) {
        // 내가 보낸 메세지는 오른쪽에 ( 텍스트, 사진 순서)
        return Row(
          children: <Widget>[
            document.get('type') == 0
                // 내가 보낸 메세지 텍스트 - type == 0
                ? Container(
                    child: Text(
                      document.get('content'),
                      style: TextStyle(color: primaryColor),
                    ),
                    padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                    width: 200.0,
                    decoration: BoxDecoration(color: greyColor2, borderRadius: BorderRadius.circular(8.0)),
                    margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                  )
                : document.get('type') == 1
                    // 내가 보낸 사진 - type == 1
                    ? Container(
                        child: OutlinedButton(
                          child: Material(
                            child: Image.network(
                              document.get("content"),
                              loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                if (loadingProgress == null) return child;
                                return Container(
                                  decoration: BoxDecoration(
                                    color: greyColor2,
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
                      )
                    // 내가 보낸 이모티콘 - type == 2
                    : Container(
                        child: Image.asset(
                          'images/${document.get('content')}.gif',
                          width: 100.0,
                          height: 100.0,
                          fit: BoxFit.cover,
                        ),
                        margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                      ),
          ],
          mainAxisAlignment: MainAxisAlignment.end,
        );
      } else {
        // 상대방 메세지는 왼쪽에 ( 사진, 텍스트 순서)
        return Container(
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  isLastMessageLeft(index)
                      ? Material(
                          child: Image.network(
                            '',
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
                        )
                      : Container(width: 35.0),
                  document.get('type') == 0
                      ? Container(
                          child: Text(
                            document.get('content'),
                            style: TextStyle(color: Colors.white),
                          ),
                          padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
                          width: 200.0,
                          decoration: BoxDecoration(color: primaryColor, borderRadius: BorderRadius.circular(8.0)),
                          margin: EdgeInsets.only(left: 10.0),
                        )
                      : document.get('type') == 1
                          ? Container(
                              child: TextButton(
                                child: Material(
                                  child: Image.network(
                                    document.get('content'),
                                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        decoration: BoxDecoration(
                                          color: greyColor2,
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
                            )
                          : Container(
                              child: Image.asset(
                                'images/${document.get('content')}.gif',
                                width: 100.0,
                                height: 100.0,
                                fit: BoxFit.cover,
                              ),
                              margin: EdgeInsets.only(bottom: isLastMessageRight(index) ? 20.0 : 10.0, right: 10.0),
                            ),
                ],
              ),

              // 메세지 보낸 시간 표시
              isLastMessageLeft(index)
                  ? Container(
                      child: Text(
                        DateFormat('dd MMM kk:mm').format(DateTime.fromMillisecondsSinceEpoch(int.parse(document.get('timestamp')))),
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

  // 내가 메시지 보낸 시간
  bool isLastMessageLeft(int index) {
    if ((index > 0 && listMessage[index - 1].get('idFrom') == myId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  // 상대가 메시지 보낸 시간
  bool isLastMessageRight(int index) {
    if ((index > 0 && listMessage[index - 1].get('idFrom') != myId) || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  // 뒤로 가기 누르면 chattingWith를 다시 null 상태로
  Future<bool> onBackPress() {
    if (isShowSticker) {
      setState(() {
        isShowSticker = false;
      });
    } else {
      FirebaseFirestore.instance.collection('users').doc(myId).update({'chattingWith': null});
      Navigator.pop(context);
    }

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

              // Sticker(이모티콘 창 누르면 타자기는 내려가게)
              isShowSticker ? buildSticker() : Container(),

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

  // 다시 켜면 끄기 전 상태 유지
  Widget buildListMessage() {
    return Flexible(
      child: peerIds.isNotEmpty
          ? StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('users').doc(myId).collection('messageWith').doc(groupChatId).collection('messages').orderBy('timestamp', descending: true).limit(_limit).snapshots(),
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasData) {
                  listMessage.addAll(snapshot.data!.docs); // 모든 메세지 get
                  return ListView.builder(
                    padding: EdgeInsets.all(10.0),
                    itemBuilder: (context, index) => buildItem(index, snapshot.data?.docs[index]),
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
          // 이미지 전송 버튼
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.image),
                onPressed: getImage,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: Icon(Icons.face),
                onPressed: getSticker,
                color: primaryColor,
              ),
            ),
            color: Colors.white,
          ),

          // 메세지 텍스트 입력 칸
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

          // 메세지 전송 버튼
          Material(
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: primaryColor,
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

  // 이모티콘 구현
  Widget buildSticker() {
    return Expanded(
      child: Container(
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage('mimi1', 2),
                  child: Image.asset(
                    'images/mimi1.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi2', 2),
                  child: Image.asset(
                    'images/mimi2.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi3', 2),
                  child: Image.asset(
                    'images/mimi3.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage('mimi4', 2),
                  child: Image.asset(
                    'images/mimi4.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi5', 2),
                  child: Image.asset(
                    'images/mimi5.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi6', 2),
                  child: Image.asset(
                    'images/mimi6.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            ),
            Row(
              children: <Widget>[
                TextButton(
                  onPressed: () => onSendMessage('mimi7', 2),
                  child: Image.asset(
                    'images/mimi7.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi8', 2),
                  child: Image.asset(
                    'images/mimi8.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage('mimi9', 2),
                  child: Image.asset(
                    'images/mimi9.gif',
                    width: 50.0,
                    height: 50.0,
                    fit: BoxFit.cover,
                  ),
                )
              ],
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            )
          ],
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        ),
        decoration: BoxDecoration(border: Border(top: BorderSide(color: greyColor2, width: 0.5)), color: Colors.white),
        padding: EdgeInsets.all(5.0),
        height: 180.0,
      ),
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
