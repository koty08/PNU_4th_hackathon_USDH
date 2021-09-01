import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:material_tag_editor/tag_editor.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:usdh/Widget/widget.dart';
import 'package:usdh/chat/const.dart';
import 'package:usdh/login/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:usdh/chat/home.dart';
import 'package:autocomplete_textfield/autocomplete_textfield.dart';
import 'package:usdh/maps/place_autocomplete.dart';
// import 'package:validators/validators.dart';
import 'package:usdh/function/chip.dart';
import 'dart:async';

late TaxiWriteState pageState;
late TaxiListState pageState2;
late TaxiShowState pageState3;
late TaxiModifyState pageState4;

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

/* ---------------------- Write Board (Taxi) ---------------------- */

class TaxiWrite extends StatefulWidget {
  @override
  TaxiWriteState createState() {
    pageState = TaxiWriteState();
    return pageState;
  }
}

class TaxiWriteState extends State<TaxiWrite> {
  late FirebaseProvider fp;
  TextEditingController titleInput = TextEditingController();
  TextEditingController contentInput = TextEditingController();
  TextEditingController timeInput = TextEditingController();
  TextEditingController memberInput = TextEditingController();
  TextEditingController startInput = TextEditingController();
  TextEditingController destInput = TextEditingController();
  TextEditingController tagInput = TextEditingController();
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseFirestore fs = FirebaseFirestore.instance;
  List tagList = [];
  TimeOfDay _time = TimeOfDay.now();
  double lat1 = 0.0, lng1 = 0.0;
  double lat2 = 0.0, lng2 = 0.0;

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
    startInput.dispose();
    destInput.dispose();
    tagInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();

    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    void onTimeChanged(TimeOfDay newTime) {
      setState(() {
        _time = newTime;
        timeInput.text = _time.format(context);
      });
    }

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
                  padding: EdgeInsets.fromLTRB(width * 0.1, height * 0.03, width * 0.1, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      cSizedBox(height*0.01, 0),
                      Text("모집조건", style: TextStyle(fontFamily: "SCDream", color: Color(0xff639ee1), fontWeight: FontWeight.w600, fontSize: 15)),
                      cSizedBox(height*0.02, 0),
                      Padding(
                          padding: EdgeInsets.fromLTRB(width*0.02, 0, width*0.02, 0),
                          child: Wrap(
                            direction: Axis.vertical,
                            spacing: -8,
                            children: [
                              Wrap(
                                spacing: 15,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    width: 60,
                                    alignment: Alignment(0.0, 0.0),
                                    child: cond2Text("모집기간"),
                                  ),
                                  GestureDetector(
                                    child: Container(width: width * 0.4,
                                      child: ccondField(timeInput, "마감 시간을 선택하세요.", "마감 시간은 필수 입력 사항입니다.")
                                    ),
                                    onTap: (){TimePicker(context, _time, onTimeChanged);}
                                  )
                                ],
                              ),
                              condWrap("모집인원", memberInput, "인원을 입력하세요. (숫자 형태)", "인원은 필수 입력 사항입니다."),
                              Wrap(
                                spacing: 15,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    width: 60,
                                    alignment: Alignment(0.0, 0.0),
                                    child: cond2Text("출발위치"),
                                  ),
                                  GestureDetector(
                                    child: Row(
                                      children: [
                                        Container(width: width * 0.4,
                                          child: ccondField(startInput, "위치를 선택하세요.", "위치는 필수 입력 사항입니다.")),
                                        Icon(Icons.search, size: 18,),
                                      ],
                                    ),
                                    onTap: () async {
                                      final data = await Navigator.push(context, MaterialPageRoute(builder: (context) => PlaceAutocomplete()));
                                      setState(() {
                                        startInput.text = data[0];
                                        lat1 = data[1];
                                        lng1 = data[2];
                                      });
                                    },
                                  ),
                                ],
                              ),
                              Wrap(
                                spacing: 15,
                                crossAxisAlignment: WrapCrossAlignment.center,
                                children: [
                                  Container(
                                    width: 60,
                                    alignment: Alignment(0.0, 0.0),
                                    child: cond2Text("도착위치"),
                                  ),
                                  GestureDetector(
                                    child: Row(
                                      children: [
                                        Container(width: width * 0.4,
                                          child: ccondField(destInput, "위치를 선택하세요.", "위치는 필수 입력 사항입니다.")),
                                        Icon(Icons.search, size: 18,),
                                      ],
                                    ),
                                    onTap: () async {
                                      final data = await Navigator.push(context, MaterialPageRoute(builder: (context) => PlaceAutocomplete()));
                                      setState(() {
                                        destInput.text = data[0];
                                        lat2 = data[1];
                                        lng2 = data[2];
                                      });
                                    },
                                  ),
                                ],
                              )
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
                          inputDecoration: InputDecoration(hintText: "스페이스바로 #태그 입력! (*첫번째 태그는 지도에 표시)", hintStyle: TextStyle(color: Color(0xffa9aaaf), fontSize: 11.5), border: InputBorder.none, focusedBorder: InputBorder.none),
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
                          tagBuilder: (context, index) => ChipState(
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
    await fs.collection('taxi_board').doc(myInfo['nick'] + myInfo['postcount'].toString()).set({
      'title': titleInput.text,
      'write_time': formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss]),
      'writer': myInfo['nick'],
      'contents': contentInput.text,
      'time':
          isTomorrow(_time.toString().substring(10, 15) + ":00") ? formatDate(DateTime.now().add(Duration(days: 1)), [yyyy, '-', mm, '-', dd]) + " " + _time.toString().substring(10, 15) + ":00" : formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]) + " " + _time.toString().substring(10, 15) + ":00",
      'currentMember': 1,
      'limitedMember': int.parse(memberInput.text),
      'start' : startInput.text,
      'dest': destInput.text,
      'tagList': tagList,
      'views': 0,
      'latlng1' : [lat1, lng1],
      'latlng2' : [lat2, lng2],
    });
    await fs.collection('users').doc(myInfo['email']).collection('applicants').doc(myInfo['nick'] + myInfo['postcount'].toString()).set({
      'where': 'taxi_board',
      'title': titleInput.text,
      'isFineForMembers': [],
      'members': [],
    });
    fp.updateIntInfo('postcount', 1);
  }
}

