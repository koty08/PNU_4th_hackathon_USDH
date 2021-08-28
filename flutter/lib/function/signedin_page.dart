import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:usdh/boards/roommate_board.dart';
import 'package:usdh/boards/sgroup_board.dart';
import 'package:usdh/boards/teambuild_board.dart';
import 'package:usdh/chat/home.dart';
import 'package:usdh/login/firebase_provider.dart';
import 'package:usdh/function/board.dart';
import 'package:usdh/function/mypage.dart';
import 'package:usdh/boards/delivery_board.dart';
import 'package:usdh/boards/community_board.dart';
import 'package:usdh/maps/delivery.dart';

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
  FirebaseFirestore fs = FirebaseFirestore.instance;
  
  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();

    return Scaffold(
      body: ListView(
        children: [
          Padding(padding: EdgeInsets.fromLTRB(0, 50, 0, 0)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // 채팅방 버튼
              IconButton(
                icon: Image.asset('assets/images/icon/iconmessage.png', width: 20, height: 20),
                onPressed: () {
                  var tmp = fp.getInfo();
                  Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(myId: tmp['email'])));
                },
              ),
              Text("유소더하", style: TextStyle(fontFamily: "SCDream", fontWeight: FontWeight.w400, height: 2, fontSize: 23, color: Color(0xFF323232)),),
              IconButton(
                icon: Image.asset('assets/images/icon/profile.png', width: 20, height: 20),
                onPressed: () {Navigator.push(context, MaterialPageRoute(builder: (context) => MyPage()));},
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
              imageAndText('assets/images/icon/icontaxi.png', "택시", DeliveryMap()),
              imageAndText('assets/images/icon/iconmotorcycle.png', "배달", DeliveryList()),
              imageAndText('assets/images/icon/iconshopping.png', "공구", ListBoard()),
              imageAndText('assets/images/icon/iconcommunity.png', "커뮤니티", CommunityList()),
              cSizedBox(0, 15),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              cSizedBox(0, 40),
              imageAndText('assets/images/icon/iconteam.png', "팀빌딩", TeambuildList()),
              imageAndText('assets/images/icon/iconplay.png', "소모임", SgroupList()),
              imageAndText('assets/images/icon/iconroom.png', "룸메이트", RoommateList()),
              cSizedBox(0, 40),
            ],
          ),
          Padding(padding: EdgeInsets.fromLTRB(0, 15, 0, 0)),

          //배달 마감 임박 게시글(시간 제일 가까운거) 연결
          messageBoard('assets/images/icon/iconclock.png', "마감 임박 게시글"),
          Padding(
            padding: EdgeInsets.fromLTRB(70, 20, 55, 0),
            child: SizedBox(
              height: 80,
              child: StreamBuilder<QuerySnapshot>(
                stream : fs.collection('delivery_board').where('time', isGreaterThan: formatDate(DateTime.now(), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss])).orderBy('time').limit(1).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if(!snapshot.hasData){
                    return Text(
                      "마감 임박 게시물이 없습니다.",
                      style: TextStyle(
                        fontFamily: "SCDream",
                        fontWeight: FontWeight.w400,
                        fontSize: 12.5,
                        color: Color(0xffDD373C44)),
                    );
                  }
                  else{
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot doc = snapshot.data!.docs[0];
                        return InkWell(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => DeliveryShow(id: doc.id)));
                            FirebaseFirestore.instance.collection('delivery_board').doc(doc.id).update({"views" : doc["views"] + 1});
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(doc['title'],
                                style: TextStyle(
                                    fontFamily: "SCDream",
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12.5,
                                    color: Color(0xffDD373C44)),
                              ),
                              cSizedBox(15, 0)
                            ]
                          )
                        );
                      }
                    );
                  }
                }
              )
            )
          ),
          //실시간 인기 (배달) 게시글 출력
          messageBoard('assets/images/icon/iconfire.png', "실시간 인기 게시글"),
          Padding(
            padding: EdgeInsets.fromLTRB(70, 20, 55, 0),
            child: SizedBox(
              height: 100,
              child: StreamBuilder<QuerySnapshot>(
                stream : fs.collection('community_board').orderBy('views', descending: true).snapshots(),
                builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot){
                  if(!snapshot.hasData){
                    return Text(
                      "실시간 인기 게시물이 없습니다.",
                      style: TextStyle(
                          fontFamily: "SCDream",
                          fontWeight: FontWeight.w400,
                          fontSize: 12.5,
                          color: Color(0xffDD373C44)),
                    );
                  }
                  else{
                    return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot doc = snapshot.data!.docs[index];
                        if(doc['write_time'].compareTo(formatDate(DateTime.now().subtract(Duration(hours: 6)), [yyyy, '-', mm, '-', dd, ' ', HH, ':', nn, ':', ss])) == 1){
                          return InkWell(
                            onTap: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => CommunityShow(doc.id)));
                              FirebaseFirestore.instance.collection('community_board').doc(doc.id).update({"views" : doc["views"] + 1});
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(doc['title'],
                                  style: TextStyle(
                                  fontFamily: "SCDream",
                                  fontWeight: FontWeight.w400,
                                  fontSize: 12.5,
                                  color: Color(0xffDD373C44)),
                                ),
                                cSizedBox(15, 0)
                              ]
                            )
                          );
                        }
                        else{
                          return Container();
                        }
                      }
                      );
                  }
                }
              )
            )
          )
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
            Text(text, style: TextStyle(fontFamily: "SCDream", fontWeight: FontWeight.w500, fontSize: 12, color: Color(0xffDD373C44)),),
          ],
        ),
      ),
    );
  }

  Widget messageBoard(String image, String title) {
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
                  Image.asset(image, width: 17, height: 17),
                  cSizedBox(0, 10),
                  Text(title, style: TextStyle(fontFamily: "SCDream", fontWeight: FontWeight.w400, fontSize: 16, color: Color(0xffDD373C44)),),
                ],
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 0, 25, 0),
                //child: Icon(Icons.add_box),
              ),
            ],
          ),
        ),
        CustomPaint(
          size: Size(310, 4),
          painter: CurvePainter(),
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
