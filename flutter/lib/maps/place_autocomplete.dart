// @dart = 2.9
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:usdh/Widget/widget.dart';
import 'package:uuid/uuid.dart';
import 'dart:async';

import 'google_map_service.dart';
import 'place.dart';


/*
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: PlaceAutocomplete(),
    );
  }
}
*/

class PlaceAutocomplete extends StatefulWidget {
  @override
  _PlaceAutocompleteState createState() => _PlaceAutocompleteState();
}

class _PlaceAutocompleteState extends State<PlaceAutocomplete> {
  final TextEditingController _searchController = TextEditingController();
  var uuid = Uuid();
  var sessionToken;
  var googleMapServices;

  PlaceDetail placeDetail;
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> _markers = Set();

  var lat;
  var lng;
  var placeId;
  var name;
  var formattedAddress;

  var state;

  /*
  state는 _moveCamera, _moveCameraByButton이 있습니다.
  state가 _moveCamera면
  placeDetail.lat, placeDetail.lng가 위도와 경도이고
  state가 _moveCameraByButton이면
  lat와 lng가 위도와 경도입니다.
  */

  @override
  void initState() {
    super.initState();
    _markers.add(
        Marker(
          markerId: MarkerId('testMarker'),
          position: LatLng(35.23159301295487, 129.08395882267462),
          infoWindow: InfoWindow(title: '여기는 어디?', snippet: '바로 부산대학교!'),
        )
    );
  }

  void _clearMarker() {
    if (_markers.length > 0) {
      setState(() {
        _markers.clear();
      });
    }
  }