/* ---------------------- Board List (Taxi) ---------------------- */

class TaxiList extends StatefulWidget {
  @override
  TaxiListState createState() {
    pageState2 = TaxiListState();
    return pageState2;
  }
}

class TaxiListState extends State<TaxiList> {
  Stream<QuerySnapshot> colstream = FirebaseFirestore.instance.collection('taxi_board').orderBy("write_time", descending: true).snapshots();
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

  bool isToday(String time) {
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
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: CustomAppBar("택시", [
        IconButton(
          icon: Image.asset('assets/images/icon/iconmap.png', width: 20, height: 20),
          onPressed: () {
            Navigator.pop(context);
            // Navigator.push(context, MaterialPageRoute(builder: (context) => TaxiMap()));
          },
        ),
        //새로고침 기능
        IconButton(
          icon: Image.asset('assets/images/icon/iconrefresh.png', width: 18, height: 18),
          onPressed: () {
            setState(() {
              colstream = FirebaseFirestore.instance.collection('taxi_board').orderBy("write_time", descending: true).snapshots();
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
                                        colstream = FirebaseFirestore.instance.collection('taxi_board').orderBy('title').startAt([searchInput.text]).endAt([searchInput.text + '\uf8ff']).snapshots();
                                      });
                                      searchInput.clear();
                                      Navigator.pop(context);
                                    } else {
                                      setState(() {
                                        colstream = FirebaseFirestore.instance.collection('taxi_board').where('tagList', arrayContains: "#" + searchInput.text + " ").snapshots();
                                      });
                                      searchInput.clear();
                                      Navigator.pop(context);
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
          icon: Image.asset('assets/images/icon/iconmessage.png', width: 20, height: 20),
          onPressed: () {
            var myInfo = fp.getInfo();
            Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(myId: myInfo['email'])));
          },
        ),
      ]),
      body: RefreshIndicator(
        //당겨서 새로고침
        onRefresh: () async {
          setState(() {
            colstream = FirebaseFirestore.instance.collection('taxi_board').orderBy("write_time", descending: true).snapshots();
          });
        },
        child: StreamBuilder<QuerySnapshot>(
            stream: colstream,
            builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return CircularProgressIndicator();
              }
              return Column(children: [
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
                                    colstream = FirebaseFirestore.instance.collection('taxi_board').where('time', isGreaterThan: formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss])).snapshots();
                                  } else {
                                    colstream = FirebaseFirestore.instance.collection('taxi_board').orderBy("write_time", descending: true).snapshots();
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
                        String info = doc['write_time'].substring(5, 7) + "/" + doc['write_time'].substring(8, 10) + doc['write_time'].substring(10, 16);
                        String time = ' | ' + '마감' + doc['time'].substring(10, 16) + ' | ';
                        String writer = doc['writer'];
                        return Column(children: [
                          InkWell(
                              onTap: () {
                                Navigator.push(context, MaterialPageRoute(builder: (context) => TaxiShow(id: doc.id)));
                                FirebaseFirestore.instance.collection('taxi_board').doc(doc.id).update({"views": doc["views"] + 1});
                              },
                              child: Container(
                                  margin: EdgeInsets.fromLTRB(width*0.07, height*0.018, 0, 0),
                                  child: Column(children: [
                                    Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                      cSizedBox(0, width*0.01),
                                      Container(
                                        width: width * 0.63,
                                        height: 13,
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: doc['tagList'].length,
                                          itemBuilder: (context, index) {
                                            String tag = doc['tagList'][index].toString();
                                            return GestureDetector(
                                                onTap: () {
                                                  setState(() {
                                                    colstream = FirebaseFirestore.instance.collection('taxi_board').where('tagList', arrayContains: tag).snapshots();
                                                  });
                                                },
                                                child: smallText(tag, 12, Color(0xffa9aaaf)));
                                          })
                                      ),
                                      cSizedBox(0, width*0.08),
                                      Container(
                                          width: width*0.2,
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
                                              cSizedBox(20, width*0.02),
                                              Container(width: width*0.13, child: smallText(member, 13, Color(0xffa9aaaf)))
                                            ],
                                          ))
                                    ]),
                                    Row(children: [
                                      isAvailable(doc['time'], doc['currentMember'], doc['limitedMember']) ? statusText("모집중") : statusText("모집완료"),
                                      cSizedBox(0, 10),
                                      Container(
                                        width: width * 0.6,
                                        child: cond2Text(doc['title'].toString()),
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
            Navigator.push(context, MaterialPageRoute(builder: (context) => TaxiWrite()));
          }),
    );
  }
}

/* ---------------------- Show Board (Taxi) ---------------------- */

class TaxiShow extends StatefulWidget {
  final String id;

