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
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:validators/validators.dart';
import 'package:usdh/maps/delivery.dart';
import 'dart:async';

late DeliveryWriteState pageState;
late DeliveryMapState pageState1;
late DeliveryListState pageState2;
late DeliveryShowState pageState3;
late DeliveryModifyState pageState4;

bool isAvailable(String time, int n1, int n2) {
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

bool isTomorrow(String time) {
  String now = formatDate(DateTime.now(), [HH, ':', nn, ':', ss]);
  print("마감 " + time);
  print("현재 " + now);
  if (time.compareTo(now) == -1) {
    print("내일");
    return true;
  } else {
    print("오늘");
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
                              // 시간은 validator 처리때문에 따로 파겠습니다.
                              // condWrap("모집기간", timeInput, "마감 시간 입력 : xx:xx (ex 21:32 형태)", "마감 시간은 필수 입력 사항입니다."),
                              Wrap(
                                spacing: 15,
                                children: [
                                  cond2Text("모집기간"),
                                  Container(
                                    width: 250,
                                    height: 20,
                                    margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
                                    child: TextFormField(
                                        controller: timeInput,
                                        style: TextStyle(fontFamily: "SCDream", color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13),
                                        decoration: InputDecoration(hintText: "마감 시간 입력 : xx:xx (ex 21:32 형태)", border: InputBorder.none, focusedBorder: InputBorder.none),
                                        validator: (text) {
                                          if (text == null || text.isEmpty) {
                                            return "마감 시간은 필수 입력 사항입니다.";
                                          } else if (isNumeric(text[0]) && isNumeric(text[1]) && (text[2] == ':') && isNumeric(text[3]) && isNumeric(text[4])) {
                                            return null;
                                          } else {
                                            return "올바른 형식으로 입력해주세요. (ex 09:10)";
                                          }
                                        }),
                                  )
                                ],
                              ),
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
                        width: MediaQuery.of(context).size.width * 0.8,
                        child: TagEditor(
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
                              tagList.add(outstandingValue);
                            });
                          },
                          onTagChanged: (newValue) {
                            setState(() {
                              tagList.add("#" + newValue + " ");
                            });
                          },
                          tagBuilder: (context, index) => _Chip(
                            index: index,
                            label: tagList[index],
                            onDeleted: _onDelete,
                          ),
                        )),
                    Container(width: MediaQuery.of(context).size.width * 0.8, child: titleField(titleInput)),
                  ])),
              Divider(
                color: Color(0xffe9e9e9),
                thickness: 2.5,
              ),
              Container(
                  padding: EdgeInsets.fromLTRB(40, 10, 40, 0),
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
              cSizedBox(350, 0)
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
      'time':
          isTomorrow(timeInput.text + ":00") ? formatDate(DateTime.now().add(Duration(days: 1)), [yyyy, '-', mm, '-', dd]) + " " + timeInput.text + ":00" : formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]) + " " + timeInput.text + ":00",
      'currentMember': 1,
      'limitedMember': int.parse(memberInput.text),
      'food': foodInput.text,
      'location': locationInput.text,
      'tagList': tagList,
      'views': 0,
    });
    await fs.collection('users').doc(myInfo['email']).collection('applicants').doc(myInfo['name'] + myInfo['postcount'].toString()).set({
      'where': 'delivery_board',
      'title': titleInput.text,
      'isFineForMembers': [],
      'members': [],
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

class DeliveryMap extends StatefulWidget {
  @override
  DeliveryMapState createState() {
    pageState1 = DeliveryMapState();
    return pageState1;
  }
}

class DeliveryMapState extends State<DeliveryMap> {
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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => DeliveryMap()));
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
                                    return StatefulBuilder(builder: (con, setS) {
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
                                                        setS(() {
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
                                                        setS(() {
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
                                                          colstream = FirebaseFirestore.instance.collection('delivery_board').where('tagList', arrayContains: "#" + searchInput.text + " ").snapshots();
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
                // ------------------------------ 아래에 지도 추가 ------------------------------
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => DeliveryWrite()));
          }),
    );
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
                              Navigator.push(context, MaterialPageRoute(builder: (context) => DeliveryGoogleMap()));
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
                                    return StatefulBuilder(builder: (con, setS) {
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
                                                        setS(() {
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
                                                        setS(() {
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
                                                          colstream = FirebaseFirestore.instance.collection('delivery_board').where('tagList', arrayContains: "#" + searchInput.text + " ").snapshots();
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
                                  if (status) {
                                    colstream = FirebaseFirestore.instance.collection('delivery_board').where('time', isGreaterThan: formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss])).snapshots();
                                  } else {
                                    colstream = FirebaseFirestore.instance.collection('delivery_board').orderBy("write_time", descending: true).snapshots();
                                  }
                                });
                              },
                            ),
                          ),
                        ),
                      ),
                      cSizedBox(5, 5),
                      Text(
                        "모집중만 보기",
                        style: TextStyle(fontFamily: "NSRound", fontWeight: FontWeight.w400, fontSize: 13, color: Colors.indigo.shade300),
                      ),
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
                        String info = doc['time'].substring(5, 7) + "/" + doc['time'].substring(8, 10) + doc['write_time'].substring(10, 16);
                        String time = ' | ' + '마감' + doc['time'].substring(10, 16) + ' | ';
                        String writer = doc['writer'];
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
                                              itemBuilder: (context, index) {
                                                String tag = doc['tagList'][index].toString();
                                                return GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        colstream = FirebaseFirestore.instance.collection('delivery_board').where('tagList', arrayContains: tag).snapshots();
                                                      });
                                                    },
                                                    child: smallText(tag, 12, Color(0xffa9aaaf)));
                                              })),
                                      cSizedBox(0, 10),
                                      Container(
                                          width: 50,
                                          child: Row(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              isAvailable(doc['time'], doc['currentMember'], doc['limitedMember'])
                                                  ? Image(
                                                      image: AssetImage('assets/images/icon/iconminiperson.png'),
                                                      height: 15,
                                                      width: 15,
                                                    )
                                                  : Image(
                                                      image: AssetImage('assets/images/icon/iconminiperson2.png'),
                                                      height: 15,
                                                      width: 15,
                                                    ),
                                              cSizedBox(20, 7),
                                              smallText(member, 13, Color(0xffa9aaaf))
                                            ],
                                          ))
                                    ]),
                                    Row(children: [
                                      isAvailable(doc['time'], doc['currentMember'], doc['limitedMember']) ? statusText("모집중") : statusText("모집완료"),
                                      cSizedBox(0, 10),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.6,
                                        child: Text(doc['title'].toString(), overflow: TextOverflow.ellipsis, style: TextStyle(fontFamily: "SCDream", fontWeight: FontWeight.w700, fontSize: 15)),
                                      ),
                                      cSizedBox(35, 0),
                                    ]),
                                    Row(
                                      children: [
                                        cSizedBox(20, 5),
                                        smallText(info, 10, Color(0xffa9aaaf)),
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

  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

  @override
  void initState() {
    super.initState();
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
                String info = snapshot.data!['write_time'].substring(5, 7) + "/" + snapshot.data!['write_time'].substring(8, 10) + snapshot.data!['write_time'].substring(10, 16) + ' | ';
                String time = snapshot.data!['time'].substring(10, 16);
                String writer = snapshot.data!['writer'];
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
                        cSizedBox(0, 250),
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
                          smallText("등록일 " + info + "마감 " + time + ' | ' + "작성자 " + writer, 11.5, Color(0xffa9aaaf))
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
                                    cond2Wrap("모집기간", time),
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
                  ],
                ));
              } else {
                return CircularProgressIndicator();
              }
            }),
        bottomNavigationBar: StreamBuilder(
            stream: fs.collection('delivery_board').doc(widget.id).snapshots(),
            builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasData && !snapshot.data!.exists) {
                return CircularProgressIndicator();
              } else if (snapshot.hasData) {
                fp.setInfo();
                if (fp.getInfo()['name'] == snapshot.data!['writer']) {
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
                            Navigator.pop(context);
                            await fs.collection('delivery_board').doc(widget.id).delete();
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
                          onTap: () async {
                            var tmp;
                            await fs.collection('delivery_board').doc(widget.id).get().then((snap) {
                              tmp = snap.data() as Map<String, dynamic>;
                            });
                            Navigator.push(context, MaterialPageRoute(builder: (context) => DeliveryModify(widget.id, tmp)));
                            setState(() {});
                          },
                        ),
                      ),
                    ],
                  );
                } else {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // 참가 신청 취소
                      Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xffcacaca),
                        ),
                        child: GestureDetector(
                          child: Align(alignment: Alignment.center, child: smallText("신청취소", 14, Colors.white)),
                          onTap: () async {
                            var myInfo = fp.getInfo();
                            String title = widget.id;
                            String hostId = '';
                            List<String> _myApplication = [];

                            await FirebaseFirestore.instance.collection('users').where('name', isEqualTo: snapshot.data!['writer']).get().then((QuerySnapshot snap) {
                              DocumentSnapshot tmp = snap.docs[0];
                              hostId = tmp['email'];
                            });
                            await FirebaseFirestore.instance.collection('users').doc(myInfo['email']).get().then((value) {
                              for (String myApplication in value['myApplication']) {
                                _myApplication.add(myApplication);
                              }
                            });

                            if (!_myApplication.contains(title)) {
                              print('참가 신청하지 않은 방입니다!!');
                            } else {
                              await FirebaseFirestore.instance.collection('users').doc(hostId).collection('applicants').doc(widget.id).update({
                                'isFineForMembers': FieldValue.arrayRemove([myInfo['nick']]),
                              });
                              await FirebaseFirestore.instance.collection('users').doc(myInfo['email']).update({
                                'myApplication': FieldValue.arrayRemove([title])
                              });

                              print('참가 신청을 취소했습니다.');
                            }
                          },
                        ),
                      ),
                      // 참가 신청
                      Container(
                        width: MediaQuery.of(context).size.width * 0.5,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(0xff639ee1),
                        ),
                        child: GestureDetector(
                          child: Align(alignment: Alignment.center, child: smallText("참가신청", 14, Colors.white)),
                          onTap: () async {
                            var myInfo = fp.getInfo();
                            int _currentMember = snapshot.data!['currentMember'];
                            int _limitedMember = snapshot.data!['limitedMember'];
                            String title = widget.id;
                            String? hostId;
                            List<String> _myApplication = [];
                            List<String> _joiningIn = [];

                            await fs.collection('users').where('name', isEqualTo: snapshot.data!['writer']).get().then((QuerySnapshot snap) {
                              DocumentSnapshot tmp = snap.docs[0];
                              hostId = tmp['email'];
                            });

                            await fs.collection('users').doc(myInfo['email']).collection('myApplication').get().then((QuerySnapshot snap) {
                              for (DocumentSnapshot doc in snap.docs) {
                                _myApplication.add(doc.id);
                              }
                            });

                            await fs.collection('users').doc(myInfo['email']).get().then((DocumentSnapshot snap) {
                              for (String joinedRoom in snap['joiningIn']) {
                                _joiningIn.add(joinedRoom);
                              }
                            });

                            if (_myApplication.contains(title) || _joiningIn.contains(title)) {
                              print('이미 신청(가입)한 방입니다!!');
                            } else if (_currentMember >= _limitedMember) {
                              print('This room is full');
                            } else {
                              // 방장에게 날리는 메세지
                              if (hostId!.isNotEmpty) {
                                await fs.collection('users').doc(hostId).collection('applicants').doc(widget.id).update({
                                  'isFineForMembers': FieldValue.arrayUnion([myInfo['nick']]),
                                });
                              } else {
                                print('hostId is null!!');
                              }
                              // 내 정보에 신청 정보를 기록
                              await fs.collection('users').doc(myInfo['email']).collection('myApplication').doc(title).set({
                                'where': "delivery_board",
                              });
                              print('참가 신청을 보냈습니다.');
                            }
                          },
                        ),
                      ),
                    ],
                  );
                }
              } else
                return CircularProgressIndicator();
            }));
  }
}

