import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:material_tag_editor/tag_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdh/Widget/widget.dart';
import 'package:usdh/login/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:usdh/chat/home.dart';
import 'package:usdh/chat/chatting.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';

late DeliveryWriteState pageState;
late DeliveryMapState pageState1;
late DeliveryListState pageState2;
late DeliveryShowState pageState3;
late DeliveryModifyState pageState4;
late ApplicantListBoardState pageState5;
late ShowApplicantListState pageState6;

bool is_available(String time, int n1, int n2) {
  if (n1 >= n2) {
    return false;
  }
  String now = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]);
  DateTime d1 = DateTime.parse(now);
  DateTime d2 = DateTime.parse(time);
  Duration diff = d1.difference(d2);
  if (diff.isNegative) {
    return true;
  } else {
    return false;
  }
}

/* ---------------------- Write Board (Delivery) ---------------------- */

class DeliveryWrite extends StatefulWidget {
  @override
  DeliveryWriteState createState() {
    pageState = DeliveryWriteState();
    return pageState;
  }
}

class DeliveryWriteState extends State<DeliveryWrite> {
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
  String gender = "";
  String tags = "";
  List tagList = [];

  final _formKey = GlobalKey<FormState>();
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

  _onDelete(index) {
    setState(() {
      tagList.removeAt(index);
    });
  }

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
                      icon: Icon(Icons.check, color: Color(0xff639ee1),),
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
                  padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                  child: Wrap(
                    direction: Axis.vertical,
                    spacing: 15,
                    children: [
                      Text("모집조건", style: TextStyle(fontFamily: "SCDream", color: Color(0xff639ee1), fontWeight: FontWeight.w600, fontSize: 15)),
                      Padding(
                        padding: EdgeInsets.fromLTRB(7, 5, 20, 0),
                        child: Wrap(
                          direction: Axis.vertical,
                          spacing: 15,
                          children: [
                            condWrap("모집기간", timeInput, "마감 시간 입력 : xx:xx (ex 21:32 형태)", "마감 시간은 필수 입력 사항입니다."),
                            condWrap("모집인원", memberInput, "인원을 입력하세요. (숫자 형태)", "인원은 필수 입력 사항입니다."),
                            condWrap("음식종류", foodInput, "음식 종류를 입력하세요.", "음식 종류는 필수 입력 사항입니다."),
                            condWrap("배분위치", locationInput, "위치를 입력하세요.", "위치는 필수 입력 사항입니다."),
                          ],
                        )),
                    ],
                  )),
              Divider(
                color: Color(0xffe9e9e9),
                thickness: 17,
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                child: Wrap(direction: Axis.vertical, spacing: -10, children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.8, child:
                    TagEditor(
                      key: key,
                      controller: tagInput,
                      keyboardType: TextInputType.multiline,
                      length: tagList.length,
                      delimiters: [',', ' '],
                      hasAddButton: false,
                      resetTextOnSubmitted: true,
                      textStyle: TextStyle(fontFamily: "SCDream", color: Color(0xffa9aaaf), fontWeight: FontWeight.w500, fontSize: 11.5),
                      inputDecoration: InputDecoration(hintText: "#태그를 입력하세요.(*첫번째 태그는 지도에 표시됩니다.)", hintStyle: TextStyle(color: Color(0xffa9aaaf), fontSize: 11.5), border: InputBorder.none, focusedBorder: InputBorder.none),
                      onSubmitted: (outstandingValue) {
                        setState(() {
                          tags = tags + "#" + outstandingValue + " ";
                          tagList.add(outstandingValue);
                        });
                      },
                      onTagChanged: (newValue) {
                        setState(() {
                          tags = tags + "#" + newValue + " ";
                          tagList.add("#" + newValue + " ");
                        });
                      },
                      tagBuilder: (context, index) => _Chip(
                        index: index,
                        label: tagList[index],
                        onDeleted: _onDelete,
                      ),
                    )
                  ),
                  Container(width: MediaQuery.of(context).size.width * 0.8, child: titleField(titleInput)),
                ])
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
            ],
          ),
        )));
  }

  void uploadOnFS() async {
    var myInfo = fp.getInfo();
    await fs.collection('delivery_board').doc(myInfo['name'] + myInfo['postcount'].toString()).set({
      'title': titleInput.text,
      'write_time': formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]),
      'writer': myInfo['name'],
      'contents': contentInput.text,
      'time': formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]) + " " + timeInput.text + ":00",
      'currentMember': 1,
      'limitedMember': int.parse(memberInput.text),
      'food': foodInput.text,
      'location': locationInput.text,
      'tags': tags,
      'gender': gender,
      'members': [],
      'isFineForMembers': [],
      'tagList': tagList,
      'views': 0,
      'likes': 0,
      'commentCount': 0,
    });
    fp.updateIntInfo('postcount', 1);
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.onDeleted,
    required this.index,
  });

  final String label;
  final ValueChanged<int> onDeleted;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Chip(
      labelStyle: TextStyle(fontFamily: "SCDream", color: Color(0xffa9aaaf), fontWeight: FontWeight.w500, fontSize: 11.5),
      labelPadding: EdgeInsets.only(left: 10),
      backgroundColor: Color(0xff639ee1).withOpacity(0.7),
      label: smallText(label, 11, Colors.white),
      deleteIcon: const Icon(
        Icons.close,
        color: Colors.white,
        size: 13,
      ),
      onDeleted: () {
        onDeleted(index);
      },
    );
  }
}