  TaxiShow({Key? key, required this.id}) : super(key: key);

  @override
  TaxiShowState createState() {
    pageState3 = TaxiShowState(id: id);
    return pageState3;
  }
}

class TaxiShowState extends State<TaxiShow> {
  final String id;

  TaxiShowState({Key? key, required this.id});

  late FirebaseProvider fp;
  final FirebaseStorage storage = FirebaseStorage.instance;
  final FirebaseFirestore fs = FirebaseFirestore.instance;
  TextEditingController commentInput = TextEditingController();

  SharedPreferences? prefs;
  bool alreadyLiked = false;

  GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();
  final _formKey = GlobalKey<FormState>();
  TextEditingController msgInput = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    msgInput.dispose();
    commentInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();

    return Scaffold(
        appBar: CustomAppBar("택시", []),
        body: StreamBuilder(
          stream: fs.collection('taxi_board').doc(widget.id).snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
              fp.setInfo();

              if (snapshot.hasData && !snapshot.data!.exists) {
                return CircularProgressIndicator();
              } else if (snapshot.hasData) {
                String info = snapshot.data!['write_time'].substring(5, 7) + "/" + snapshot.data!['write_time'].substring(8, 10) + snapshot.data!['write_time'].substring(10, 16) + ' | ';
                String time = snapshot.data!['time'].substring(11, 16);
                String writer = snapshot.data!['writer'];
                return SingleChildScrollView(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                        padding: EdgeInsets.fromLTRB(40, 20, 40, 20),
                        child: Wrap(direction: Axis.vertical, spacing: 15, children: [
                          Container(
                            width: MediaQuery.of(context).size.width * 0.8,
                            child: tagText(snapshot.data!['tagList'].join(' ')),
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
                                    cond2Wrap("출발위치", snapshot.data!['start']),
                                    cond2Wrap("도착위치", snapshot.data!['dest']),
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
          stream: fs.collection('taxi_board').doc(widget.id).snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            final width = MediaQuery.of(context).size.width;
            final height = MediaQuery.of(context).size.height;
              if (snapshot.hasData && !snapshot.data!.exists) {
                return CircularProgressIndicator();
              } else if (snapshot.hasData) {
                fp.setInfo();
                if (fp.getInfo()['nick'] == snapshot.data!['writer']) {
                  if (isAvailable(snapshot.data!['time'], snapshot.data!['currentMember'], snapshot.data!['limitedMember']))
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // 삭제
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
                              List<String> isFineForMemberNicks = [];
                              List<String> isFineForMemberIds = [];
                              await fs.collection('users').doc(fp.getInfo()['email']).collection('applicants').doc(snapshot.data!.id).get().then((DocumentSnapshot snap) {
                                if (snap.get('isFineForMembers').length != 0) {
                                  for (String iFFMember in snap.get('isFineForMembers')) {
                                    isFineForMemberNicks.add(iFFMember);
                                  }
                                } else {
                                  print(snapshot.data!['title'] + '에는 참가자가 없었습니다.');
                                }
                              });
                              if (isFineForMemberNicks.length != 0) {
                                for (String iFFmember in isFineForMemberNicks) {
                                  await fs.collection('users').where('nick', isEqualTo: iFFmember).get().then((QuerySnapshot snap) {
                                    isFineForMemberIds.add(snap.docs[0].get('email'));
                                  });
                                }
                              }
                              if (isFineForMemberIds.length != 0) {
                                for (String iFFMemberId in isFineForMemberIds) {
                                  await fs.collection('users').doc(iFFMemberId).collection('myApplication').doc(snapshot.data!.id).update({'where': 'deleted'});
                                }
                              }

                              await fs.collection('taxi_board').doc(widget.id).delete();
                              await fs.collection('users').doc(fp.getInfo()['email']).collection('applicants').doc(snapshot.data!.id).delete();
                              fp.updateIntInfo('postcount', -1);
                            },
                          ),
                        ),
                        // 수정
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
                              await fs.collection('taxi_board').doc(widget.id).get().then((snap) {
                                tmp = snap.data() as Map<String, dynamic>;
                              });
                              Navigator.push(context, MaterialPageRoute(builder: (context) => TaxiModify(widget.id, tmp)));
                              setState(() {});
                            },
                          ),
                        )
                      ]
                    );
                  // 삭제
                  else return Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: Color(0xffcacaca),
                      ),
                      child: GestureDetector(
                        child: Align(alignment: Alignment.center, child: smallText("삭제", 14, Colors.white)),
                        onTap: () async {
                          Navigator.pop(context);
                          List<String> isFineForMemberNicks = [];
                          List<String> isFineForMemberIds = [];
                          await fs.collection('users').doc(fp.getInfo()['email']).collection('applicants').doc(snapshot.data!.id).get().then((DocumentSnapshot snap) {
                            if (snap.get('isFineForMembers').length != 0) {
                              for (String iFFMember in snap.get('isFineForMembers')) {
                                isFineForMemberNicks.add(iFFMember);
                              }
                            } else {
                              print(snapshot.data!['title'] + '에는 참가자가 없었습니다.');
                            }
                          });
                          if (isFineForMemberNicks.length != 0) {
                            for (String iFFmember in isFineForMemberNicks) {
                              await fs.collection('users').where('nick', isEqualTo: iFFmember).get().then((QuerySnapshot snap) {
                                isFineForMemberIds.add(snap.docs[0].get('email'));
                              });
                            }
                          }
                          if (isFineForMemberIds.length != 0) {
                            for (String iFFMemberId in isFineForMemberIds) {
                              await fs.collection('users').doc(iFFMemberId).collection('myApplication').doc(snapshot.data!.id).update({'where': 'deleted'});
                            }
                          }

                          await fs.collection('taxi_board').doc(widget.id).delete();
                          await fs.collection('users').doc(fp.getInfo()['email']).collection('applicants').doc(snapshot.data!.id).delete();
                          fp.updateIntInfo('postcount', -1);
                        },
                      ),
                    );
                } else {
                  if (isAvailable(snapshot.data!['time'], snapshot.data!['currentMember'], snapshot.data!['limitedMember'])){
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
                            child: Align(alignment: Alignment.center, child: smallText("신청취소", 14, Colors.white)),
                            onTap: () async {
                              var myInfo = fp.getInfo();
                              String title = widget.id;
                              String hostId = await fs.collection('users').where('nick', isEqualTo: snapshot.data!['writer']).get().then((snap) {
                                DocumentSnapshot tmp = snap.docs[0];
                                return tmp['email'];
                              });
                              List<String> _myApplication = [];

                              await fs.collection('users').doc(myInfo['email']).collection('myApplication').get().then((QuerySnapshot snap) {
                                if (snap.docs.length != 0) {
                                  for (DocumentSnapshot doc in snap.docs) {
                                    _myApplication.add(doc.id);
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                  showMessage('참가 신청 내역이 비어있습니다.');
                                }
                              });

                              if (!_myApplication.contains(title)) {
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                showMessage("참가 신청하지 않은 방입니다.");
                              }
                              else {
                                List<dynamic> _messages = [];
                                List<dynamic> _isFineForMember = [];
                                await fs.collection('users').doc(hostId).collection('applicants').doc(widget.id).get().then((value) {
                                  _messages = value['messages'];
                                });
                                await fs.collection('users').doc(hostId).collection('applicants').doc(widget.id).get().then((value) {
                                  _isFineForMember = value['isFineForMembers'];
                                });
                                int _msgIndex = _isFineForMember.indexWhere((element) => element == myInfo['nick']);
                                if (_msgIndex >= 0) {
                                  await fs.collection('users').doc(hostId).collection('applicants').doc(widget.id).update({
                                    'isFineForMembers': FieldValue.arrayRemove([myInfo['nick']]),
                                    'messages': FieldValue.arrayRemove([_messages[_msgIndex]])
                                  });
                                }
                                await fs.collection('users').doc(myInfo['email']).collection('myApplication').doc(title).delete();
                                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                showMessage("참가 신청을 취소했습니다.");
                              }
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
                            child: Align(alignment: Alignment.center, child: smallText("참가신청", 14, Colors.white)),
                            onTap: () async {
                              var myInfo = fp.getInfo();
                              int _currentMember = snapshot.data!['currentMember'];
                              int _limitedMember = snapshot.data!['limitedMember'];
                              String title = widget.id;
                              String hostId = await fs.collection('users').where('nick', isEqualTo: snapshot.data!['writer']).get().then((QuerySnapshot snap) {
                                DocumentSnapshot tmp = snap.docs[0];
                                return tmp['email'];
                              });
                              List<String> _myApplication = [];

                              showDialog(
                                  context: context,
                                  barrierColor: null,
                                  builder: (BuildContext con) {
                                    return Form(
                                        key: _formKey,
                                        child: AlertDialog(
                                            elevation: 0.3,
                                            contentPadding: EdgeInsets.zero,
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                            backgroundColor: Colors.grey[200],
                                            content: Container(
                                                height: height * 0.32,
                                                width: width*0.8,
                                                padding: EdgeInsets.fromLTRB(0, height*0.05, 0, 0),
                                                child: Column(
                                                  children: [
                                                    Container(width: width*0.65, child: smallText("방장한테 보낼 메세지를 입력하세요\n(20자 이내)", 16, Color(0xB2000000))),
                                                    Container(width: width*0.65,
                                                      padding: EdgeInsets.fromLTRB(0, height*0.02, 0, 0),
                                                      child: TextFormField(
                                                          controller: msgInput,
                                                          keyboardType: TextInputType.multiline,
                                                          inputFormatters: [
                                                            LengthLimitingTextInputFormatter(20),
                                                          ],
                                                          style: TextStyle(fontFamily: "SCDream", color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 14),
                                                          decoration: InputDecoration(
                                                              focusedBorder: UnderlineInputBorder(
                                                                borderSide: BorderSide(color: Colors.black87, width: 1.5),
                                                              ),
                                                              hintText: "메세지를 입력하세요.", hintStyle: TextStyle(fontFamily: "SCDream", color: Colors.black45, fontWeight: FontWeight.w500, fontSize: 14)
                                                          ),
                                                          validator: (text) {
                                                            if (text == null || text.isEmpty) {
                                                              return "메세지를 입력하지 않으셨습니다.";
                                                            }
                                                            return null;
                                                          }
                                                      ),
                                                    ),
                                                    Row(
                                                      mainAxisAlignment: MainAxisAlignment.end,
                                                      children: [
                                                        TextButton(
                                                            onPressed: () async {
                                                              if (_formKey.currentState!.validate()) {
                                                                await fs.collection('users').doc(myInfo['email']).collection('myApplication').get().then((QuerySnapshot snap) {
                                                                  if (snap.docs.length != 0) {
                                                                    for (DocumentSnapshot doc in snap.docs) {
                                                                      _myApplication.add(doc.id);
                                                                    }
                                                                  } else {
                                                                    print('myApplication 콜렉션이 비어있읍니다.');
                                                                  }
                                                                });

                                                                if (_myApplication.contains(title)) {
                                                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                                  showMessage("이미 신청한 방입니다.");
                                                                } else if (_currentMember >= _limitedMember) {
                                                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                                  showMessage("방이 모두 차있습니다.");
                                                                } else {
                                                                  // 방장에게 날리는 메세지
                                                                  await fs.collection('users').doc(hostId).collection('applicants').doc(widget.id).update({
                                                                    'isFineForMembers': FieldValue.arrayUnion([myInfo['nick']]),
                                                                    'messages': FieldValue.arrayUnion([msgInput.text]),
                                                                  });
                                                                  // 내 정보에 신청 정보를 기록
                                                                  await fs.collection('users').doc(myInfo['email']).collection('myApplication').doc(title).set({'where': "taxi_board", 'isRejected': false, 'isJoined': false});
                                                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                                  showMessage("참가 신청을 보냈습니다.");
                                                                }
                                                                msgInput.clear();
                                                                Navigator.pop(con);
                                                              }
                                                            },
                                                            child: info2Text("확인")
                                                        ),
                                                        TextButton(onPressed: (){
                                                          msgInput.clear();
                                                          Navigator.pop(con);
                                                        },
                                                            child: info2Text("취소")
                                                        ),
                                                        cSizedBox(0, width*0.05)
                                                      ],
                                                    )
                                                  ],
                                                )
                                            )
                                        ));
                                  });
                            },
                          ),
                        ),
                      ],
                    );
                  }
                  else return SizedBox.shrink();
                }
              } else
                return CircularProgressIndicator();
            }));
  }

  showMessage(String msg) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: Colors.blue[200],
      duration: Duration(seconds: 7),
      content: smallText(msg, 13, Colors.white),
    ));
  }
}

