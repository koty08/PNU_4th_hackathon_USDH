import 'package:day_night_time_picker/lib/daynight_timepicker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget cSizedBox(double h, double w) {
  return SizedBox(
    height: h,
    width: w,
  );
}

/* ---------------------- CustomAppBar ---------------------- */

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final String title;
  final List<Widget> widgets;

  @override
  final Size preferredSize;

  CustomAppBar(this.title, this.widgets, {Key? key}) : preferredSize = Size.fromHeight(kToolbarHeight),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return AppBar(
      leading: IconButton(
        padding: EdgeInsets.fromLTRB(width*0.05, 0, 0, 0),
        icon: Image.asset('assets/images/icon/iconback.png', width: 20, height: 20),
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
          Navigator.pop(context);
        },
      ),
      title: headerText('$title'),
      actions: widgets,
      backgroundColor: Colors.white,
      bottom: PreferredSize(
        child: headerDivider(),
        preferredSize: Size.fromHeight(3),
      ),
      elevation: 0,
    );
  }
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


/* ---------------------- inputNav ---------------------- */

Widget inputNav2(String data, String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(padding: EdgeInsets.fromLTRB(35, 0, 0, 30)),
      Image(image: AssetImage(data), height: 18, width: 18,),
      Container(
        height: 25,
        child: Text(
          text,
          style: TextStyle(fontFamily: "SCDream", color: Color(0xff548ee0), fontWeight: FontWeight.w500, fontSize: 15),
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

Widget small2Text(String text, double size, Color color) {
  return Text(
      text,
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
    width: 55,
    height: 18,
    decoration: BoxDecoration(
      color: statuscolor,
      borderRadius: BorderRadius.circular(5)
    ),
    child: Text(text, textAlign: TextAlign.center,
      style: TextStyle(height: 1.5, fontFamily: "SCDream", color: Colors.white, fontWeight: FontWeight.w500, fontSize: 11)
    )
  );
}

Widget infoText(String text) {
  return Text(
      text,
      style: TextStyle(fontFamily: "SCDream", color: Color(0xff639ee1), fontWeight: FontWeight.w600, fontSize: 15)
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
      text, overflow: TextOverflow.ellipsis,
      style: TextStyle(fontFamily: "SCDream", color: Colors.black87, fontWeight: FontWeight.w700, fontSize: 13)
  );
}


/* ---------------------- Text Field ---------------------- */

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
    decoration: InputDecoration(hintText: hint, border: InputBorder.none, focusedBorder: InputBorder.none,
      errorStyle: TextStyle(color: Colors.indigo.shade200),
    ),
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


/* ---------------------- Sign up ---------------------- */

Widget inputNav(IconData data, String text) {
  return Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      cSizedBox(0, 45),
      Icon(data, color: Color(0xffFF576FBA), size: 19),
      Container(
        height: 25,
        child: smallText(text, 15, Colors.indigo.shade300),
      ),
    ],
  );
}


Widget userField(BuildContext context, TextEditingController controller, String hint, valid) {
  final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height;
  return Container(
      margin: EdgeInsets.fromLTRB(0, 5, 0, 15),
      width: width*0.7,
      height: height*0.1,
      child: TextFormField(
          controller: controller,
          style: TextStyle(fontFamily: "SCDream", color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 13),
          decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.indigo.shade200, width: 1.5),
            ),
            contentPadding: EdgeInsets.fromLTRB(width*0.05, 0, 0, 0),
            hintText: hint, errorStyle: TextStyle(color: Colors.indigo.shade200),
          ),
          validator: valid
      )
  );
}

Widget userField2(BuildContext context, TextEditingController controller, String hint, valid) {
  final width = MediaQuery.of(context).size.width;
  final height = MediaQuery.of(context).size.height;
  return Container(
      margin: EdgeInsets.fromLTRB(0, 5, 0, 15),
      width: width*0.7,
      height: height*0.1,
      child: TextFormField(
          controller: controller,
          obscureText: true,
          style: TextStyle(fontFamily: "SCDream", color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 13),
          decoration: InputDecoration(
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.indigo.shade200, width: 1.5),
            ),
            contentPadding: EdgeInsets.fromLTRB(width*0.05, 0, 0, 0),
            hintText: hint, errorStyle: TextStyle(color: Colors.indigo.shade200),
          ),
          validator: valid
      )
  );
}


/* ---------------------- Wrap ---------------------- */


Widget condWrap(String ctext, TextEditingController controller, String hint, String valid){
  return Wrap(
    spacing: 15,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Container(
        width: 60,
        alignment: Alignment(0.0, 0.0),
        child: cond2Text(ctext),
      ),
      Container(width: 250,
        child: condField(controller, hint, valid)
      )
    ],
  );
}

void TimePicker(BuildContext context, TimeOfDay _time, onTimeChanged) {
  Navigator.of(context).push(
    showPicker(
      context: context,
      value: _time,
      onChange: onTimeChanged,
      iosStylePicker: true,
      accentColor: Color(0xff639ee1),
      okText: "설정",
      cancelText: "취소",
      hourLabel: '시',
      minuteLabel: '분',
      is24HrFormat: true,
    ),
  );
}

Widget ccondWrap(String ctext, TextEditingController controller, String hint, String? Function(String?)? function){
  return Wrap(
    spacing: 15,
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Container(
        width: 60,
        alignment: Alignment(0.0, 0.0),
        child: cond2Text(ctext),
      ),
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
    crossAxisAlignment: WrapCrossAlignment.center,
    children: [
      Container(
        width: 50,
        alignment: Alignment(0.0, 0.0),
        child: cond2Text(ctext),
      ),
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

Widget goButton(Widget widget, Function()? function){
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      primary: Color(0xff639ee1).withOpacity(0.7),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
    ),
    onPressed: function,
    child: widget
  );
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
