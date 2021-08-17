import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdh/Widget/widget.dart';
import 'package:usdh/login/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:usdh/chat/home.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

late CommunityWriteState pageState;
late CommunityListState pageState2;
late CommunityShowState pageState3;
late CommunityModifyState pageState4;

class Choice {
  const Choice({required this.title, required this.icon});

  final String title;
  final IconData icon;
}

String howLongAgo(String time) {
  //String now = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
  String now = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
  if (time.substring(0, 4).compareTo(now.substring(0, 4)) == -1) {
    int diff = int.parse(now.substring(0, 4)) - int.parse(time.substring(0, 4));
    return diff.toString() + "년전";
  } else if (time.substring(5, 7).compareTo(now.substring(5, 7)) == -1) {
    int diff = int.parse(now.substring(5, 7)) - int.parse(time.substring(5, 7));
    return diff.toString() + "달전";
  } else if (time.substring(8, 10).compareTo(now.substring(8, 10)) == -1) {
    int diff = int.parse(now.substring(8, 10)) - int.parse(time.substring(8, 10));
    return diff.toString() + "일전";
  } else if (time.substring(11, 13).compareTo(now.substring(11, 13)) == -1) {
    int diff = int.parse(now.substring(11, 13)) - int.parse(time.substring(11, 13));
    return diff.toString() + "시간전";
  } else if (time.substring(14, 16).compareTo(now.substring(14, 16)) == -1) {
    int diff = int.parse(now.substring(14, 16)) - int.parse(time.substring(14, 16));
    return diff.toString() + "분전";
  } else {
    int diff = int.parse(now.substring(17, 19)) - int.parse(time.substring(17, 19));
    return diff.toString() + "초전";
  }
}

/* ---------------------- Write Board (Community) ---------------------- */

class CommunityWrite extends StatefulWidget {
  @override
  CommunityWriteState createState() {
    pageState = CommunityWriteState();
    return pageState;
  }
}

class CommunityWriteState extends State<CommunityWrite> {
  late FirebaseProvider fp;
  TextEditingController titleInput = TextEditingController();
  TextEditingController contentInput = TextEditingController();
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseFirestore fs = FirebaseFirestore.instance;
  final _picker = ImagePicker();
  List urlList = [];

  final _formKey = GlobalKey<FormState>();
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

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
        body: SingleChildScrollView(
            child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              cSizedBox(35, 0),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Image.asset('assets/images/icon/iconback.png', width: 22, height: 22),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  headerText("글 작성"),
                  cSizedBox(0, 160),
                  IconButton(
                      icon: Icon(
                        Icons.check,
                        color: Color(0xff639ee1),
                      ),
                      onPressed: () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        if (_formKey.currentState!.validate()) {
                          uploadOnFS();
                          Navigator.pop(context);
                        }
                      }),
                ],
              ),
              headerDivider(),
              Padding(
                padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                child: Column(
                  children: [
                    Container(width: MediaQuery.of(context).size.width * 0.8, child: titleField(titleInput)),
                  ],
                ),
              ),
              Divider(
                color: Color(0xffe9e9e9),
                thickness: 2.5,
              ),
              Padding(
                  padding: EdgeInsets.fromLTRB(40, 10, 40, 30),
                  child: TextFormField(
                      controller: contentInput,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      style: TextStyle(fontSize: 14),
                      decoration: InputDecoration(
                        hintText: "내용을 입력하세요.",
                        border: InputBorder.none,
                      ),
                      validator: (text) {
                        if (text == null || text.isEmpty) {
                          return "내용은 필수 입력 사항입니다.";
                        }
                        return null;
                      })),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  ElevatedButton(
                      child: Text("갤러리에서 불러오기"),
                      onPressed: () {
                        uploadImage();
                      }),
                ],
              ),
              Divider(
                color: Colors.black,
              ),
              urlList.isEmpty
                  ? Container()
                  : Container(
                      height: 300,
                      child: ListView.builder(
                          itemCount: urlList.length,
                          itemBuilder: (BuildContext context, int idx) {
                            return Card(
                              child: Column(
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      deleteImage(urlList[idx]);
                                    },
                                    child: Text("X"),
                                  ),
                                  Image.network(urlList[idx]),
                                ],
                              ),
                            );
                          }),
                    ),
            ],
          ),
        )));
  }

  void uploadImage() async {
    final pickedImgList = await _picker.pickMultiImage();

    List<String> pickUrlList = [];

    var tmp = fp.getInfo();

    late Reference ref;
    for (int i = 0; i < pickedImgList!.length; i++) {
      ref = storage.ref().child('board/${tmp['nick'] + tmp['piccount'].toString()}');
      await ref.putFile(File(pickedImgList[i].path));
      fp.updateIntInfo('piccount', 1);
      String url = await ref.getDownloadURL();
      pickUrlList.add(url);
    }

    setState(() {
      urlList = pickUrlList;
    });
  }

  void deleteImage(String url) async {
    Reference ref = storage.refFromURL(url);
    await ref.delete();
    fp.updateIntInfo("piccount", -1);

    setState(() {
      urlList.remove(url);
    });
  }

  void uploadOnFS() async {
    var myInfo = fp.getInfo();
    await fs.collection('community_board').doc(myInfo['nick'] + myInfo['postcount'].toString()).set({
      'commentCount': 0,
      'contents': contentInput.text,
      'likeCount': 0,
      'title': titleInput.text,
      'pic': urlList,
      'views': 0,
      'whoLike': [],
      'write_time': formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]),
      'writer': myInfo['nick'],
    });
    fp.updateIntInfo('postcount', 1);
  }
}