/* ---------------------- Board Map (Delivery) ---------------------- */
/* ----------------------    지우지 말아주세요    ---------------------- */

class DeliveryMap extends StatefulWidget {
  @override
  DeliveryMapState createState() {
    pageState1 = DeliveryMapState();
    return pageState1;
  }
}

class DeliveryMapState extends State<DeliveryMap> {
  late FirebaseProvider fp;
  TextEditingController searchInput = TextEditingController();

  @override
  void dispose() {
    searchInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();

    return Scaffold(body: Container());
  }
}

/* ---------------------- Board List (Delivery) ---------------------- */

class DeliveryList extends StatefulWidget {
  @override
  DeliveryListState createState() {
    pageState2 = DeliveryListState();
    return pageState2;
  }
}

class DeliveryListState extends State<DeliveryList> {
  Stream<QuerySnapshot> colstream = FirebaseFirestore.instance.collection('delivery_board').orderBy("write_time", descending: true).snapshots();
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

  bool is_today(String time) {
    String now = formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]);
    if (time.split(" ")[0] == now) {
      return true;
    } else {
      return false;
    }
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
            colstream = FirebaseFirestore.instance.collection('delivery_board').orderBy("write_time", descending: true).snapshots();
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
                      headerText("배달"),
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
                                colstream = FirebaseFirestore.instance.collection('delivery_board').orderBy("write_time", descending: true).snapshots();
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
                                                          colstream = FirebaseFirestore.instance.collection('delivery_board').where('tagList', arrayContains: "#"+searchInput.text+" ").snapshots();
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
                headerDivider(),
                Container(
                    padding: EdgeInsets.fromLTRB(0, 10, 25, 5),
                    child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      Container(
                        width: 15,
                        height: 15,
                        child: Transform.scale(
                          scale: 0.7,
                          child: Theme(
                            data: ThemeData(unselectedWidgetColor: Colors.indigo.shade300),
                            child: Checkbox(
                              value: status,
                              activeColor: Colors.indigo.shade300,
                              onChanged: (val) {
                                setState(() {
                                  status = val ?? false;
                                  if(status){
                                    colstream = FirebaseFirestore.instance.collection('delivery_board').where('time', isGreaterThan: formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss])).snapshots();
                                  }
                                  else{
                                    colstream = FirebaseFirestore.instance.collection('delivery_board').orderBy("write_time", descending: true).snapshots();
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      cSizedBox(5, 5),
                      Text("모집중만 보기", style: TextStyle(fontFamily: "NSRound", fontWeight: FontWeight.w400, fontSize: 13, color: Colors.indigo.shade300),),
                    ])),
                // Container or Expanded or Flexible 사용
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
                          String member = doc['currentMember'].toString() + '/' + doc['limitedMember'].toString();
                          String info = doc['time'].substring(5,7) + "/" + doc['time'].substring(8,10) + doc['write_time'].substring(10,16);
                          String time = ' |' + doc['time'].substring(10,16) + ' | ';
                          String writer = doc['writer'] ;
                          return Column(children: [
                            Padding(padding: EdgeInsets.fromLTRB(10, 0, 10, 0)),
                            InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => DeliveryShow(doc.id)));
                                FirebaseFirestore.instance.collection('delivery_board').doc(doc.id).update({"views": doc["views"] + 1});
                              },
                              child: Container(
                                  margin: EdgeInsets.fromLTRB(25, 17, 10, 0),
                                  child: Column(children: [
                                    Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                      cSizedBox(0, 10),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.7,
                                        height: 13,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: doc['tagList'].length,
                                          itemBuilder: (context, index){
                                            String tag = doc['tagList'][index].toString();
                                            return GestureDetector(
                                              onTap: () {
                                                setState((){
                                                  colstream = FirebaseFirestore.instance.collection('delivery_board').where('tagList', arrayContains: tag).snapshots();
                                                });
                                              },
                                              child: smallText(tag, 12, Color(0xffa9aaaf))
                                            );
                                          }
                                        )
                                      ),
                                      cSizedBox(0, 10),
                                      Container(width: 50, child: Row(crossAxisAlignment: CrossAxisAlignment.end,
                                        children: [
                                        is_available(doc['time'], doc['currentMember'], doc['limitedMember']) ?
                                          Image(image: AssetImage('assets/images/icon/iconminiperson.png'), height: 15, width: 15,) :
                                          Image(image: AssetImage('assets/images/icon/iconminiperson2.png'), height: 15, width: 15,),
                                        cSizedBox(20, 7),
                                        smallText(member, 13, Color(0xffa9aaaf))
                                      ],))
                                    ]),
                                    Row(children: [
                                      is_available(doc['time'], doc['currentMember'], doc['limitedMember']) ? statusText("모집중") : statusText("모집완료"),
                                      cSizedBox(0, 10),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.6,
                                        child: Text(doc['title'].toString(), overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: "SCDream", fontWeight: FontWeight.w700, fontSize: 15)),
                                      ),
                                      cSizedBox(35, 0),
                                    ]),
                                    Row(children: [
                                      cSizedBox(20, 5),
                                      smallText(info, 10, Color(0xffa9aaaf)),
                                      smallText(time, 10, Color(0xffa9aaaf)),
                                      smallText(writer, 10, Color(0xffa9aaaf)),
                                    ],),
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
        child: Image(image: AssetImage('assets/images/icon/iconpencil.png'), height: 28, width: 28,),
        onPressed: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => DeliveryWrite()));
        }),
    );
  }
}

