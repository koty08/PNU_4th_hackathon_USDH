import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:parallax_image/parallax_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar("글 작성", [
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
            }
        )]),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.fromLTRB(width * 0.1, height * 0.01, width * 0.1, height * 0.01),
                child: Column(
                  children: [
                    Container(width: width * 0.8, child: titleField(titleInput)),
                  ],
                ),
              ),
              Divider(
                color: Color(0xffe9e9e9),
                thickness: 2.5,
              ),
              Container(
                height: height*0.4,
                padding: EdgeInsets.fromLTRB(width * 0.1, height * 0.01, width * 0.1, height * 0.01),
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
                  })
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  cSizedBox(0, width*0.05),
                  IconButton(
                    icon: Icon(Icons.image),
                    onPressed: () {
                      addImage();
                    }
                  ),
                ],
              ),
              urlList.isEmpty
              ? SizedBox.shrink()
              : Container(
                  height: 100,
                  width: width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.transparent
                  ),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: urlList.length,
                    itemBuilder: (BuildContext context, int idx) {
                      return Card(
                        child: Stack(
                          children: [
                            Image.network(urlList[idx], width: 100, height: 100, fit:BoxFit.contain),
                            IconButton(
                              onPressed: () {
                                deleteImage(urlList[idx]);
                              },
                              icon: Image.asset('assets/images/icon/iconx.png', width: 15, height: 15),
                            ),
                          ],
                        ),
                      );
                    }
                  ),
              ),
              Container(
                  height: height*0.29,
                  width: width,
                  decoration: BoxDecoration(
                      color: Colors.grey[300]
                  ),
                  padding: EdgeInsets.fromLTRB(width * 0.07, height * 0.02, width * 0.07, 0),
                  child: Column(
                    children: [
                      info2Text("커뮤니티 이용규칙\n"),
                      small2Text("유소더하 커뮤니티는 누구나 가볍고 즐겁게 이용할 수 있는\n"
                          "커뮤니티를 만들기 위해 아래와 같은 게시물 규칙을 기반으로 운영합니다.\n"
                          "\n1. 정치, 사회 관련 게시물 게시 금지\n2. 혐오성 발언 금지\n3. 성적인 발언 금지\n"
                          "\n클린한 커뮤니티 조성을 위해 이용규칙을 반드시 지켜주세요.", 10.2, Colors.black54)
                    ],
                  )
              ),
            ],
          ),
        )));
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar("커뮤니티", [
        //새로고침 기능
        IconButton(
          icon: Image.asset('assets/images/icon/iconrefresh.png', width: 18, height: 18),
          onPressed: () {
            setState(() {
              colstream = FirebaseFirestore.instance.collection('community_board').orderBy("write_time", descending: true).snapshots();
            });
          },
        ),
        //검색 기능 팝업
        IconButton(
          icon: Image.asset('assets/images/icon/iconsearch.png', width: 20, height: 20),
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
                              }
                          ),
                          actions: <Widget>[
                            TextButton(
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    setState(() {
                                      colstream = FirebaseFirestore.instance.collection('community_board').orderBy('title').startAt([searchInput.text]).endAt([searchInput.text + '\uf8ff']).snapshots();
                                    });
                                    searchInput.clear();
                                    Navigator.pop(context);
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
      ]),
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
                cSizedBox(height*0.02, 0),
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
                        String time = doc['write_time'].substring(0, 16) + ' | ';
                        String writer = doc['writer'];
                        return Column(children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityShow(doc.id)));
                              FirebaseFirestore.instance.collection('community_board').doc(doc.id).update({"views": doc["views"] + 1});
                            },
                            child: Container(
                              margin: EdgeInsets.fromLTRB(width * 0.03, height * 0.025, width * 0.05, height * 0.015),
                              child: Wrap(
                                crossAxisAlignment: WrapCrossAlignment.start,
                                spacing: height*0.01,
                                children: [
                                  Container(
                                    width: width * 0.8,
                                    child: Text(doc['title'].toString(), overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: "SCDream", fontWeight: FontWeight.w500, fontSize: 14)),
                                  ),
                                  cSizedBox(height*0.035, 0),
                                      smallText(time + writer, 10, Color(0xffa9aaaf)),
                                  cSizedBox(height*0.03, 0)
                              ]))
                          )
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

  SharedPreferences? prefs;
  bool alreadyLiked = false;
  bool isOnCcoment = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    commentInput.dispose();
    super.dispose();
  }

  List<Choice> choices = const <Choice>[
    const Choice(title: '수정', icon: Icons.edit),
    const Choice(title: '삭제', icon: Icons.delete_forever_rounded),
  ];

  void onItemMenuPress(Choice choice) {
    if (choice.title == '수정') {
      modifyCommunity();
    } else {
      deleteCommunity();
    }
  }

  void modifyCommunity() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityModify(widget.id)));
  }
  Future<Null> deleteCommunity() async {
    Navigator.pop(context);

    var snapshot = await fs.collection('community_board').doc(widget.id).get();
    if (fp.getInfo()['nick'] == snapshot.get('writer')) {
      List<dynamic> urlList = snapshot.get('pic');
      for (int i = 0; i < urlList.length; i++) {
        Reference ref = storage.refFromURL(urlList[i]);
        ref.delete();
      }
      await fs.collection('community_board').doc(widget.id).delete();
      fp.updateIntInfo('postcount', -1);
    }
  }

  @override
  Widget build(BuildContext context) {
    Stream<DocumentSnapshot> boardStream = fs.collection('community_board').doc(widget.id).snapshots();
    Stream<QuerySnapshot> commentsStream = fs.collection('community_board').doc(widget.id).collection('comments').snapshots();

    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    Widget commentsSection(AsyncSnapshot<QuerySnapshot> commentsSnapshot, String myNick) {
      if (commentsSnapshot.data != null) {
        return SingleChildScrollView(
          child: ListView.builder(
            primary: false,
            shrinkWrap: true,
            itemCount: commentsSnapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DateTime dateTime = Timestamp.fromMillisecondsSinceEpoch(int.parse(commentsSnapshot.data!.docs[index].get('timestamp'))).toDate();
              int _likeCount = commentsSnapshot.data!.docs[index].get('likeCount');
              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      cSizedBox(0, width*0.07),
                      Container(
                        width: width*0.5,
                        margin: EdgeInsets.fromLTRB(0, 0, width*0.18, 0),
                        child: small2Text(commentsSnapshot.data!.docs[index].get('commentFrom'), 12, Colors.black87),
                      ),
                      Row(
                        children: [
                          Container(
                            width: width*0.1,
                            margin: EdgeInsets.fromLTRB(0, 0, width*0.0, 0),
                            alignment: Alignment(1.0, 0.0),
                            child: smallText(howLongAgo(formatDate(dateTime, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss])), 11, Colors.black54),
                          ),
                          cSizedBox(0, 10),
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
                                      padding: EdgeInsets.zero,
                                      constraints: BoxConstraints(),
                                      icon: Icon(alreadyLiked ? Icons.favorite : Icons.favorite_border, color: Colors.blueGrey, size: 15,),
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
                          (_likeCount != 0)
                              ? smallText(_likeCount.toString(), 11, Colors.grey)
                              : SizedBox.shrink(),
                        ],
                      ),
                    ]
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      cSizedBox(0, width*0.07),
                      Container(
                        width: width*0.8,
                        margin: EdgeInsets.fromLTRB(0, 0, width*0.02, 0),
                        child: small2Text(commentsSnapshot.data!.docs[index].get('comment'), 12, Colors.black54),
                      ),
                  ],),
                  Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, height*0.02))
                ],
                );
            },
          ),
        );
      }
      return SizedBox.shrink();
    }

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: CustomAppBar("커뮤니티", [
          PopupMenuButton<Choice>(
            icon: Image.asset('assets/images/icon/iconthreedot.png', width: 22, height: 22),
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
                        info2Text(choice.title),
                      ],
                    ));
              }).toList();
            },
          ),
          Padding(padding: EdgeInsets.fromLTRB(10, 0, 0, 0)),
        ],
      ),

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
                  return Column(
                    children: [
                      Flexible(
                        flex: 10,
                        fit: FlexFit.tight,
                        child: SingleChildScrollView(
                          child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                    padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                                    child: Wrap(direction: Axis.vertical, spacing: 15, children: [
                                      Container(width: MediaQuery.of(context).size.width * 0.8, child: titleText(boardSnapshot.data!['title'])),
                                      smallText("작성일" + writeTime + "작성자 " + writer + " | 조회수 " + boardSnapshot.data!['views'].toString(), 11.5, Color(0xffa9aaaf))
                                    ])),
                                Divider(
                                  color: Color(0xffe9e9e9),
                                  thickness: 15,
                                ),
                                Padding(
                                  padding: EdgeInsets.fromLTRB(50, height*0.05, 50, height*0.07),
                                  child: Text(boardSnapshot.data!['contents'], style: TextStyle(fontSize: 14)),
                                ),
                                boardSnapshot.data!['pic'].isEmpty
                                    ? SizedBox.shrink()
                                    : Container(
                                    margin: EdgeInsets.fromLTRB(width*0.03, 0, width*0.03, height*0.03),
                                    height: 100,
                                    width: width,
                                    child: ListView.builder(
                                      scrollDirection: Axis.horizontal,
                                      itemBuilder: (BuildContext context, int idx) {
                                        return GestureDetector(
                                            onTap: (){open(context, idx, boardSnapshot.data!['pic']);},
                                            child: Card(
                                              elevation: 0,
                                              child: Image.network(boardSnapshot.data!['pic'][idx], width: 100, height: 100, fit:BoxFit.contain),
                                            )
                                        );
                                      },
                                      itemCount: boardSnapshot.data!['pic'].length,
                                    )
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
                                        return Row(
                                          children: [
                                            cSizedBox(0, width*0.02),
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
                                                      return info2Text(snapshot.data!['likeCount'].toString());
                                                      //Text("좋아요 " +  + "개", style: TextStyle(fontSize: 14));
                                                    }
                                                    return SizedBox.shrink();
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
                                // 댓글들
                                commentsSection(commentsSnapshot, myInfo['nick']),
                                Padding(padding: EdgeInsets.fromLTRB(0, 0, 0, height*0.02))
                              ],
                            )
                          ),
                      ),
                      Flexible(
                        flex: 1,
                        fit: FlexFit.tight,
                        child: Container(
                          padding: EdgeInsets.fromLTRB(width*0.05, 0, width*0.05, height*0.01),
                          color: Colors.transparent,
                          width: MediaQuery.of(context).size.width,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: width*0.75,
                                child: TextField(
                                  controller: commentInput,
                                  decoration: InputDecoration(
                                    focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.indigo.shade200, width: 1.5),
                                    ),
                                    contentPadding: EdgeInsets.fromLTRB(width*0.05, 0, 0, 0),
                                    hintText: "댓글을 남기세요.",
                                    hintStyle: TextStyle(fontFamily: "SCDream", color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 13),
                                    errorStyle: TextStyle(color: Colors.indigo.shade200),
                                    enabledBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey.shade400, width: 1.5),
                                    ),
                                  ),
                                  focusNode: FocusNode(),
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.send, color: Colors.grey,),
                                onPressed: () {
                                  FocusScope.of(context).requestFocus(new FocusNode());
                                  if (commentInput.text.isNotEmpty) {
                                    commentUploadOnFS();
                                  }
                                },
                              ),
                            ],
                          )
                        ),
                      ),
                    ],
                  );
                } else {
                  return CircularProgressIndicator();
                }
              },
            );
          }
      ),
    );
  }

  void open(BuildContext context, final int index, List items) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GalleryPhotoViewWrapper(
          galleryItems: items,
          backgroundDecoration: const BoxDecoration(
            color: Colors.black,
          ),
          initialIndex: index,
          scrollDirection: Axis.horizontal,
        ),
      ),
    );
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar("글 수정", [
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
            }
        )]),
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
          child: StreamBuilder(
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
                      Padding(
                        padding: EdgeInsets.fromLTRB(width * 0.1, height * 0.01, width * 0.1, height * 0.01),
                        child: Column(
                          children: [
                            Container(width: width * 0.8, child: titleField(titleInput)),
                          ],
                        ),
                      ),
                      Divider(
                        color: Color(0xffe9e9e9),
                        thickness: 2.5,
                      ),
                      Container(
                        height: height*0.4,
                        padding: EdgeInsets.fromLTRB(width * 0.1, height * 0.01, width * 0.1, height * 0.01),
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
                          })
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: <Widget>[
                          cSizedBox(0, width*0.05),
                          IconButton(
                              icon: Icon(Icons.image),
                              onPressed: () {
                                addImage();
                              }
                          ),
                        ],
                      ),
                    snapshot.data!['pic'].isEmpty
                    ? SizedBox.shrink()
                    : Container(
                      height: 100,
                      width: width * 0.9,
                      decoration: BoxDecoration(
                          color: Colors.transparent
                      ),
                      child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: urlList.length,
                          itemBuilder: (BuildContext context, int idx) {
                            return Card(
                              child: Stack(
                                children: [
                                  Image.network(urlList[idx], width: 100, height: 100, fit:BoxFit.contain),
                                  IconButton(
                                    onPressed: () {
                                      deleteImage(urlList[idx]);
                                    },
                                    icon: Image.asset('assets/images/icon/iconx.png', width: 22, height: 22),
                                  ),
                                ],
                              ),
                            );
                          }
                      ),
                    ),
                    Container(
                      height: height*0.29,
                      width: width,
                      decoration: BoxDecoration(
                          color: Colors.grey[300]
                      ),
                      padding: EdgeInsets.fromLTRB(width * 0.07, height * 0.02, width * 0.07, 0),
                      child: Column(
                        children: [
                          info2Text("커뮤니티 이용규칙\n"),
                          small2Text("유소더하 커뮤니티는 누구나 가볍고 즐겁게 이용할 수 있는\n"
                              "커뮤니티를 만들기 위해 아래와 같은 게시물 규칙을 기반으로 운영합니다.\n"
                              "\n1. 정치, 사회 관련 게시물 게시 금지\n2. 혐오성 발언 금지\n3. 성적인 발언 금지\n"
                              "\n클린한 커뮤니티 조성을 위해 이용규칙을 반드시 지켜주세요.", 10.2, Colors.black54)
                        ],
                      )
                    ),
                    ],
                  ),
                );
              }
              return CircularProgressIndicator();
            }
          )
      )
    );
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


// photo view - gallery

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex = 0,
    required this.galleryItems,
    this.scrollDirection = Axis.horizontal,
  }) : pageController = PageController(initialPage: initialIndex);

  final BoxDecoration? backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  List galleryItems;
  final Axis scrollDirection;

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  late int currentIndex = widget.initialIndex;

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: widget.backgroundDecoration,
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index) {
                return PhotoViewGalleryPageOptions(
                  imageProvider: NetworkImage(widget.galleryItems[index]),
                  initialScale: PhotoViewComputedScale.contained * 0.8,
                  minScale: PhotoViewComputedScale.contained * (0.5 + index / 10),
                  maxScale: PhotoViewComputedScale.covered * 4.1,
                );
              },
              itemCount: widget.galleryItems.length,
              backgroundDecoration: widget.backgroundDecoration,
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
              scrollDirection: widget.scrollDirection,
            ),
          ],
        ),
      ),
    );
  }
}