// class _Chip extends StatelessWidget {
//   const _Chip({
//     required this.label,
//     required this.onDeleted,
//     required this.index,
//   });
//   final String label;
//   final ValueChanged<int> onDeleted;
//   final int index;
//   @override
//   Widget build(BuildContext context) {
//     return Chip(
//       labelStyle: TextStyle(fontFamily: "SCDream", color: Color(0xffa9aaaf), fontWeight: FontWeight.w500, fontSize: 11.5),
//       labelPadding: EdgeInsets.only(left: 10),
//       backgroundColor: Color(0xff639ee1).withOpacity(0.7),
//       label: smallText(label, 11, Colors.white),
//       deleteIcon: const Icon(
//         Icons.close,
//         color: Colors.white,
//         size: 13,
//       ),
//       onDeleted: () {
//         onDeleted(index);
//       },
//     );
//   }
// }

/* ---------------------- Board List (Community) ---------------------- */

class CommunityList extends StatefulWidget {
  @override
  CommunityListState createState() {
    pageState2 = CommunityListState();
    return pageState2;
  }
}

class CommunityListState extends State<CommunityList> {
  Stream<QuerySnapshot> colstream = FirebaseFirestore.instance.collection('community_board').orderBy("write_time", descending: true).snapshots();
  late FirebaseProvider fp;
  final _formKey = GlobalKey<FormState>();
  TextEditingController searchInput = TextEditingController();
  String search = "";
  bool status = false;
  String limit = "";

  @override
  void initState() {
    search = "제목";
    super.initState();
  }

