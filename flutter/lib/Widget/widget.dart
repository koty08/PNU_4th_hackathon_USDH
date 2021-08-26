import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:usdh/chat/home.dart';
import 'package:usdh/login/firebase_provider.dart';
import 'package:validators/validators.dart';

Widget cSizedBox(double h, double w) {
  return SizedBox(
    height: h,
    width: w,
  );
}

/* ---------------------- topbar(n) ---------------------- */
/* n = widget 개수 */

Widget topbar2 (BuildContext context, String text) {
  final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height;
  return Column(
    children: [
      cSizedBox(35, 0),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            padding: EdgeInsets.fromLTRB(width*0.07, 0, 0, 0),
            icon: Image.asset('assets/images/icon/iconback.png', width: 22, height: 22),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          cSizedBox(0, width*0.08),
          Container(width: MediaQuery.of(context).size.width * 0.6,
            child: headerText(text),),
        ],
      ),
      headerDivider(),
    ],
  );
}

Widget profilebar2 (BuildContext context, String nick, String text) {
  final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height;
  return Column(
    children: [
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            padding: EdgeInsets.fromLTRB(width*0.05, 0, 0, 0),
            icon: Image.asset('assets/images/icon/iconback.png', width: 20, height: 20),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          cSizedBox(0, width*0.05),
          Container(width: MediaQuery.of(context).size.width * 0.6,
            child: smallText(nick + " 님의 " + text, 16, Color(0xff548ee0)),),
        ],
      ),
      headerDivider(),
    ],
  );
}

Widget topbar3 (BuildContext context, String text, Function()? function) {
  final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height;
  return Column(
    children: [
      cSizedBox(35, 0),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            padding: EdgeInsets.fromLTRB(width*0.07, 0, 0, 0),
            icon: Image.asset('assets/images/icon/iconback.png', width: 22, height: 22),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          cSizedBox(0, width*0.07),
          headerText(text),
          cSizedBox(0, width*0.45),
          IconButton(
            icon: Icon(
              Icons.check,
              color: Color(0xff639ee1),
            ),
            onPressed: function
          ),
        ],
      ),
      headerDivider(),
    ],
  );
}

Widget topbar5 (BuildContext context, String text, Function()? function, Widget route) {
  final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height;
  late FirebaseProvider fp = Provider.of<FirebaseProvider>(context);
  return Column(
    children: [
      cSizedBox(35, 0),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            padding: EdgeInsets.fromLTRB(width*0.07, 0, 0, 0),
            icon: Image.asset('assets/images/icon/iconback.png', width: 22, height: 22),
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              Navigator.pop(context);
            },
          ),
          cSizedBox(0, width*0.07),
          headerText(text),
          cSizedBox(0, width*0.3),
          Wrap(
            spacing: -7,
            children: [
              IconButton(
                icon: Image.asset('assets/images/icon/icongoboard.png', width: 22, height: 22),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => route));
                },
              ),
              //새로고침 기능
              IconButton(
                icon: Image.asset('assets/images/icon/iconrefresh.png', width: 22, height: 22),
                onPressed: function,
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
      headerDivider(),
    ],
  );
}


Widget topbar4_nomap (BuildContext context, String text, Function()? function, Key? key,
    String search, TextEditingController? searchInput, Function()? function2) {
  final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height;
  late FirebaseProvider fp = Provider.of<FirebaseProvider>(context);
  return Column(
    children: [
      cSizedBox(35, 0),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            padding: EdgeInsets.fromLTRB(width*0.07, 0, 0, 0),
            icon: Image.asset('assets/images/icon/iconback.png', width: 22, height: 22),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          cSizedBox(0, width*0.07),
          headerText(text),
          cSizedBox(0, width*0.3),
          Wrap(
            spacing: -7,
            children: [
              //새로고침 기능
              IconButton(
                icon: Image.asset('assets/images/icon/iconrefresh.png', width: 22, height: 22),
                onPressed: function,
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
                              key: key,
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
                                      onPressed: function2,
                                      child: Text("검색")),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(con);
                                        searchInput!.clear();
                                      },
                                      child: Text("취소")),
                                ],
                              ));
                        });
                      });
                },
              ),
            ],
          )
        ],
      ),
      headerDivider(),
    ],
  );
}

