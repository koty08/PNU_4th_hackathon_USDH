import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';


class DeliveryGoogleMap extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  Completer<GoogleMapController> _controller = Completer();
  var _viewType = 0;
  var _buttonText = "내 위치";
  var _lock = true;

  // 초기 위치 : 부산대학교 정문
  static final CameraPosition _pusanUniversity = CameraPosition(
    target: LatLng(35.23159301295487, 129.08395882267462),
    zoom: 16);

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _pusanUniversity,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: false,
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