/* ---------------------- Show Board (Delivery) ---------------------- */

class DeliveryShow extends StatefulWidget {
  DeliveryShow(this.id);
  final String id;

  @override
  DeliveryShowState createState() {
    pageState3 = DeliveryShowState();
    return pageState3;
  }
}

class DeliveryShowState extends State<DeliveryShow> {
  late FirebaseProvider fp;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore fs = FirebaseFirestore.instance;
  TextEditingController commentInput = TextEditingController();

  SharedPreferences? prefs;
  bool alreadyLiked = false;

  final _formKey = GlobalKey<FormState>();
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();

    return Scaffold(
        body: StreamBuilder(
            stream: fs.collection('delivery_board').doc(widget.id).snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              fp.setInfo();

              if (snapshot.hasData && !snapshot.data!.exists) {
                return CircularProgressIndicator();
              } else if (snapshot.hasData) {
                String info = snapshot.data!['time'].substring(5,7) + "/" + snapshot.data!['time'].substring(8,10) + snapshot.data!['write_time'].substring(10,16)+ ' | ';
                String time = snapshot.data!['time'].substring(10,16) + ' | ';
                String writer = snapshot.data!['writer'] ;
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
                        headerText("배달"),
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
                          Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: tagText(snapshot.data!['tagList'].join('')),
                          ),
                          Container(width: MediaQuery.of(context).size.width * 0.8, child: titleText(snapshot.data!['title'])),
                          smallText("등록일 " + info + "마감 " + time + "작성자 " + writer, 11.5, Color(0xffa9aaaf))
                        ])),
                    Divider(
                      color: Color(0xffe9e9e9),
                      thickness: 15,
                    ),
                    Padding(
                        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                        child: Wrap(
                          direction: Axis.vertical,
                          spacing: 15,
                          children: [
                            Text("모집조건", style: TextStyle(fontFamily: "SCDream", color: Color(0xff639ee1), fontWeight: FontWeight.w600, fontSize: 15)),
                            Padding(
                                padding: EdgeInsets.fromLTRB(7, 5, 20, 0),
                                child: Wrap(
                                  direction: Axis.vertical,
                                  spacing: 15,
                                  children: [
                                    cond2Wrap("모집기간", formatDate(DateTime.parse(snapshot.data!['time']), [HH, ':', nn])),
                                    cond2Wrap("모집인원", snapshot.data!['currentMember'].toString() + "/" + snapshot.data!['limitedMember'].toString()),
                                    cond2Wrap("음식종류", snapshot.data!['food']),
                                    cond2Wrap("배분위치", snapshot.data!['location']),
                                  ],
                                ))
                          ],
                        )),
                    Divider(
                      color: Color(0xffe9e9e9),
                      thickness: 15,
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(50, 30, 50, 30),
                      child: Text(snapshot.data!['contents'], style: TextStyle(fontSize: 14)),
                    ),
                    // 좋아요
                    headerDivider(),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(alreadyLiked ? Icons.favorite_border : Icons.favorite),
                          onPressed: () async {
                            var myInfo = fp.getInfo();
                            if (!alreadyLiked) {
                              await FirebaseFirestore.instance.collection('delivery_board').doc(widget.id).update({'likes': FieldValue.increment(1)});
                              await FirebaseFirestore.instance.collection('users').doc(myInfo['email']).update({
                                'likedBoard': FieldValue.arrayUnion([widget.id])
                              });
                            } else {
                              await FirebaseFirestore.instance.collection('delivery_board').doc(widget.id).update({'likes': FieldValue.increment(-1)});
                              await FirebaseFirestore.instance.collection('users').doc(myInfo['email']).update({
                                'likedBoard': FieldValue.arrayRemove([widget.id])
                              });
                            }
                            alreadyLiked = !alreadyLiked;
                          },
                        ),
                        Text(snapshot.data!['likes'].toString()),
                      ],
                    ),
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
                            commentUploadOnFS();
                          },
                        ),
                      ],
                    ),
                    // 댓글들 (추가해야함)
                  ],
                ));
              } else {
                return CircularProgressIndicator();
              }
            }
        ),
    bottomNavigationBar:
      StreamBuilder(
        stream: fs.collection('delivery_board').doc(widget.id).snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.hasData && !snapshot.data!.exists) {
            return CircularProgressIndicator();
          } else if (snapshot.hasData) {
            fp.setInfo();
            if (fp.getInfo()['name'] == snapshot.data!['writer']){
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 50,
                    decoration: BoxDecoration(color: Color(0xffcacaca),),
                    child: GestureDetector(
                      child: Align(alignment: Alignment.center,
                          child: smallText("삭제", 14, Colors.white)),
                      onTap: () async {
                        Navigator.pop(context);
                        await fs.collection('delivery_board').doc(widget.id).delete();
                        fp.updateIntInfo('postcount', -1);
                      },
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 50,
                    decoration: BoxDecoration(color: Color(0xff639ee1),),
                    child: GestureDetector(
                      child: Align(alignment: Alignment.center,
                          child: smallText("수정", 14, Colors.white)),
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => DeliveryModify(widget.id)));
                        setState(() {});
                      },
                    ),
                  ),
                ],
              );
            }
            else {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 참가 버튼을 누르면 currentMember+1, 제한 넘으면 불가
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 50,
                    decoration: BoxDecoration(color: Color(0xffcacaca),),
                    child: GestureDetector(
                      child: Align(alignment: Alignment.center,
                          child: smallText("신청취소", 14, Colors.white)),
                      onTap: () async {
                        var myInfo = fp.getInfo();
                        String title = widget.id;

                        List<String> _myApplications = [];
                        await FirebaseFirestore.instance.collection('users').doc(
                            myInfo['email']).get().then((value) {
                          for (String myApplication in value['myApplication']) {
                            _myApplications.add(myApplication);
                          }
                        });
                        // 참가 신청하지 않은 경우
                        if (!_myApplications.contains(title)) {
                          print('참가 신청하지 않은 방입니다!!');
                        } else {
                          await FirebaseFirestore.instance.collection('users')
                              .doc(myInfo['email'])
                              .update({
                            'myApplication': FieldValue.arrayRemove([title])
                          });
                        }
                      },
                    ),
                  ),
                  Container(
                    width: MediaQuery.of(context).size.width * 0.5,
                    height: 50,
                    decoration: BoxDecoration(color: Color(0xff639ee1),),
                    child: GestureDetector(
                      child: Align(alignment: Alignment.center,
                          child: smallText("참가신청", 14, Colors.white)),
                      onTap: () async {
                        var myInfo = fp.getInfo();
                        int _currentMember = snapshot.data!['currentMember'];
                        int _limitedMember = snapshot.data!['limitedMember'];
                        String title = widget.id;

                        List<String> _joiningRoom = [];
                        await FirebaseFirestore.instance.collection('users').doc(
                            myInfo['email']).get().then((value) {
                          for (String room in value['joiningIn']) {
                            _joiningRoom.add(room);
                          }
                        });
                        // 이미 참가한 방인 경우
                        if (_joiningRoom.contains(title)) {
                          print('이미 참가한 방입니다!!');
                        }
                        // 제한 인원 꽉 찰 경우
                        else if (_currentMember >= _limitedMember) {
                          print('This room is full');
                        }
                        // 인원이 남을 경우
                        else {
                          // 방장에게 날리는 메세지
                          await FirebaseFirestore.instance.collection(
                              'delivery_board').doc(title).update({
                            'isFineForMembers': FieldValue.arrayUnion(
                                [myInfo['email']])
                          });
                          // 내 정보에 신청 정보를 기록
                          await FirebaseFirestore.instance.collection('users')
                              .doc(myInfo['email'])
                              .update({
                            'myApplication': FieldValue.arrayUnion([title])
                          });
                          print('참가 신청을 보냈습니다.');
                        }
                      },
                    ),
                  ),
                ],
              );
          }}
          else return CircularProgressIndicator();
        }
      )
    );
  }

  void commentUploadOnFS() async {
    var myInfo = fp.getInfo();
    int? commentCount;
    await fs.collection('delivery_board').doc(widget.id).get().then((value) {
      commentCount = value['commentCount'];
    });
    await fs.collection('delivery_board').doc(widget.id).update({
      'commentCount': FieldValue.increment(1),
      'comments.comment$commentCount': FieldValue.arrayUnion([commentInput.text, 0]), // [댓글, 좋아요수]
    });
    print(commentInput.text);
    commentInput.clear();
  }
}

