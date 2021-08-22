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
      resizeToAvoidBottomInset: false,
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              topbar3(context, "글 작성", () {
                FocusScope.of(context).requestFocus(new FocusNode());
                if (_formKey.currentState!.validate()) {
                  uploadOnFS();
                  Navigator.pop(context);
                }
              }),
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
                margin: EdgeInsets.fromLTRB(0, height * 0.02, 0, 0),
                padding: EdgeInsets.fromLTRB(width * 0.07, height * 0.055, width * 0.07, height * 0.04),
                child: Column(
                  children: [
                    info2Text("커뮤니티 이용규칙\n"),
                    smallText("유소더하 커뮤니티는 누구나 가볍고 즐겁게 이용할 수 있는\n"
                        "커뮤니티를 만들기 위해 아래와 같은 게시물 규칙을 기반으로 운영합니다.\n"
                        "\n1. 정치, 사회 관련 게시물 게시 금지\n2. 혐오성 발언 금지\n3. 성적인 발언 금지\n"
                        "\n클린한 커뮤니티 조성을 위해 이용규칙을 반드시 지켜주세요.", 10.5, Colors.black54)
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
                topbar4_nomap(context, "커뮤니티", () {
                  setState(() {
                    colstream = FirebaseFirestore.instance.collection('community_board').orderBy("write_time", descending: true).snapshots();
                  });
                }, _formKey, search, searchInput,() {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      colstream = FirebaseFirestore.instance.collection('community_board').orderBy('title').startAt([searchInput.text]).endAt([searchInput.text + '\uf8ff']).snapshots();
                    });
                    searchInput.clear();
                    Navigator.pop(context);
                  }
                }, ),
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
  TextEditingController ccommentInput = TextEditingController();

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
  }

  @override
  void dispose() {
    commentInput.dispose();
    ccommentInput.dispose();
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

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
              bool doCcomment = false;
              return Column(children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    //프사
                    FutureBuilder(
                        future: getPhotoUrl(commentsSnapshot.data!.docs[index].get('commentFrom')),
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(60),
                              child: Image.network(
                                snapshot.data.toString(),
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
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
                                doCcomment = true;
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
                    //댓글 팝업 버튼
                    myNick == commentsSnapshot.data!.docs[index].get('commentFrom')
                        ? PopupMenuButton<Choice>(
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
                          )
                        : PopupMenuButton<Choice>(
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
                doCcomment
                    ? Row(
                        children: [
                          TextField(
                            controller: ccommentInput,
                          ),
                          IconButton(
                              icon: Icon(Icons.send),
                              onPressed: () async {
                                FocusScope.of(context).requestFocus(new FocusNode());
                                if (commentInput.text.isNotEmpty) {
                                  ccommentUploadOnFS(commentsSnapshot.data!.docs[index].id);
                                }
                              }),
                        ],
                      )
                    : Container(),

                //대댓글
                StreamBuilder(
                    stream: fs.collection('community_board').doc(widget.id).collection('comments').doc(commentsSnapshot.data!.docs[index].id).collection('comments').snapshots(),
                    builder: (context, AsyncSnapshot<QuerySnapshot> ccommentsSnapshot) {
                      if (ccommentsSnapshot.hasData) {
                        return Container(
                            child: ListView.builder(
                                primary: false,
                                shrinkWrap: true,
                                itemCount: ccommentsSnapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  void onItemMenuPress(Choice choice) {
                                    if (choice.title == '삭제') {
                                      deleteComment(ccommentsSnapshot.data!.docs[index].id);
                                    } else if (choice.title == '신고') {
                                      reportComment(ccommentsSnapshot.data!.docs[index].id);
                                    } else if (choice.title == '뭔가') {
                                      print('댓글 뭔가');
                                    }
                                  }

                                  DateTime dateTime = Timestamp.fromMillisecondsSinceEpoch(int.parse(ccommentsSnapshot.data!.docs[index].get('timestamp'))).toDate();
                                  return Column(children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Container(
                                          padding: EdgeInsets.only(left: 10),
                                          child: Icon(Icons.arrow_forward_rounded),
                                        ),
                                        //프사
                                        FutureBuilder(
                                            future: getPhotoUrl(ccommentsSnapshot.data!.docs[index].get('commentFrom')),
                                            builder: (context, AsyncSnapshot snapshot) {
                                              if (snapshot.hasData) {
                                                return ClipRRect(
                                                  borderRadius: BorderRadius.circular(60),
                                                  child: Image.network(
                                                    snapshot.data.toString(),
                                                    width: 40,
                                                    height: 40,
                                                    fit: BoxFit.cover,
                                                  ),
                                                );
                                              } else {
                                                return CircularProgressIndicator();
                                              }
                                            }),
                                        //1층: 닉넴, 댓글내용, 2층: 글쓴시간, 좋아요개수
                                        Column(
                                          children: [
                                            Row(
                                              children: [
                                                Text(ccommentsSnapshot.data!.docs[index].get('commentFrom'), style: TextStyle(fontSize: 14)),
                                                cSizedBox(0, 35),
                                                Text(ccommentsSnapshot.data!.docs[index].get('comment'), style: TextStyle(fontSize: 14)),
                                              ],
                                            ),
                                            Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                                            Row(
                                              children: [
                                                Text(howLongAgo(formatDate(dateTime, [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]))),
                                                cSizedBox(0, 10),
                                                StreamBuilder(
                                                    stream: fs
                                                        .collection('community_board')
                                                        .doc(widget.id)
                                                        .collection('comments')
                                                        .doc(commentsSnapshot.data!.docs[index].id)
                                                        .collection('comments')
                                                        .doc(ccommentsSnapshot.data!.docs[index].id)
                                                        .snapshots(),
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
                                            ),
                                          ],
                                        ),
                                        //좋아요
                                        StreamBuilder<DocumentSnapshot>(
                                            stream: fs
                                                .collection('community_board')
                                                .doc(widget.id)
                                                .collection('comments')
                                                .doc(commentsSnapshot.data!.docs[index].id)
                                                .collection('comments')
                                                .doc(ccommentsSnapshot.data!.docs[index].id)
                                                .snapshots(),
                                            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                                              print('#########');
                                              print(snapshot.toString());
                                              print(snapshot.data.toString());
                                              if (snapshot.hasData && snapshot.data.toString() == 'null') {
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
                                                        await fs
                                                            .collection('community_board')
                                                            .doc(widget.id)
                                                            .collection('comments')
                                                            .doc(commentsSnapshot.data!.docs[index].id)
                                                            .collection('comments')
                                                            .doc(ccommentsSnapshot.data!.docs[index].id)
                                                            .update({
                                                          'likeCount': FieldValue.increment(1),
                                                          'whoLike': FieldValue.arrayUnion([myNick])
                                                        });
                                                      } else {
                                                        await fs
                                                            .collection('community_board')
                                                            .doc(widget.id)
                                                            .collection('comments')
                                                            .doc(commentsSnapshot.data!.docs[index].id)
                                                            .collection('comments')
                                                            .doc(ccommentsSnapshot.data!.docs[index].id)
                                                            .update({
                                                          'likeCount': FieldValue.increment(-1),
                                                          'whoLike': FieldValue.arrayRemove([myNick])
                                                        });
                                                      }
                                                    });
                                              } else {
                                                return CircularProgressIndicator();
                                              }
                                            }),
                                        //댓글 팝업 버튼
                                        myNick == commentsSnapshot.data!.docs[index].get('commentFrom')
                                            ? PopupMenuButton<Choice>(
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
                                              )
                                            : PopupMenuButton<Choice>(
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
                                    )
                                  ]);
                                }));
                      } else {
                        return CircularProgressIndicator();
                      }
                    }),
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
                        topbar2(context, "커뮤니티"),
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
                        ? SizedBox.shrink()
                        : Container(
                          margin: EdgeInsets.fromLTRB(width*0.03, 0, width*0.03, 0),
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

  void ccommentUploadOnFS(String commentId) async {
    var myInfo = fp.getInfo();
    await fs.collection('community_board').doc(widget.id).collection('comments').doc(commentId).update({'commentCount': FieldValue.increment(1)});
    await fs
        .collection('community_board')
        .doc(widget.id)
        .collection('comments')
        .doc(commentId)
        .collection('comments')
        .doc(DateTime.now().millisecondsSinceEpoch.toString())
        .set({'comment': ccommentInput.text, 'commentCount': 0, 'commentFrom': myInfo['nick'], 'likeCount': 0, 'timestamp': DateTime.now().millisecondsSinceEpoch.toString(), 'whoLike': []});

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
                      topbar3(context, "글 수정", () {
                        FocusScope.of(context).requestFocus(new FocusNode());
                        if (_formKey.currentState!.validate()) {
                          updateOnFS();
                          Navigator.pop(context);
                        }
                      }),
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
                      margin: EdgeInsets.fromLTRB(0, height * 0.02, 0, 0),
                      padding: EdgeInsets.fromLTRB(width * 0.07, height * 0.055, width * 0.07, height * 0.04),
                      child: Column(
                        children: [
                          info2Text("커뮤니티 이용규칙\n"),
                          smallText("유소더하 커뮤니티는 누구나 가볍고 즐겁게 이용할 수 있는\n"
                              "커뮤니티를 만들기 위해 아래와 같은 게시물 규칙을 기반으로 운영합니다.\n"
                              "\n1. 정치, 사회 관련 게시물 게시 금지\n2. 혐오성 발언 금지\n3. 성적인 발언 금지\n"
                              "\n클린한 커뮤니티 조성을 위해 이용규칙을 반드시 지켜주세요.", 10.5, Colors.black54)
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