  @override
  void dispose() {
    searchInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();

    return Scaffold(
      body: RefreshIndicator(
        //당겨서 새로고침
        onRefresh: () async {
          setState(() {
            colstream = FirebaseFirestore.instance.collection('community_board').orderBy("write_time", descending: true).snapshots();
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
                Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Image.asset('assets/images/icon/iconback.png', width: 22, height: 22),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      headerText("커뮤니티"),
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
                                colstream = FirebaseFirestore.instance.collection('community_board').orderBy("write_time", descending: true).snapshots();
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
                                    return StatefulBuilder(builder: (con, setS) {
                                      return Form(
                                          key: _formKey,
                                          child: AlertDialog(
                                            content: TextFormField(
                                                controller: searchInput,
                                                decoration: InputDecoration(hintText: "검색할 제목을 입력하세요."),
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
                                                      setState(() {
                                                        colstream = FirebaseFirestore.instance.collection('community_board').orderBy('title').startAt([searchInput.text]).endAt([searchInput.text + '\uf8ff']).snapshots();
                                                      });
                                                      searchInput.clear();
                                                      Navigator.pop(con);
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
                          //채팅 기능
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
                headerDivider(),
                Expanded(
                    // 아래 간격 두고 싶으면 Container, height 사용
                    //height: MediaQuery.of(context).size.height * 0.8,
                    child: MediaQuery.removePadding(
                  context: context,
                  removeTop: true,
                  child: ListView.separated(
                      separatorBuilder: (context, index) => middleDivider(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final DocumentSnapshot doc = snapshot.data!.docs[index];
                        String time = doc['write_time'] + ' | ';
                        String writer = doc['writer'];
                        return Column(children: [
                          Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                          InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityShow(doc.id)));
                                FirebaseFirestore.instance.collection('community_board').doc(doc.id).update({"views": doc["views"] + 1});
                              },
                              child: Container(
                                  margin: EdgeInsets.fromLTRB(25, 17, 10, 0),
                                  child: Column(children: [
                                    Row(children: [
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.6,
                                        child: Text(doc['title'].toString(), overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: "SCDream", fontWeight: FontWeight.w700, fontSize: 15)),
                                      ),
                                      cSizedBox(35, 0),
                                    ]),
                                    Row(
                                      children: [
                                        cSizedBox(20, 5),
                                        smallText(time, 10, Color(0xffa9aaaf)),
                                        smallText(writer, 10, Color(0xffa9aaaf)),
                                      ],
                                    ),
                                    cSizedBox(10, 0)
                                  ])))
                        ]);
                      }),
                )),
              ]);
            }),
      ),
      floatingActionButton: FloatingActionButton(
          backgroundColor: Color(0xff639ee1),
          child: Image(
            image: AssetImage('assets/images/icon/iconpencil.png'),
            height: 28,
            width: 28,
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityWrite()));
          }),
    );
  }
}

/* ---------------------- Show Board (Community) ---------------------- */

class CommunityShow extends StatefulWidget {
  CommunityShow(this.id);
  final String id;

  @override
  CommunityShowState createState() {
    pageState3 = CommunityShowState(id: id);
    return pageState3;
  }
}

class CommunityShowState extends State<CommunityShow> {
  final String id;

  CommunityShowState({Key? key, required this.id});

  late FirebaseProvider fp;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore fs = FirebaseFirestore.instance;
  TextEditingController commentInput = TextEditingController();
  TextEditingController recommentInput = TextEditingController();

  // 댓글 수정, 삭제 버튼 생성(버튼이름, 아이콘)
  List<Choice> myChoices = const <Choice>[
    const Choice(title: '삭제', icon: Icons.delete),
  ];

  List<Choice> otherChoices = const <Choice>[
    const Choice(title: '신고', icon: Icons.sports_bar),
    const Choice(title: '뭔가', icon: Icons.sports_baseball),
  ];

  SharedPreferences? prefs;
  bool alreadyLiked = false;
  bool isOnCcoment = false;

  @override
  void initState() {
    super.initState();
    readLocal();
  }

  readLocal() async {
    prefs = await SharedPreferences.getInstance();
    alreadyLiked = prefs?.getBool('alreadyLiked') ?? false;
  }

  @override
  void dispose() {
    commentInput.dispose();
    recommentInput.dispose();
    super.dispose();
  }

  Future<Null> deleteComment(String commentId) async {
    await fs.collection('community_board').doc(id).collection('comments').doc(commentId).delete();
    print('댓글 삭제');
  }

  Future<Null> reportComment(String commentId) async {
    print('댓글 신고');
  }