/* ---------------------- Modify Board (Delivery) ---------------------- */

class DeliveryModify extends StatefulWidget {
  DeliveryModify(this.id, this.datas);
  final String id;
  final Map<String, dynamic> datas;
  @override
  State<StatefulWidget> createState() {
    pageState4 = DeliveryModifyState();
    return pageState4;
  }
}

class DeliveryModifyState extends State<DeliveryModify> {
  late FirebaseProvider fp;
  final FirebaseFirestore fs = FirebaseFirestore.instance;
  late TextEditingController titleInput;
  late TextEditingController contentInput;
  late TextEditingController timeInput;
  late TextEditingController memberInput;
  late TextEditingController foodInput;
  late TextEditingController locationInput;
  late TextEditingController tagInput;
  List<dynamic> tagList = [];
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
      tagList = widget.datas['tagList'];
      d = DateTime.parse(widget.datas['time']);
      titleInput = TextEditingController(text: widget.datas['title']);
      timeInput = TextEditingController(text: formatDate(d, [HH, ':', nn]));
      contentInput = TextEditingController(text: widget.datas['contents']);
      memberInput = TextEditingController(text: widget.datas['limitedMember'].toString());
      foodInput = TextEditingController(text: widget.datas['food']);
      locationInput = TextEditingController(text: widget.datas['location']);
      tagInput = TextEditingController();
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
                                      width: MediaQuery.of(context).size.width * 0.8,
                                      child: TagEditor(
                                        key: key,
                                        controller: tagInput,
                                        keyboardType: TextInputType.multiline,
                                        length: tagList.length,
                                        delimiters: [',', ' '],
                                        hasAddButton: false,
                                        resetTextOnSubmitted: true,
                                        textStyle: TextStyle(fontFamily: "SCDream", color: Color(0xffa9aaaf), fontWeight: FontWeight.w500, fontSize: 11.5),
                                        inputDecoration:
                                            InputDecoration(hintText: "#태그를 입력하세요.(*첫번째 태그는 지도에 표시됩니다.)", hintStyle: TextStyle(color: Color(0xffa9aaaf), fontSize: 11.5), border: InputBorder.none, focusedBorder: InputBorder.none),
                                        onSubmitted: (outstandingValue) {
                                          setState(() {
                                            tagList.add(outstandingValue);
                                          });
                                        },
                                        onTagChanged: (newValue) {
                                          setState(() {
                                            tagList.add("#" + newValue + " ");
                                          });
                                        },
                                        tagBuilder: (context, index) => _Chip(
                                          index: index,
                                          label: tagList[index],
                                          onDeleted: _onDelete,
                                        ),
                                      )),
                                  Container(width: MediaQuery.of(context).size.width * 0.8, child: titleField(titleInput)),
                                ])),
                            Divider(
                              color: Color(0xffe9e9e9),
                              thickness: 2.5,
                            ),
                            Container(
                                padding: EdgeInsets.fromLTRB(40, 10, 40, 0),
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
                            cSizedBox(350, 0)
                          ],
                        ));
                  }
                  return CircularProgressIndicator();
                })));
  }

  void updateOnFS() async {
    var myInfo = fp.getInfo();
    await fs.collection('delivery_board').doc(widget.id).update({
      'title': titleInput.text,
      'contents': contentInput.text,
      //원래 이전 날짜 기억하려 d 사용했다가 현재 잠시 바꿈 (오늘, 내일 테스트용)
      'time':
          isTomorrow(timeInput.text + ":00") ? formatDate(DateTime.now().add(Duration(days: 1)), [yyyy, '-', mm, '-', dd]) + " " + timeInput.text + ":00" : formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]) + " " + timeInput.text + ":00",
      'limitedMember': int.parse(memberInput.text),
      'food': foodInput.text,
      'location': locationInput.text,
      'tagList': tagList,
      'members': [],
    });
    await fs.collection('users').doc(myInfo['email']).collection('applicants').doc(widget.id).update({
      'where': 'delivery_board',
      'title': titleInput.text,
      'isFineForMembers': [],
      'members': [],
    });
  }
}
