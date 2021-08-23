import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:usdh/Widget/widget.dart';
import 'package:usdh/boards/delivery_board.dart';
// import 'package:usdh/chat/home.dart';
import 'package:usdh/login/firebase_provider.dart';


late DeliveryMapState pageState1;


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
              // TO DO: 게시물 정보 보이게끔
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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