/* ---------------------- Modify Board (Taxi) ---------------------- */

class TaxiModify extends StatefulWidget {
  TaxiModify(this.id, this.datas);
  final String id;
  final Map<String, dynamic> datas;
  @override
  State<StatefulWidget> createState() {
    pageState4 = TaxiModifyState();
    return pageState4;
  }
}

class TaxiModifyState extends State<TaxiModify> {
  late FirebaseProvider fp;
  final FirebaseFirestore fs = FirebaseFirestore.instance;
  late TextEditingController titleInput;
  late TextEditingController contentInput;
  late TextEditingController timeInput;
  late TextEditingController memberInput;
  late TextEditingController startInput;
  late TextEditingController destInput;
  late TextEditingController tagInput;
  List<dynamic> tagList = [];
  late DateTime d;
  TimeOfDay _time = TimeOfDay.now();
  double lat1 = 0.0, lng1 = 0.0;
  double lat2 = 0.0, lng2 = 0.0;

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
      startInput = TextEditingController(text: widget.datas['start']);
      destInput = TextEditingController(text: widget.datas['dest']);
      tagInput = TextEditingController();
      lat1 = widget.datas['latlng1'][0];
      lng1 = widget.datas['latlng1'][1];
      lat2 = widget.datas['latlng2'][0];
      lng2 = widget.datas['latlng2'][1];
    });
    super.initState();
  }

  @override
  void dispose() {
    titleInput.dispose();
    contentInput.dispose();
    timeInput.dispose();
    memberInput.dispose();
    startInput.dispose();
    destInput.dispose();
    tagInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    void onTimeChanged(TimeOfDay newTime) {
      setState(() {
        _time = newTime;
        timeInput.text = _time.format(context);
      });
    }

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
                stream: fs.collection('taxi_board').doc(widget.id).snapshots(),
                builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasData && !snapshot.data!.exists) return CircularProgressIndicator();
                  if (snapshot.hasData) {
                    return Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                                padding: EdgeInsets.fromLTRB(width * 0.1, height * 0.03, width * 0.1, 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    cSizedBox(height*0.01, 0),
                                    Text("모집조건", style: TextStyle(fontFamily: "SCDream", color: Color(0xff639ee1), fontWeight: FontWeight.w600, fontSize: 15)),
                                    cSizedBox(height*0.02, 0),
                                    Padding(
                                        padding: EdgeInsets.fromLTRB(width*0.02, 0, width*0.02, 0),
                                        child: Wrap(
                                          direction: Axis.vertical,
                                          spacing: -8,
                                          children: [
                                            Wrap(
                                              spacing: 15,
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              children: [
                                                Container(
                                                  width: 60,
                                                  alignment: Alignment(0.0, 0.0),
                                                  child: cond2Text("모집기간"),
                                                ),
                                                GestureDetector(
                                                    child: Container(width: width * 0.4,
                                                        child: ccondField(timeInput, "마감 시간을 선택하세요.", "마감 시간은 필수 입력 사항입니다.")
                                                    ),
                                                    onTap: (){TimePicker(context, _time, onTimeChanged);}
                                                )
                                              ],
                                            ),
                                            condWrap("모집인원", memberInput, "인원을 입력하세요. (숫자 형태)", "인원은 필수 입력 사항입니다."),
                                            Wrap(
                                              spacing: 15,
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              children: [
                                                Container(
                                                  width: 60,
                                                  alignment: Alignment(0.0, 0.0),
                                                  child: cond2Text("출발위치"),
                                                ),
                                                GestureDetector(
                                                  child: Row(
                                                    children: [
                                                      Container(width: width * 0.4,
                                                          child: ccondField(startInput, "위치를 선택하세요.", "위치는 필수 입력 사항입니다.")),
                                                      Icon(Icons.search, size: 18,),
                                                    ],
                                                  ),
                                                  onTap: () async {
                                                    final data = await Navigator.push(context, MaterialPageRoute(builder: (context) => PlaceAutocomplete()));
                                                    setState(() {
                                                      startInput.text = data[0];
                                                      lat1 = data[1];
                                                      lng1 = data[2];
                                                    });
                                                  },
                                                ),
                                              ],
                                            ),
                                            Wrap(
                                              spacing: 15,
                                              crossAxisAlignment: WrapCrossAlignment.center,
                                              children: [
                                                Container(
                                                  width: 60,
                                                  alignment: Alignment(0.0, 0.0),
                                                  child: cond2Text("배분위치"),
                                                ),
                                                GestureDetector(
                                                  child: Row(
                                                    children: [
                                                      Container(width: width * 0.4,
                                                          child: ccondField(destInput, "위치를 선택하세요.", "위치는 필수 입력 사항입니다.")),
                                                      Icon(Icons.search, size: 18,),
                                                    ],
                                                  ),
                                                  onTap: () async {
                                                    final data = await Navigator.push(context, MaterialPageRoute(builder: (context) => PlaceAutocomplete()));
                                                    setState(() {
                                                      destInput.text = data[0];
                                                      lat2 = data[1];
                                                      lng2 = data[2];
                                                    });
                                                  },
                                                ),
                                              ],
                                            )
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
                                            InputDecoration(hintText: "스페이스바로 #태그 입력! (*첫번째 태그는 지도에 표시)", hintStyle: TextStyle(color: Color(0xffa9aaaf), fontSize: 11.5), border: InputBorder.none, focusedBorder: InputBorder.none),
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
                                        tagBuilder: (context, index) => ChipState(
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
    await fs.collection('taxi_board').doc(widget.id).update({
      'title': titleInput.text,
      'contents': contentInput.text,
      //원래 이전 날짜 기억하려 d 사용했다가 현재 잠시 바꿈 (오늘, 내일 테스트용)
      'time':
        isTomorrow(_time.toString().substring(10, 15) + ":00") ? formatDate(DateTime.now().add(Duration(days: 1)), [yyyy, '-', mm, '-', dd]) + " " + _time.toString().substring(10, 15) + ":00" : formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd]) + " " + _time.toString().substring(10, 15) + ":00",
      'limitedMember': int.parse(memberInput.text),
      'start': startInput.text,
      'dest': destInput.text,
      'tagList': tagList,
      'latlng1' : [lat1, lng1],
      'latlng2' : [lat2, lng2],
    });
    await fs.collection('users').doc(myInfo['email']).collection('applicants').doc(widget.id).update({
      'where': 'taxi_board',
      'title': titleInput.text,
      // 'members': [],
    });
  }
}