Widget topbar6_map (BuildContext context, String text, Widget route, Function()? function, Key? key,
    String search, TextEditingController? searchInput, Function()? function2) {
  final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height;
  late FirebaseProvider fp = Provider.of<FirebaseProvider>(context);
  return Column(
    children: [
      cSizedBox(35, 0),
      Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            padding: EdgeInsets.fromLTRB(width*0.07, 0, 0, 0),
            icon: Image.asset('assets/images/icon/iconback.png', width: 22, height: 22),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          cSizedBox(0, width*0.07),
          headerText(text),
          cSizedBox(0, width*0.21),
          Wrap(
            spacing: -9,
            children: [
              IconButton(
                icon: Image.asset('assets/images/icon/iconmap.png', width: 22, height: 22),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => route));
                },
              ),
              //새로고침 기능
              IconButton(
                icon: Image.asset('assets/images/icon/iconrefresh.png', width: 22, height: 22),
                onPressed: function,
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
                              key: key,
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
                                      onPressed: function2,
                                      child: Text("검색")),
                                  TextButton(
                                      onPressed: () {
                                        Navigator.pop(con);
                                        searchInput!.clear();
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
      headerDivider(),
    ],
  );
}


/* ---------------------- inputNav ---------------------- */

Widget inputNav2(String data, String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(padding: EdgeInsets.fromLTRB(35, 0, 0, 30)),
      Image(image: AssetImage(data), height: 19, width: 19,),
      Container(
        height: 25,
        child: Text(
          text,
          style: TextStyle(fontFamily: "SCDream", color: Color(0xff548ee0), fontWeight: FontWeight.w500, fontSize: 17),
          textAlign: TextAlign.left,
        ),
      ),
    ],
  );
}


/* ---------------------- Divider ---------------------- */

Widget headerDivider() {
  return Container(
    height: 3,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topLeft, end: Alignment.bottomRight, stops: [0.0, 1.0],
        colors: [Colors.blue.shade100, Colors.deepPurple.shade100,],
      ),
    ),
  );
}

Widget middleDivider() {
  return Container(
    margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
    height: 0.6,
    decoration: BoxDecoration(
      color: Color(0xffc4c4c4),
      borderRadius: BorderRadius.circular(20),
    ),
  );
}

Widget largeDivider() {
  return Container(
    margin: EdgeInsets.fromLTRB(0, 3, 0, 3),
    height: 10,
    decoration: BoxDecoration(
      color: Color(0xffc4c4c4),
      borderRadius: BorderRadius.circular(20),
    ),
  );
}


/* ---------------------- Text ---------------------- */

Widget headerText(String text) {
  return Text(
      text, overflow: TextOverflow.ellipsis,
      style: TextStyle(fontFamily: "SCDream", color: Color(0xff548ee0), fontWeight: FontWeight.w500, fontSize: 18)
  );
}

Widget tagText(String text) {
  return Text(
    text,
    style: TextStyle(fontFamily: "SCDream", color: Color(0xffa9aaaf), fontWeight: FontWeight.w500, fontSize: 13)
  );
}

Widget smallText(String text, double size, Color color) {
  return Text(
    text, overflow: TextOverflow.ellipsis,
      style: TextStyle(fontFamily: "SCDream", color: color, fontWeight: FontWeight.w500, fontSize: size)
  );
}

Widget middleText(String text, double size, Color color) {
  return Text(
      text, overflow: TextOverflow.ellipsis,
      style: TextStyle(fontFamily: "SCDream", color: color, fontWeight: FontWeight.w700, fontSize: size)
  );
}

Widget statusText(String text) {
  Color statuscolor = Color(0xff639ee1);
  if (text=="모집완료")
    statuscolor = Color(0xffcacaca);
  return Container(
    width: 60,
    height: 20,
    decoration: BoxDecoration(
      color: statuscolor,
      borderRadius: BorderRadius.circular(5)
    ),
    child: Text(text, textAlign: TextAlign.center,
      style: TextStyle(height: 1.5, fontFamily: "SCDream", color: Colors.white, fontWeight: FontWeight.w500, fontSize: 12.5)
    )
  );
}

Widget infoText(String text) {
  return Text(
      text,
      style: TextStyle(fontFamily: "SCDream", color: Color(0xff639ee1), fontWeight: FontWeight.w600, fontSize: 16)
  );
}

Widget info2Text(String text) {
  return Text(
      text,
      style: TextStyle(fontFamily: "SCDream", color: Color(0xB2000000), fontWeight: FontWeight.w500, fontSize: 13)
  );
}

Widget titleText(String text) {
  return Text(
      text,
      style: TextStyle(fontFamily: "SCDream", color: Color(0xff646464), fontWeight: FontWeight.w600, fontSize: 18)
  );
}