  @override
  Widget build(BuildContext context) {
    Stream<DocumentSnapshot> boardStream = fs.collection('community_board').doc(widget.id).snapshots();
    Stream<QuerySnapshot> commentsStream = fs.collection('community_board').doc(widget.id).collection('comments').snapshots();

    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();

    Future<String?> getPhotoUrl(dynamic nick) async {
      String? photoUrl;
      await fs.collection('users').where('nick', isEqualTo: nick).get().then((snapshot) {
        photoUrl = snapshot.docs[0].get('photoUrl');
      });
      return photoUrl;
    }

    Widget commentsSection(AsyncSnapshot<QuerySnapshot> commentsSnapshot, String myNick) {
      if (commentsSnapshot.data != null) {
        return Container(
          child: ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: commentsSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              void onItemMenuPress(Choice choice) {
                if (choice.title == '삭제') {
                  deleteComment(commentsSnapshot.data!.docs[index].id);
                } else if (choice.title == '신고') {
                  reportComment(commentsSnapshot.data!.docs[index].id);
                } else if (choice.title == '뭔가') {
                  print('댓글 뭔가');
                }
              }

              DateTime dateTime = Timestamp.fromMillisecondsSinceEpoch(int.parse(commentsSnapshot.data!.docs[index].get('timestamp'))).toDate();
              return Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //프사
                    FutureBuilder(
                        future: getPhotoUrl(commentsSnapshot.data!.docs[index].get('commentFrom')),
                        builder: (context, AsyncSnapshot snapshot) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(60),
                            child: Image.network(
                              snapshot.data.toString(),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          );
                        }),
                    //1층: 닉넴, 댓글내용, 2층: 글쓴시간, 좋아요개수, 대댓글버튼(수정필요)
                    Column(
                      children: [
                        Row(
                          children: [
                            Text(commentsSnapshot.data!.docs[index].get('commentFrom'), style: TextStyle(fontSize: 14)),
                            cSizedBox(0, 35),
                            Text(commentsSnapshot.data!.docs[index].get('comment'), style: TextStyle(fontSize: 14)),
                          ],
                        ),
                        Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                        Row(
                          children: [
                            Text(howLongAgo(formatDate(dateTime, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]))),
                            cSizedBox(0, 10),
                            StreamBuilder(
                                stream: fs.collection('community_board').doc(widget.id).collection('comments').doc(commentsSnapshot.data!.docs[index].id).snapshots(),
                                builder: (context, AsyncSnapshot snapshot) {
                                  if (snapshot.hasData) {
                                    int _likeCount = snapshot.data!['likeCount'];
                                    if (_likeCount != 0) {
                                      return Text("좋아요 " + snapshot.data!['likeCount'].toString() + "개", style: TextStyle(fontSize: 14));
                                    }
                                    return Text('');
                                  } else {
                                    return CircularProgressIndicator();
                                  }
                                }),
                            cSizedBox(0, 10),
                            IconButton(
                              icon: Icon(Icons.chat),
                              onPressed: () async {
                                print('대댓글 추가...');
                              },
                            )
                          ],
                        ),
                      ],
                    ),
                    //좋아요
                    StreamBuilder(
                        stream: fs.collection('community_board').doc(widget.id).collection('comments').doc(commentsSnapshot.data!.docs[index].id).snapshots(),
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            List<dynamic> whoLike = snapshot.data!['whoLike'];
                            bool alreadyLiked = false;
                            if (whoLike.contains(myNick)) {
                              alreadyLiked = true;
                            }
                            return IconButton(
                                icon: Icon(alreadyLiked ? Icons.favorite : Icons.favorite_border, color: Color(0xff548ee0)),
                                onPressed: () async {
                                  List<dynamic> whoLike = [];
                                  await fs.collection('community_board').doc(widget.id).collection('comments').doc(commentsSnapshot.data!.docs[index].id).get().then((value) {
                                    for (var who in value['whoLike']) {
                                      whoLike.add(who);
                                    }
                                  });
                                  if (!whoLike.contains(myNick)) {
                                    await fs.collection('community_board').doc(widget.id).collection('comments').doc(commentsSnapshot.data!.docs[index].id).update({
                                      'likeCount': FieldValue.increment(1),
                                      'whoLike': FieldValue.arrayUnion([myNick])
                                    });
                                  } else {
                                    await fs.collection('community_board').doc(widget.id).collection('comments').doc(commentsSnapshot.data!.docs[index].id).update({
                                      'likeCount': FieldValue.increment(-1),
                                      'whoLike': FieldValue.arrayRemove([myNick])
                                    });
                                  }
                                });
                          } else {
                            return CircularProgressIndicator();
                          }
                        }),
                    myNick == commentsSnapshot.data!.docs[index].get('commentFrom') ?
                      //삭제 팝업 버튼
                      PopupMenuButton<Choice>(
                        onSelected: onItemMenuPress,
                        itemBuilder: (context) {
                          return myChoices.map((Choice choice) {
                            return PopupMenuItem<Choice>(
                              value: choice,
                              child: Row(
                                children: [Icon(choice.icon), Container(width: 10.0), Text(choice.title)],
                              ),
                            );
                          }).toList();
                        },
                      ) : PopupMenuButton<Choice>(
                        onSelected: onItemMenuPress,
                        itemBuilder: (context) {
                          return otherChoices.map((Choice choice) {
                            return PopupMenuItem<Choice>(
                              value: choice,
                              child: Row(
                                children: [Icon(choice.icon), Container(width: 10.0), Text(choice.title)],
                              ),
                            );
                          }).toList();
                        },
                      ),
                  ],
                ),
                // middleDivider(),
                // Text('test text container?'),
                headerDivider(),
              ]);
            },
          ),
        );
      }
      return Container();
    }

    return Scaffold(
        body: StreamBuilder(
            stream: boardStream,
            builder: (context, AsyncSnapshot<DocumentSnapshot> boardSnapshot) {
              return StreamBuilder(
                stream: commentsStream,
                builder: (context, AsyncSnapshot<QuerySnapshot> commentsSnapshot) {
                  fp.setInfo();

                  if (boardSnapshot.hasData && !boardSnapshot.data!.exists) {
                    return CircularProgressIndicator();
                  } else if (boardSnapshot.hasData) {
                    var myInfo = fp.getInfo();
                    String writeTime = boardSnapshot.data!['write_time'].substring(10, 16) + ' | ';
                    String writer = boardSnapshot.data!['writer'];
                    return SingleChildScrollView(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        cSizedBox(35, 0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Image.asset('assets/images/icon/iconback.png', width: 22, height: 22),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            headerText("커뮤니티"),
                            cSizedBox(0, 175),
                            IconButton(
                              icon: Image.asset('assets/images/icon/iconmessage.png', width: 22, height: 22),
                              onPressed: () {
                                var myInfo = fp.getInfo();
                                Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(myId: myInfo['email'])));
                              },
                            ),
                          ],
                        ),
                        headerDivider(),
                        Padding(
                            padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                            child: Wrap(direction: Axis.vertical, spacing: 15, children: [
                              Container(width: MediaQuery.of(context).size.width * 0.8, child: titleText(boardSnapshot.data!['title'])),
                              smallText("작성일 " + writeTime + "작성자 " + writer + " | 조회수 " + boardSnapshot.data!['views'].toString(), 11.5, Color(0xffa9aaaf))
                            ])),
                        Divider(
                          color: Color(0xffe9e9e9),
                          thickness: 15,
                        ),
                        Padding(
                          padding: EdgeInsets.fromLTRB(50, 30, 50, 30),
                          child: Text(boardSnapshot.data!['contents'], style: TextStyle(fontSize: 14)),
                        ),
                        boardSnapshot.data!['pic'].isEmpty
                            ? Container()
                            : Container(
                                height: 300,
                                child: ListView.builder(
                                    itemCount: boardSnapshot.data!['pic'].length,
                                    itemBuilder: (BuildContext context, int idx) {
                                      return Image.network(boardSnapshot.data!['pic'][idx]);
                                    }),
                              ),
                        // 좋아요
                        headerDivider(),
                        StreamBuilder(
                            stream: fs.collection('community_board').doc(widget.id).snapshots(),
                            builder: (context, AsyncSnapshot snapshot) {
                              if (snapshot.hasData) {
                                List<dynamic> whoLike = snapshot.data!['whoLike'];
                                bool alreadyLiked = false;
                                if (whoLike.contains(myInfo['nick'])) {
                                  alreadyLiked = true;
                                }
                                return Column(
                                  children: [
                                    IconButton(
                                        icon: Icon(alreadyLiked ? Icons.favorite : Icons.favorite_border, color: Color(0xff548ee0)),
                                        onPressed: () async {
                                          List<dynamic> whoLike = [];
                                          await fs.collection('community_board').doc(widget.id).get().then((value) {
                                            for (var who in value['whoLike']) {
                                              whoLike.add(who);
                                            }
                                          });
                                          if (!whoLike.contains(myInfo['nick'])) {
                                            await fs.collection('community_board').doc(widget.id).update({
                                              'likeCount': FieldValue.increment(1),
                                              'whoLike': FieldValue.arrayUnion([myInfo['nick']])
                                            });
                                          } else {
                                            await fs.collection('community_board').doc(widget.id).update({
                                              'likeCount': FieldValue.increment(-1),
                                              'whoLike': FieldValue.arrayRemove([myInfo['nick']])
                                            });
                                          }
                                        }),
                                    StreamBuilder(
                                      stream: fs.collection('community_board').doc(widget.id).snapshots(),
                                      builder: (context, AsyncSnapshot snapshot) {
                                        if (snapshot.hasData) {
                                          int _likeCount = snapshot.data!['likeCount'];
                                          if (_likeCount != 0) {
                                            return Text("좋아요 " + snapshot.data!['likeCount'].toString() + "개", style: TextStyle(fontSize: 14));
                                          }
                                          return Text('');
                                        } else {
                                          return CircularProgressIndicator();
                                        }
                                      }),
                                  ],
                                );
                              } else {
                                return CircularProgressIndicator();
                              }
                            }),
                        headerDivider(),
                        // 댓글쓰기
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 30,
                                child: TextField(
                                  controller: commentInput,
                                  decoration: InputDecoration(hintText: "코멘트를 남기세요."),
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(Icons.send),
                              onPressed: () {
                                FocusScope.of(context).requestFocus(new FocusNode());
                                if (commentInput.text.isNotEmpty) {
                                  commentUploadOnFS();
                                }
                              },
                            ),
                          ],
                        ),
                        // 댓글들
                        commentsSection(commentsSnapshot, myInfo['nick']),
                      ],
                    ));
                  } else {
                    return CircularProgressIndicator();
                  }
                },
              );
            }),
        bottomNavigationBar: StreamBuilder(
            stream: fs.collection('community_board').doc(widget.id).snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData && !snapshot.data!.exists) {
                return CircularProgressIndicator();
              } else if (snapshot.hasData) {
                fp.setInfo();
                if (fp.getInfo()['nick'] == snapshot.data!['writer']) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xffcacaca),
                        ),
                        child: GestureDetector(
                          child: Align(alignment: Alignment.center, child: smallText("삭제", 14, Colors.white)),
                          onTap: () async {
                            var urlList = snapshot.data!['pic'];
                            for (int i = 0; i < urlList.length; i++) {
                              Reference ref = storage.refFromURL(urlList[i]);
                              ref.delete();
                            }
                            Navigator.pop(context);
                            await fs.collection('community_board').doc(widget.id).delete();
                            fp.updateIntInfo('postcount', -1);
                          },
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xff639ee1),
                        ),
                        child: GestureDetector(
                          child: Align(alignment: Alignment.center, child: smallText("수정", 14, Colors.white)),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityModify(widget.id)));
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return cSizedBox(0, 10);
                }
              } else {
                return CircularProgressIndicator();
              }
            }));
  }

  void commentUploadOnFS() async {
    var myInfo = fp.getInfo();
    await fs.collection('community_board').doc(widget.id).update({'commentCount': FieldValue.increment(1)});
    await fs
        .collection('community_board')
        .doc(widget.id)
        .collection('comments')
        .doc(DateTime.now().millisecondsSinceEpoch.toString())
        .set({'comment': commentInput.text, 'commentCount': 0, 'commentFrom': myInfo['nick'], 'likeCount': 0, 'timestamp': DateTime.now().millisecondsSinceEpoch.toString(), 'whoLike': []});

    commentInput.clear();
  }
}