  void _moveCamera() async {
    state = "_moveCamera";
    _clearMarker();

    GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(placeDetail.lat, placeDetail.lng),
      ),
    );

    setState(() {
      _markers.add(
        Marker(
            markerId: MarkerId(placeDetail.placeId),
            position: LatLng(placeDetail.lat, placeDetail.lng),
            infoWindow: InfoWindow(
              title: placeDetail.name,
              snippet: placeDetail.formattedAddress,
            )
        ),
      );
    });
  }

  void _moveCameraByButton() async {
    state = "_moveCameraByButton";
    _clearMarker();

    GoogleMapController controller = await _controller.future;
    controller.animateCamera(
      CameraUpdate.newLatLng(
        LatLng(lat, lng),
      ),
    );

    setState(() {
      _markers.add(
        Marker(
            markerId: MarkerId(placeId),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(
              title: name,
              snippet: formattedAddress,
            )
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: CustomAppBar("위치", []),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 2.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              cSizedBox(height*0.02, 0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: width*0.7,
                    padding: EdgeInsets.fromLTRB(width*0.04, 0, width*0.02, 0),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey,
                        width: 1
                      )
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(right: 5.0),
                          child:Image.asset('assets/images/icon/iconsearch.png', scale: 18),
                        ),
                        Flexible(
                          child: Container(
                            width: width*0.8,
                            child: TypeAheadField(
                              debounceDuration: Duration(milliseconds: 500),
                              textFieldConfiguration: TextFieldConfiguration(
                                scrollPadding: EdgeInsets.all(0),
                                controller: _searchController,
                                autofocus: true,
                                decoration: InputDecoration(
                                  border: InputBorder.none, focusedBorder: InputBorder.none,
                                  contentPadding: EdgeInsets.all(10),
                                  isDense: true,
                                  hintText: '위치 찾아보기',
                                  hintStyle: TextStyle(fontFamily: "SCDream", color: Color(0xffa9aaaf), fontWeight: FontWeight.w500, fontSize: 14),
                                ),
                                style: TextStyle(fontFamily: "SCDream", color: Colors.black87, fontWeight: FontWeight.w500, fontSize: 14),
                                cursorColor: Colors.grey,
                              ),

                              suggestionsCallback: (pattern) async {
                                if (sessionToken == null) {
                                  sessionToken = uuid.v4();
                                }
                                googleMapServices = GoogleMapServices(sessionToken: sessionToken);
                                return await googleMapServices.getSuggestions(pattern);
                              },
                              itemBuilder: (context, suggestion) {
                                return ListTile(
                                  title: condText(suggestion.main_text),
                                );
                              },
                              onSuggestionSelected: (suggestion) async {
                                placeDetail = await googleMapServices.getPlaceDetail(
                                  suggestion.placeId,
                                  sessionToken,
                                );
                                sessionToken = null;
                                _moveCamera();
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(left: width*0.04),
                    child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          primary: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(width: 1.8, color: Color(0xff639ee1))
                          ),
                          elevation: 0
                        ),
                        onPressed: () {
                          if (state == "_moveCamera") {
                            Navigator.pop(context, [placeDetail.name, placeDetail.lat, placeDetail.lng]);
                          }
                          else if (state == "_moveCameraByButton") {
                            Navigator.pop(context, [name, lat, lng]);
                          }
                        },
                        child: smallText('결정 !', 12.5, Color(0xff639ee1))
                    ),
                  )
                ]
              ),
              cSizedBox(height*0.02, 0),
              Text("옆으로 스크롤해서 부산대 빠른 위치를 선택해보세요!", style: TextStyle(fontFamily: "SCDream", color: Colors.grey, fontWeight: FontWeight.w500, fontSize: 13)),
              Container(
                width: width*0.9,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Wrap(
                    spacing: 10,
                    children: [
                      goButton(smallText("학교 앞 부산은행", 12.5, Colors.white,),
                          () => {
                        _searchController.text = "부산은행 장전점",
                        _setPlaceToBank(),
                        _moveCameraByButton(),
                      }),
                      goButton(smallText("NC백화점", 12.5, Colors.white,),
                          () => {
                        _searchController.text = "부산대 NC백화점",
                        _setPlaceToNC(),
                        _moveCameraByButton()
                      }),
                      goButton(smallText("정문 원룸촌 GS", 12.5, Colors.white,),
                          () => {
                        _searchController.text = "GS25 장전효원점",
                        _setPlaceToGS25(),
                        _moveCameraByButton(),
                      }),
                      goButton(smallText("자유관", 12.5, Colors.white,),
                          () => {
                        _searchController.text = "부산대학교 자유관",
                        _setPlaceToJayu(),
                        _moveCameraByButton(),
                      }),
                      goButton(smallText("웅비관", 12.5, Colors.white,),
                          () => {
                        _searchController.text = "부산대학교 웅비관",
                        _setPlaceToWoongbi(),
                        _moveCameraByButton(),
                      }),
                      goButton(smallText("진리관", 12.5, Colors.white,),
                          () => {
                        _searchController.text = "부산대학교 진리관",
                        _setPlaceToJinri(),
                        _moveCameraByButton(),
                      }),
                    ],
                  ),
                )
              ),
              cSizedBox(height*0.02, 0),
              Container(
                  width: double.infinity,
                  height: height*0.65,
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: CameraPosition(
                        target: LatLng(35.23159301295487, 129.08395882267462),
                        zoom: 16),
                    onMapCreated: (GoogleMapController controller) {
                      _controller.complete(controller);
                    },
                    myLocationEnabled: true,
                    markers: _markers,
                    compassEnabled: false,
                    mapToolbarEnabled: false,
                    zoomControlsEnabled: false,
                  )
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setPlaceToNC() {
    placeId = "ChIJVdt9bvKTaDURBtndGELj2yI";
    formattedAddress = "대한민국 부산광역시 금정구 장전동 부산대학로63번길 2";
    name = "부산대 NC백화점";
    lat = 35.2322978;
    lng = 129.0842446;
  }

  void _setPlaceToBank() {
    placeId = "ChIJE1Y0euyTaDURgQQO8QrEw98";
    formattedAddress = "대한민국 부산광역시 금정구 장전3동 417-36";
    name = "학교 앞 부산은행";
    lat = 35.2314097;
    lng = 129.0863613;
  }

  void _setPlaceToGS25() {
    placeId = "ChIJuSs9me6TaDUR3qt6fhMneMU";
    formattedAddress = "대한민국 부산광역시 금정구 장전동 부산대학로64번길 60";
    name = "GS25 장전효원점";
    lat = 35.2340761;
    lng = 129.0851947;
  }

  void _setPlaceToJayu() {
    placeId = "ChIJe4dmZ0eTaDURkTqW6PYaBpc";
    formattedAddress = "대한민국 부산광역시 금정구 장전2동 부산대학교 자유관";
    name = "부산대학교 자유관";
    lat = 35.2356592;
    lng = 129.0824171;
  }

  void _setPlaceToWoongbi() {
    placeId = "ChIJP52ZRJKTaDURr0BDIhCDtJQ";
    formattedAddress = "대한민국 부산광역시 금정구 장전1동 부산대학교 웅비관";
    name = "부산대학교 웅비관";
    lat = 35.2372385;
    lng = 129.0769734;
  }

  void _setPlaceToJinri() {
    placeId = "ChIJaQRJOPGTaDURX1n-MDiyyB0";
    formattedAddress = "대한민국 부산광역시 금정구 장전동 부산대학교 진리관";
    name = "부산대학교 진리관";
    lat = 35.238131;
    lng = 129.0770287;
  }
}