Widget condText(String text) {
  return Text(
      text,
      style: TextStyle(fontFamily: "SCDream", color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13)
  );
}

Widget cond2Text(String text) {
  return Text(
      text,
      style: TextStyle(fontFamily: "SCDream", color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 13)
  );
}


/* ---------------------- Text Field ---------------------- */

// Widget tagField(TextEditingController controller, String hint, String valid) {
//   GlobalKey<AutoCompleteTextFieldState<String>> key = new GlobalKey();

//   return SimpleAutoCompleteTextField(
//       key: key,
//       controller: controller,
//       keyboardType: TextInputType.multiline, 
//       clearOnSubmit: true,
//       style: TextStyle(fontFamily: "SCDream", color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: 14),
//       decoration: InputDecoration(hintText: hint, border: InputBorder.none, focusedBorder: InputBorder.none),
//       suggestions: [
//         "#치킨",
//         "b",
//         "c",
//         "d",
//         "e",
//       ],
//   );
// }

Widget titleField(TextEditingController controller) {
  return TextFormField(
    controller: controller,
    inputFormatters: [
      LengthLimitingTextInputFormatter(30),
    ],
    keyboardType: TextInputType.multiline, maxLines: null,
    style: TextStyle(fontFamily: "SCDream", color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18),
    decoration: InputDecoration(hintText: "제목을 입력하세요.", border: InputBorder.none, focusedBorder: InputBorder.none),
    validator: (text) {
      if (text == null || text.isEmpty) {
        return "제목은 필수 입력 사항입니다.";
      }
      return null;
    }
  );
}

Widget condField(TextEditingController controller, String hint, String valid) {
  return TextFormField(
    controller: controller,
    style: TextStyle(fontFamily: "SCDream", color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13),
    decoration: InputDecoration(hintText: hint, border: InputBorder.none, focusedBorder: InputBorder.none),
    validator: (text) {
      if (text == null || text.isEmpty) {
        return valid;
      }
      return null;
    }
  );
}

// 양산형 위젯... ㅈㅅㅈㅅ...
Widget ccondField(TextEditingController controller, String hint, String valid) {
  return TextFormField(
      enabled: false,
      controller: controller,
      style: TextStyle(fontFamily: "SCDream", color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13),
      decoration: InputDecoration(hintText: hint, border: InputBorder.none, focusedBorder: InputBorder.none),
      validator: (text) {
        if (text == null || text.isEmpty) {
          return valid;
        }
        return null;
      }
  );
}

Widget condWrap(String ctext, TextEditingController controller, String hint, String valid){
  return Wrap(
    spacing: 15,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      cond2Text(ctext),
      Container(width: 250,
          child: condField(controller, hint, valid)
      )
    ],
  );
}
Widget ccondWrap(String ctext, TextEditingController controller, String hint, String? Function(String?)? function){
  return Wrap(
    spacing: 15,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      cond2Text(ctext),
      Container(width: 250,
          child: TextFormField(
            controller: controller,
            style: TextStyle(fontFamily: "SCDream", color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 13),
            decoration: InputDecoration(hintText: hint, border: InputBorder.none, focusedBorder: InputBorder.none),
            validator: function,
            // autovalidateMode: AutovalidateMode.always,
            keyboardType: TextInputType.number,
            onChanged: (value){
              if(value.length == 2){
                controller.text += ":";
                controller.selection = TextSelection.fromPosition(TextPosition(offset: controller.text.length));
              }
            },
          )
      )
    ],
  );
}

Widget cond2Wrap(String ctext, String ctext2){
  return Wrap(
    spacing: 15,
    children: [
      cond2Text(ctext),
      condText(ctext2)
    ],
  );
}

/* ---------------------- Painter ---------------------- */

class CurvePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.shader = RadialGradient(
        colors: [Colors.blue.shade100, Colors.deepPurple.shade200])
        .createShader(Rect.fromCircle(center: Offset(160, 2), radius: 180));
    paint.style = PaintingStyle.fill; // Change this to fill

    var path = Path();

    path.moveTo(0, 0);
    path.quadraticBezierTo(size.width / 2, size.height / 2, size.width, 0);
    path.quadraticBezierTo(size.width / 2, -size.height / 2, 0, 0);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

//---profile--//

Widget imageProfile() {
  return Stack(children : [
    Padding(padding: EdgeInsets.fromLTRB(30, 100, 0, 10)),
    CircleAvatar(
      radius: 40.0,
      backgroundImage: AssetImage("assets/images/profile.png"),
    ),
  ]);

}