/* ---------------------- Modify Board (Community) ---------------------- */

class CommunityModify extends StatefulWidget {
  CommunityModify(this.id);
  final String id;
  @override
  State<StatefulWidget> createState() {
    pageState4 = CommunityModifyState();
    return pageState4;
  }
}

class CommunityModifyState extends State<CommunityModify> {
  late FirebaseProvider fp;
  final FirebaseFirestore fs = FirebaseFirestore.instance;
  final FirebaseStorage storage = FirebaseStorage.instance;
  TextEditingController titleInput = TextEditingController();
  TextEditingController contentInput = TextEditingController();
  final _picker = ImagePicker();

  final _formKey = GlobalKey<FormState>();
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  List urlList = [];

  @override
  void initState() {
    setState(() {
      fs.collection('community_board').doc(widget.id).get().then((snapshot) {
        var tmp = snapshot.data() as Map<String, dynamic>;
        titleInput = TextEditingController(text: tmp['title']);
        contentInput = TextEditingController(text: tmp['contents']);
        urlList = tmp['pic'];
      });
    });
    super.initState();
  }

  @override
  void dispose() {
    titleInput.dispose();
    contentInput.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: StreamBuilder(
            stream: fs.collection('community_board').doc(widget.id).snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData && !snapshot.data!.exists) {
                return CircularProgressIndicator();
              }
              if (snapshot.hasData) {
                return Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      cSizedBox(35, 0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          IconButton(
                            icon: Image.asset('assets/images/icon/iconback.png', width: 22, height: 22),
                            onPressed: () {
                              Navigator.pop(context);
                            },
                          ),
                          headerText("글 수정"),
                          cSizedBox(0, 160),
                          IconButton(
                              icon: Icon(
                                Icons.check,
                                color: Color(0xff639ee1),
                              ),
                              onPressed: () {
                                FocusScope.of(context).requestFocus(new FocusNode());
                                if (_formKey.currentState!.validate()) {
                                  updateOnFS();
                                  Navigator.pop(context);
                                }
                              }),
                        ],
                      ),
                      headerDivider(),
                      Padding(
                        padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                        child: Column(
                          children: [
                            Container(width: MediaQuery.of(context).size.width * 0.8, child: titleField(titleInput)),
                          ],
                        ),
                      ),
                      Divider(
                        color: Color(0xffe9e9e9),
                        thickness: 2.5,
                      ),
                      Padding(
                          padding: EdgeInsets.fromLTRB(40, 10, 40, 30),
                          child: TextFormField(
                              controller: contentInput,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              style: TextStyle(fontSize: 14),
                              decoration: InputDecoration(
                                hintText: "내용을 입력하세요.",
                                border: InputBorder.none,
                              ),
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return "내용은 필수 입력 사항입니다.";
                                }
                                return null;
                              })),
                      Divider(
                        color: Colors.black,
                      ),
                      snapshot.data!['pic'].isEmpty
                          ? Container()
                          : Container(
                              height: 300,
                              child: ListView.builder(
                                  itemCount: urlList.length,
                                  itemBuilder: (BuildContext context, int idx) {
                                    return Card(
                                      child: Column(
                                        children: [
                                          TextButton(
                                            onPressed: () {
                                              deleteImage(urlList[idx]);
                                              setState(() {});
                                            },
                                            child: Text("X"),
                                          ),
                                          Image.network(urlList[idx]),
                                        ],
                                      ),
                                    );
                                  }),
                            ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          ElevatedButton(
                              child: Text("사진 추가"),
                              onPressed: () {
                                addImage();
                              }),
                        ],
                      ),
                    ],
                  ),
                );
              }
              return CircularProgressIndicator();
            }));
  }

  void addImage() async {
    final pickedImgList = await _picker.pickMultiImage();

    List<String> pickUrlList = [];

    var tmp = fp.getInfo();

    late Reference ref;
    for (int i = 0; i < pickedImgList!.length; i++) {
      ref = storage.ref().child('board/${tmp['nick'] + tmp['piccount'].toString()}');
      await ref.putFile(File(pickedImgList[i].path));
      fp.updateIntInfo('piccount', 1);
      String url = await ref.getDownloadURL();
      pickUrlList.add(url);
    }

    setState(() {
      urlList.addAll(pickUrlList);
    });

    await fs.collection('community_board').doc(widget.id).update({
      'pic': urlList,
    });
  }

  void deleteImage(String url) async {
    Reference ref = storage.refFromURL(url);
    await ref.delete();
    fp.updateIntInfo("piccount", -1);

    setState(() {
      urlList.remove(url);
      fs.collection('community_board').doc(widget.id).update({
        'pic': urlList,
      });
    });
  }

  void updateOnFS() async {
    await fs.collection('community_board').doc(widget.id).update({
      'title': titleInput.text,
      'contents': contentInput.text,
      'pic': urlList,
    });
  }
}
