import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:usdh/Widget/widget.dart';
import 'package:usdh/chat/home.dart';
import 'package:usdh/function/portfolio.dart';
import '../login/firebase_provider.dart';
import 'package:provider/provider.dart';
import 'board.dart';

late MyPageState pageState;

class MyPage extends StatefulWidget {
  @override
  MyPageState createState() {
    pageState = MyPageState();
    return pageState;
  }
}

class MyPageState extends State<MyPage> {
  late FirebaseProvider fp;
  final FirebaseFirestore fs = FirebaseFirestore.instance;

  TextStyle tsItem = const TextStyle(
      color: Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.bold);
  TextStyle tsContent = const TextStyle(color: Colors.blueGrey, fontSize: 12);

  TextEditingController myIntroInput = TextEditingController();

  @override
  void dispose() {
    myIntroInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();

    double propertyWith = 130;
    if (fp.getUser() == null) {
      return CircularProgressIndicator();
    } else {
      return Scaffold(
        body: Column(
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
                headerText("마이페이지"),
                cSizedBox(0, 175),
              ],
            ),

            headerDivider(),

            Row(
              children: [
                Padding(padding: EdgeInsets.fromLTRB(20, 0, 0, 0)),
                InkWell(
                  onTap: () => {
                    // TODO : 프로필 변경하는거 해야해용
                  },

                  child: CircleAvatar(
                    radius: 20, //TODO : Image 넣기 해야해요 내일 하겠음
                  ),
                ),

                Column(
                  children: [
                    Row(
                      children: [
                        Text("이름"),
                        IconButton(onPressed: () => {
                          //TODO : 이름 변경
                        },
                            icon: Icon(Icons.edit)),
                      ],

                    ),
                    Text("이름"),
                  ],
                )
              ],
            ),


            middleDivider(),

            titleText("내 정보"),

            touchableText(() => {
              print("비밀번호 변경"), // TODO : 창 띄우기
            }, "비밀번호 변경"),

            touchableText(() => {
              print("포트폴리오 변경")
            }, "포트폴리오 변경"),

            touchableText(() => {
              print("자기소개 변경")
            }, "자기소개 변경"),
            //         onPressed: () {
            //           if(fp.getInfo()['myintro'] == ""){
            //             myIntroInput = TextEditingController();
            //           }
            //           else{
            //             myIntroInput = TextEditingController(text: fp.getInfo()['myintro']);
            //           }
            //           showDialog(context: context,
            //             builder: (BuildContext con){
            //               return AlertDialog(
            //                 title: Text("자기소개 변경"),
            //                 content: TextField(
            //                   controller: myIntroInput,
            //                   decoration: InputDecoration(hintText: "자기소개를 입력하세요."),
            //                 ),
            //                 actions: <Widget>[
            //                   TextButton(onPressed: () {
            //                     setState(() {
            //                       fs.collection('users').doc(fp.getUser()!.email).update({
            //                         'myintro' : myIntroInput.text
            //                       });
            //                     });
            //                     Navigator.pop(con);
            //                   },
            //                     child: Text("입력")
            //                   ),
            //                   TextButton(onPressed: (){
            //                     Navigator.pop(con);
            //                   },
            //                     child: Text("취소")
            //                   ),
            //                 ],
            //               );
            //           });
            //         },

            middleDivider(),

            titleText("신청 이력"),

            middleDivider(),

            titleText("채팅 이력"),

            middleDivider(),

            titleText("이용정보"),

            touchableText(() => {
              print("로그아웃")
            }, "로그아웃"),

            touchableText(() => {
              print("계정 삭제")
            }, "계정 삭제"),



          ],
        ),


        // body: ListView(
        //   children: <Widget>[


        // Container(
        //   margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
        //   child: Column(
        //     children: <Widget>[
        //       //헤더
        //       Container(
        //         height: 50,
        //         decoration: BoxDecoration(color: Colors.amber),
        //         child: Center(
        //           child: Text(
        //             "포트폴리오 테스트",
        //             style: TextStyle(
        //                 fontSize: 16, fontWeight: FontWeight.bold),
        //           ),
        //         ),
        //       ),

