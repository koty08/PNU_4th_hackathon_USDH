import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget cSizedBox(double h, double w) {
  return SizedBox(
    height: h,
    width: w,
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


/* ---------------------- Text ---------------------- */

Widget headerText(String text) {
  return Text(
      text,
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
    text,
    style: TextStyle(fontFamily: "SCDream", color: color, fontWeight: FontWeight.w500, fontSize: size)
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

Widget condWrap(String ctext, TextEditingController controller, String hint, String valid){
  return Wrap(
    spacing: 15,
    children: [
      cond2Text(ctext),
      Container(width: 250, height: 20,
        margin: EdgeInsets.fromLTRB(0, 3, 0, 0),
        child: condField(controller, hint, valid)
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