/* ---------------------- Modify Board (Delivery) ---------------------- */

class DeliveryModify extends StatefulWidget {
  DeliveryModify(this.id);
  final String id;
  @override
  State<StatefulWidget> createState() {
    pageState4 = DeliveryModifyState();
    return pageState4;
  }
}

class DeliveryModifyState extends State<DeliveryModify> {
  final FirebaseFirestore fs = FirebaseFirestore.instance;
  late TextEditingController titleInput;
  late TextEditingController contentInput;
  late TextEditingController timeInput;
  late TextEditingController memberInput;
  late TextEditingController foodInput;
  late TextEditingController locationInput;
  late TextEditingController tagInput;
  String gender = "";
  String tags = "";
  List<String> tagList = [];
  late DateTime d;

  final _formKey = GlobalKey<FormState>();
  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

  _onDelete(index) {
    setState(() {
      tagList.removeAt(index);
    });
  }

  @override
  void initState() {
    setState(() {
      gender = "상관없음";
      fs.collection('delivery_board').doc(widget.id).get().then((snapshot) {
        var tmp = snapshot.data() as Map<String, dynamic>;
        tags = tmp['tags'];
        titleInput = TextEditingController(text: tmp['title']);
        contentInput = TextEditingController(text: tmp['contents']);
        timeInput = TextEditingController(text: formatDate(DateTime.parse(tmp['time']), [HH, ':', nn]));
        d = DateTime.parse(tmp['time']);
        memberInput = TextEditingController(text: tmp['limitedMember'].toString());
        foodInput = TextEditingController(text: tmp['food']);
        locationInput = TextEditingController(text: tmp['location']);
        tagInput = TextEditingController();
      });
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
        body: SingleChildScrollView(
            child: StreamBuilder(
                stream: fs.collection('delivery_board').doc(widget.id).snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData && !snapshot.data!.exists) return CircularProgressIndicator();
                  if (snapshot.hasData) {
                    return Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                headerText("글 수정"),
                                cSizedBox(0, 160),
                                IconButton(
                                  icon: Icon(Icons.check, color: Color(0xff639ee1),),
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
                                padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                                child: Wrap(
                                    direction: Axis.vertical,
                                    spacing: 15,
                                    children: [
                                      Text("모집조건", style: TextStyle(fontFamily: "SCDream", color: Color(0xff639ee1), fontWeight: FontWeight.w600, fontSize: 15)),
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(7, 5, 20, 0),
                                          child: Wrap(
                                            direction: Axis.vertical,
                                            spacing: 15,
                                            children: [
                                              condWrap("모집기간", timeInput, "마감 시간 입력 : xx:xx (ex 21:32 형태)", "마감 시간은 필수 입력 사항입니다."),
                                              condWrap("모집인원", memberInput, "인원을 입력하세요. (숫자 형태)", "인원은 필수 입력 사항입니다."),
                                              condWrap("음식종류", foodInput, "음식 종류를 입력하세요.", "음식 종류는 필수 입력 사항입니다."),
                                              condWrap("배분위치", locationInput, "위치를 입력하세요.", "위치는 필수 입력 사항입니다."),
                                            ],
                                          )),
                                    ],
                                )),
                            Divider(
                              color: Color(0xffe9e9e9),
                              thickness: 17,
                            ),Padding(
                                padding: EdgeInsets.fromLTRB(40, 10, 40, 10),
                                child: Wrap(direction: Axis.vertical, spacing: -10, children: [
                                  Container(
                                      width: MediaQuery.of(context).size.width * 0.8, child:
                                  TagEditor(
                                    key: key,
                                    controller: tagInput,
                                    keyboardType: TextInputType.multiline,
                                    length: tagList.length,
                                    delimiters: [',', ' '],
                                    hasAddButton: false,
                                    resetTextOnSubmitted: true,
                                    textStyle: TextStyle(fontFamily: "SCDream", color: Color(0xffa9aaaf), fontWeight: FontWeight.w500, fontSize: 11.5),
                                    inputDecoration: InputDecoration(hintText: "#태그를 입력하세요.(*첫번째 태그는 지도에 표시됩니다.)", hintStyle: TextStyle(color: Color(0xffa9aaaf), fontSize: 11.5), border: InputBorder.none, focusedBorder: InputBorder.none),
                                    onSubmitted: (outstandingValue) {
                                      setState(() {
                                        tags = tags + "#" + outstandingValue + " ";
                                        tagList.add(outstandingValue);
                                      });
                                    },
                                    onTagChanged: (newValue) {
                                      setState(() {
                                        tags = tags + "#" + newValue + " ";
                                        tagList.add("#" + newValue + " ");
                                      });
                                    },
                                    tagBuilder: (context, index) => _Chip(
                                      index: index,
                                      label: tagList[index],
                                      onDeleted: _onDelete,
                                    ),
                                  )
                                  ),
                                  Container(width: MediaQuery.of(context).size.width * 0.8, child: titleField(titleInput)),
                                ])),
                            Divider(
                              color: Color(0xffe9e9e9),
                              thickness: 2.5,
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(50, 30, 50, 30),
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
                                  }
                              )
                            ),
                          ],
                        ));
                  }
                  return CircularProgressIndicator();
                })));
  }

  void updateOnFS() async {
    await fs.collection('delivery_board').doc(widget.id).update({
      'title': titleInput.text,
      'contents': contentInput.text,
      'time': formatDate(d, [yyyy, '-', mm, '-', dd]) + " " + timeInput.text + ":00",
      'limitedMember': int.parse(memberInput.text),
      'food': foodInput.text,
      'location': locationInput.text,
      'tags': tags,
      'tagList': tagList,
      'gender': gender,
      'members': [],
      'isFineForMembers': [],
    });
  }
}



/* -----------------Applicant Board List -------------------- */

class ApplicantListBoard extends StatefulWidget {
  @override
  ApplicantListBoardState createState() {
    pageState5 = ApplicantListBoardState();
    return pageState5;
  }
}

class ApplicantListBoardState extends State<ApplicantListBoard> {
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
                      "신청자 목록",
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
                              colstream = FirebaseFirestore.instance.collection('delivery_board').orderBy("write_time", descending: true).snapshots();
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
              CustomPaint(
                size: Size(400, 4),
                painter: CurvePainter(),
              ),
              // Container or Expanded or Flexible 사용
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
                      if (fp.getInfo()['name'] == doc['writer']) {
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
      floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => DeliveryWrite()));
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
