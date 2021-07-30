import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Widget cSizedBox(double h, double w) {
  return SizedBox(
    height: h,
    width: w,
  );
}

Widget tagText(String text) {
  return Text(
    text,
    style: TextStyle(fontFamily: "SCDream", color: Colors.grey[600], fontWeight: FontWeight.w500, fontSize: 14)
  );
}

Widget titleText(String text) {
  return Text(
      text,
      style: TextStyle(fontFamily: "SCDream", color: Colors.black87, fontWeight: FontWeight.w600, fontSize: 18)
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