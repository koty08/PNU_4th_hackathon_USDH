import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:login_test/chat/home.dart';
import 'package:login_test/login/firebase_provider.dart';
import 'board.dart';
import 'mypage.dart';

late SignedInPageState pageState;

class SignedInPage extends StatefulWidget {
  @override
  SignedInPageState createState() {
    pageState = SignedInPageState();
    return pageState;
  }
}

class SignedInPageState extends State<SignedInPage> {
  late FirebaseProvider fp;

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();
    return Scaffold(
      body: Column(
        children: [
          Padding(padding: EdgeInsets.fromLTRB(0, 50, 0, 0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 채팅방 버튼
              IconButton(
                icon: Icon(Icons.message),
                onPressed: () {
                  var tmp = fp.getInfo();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              HomeScreen(currentUserId: tmp['email'])));
                },
              ),
              Text(
                "유소더하",
                style: TextStyle(
                    fontFamily: "SCDream",
                    fontWeight: FontWeight.w200,
                    height: 2,
                    fontSize: 23,
                    color: Color(0xFF323232)),
              ),
              IconButton(
                icon: Image.asset('assets/images/icon/profile.png',
                    width: 22, height: 22),
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => MyPage()));
                },
              ),
            ],
          ),
          Padding(padding: EdgeInsets.fromLTRB(0, 8, 0, 0)),
          CustomPaint(
            size: Size(320, 4),
            painter: CurvePainter(),
          ),
          Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              cSizedBox(0, 15),
              imageAndText('assets/images/icon/group.png', "택시", ListBoard()),
              imageAndText('assets/images/icon/group.png', "배달", ListBoard()),
              imageAndText('assets/images/icon/group.png', "공구", ListBoard()),
              imageAndText('assets/images/icon/group.png', "팀빌딩", ListBoard()),
              cSizedBox(0, 15),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              cSizedBox(0, 40),
              imageAndText('assets/images/icon/group.png', "소모임", ListBoard()),
              imageAndText('assets/images/icon/group.png', "룸메이트", ListBoard()),
              imageAndText('assets/images/icon/group.png', "커뮤니티", ListBoard()),
              cSizedBox(0, 40),
            ],
          ),
          Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),
          messageBoard(Icons.timer, "마감 임박 게시글", [
            "[택시] 택시 게시글",
            "[배달] 배달 게시글",
            "[공구] 공구 게시물",
            "1",
            "2",
            "3",
            "4"
          ]),
          messageBoard(Icons.fireplace, "실시간 인기 게시글",
              ["[123] 456", "[11] 22", "[33] 44", "[55] 66"]),
        ],
      ),
    );
  }

  Widget imageAndText(String data, String text, Widget route) {
    return TextButton(
      onPressed: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => route));
      },
      child: SizedBox(
        width: 55,
        height: 60,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(data, width: 35, height: 35),
            cSizedBox(5, 0),
            Text(
              text,
              style: TextStyle(
                  fontFamily: "SCDream",
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                  color: Color(0xffDD373C44)),
            ),
          ],
        ),
      ),
    );
  }

  Widget messageBoard(IconData iconData, String title, List<String> data) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(30, 25, 20, 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  cSizedBox(0, 10),
                  Icon(iconData),
                  cSizedBox(0, 10),
                  Text(
                    title,
                    style: TextStyle(
                        fontFamily: "SCDream",
                        fontWeight: FontWeight.w400,
                        fontSize: 17,
                        color: Color(0xffDD373C44)),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 25, 0),
                child: Icon(Icons.add_box),
              ),
            ],
          ),
        ),
        CustomPaint(
          size: Size(310, 4),
          painter: CurvePainter(),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(70, 10, 55, 10),
          child: SizedBox(
            height: 110,
            child: ListView.builder(
                padding: EdgeInsets.fromLTRB(0, 5, 0, 0),
                itemCount: data.length,
                itemExtent: 30,
                itemBuilder: (BuildContext context, int index) {
                  return Text(
                    data[index],
                    style: TextStyle(
                        fontFamily: "SCDream",
                        fontWeight: FontWeight.w300,
                        fontSize: 12.5,
                        color: Color(0xffDD373C44)),
                  );
                }),
          ),
        ),
      ],
    );
  }

  Widget cSizedBox(double h, double w) {
    return SizedBox(
      height: h,
      width: w,
    );
  }
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