        //       // 정보 영역
        //       Container(
        //         decoration: BoxDecoration(
        //           border: Border.all(color: Colors.amber, width: 1),
        //         ),
        //         child: Column(
        //           children: <Widget>[
        //             Row(
        //               children: <Widget>[
        //                 Container(
        //                   width: propertyWith,
        //                   child: Text("포트폴리오 자기소개", style: tsItem),
        //                 ),
        //                 Expanded(
        //                   child: Text(fp.getInfo()['portfolio'][0],
        //                       style: tsContent),
        //                 )
        //               ],
        //             ),
        //             Divider(height: 1),
        //             Row(
        //               children: <Widget>[
        //                 Container(
        //                   width: propertyWith,
        //                   child: Text("포트폴리오 자기스펙", style: tsItem),
        //                 ),
        //                 Expanded(
        //                   child: Text(fp.getInfo()['portfolio'][1],
        //                       style: tsContent),
        //                 )
        //               ],
        //             ),
        //             Divider(height: 1),
        //             Row(
        //               children: <Widget>[
        //                 Container(
        //                   width: propertyWith,
        //                   child: Text("포트폴리오 태그", style: tsItem),
        //                 ),
        //                 Expanded(
        //                   child: Text(fp.getInfo()['portfolio'][2],
        //                       style: tsContent),
        //                 )
        //               ],
        //             ),
        //           ].map((c) {
        //             return Padding(
        //               padding: const EdgeInsets.symmetric(
        //                   vertical: 10, horizontal: 10),
        //               child: c,
        //             );
        //           }).toList(),
        //         ),
        //       )
        //     ],
        //   ),
        // ),
        //     Container(
        //       margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        //       child: ElevatedButton(
        //         style: ElevatedButton.styleFrom(
        //           primary: Colors.indigo[300],
        //         ),
        //         child: Text(
        //           "로그아웃",
        //           style: TextStyle(color: Colors.white),
        //         ),
        //         onPressed: () async {
        //           Navigator.popUntil(context, (route) => route.isFirst);
        //           fp.signOut();
        //         },
        //       ),
        //     ),
        //     Container(
        //       margin: const EdgeInsets.only(left: 20, right: 20, top: 0),
        //       child: ElevatedButton(
        //         style: ElevatedButton.styleFrom(
        //           primary: Colors.orange[300],
        //         ),
        //         child: Text(
        //           "포트폴리오 변경",
        //           style: TextStyle(color: Colors.white),
        //         ),
        //         onPressed: () {
        //           Navigator.push(context,
        //               MaterialPageRoute(builder: (context) => Portfolio()));
        //         },
        //       ),
        //     ),
        //     Container(
        //       margin: const EdgeInsets.only(left: 20, right: 20, top: 0),
        //       child: ElevatedButton(
        //         style: ElevatedButton.styleFrom(
        //           primary: Colors.orange[300],
        //         ),
        //         child: Text(
        //           "자기소개 변경",
        //           style: TextStyle(color: Colors.white),
        //         ),
        //         onPressed: () {
        //           if(fp.getInfo()['myintro'] == ""){
        //             myIntroInput = TextEditingController();
        //           }
        //           else{
        //             myIntroInput = TextEditingController(text: fp.getInfo()['myintro']);
        //           }
        //           showDialog(context: context,
        //             builder: (BuildContext con){
        //               return AlertDialog(
        //                 title: Text("자기소개 변경"),
        //                 content: TextField(
        //                   controller: myIntroInput,
        //                   decoration: InputDecoration(hintText: "자기소개를 입력하세요."),
        //                 ),
        //                 actions: <Widget>[
        //                   TextButton(onPressed: () {
        //                     setState(() {
        //                       fs.collection('users').doc(fp.getUser()!.email).update({
        //                         'myintro' : myIntroInput.text
        //                       });
        //                     });
        //                     Navigator.pop(con);
        //                   },
        //                     child: Text("입력")
        //                   ),
        //                   TextButton(onPressed: (){
        //                     Navigator.pop(con);
        //                   },
        //                     child: Text("취소")
        //                   ),
        //                 ],
        //               );
        //           });
        //         },
        //       ),
        //     ),
        //     Container(
        //       margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
        //       child: ElevatedButton(
        //         style: ElevatedButton.styleFrom(
        //           primary: Colors.red[300],
        //         ),
        //         child: Text(
        //           "계정 삭제",
        //           style: TextStyle(color: Colors.white),
        //         ),
        //         onPressed: () {
        //           fp.withdraw();
        //         },
        //       ),
        //     ),
        //     Container(
        //       margin: const EdgeInsets.only(left: 20, right: 20, top: 5),
        //       child: ElevatedButton(
        //           child: Text(
        //             "게시판 글쓰기",
        //             style: TextStyle(color: Colors.black),
        //           ),
        //           onPressed: () {
        //             Navigator.push(context,
        //                 MaterialPageRoute(builder: (context) => WriteBoard()));
        //           }),
        //     ),
        //     Container(
        //       margin: const EdgeInsets.only(left: 20, right: 20, top: 5),
        //       child: ElevatedButton(
        //           child: Text(
        //             "게시글 목록",
        //             style: TextStyle(color: Colors.black),
        //           ),
        //           onPressed: () {
        //             Navigator.push(context,
        //                 MaterialPageRoute(builder: (context) => ListBoard()));
        //           }),
        //     ),
        //     Container(
        //       margin: const EdgeInsets.only(left: 20, right: 20, top: 5),
        //       child: ElevatedButton(
        //           child: Text(
        //             "신청자 목록",
        //             style: TextStyle(color: Colors.black),
        //           ),
        //           onPressed: (){
        //             Navigator.push(context, MaterialPageRoute(builder: (context) => ApplicantListBoard()));
        //           }),
        //     )
        //   ],
        // ),
      );
    }
  }


  Widget touchableText(onTap, text) {
    return InkWell(
      onTap: onTap,

      child: condText(text),
    );
  }
}

//*---------토글입니다 지금 사용 안해요----


//
//
//
//
//
// Row(
// children: [
// condText("내 포트폴리오 검색 허용"),
//
// Switch(
// value: false, //스위치는 벨류 설정해줘야 한대요1!!!!!!!
// onChanged: (value) {
// setState(() {
// // isSwitched = value;
// // print(isSwitched);
// });
// },
// activeTrackColor: Colors.lightGreenAccent,
// activeColor: Colors.green,
// ),
// ],
// ),
//
// Row(
// children: [
// condText("늦은 시간 채팅 받기"),
//
// Switch(
// value: false,
// onChanged: (value) {
// setState(() {
// // isSwitched = value;
// // print(isSwitched);
// });
// },
// activeTrackColor: Colors.lightGreenAccent,
// activeColor: Colors.green,
// ),
// ],
// ),
//
// Row(
// children: [
// condText("채팅 받기"),
//
// Switch(
// value: false,
// onChanged: (value) {
// setState(() {
// // isSwitched = value;
// // print(isSwitched);
// });
// },
// activeTrackColor: Colors.lightGreenAccent,
// activeColor: Colors.green,
// ),
// ],
// ),
