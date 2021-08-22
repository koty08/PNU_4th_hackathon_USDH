// @dart = 2.9
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  @override
  void initState() {
    super.initState();
    _markers.add(
        Marker(
          markerId: MarkerId('testMarker'),
          position: LatLng(35.23159301295487, 129.08395882267462),
          infoWindow: InfoWindow(title: '여기는 어디?', snippet: '바로 부산대학교!'),
        ));
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
    return Scaffold(
      appBar: AppBar(
        title: Text('Places Autocomplete'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3.0, vertical: 2.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget> [
              SizedBox(height: 5.0),
              Container(
                width: double.infinity,
                height: 60,
                child: TypeAheadField(
                  debounceDuration: Duration(milliseconds: 500),
                  textFieldConfiguration: TextFieldConfiguration(
                    controller: _searchController,
                    autofocus: true,
                    decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '위치 찾아보기'
                    ),
                  ),

                  suggestionsCallback: (pattern) async {
                    if (sessionToken == null) {
                      sessionToken = uuid.v4();
                    }

                    googleMapServices = GoogleMapServices(sessionToken:
                    sessionToken);

                    return await googleMapServices.getSuggestions(pattern);
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                        title: Text(suggestion.description),
                        subtitle: Text('${suggestion.placeId}')
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
              SizedBox(height: 6),
              Container(
                  width: double.infinity,
                  height: 450,
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
                  )
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                      onPressed: () => {
                        _setPlaceToBank(),
                        _moveCameraByButton(),
                      },
                      child: Text("학교 앞 부산은행")),
                  ElevatedButton(
                      onPressed: () => {
                        _setPlaceToNC(),
                        _moveCameraByButton()
                      },
                      child: Text("NC백화점")),
                  ElevatedButton(
                      onPressed: () => {
                        _setPlaceToGS25(),
                        _moveCameraByButton(),
                      },
                      child: Text("정문 원룸촌 GS")),
                ],
              ),
              Row(
                children: [
                  ElevatedButton(
                      onPressed: () => {
                        _setPlaceToJayu(),
                        _moveCameraByButton(),
                      },
                      child: Text("자유관")),
                  ElevatedButton(
                      onPressed: () => {
                        _setPlaceToWoongbi(),
                        _moveCameraByButton(),
                      },
                      child: Text("웅비관")),
                  ElevatedButton(
                      onPressed: () => {
                        _setPlaceToJinri(),
                        _moveCameraByButton(),
                      },
                      child: Text("진리관")),
                ],
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      onPrimary: Colors.blue,
                    ),
                    onPressed: () {
                      if (state == "_moveCamera") {
                        if (placeDetail.name.length <= 9) {
                          Navigator.pop(context, placeDetail.name);
                        }
                        else {
                          Navigator.pop(context, _searchController.text);
                        }
                      }
                      else if (state == "_moveCameraByButton") {
                        Navigator.pop(context, name);
                      }
                    },
                    child: Text('여기로 결정 !')),
              )
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

