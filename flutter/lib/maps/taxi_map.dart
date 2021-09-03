import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:usdh/Widget/widget.dart';
import 'package:usdh/boards/taxi_board.dart';
import 'package:usdh/chat/home.dart';
import 'package:usdh/login/firebase_provider.dart';


late TaxiMapState pageState1;

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

class TaxiMap extends StatefulWidget {
  @override
  TaxiMapState createState() {
    pageState1 = TaxiMapState();
    return pageState1;
  }
}

class TaxiMapState extends State<TaxiMap> {
  Stream<QuerySnapshot> colstream = FirebaseFirestore.instance.collection('taxi_board').orderBy("write_time", descending: true).snapshots();
  late FirebaseProvider fp;
  Completer<GoogleMapController> _controller = Completer();

  var _viewType = 0;
  var _buttonText = "내 위치";
  var _lock = true;

  List datum = [];
  List markerLat = [];
  List markerLng = [];
  Set<Marker> _markers = Set();

  // 초기 위치 : 부산대학교 정문
  final CameraPosition _pusanUniversity = CameraPosition(
      target: LatLng(35.23159301295487, 129.08395882267462),
      zoom: 16.2
  );

  @override
  void initState() {
    super.initState();
    _setMarker();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _setMarker() {
    _markers.clear();
    markerLat.clear();
    markerLng.clear();
    var infoText = "";

    for (int i = 0; i < datum.length; i++) {
      // datum의 한 원소의 구성: [게시물 ID, 위도, 경도, 첫번째 태그]
      if (datum[i].length >= 3) { // (태그는 없어도 됨) 나머지 세개 다 있어야 표시되게
        if (datum[i].length == 4) {
          // 태그 있으면 infoText로 tag값 띄우기
          infoText = datum[i][3];
        }
        if (markerLat.contains(datum[i][1]) && markerLng.contains(datum[i][2])) {
          datum[i][1] = datum[i][1] + 0.00002;
          datum[i][2] = datum[i][2] + 0.00002;
        }
        else {
          markerLat.add(datum[i][1]);
          markerLng.add(datum[i][2]);
        }

        _markers.add(
          Marker(
              markerId: MarkerId(datum[i][0]),
              position: LatLng(
                  datum[i][1], datum[i][2]
              ),
              infoWindow: InfoWindow(
                  title: infoText
              ),
              onTap: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: Colors.white.withOpacity(0.9),
                      duration: Duration(seconds: 20),
                      content:
                      StreamBuilder(
                          stream: FirebaseFirestore.instance.collection('taxi_board').doc(datum[i][0]).snapshots(),
                          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot){
                            final width = MediaQuery.of(context).size.width;
                            final height = MediaQuery.of(context).size.height;
                            if(!snapshot.hasData){
                              return CircularProgressIndicator();
                            }
                            else{
                              String info = snapshot.data!['write_time'].substring(5, 7) + "/" + snapshot.data!['write_time'].substring(8, 10) + snapshot.data!['write_time'].substring(10, 16) + ' | ';
                              String time = snapshot.data!['time'].substring(11, 16);
                              String writer = snapshot.data!['writer'];
                              return SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                          padding: EdgeInsets.fromLTRB(width*0.05, height*0.02, width*0.05, height*0.02),
                                          child: Wrap(direction: Axis.vertical, spacing: 10, children: [
                                            Row(
                                              children: [
                                                Container(
                                                  width: MediaQuery.of(context).size.width * 0.8,
                                                  child: tagText(snapshot.data!['tagList'].join(' ')),
                                                ),

                                              ],
                                            ),
                                            Container(width: MediaQuery.of(context).size.width * 0.8, child: titleText(snapshot.data!['title'])),
                                            smallText("등록일 " + info + "마감 " + time + ' | ' + "작성자 " + writer, 11.5, Color(0xffa9aaaf))
                                          ])),
                                      Divider(color: Color(0xffe9e9e9), thickness: 1,),
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(width*0.05, height*0.01, width*0.05, height*0.03),
                                        child: Wrap(
                                          direction: Axis.vertical,
                                          spacing: 10,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text("모집조건", style: TextStyle(fontFamily: "SCDream", color: Color(0xff639ee1), fontWeight: FontWeight.w600, fontSize: 15)),
                                                IconButton(
                                                  icon: Image.asset('assets/images/icon/icongoboard.png', width: 20, height: 20),
                                                  onPressed: () {
                                                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                    Navigator.push(context, MaterialPageRoute(builder: (context) => TaxiShow(id : datum[i][0])));
                                                  },
                                                ),
                                              ],
                                            ),
                                            Padding(
                                                padding: EdgeInsets.fromLTRB(7, 0, 0, 0),
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
                                        ),
                                      ),
                                    ],
                                  )
                              );
                            }
                          }
                      ),
                    )
                );
              }
          ),
        );
      }
    }
    print("markers");
    print(_markers);
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    return WillPopScope(
      child: Scaffold(
        appBar: CustomAppBar("택시", [
          IconButton(
            icon: Image.asset('assets/images/icon/icongolist.png', width: 20, height: 20),
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => TaxiList()));
            },
          ),
          //새로고침 기능
          IconButton(
            icon: Image.asset('assets/images/icon/iconrefresh.png', width: 20, height: 20),
            onPressed: () {
              setState(() {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                colstream = FirebaseFirestore.instance.collection('taxi_board').snapshots();
              });
            },
          ),
          IconButton(
            icon: Image.asset('assets/images/icon/iconmessage.png', width: 20, height: 20),
            onPressed: () {
              var myInfo = fp.getInfo();
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen(myId: myInfo['email'])));
            },
          ),
        ]),
        body: RefreshIndicator(
          // 당겨서 새로고침
          onRefresh: () async {
            setState(() {
              colstream = FirebaseFirestore.instance.collection('taxi_board').snapshots();
            });
          },
          child: StreamBuilder<QuerySnapshot>(
              stream: colstream,
              builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (!snapshot.hasData) {
                  return CircularProgressIndicator();
                }
                else {
                  datum = [];
                  snapshot.data!.docs.forEach((doc){
                    if(isAvailable(doc['time'], doc['currentMember'], doc['limitedMember'])){
                      List tmp = [];
                      tmp.add(doc.id);
                      tmp.add(doc.get("latlng1")[0]);
                      tmp.add(doc.get("latlng1")[1]);
                      try{
                        tmp.add(doc.get("tagList")[0].trim());
                      } catch(e) {}
                      datum.add(tmp);
                    }
                  });
                  _setMarker();
                  print(datum);

                  return Column(children: [
                    // ------------------------------ 아래에 지도 추가 ------------------------------
                    Expanded(
                        child: Stack(
                          children: [
                            GoogleMap(
                              compassEnabled: false,
                              mapToolbarEnabled: false,
                              zoomControlsEnabled: false,
                              markers: _markers,
                              mapType: MapType.normal,
                              initialCameraPosition: _pusanUniversity,
                              onMapCreated: (GoogleMapController controller) {
                                _controller.complete(controller);
                              },
                              myLocationEnabled: true,
                              myLocationButtonEnabled: false,
                            ),
                          ],
                        )),
                  ]);
                }
              }),
        ),
        floatingActionButton: FloatingActionButton.extended(
          backgroundColor: Color(0xff4E94EC),
          onPressed: _showAndChangeViewType,
          label: small2Text("$_buttonText", 13, Colors.white),
          icon: Icon(Icons.my_location),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      ),
      onWillPop: () async {
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        return true;
      },
    );
  }

  void _showAndChangeViewType() {
    setState(() {
      if (_lock) {
        switch(_viewType) {
          case 0:
            _buttonText = "부산대로";
            _goToCurrentLocation();
            break;
          case 1:
            _buttonText = "내 위치";
            _goToPusanUniv();
            break;
          default:
            _buttonText = "";
            break;
        }
        // _viewType: 0 -> 1, 1 -> 0
        _viewType++;
        _viewType = _viewType % 2;
      }
    });
  }

  Future<void> _goToPusanUniv() async {
    _lock = false;
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_pusanUniversity));
    _lock = true;
  }

  Future<void> _goToCurrentLocation() async {
    _lock = false;
    final GoogleMapController controller = await _controller.future;
    LocationData currentLocation;
    var location = new Location();
    currentLocation = await location.getLocation();
    controller.animateCamera(CameraUpdate.newCameraPosition(
      CameraPosition(
          target: LatLng(currentLocation.latitude!, currentLocation.longitude!),
          zoom: 16.2),
    ));
    _lock = true;
  }
}