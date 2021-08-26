import 'dart:async';
// import 'dart:html';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:usdh/Widget/widget.dart';
import 'package:usdh/boards/delivery_board.dart';
// import 'package:usdh/chat/home.dart';
import 'package:usdh/login/firebase_provider.dart';


late DeliveryMapState pageState1;

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
  Completer<GoogleMapController> _controller = Completer();

  var _viewType = 0;
  var _buttonText = "내 위치";
  var _lock = true;

  List datum = [];
  Set<Marker> _markers = Set();

  // 초기 위치 : 부산대학교 정문
  static final CameraPosition _pusanUniversity = CameraPosition(
    target: LatLng(35.23159301295487, 129.08395882267462),
    zoom: 16
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

    for (int i = 0; i < datum.length; i++) {
      // datum의 한 원소의 구성: [게시물 ID, 첫번째 태그, 위도, 경도]
      if (datum[i].length == 4) { // 모든 요소가 있어야 표시되게
        _markers.add(
          Marker(
            markerId: MarkerId(datum[i][0]),
            position: LatLng(
                datum[i][2], datum[i][3]
            ),
            infoWindow: InfoWindow(
                title: datum[i][1]
            ),
            onTap: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                backgroundColor: Colors.white,
                duration: Duration(seconds: 20),
                content: 
                  StreamBuilder(
                    stream: FirebaseFirestore.instance.collection('delivery_board').doc(datum[i][0]).snapshots(),
                    builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot){
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
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 10),
                                  child: Wrap(direction: Axis.vertical, spacing: 10, children: [
                                    Row(
                                      children: [
                                        Container(
                                          width: MediaQuery.of(context).size.width * 0.8,
                                          child: tagText(snapshot.data!['tagList'].join('')),
                                        ),

                                      ],
                                    ),
                                    Container(width: MediaQuery.of(context).size.width * 0.8, child: titleText(snapshot.data!['title'])),
                                    smallText("등록일 " + info + "마감 " + time + ' | ' + "작성자 " + writer, 11.5, Color(0xffa9aaaf))
                                  ])),
                              Container(
                                width: double.infinity,
                                child: Divider(
                                  color: Color(0xffe9e9e9),
                                  thickness: 1,
                                )),
                              Padding(
                                  padding: EdgeInsets.fromLTRB(0, 0, 0, 10),
                                  child: Wrap(
                                    direction: Axis.vertical,
                                    spacing: 10,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        // spaceBetween 왜 적용이 안될까...? Why...
                                        children: [
                                          Text("모집조건", style: TextStyle(fontFamily: "SCDream", color: Color(0xff639ee1), fontWeight: FontWeight.w600, fontSize: 15)),
                                          IconButton(
                                            icon: Image.asset('assets/images/icon/icongoboard.png', width: 20, height: 20),
                                            onPressed: () {
                                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                              Navigator.push(context, MaterialPageRoute(builder: (context) => DeliveryShow(id : datum[i][0])));
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
                                              cond2Wrap("음식종류", snapshot.data!['food']),
                                              cond2Wrap("배분위치", snapshot.data!['location']),
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
              ));
            }
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    fp = Provider.of<FirebaseProvider>(context);
    fp.setInfo();
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    return Scaffold(
      body: RefreshIndicator(
        // 당겨서 새로고침
        onRefresh: () async {
          setState(() {
            colstream = FirebaseFirestore.instance.collection('delivery_board').snapshots();
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
                    try{
                      tmp.add(doc.get("tagList")[0].trim());
                    } catch(e) {}

                    //현재 경도위도 없는 게시물때문에 만든 오류처리 -> 이후 게시판 다 갈아엎으면 지우기
                    try{
                      tmp.add(doc.get("latlng")[0]);
                      tmp.add(doc.get("latlng")[1]);
                    } catch(e) {
                      // print("경도 위도 없음");
                    }
                    datum.add(tmp);
                  }
                });
                _setMarker();
                print(datum);

                return Column(children: [
                  topbar5(context, "배달", () {
                    setState(() {
                      colstream = FirebaseFirestore.instance.collection('delivery_board').snapshots();
                    });
                  }, DeliveryList()),
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
        onPressed: _showAndChangeViewType,
        label: Text("$_buttonText"),
        icon: Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
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
          zoom: 16),
    ));
    _lock = true;
  }
}