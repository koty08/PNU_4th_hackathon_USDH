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

  // 초기 위치 : 부산대학교 정문
  CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(35.23159301295487, 129.08395882267462),
    zoom: 16,
  );

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: _initialCameraPosition,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
        myLocationEnabled: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToCurrentLocation,
        label: Text("내 위치"),
        icon: Icon(Icons.my_location),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // Floating 버튼 클릭 시 현재 위치 표시
  Future<void> _goToCurrentLocation() async {
    final locData = await Location().getLocation();
    final lat = locData.latitude;
    final lng = locData.longitude;

    CameraPosition _currentLocation = CameraPosition(
      target: LatLng(lat!, lng!),
      zoom: 16,
    );

    final GoogleMapController controller = await _controller.future;
    Location location = new Location();
    location.onLocationChanged.listen((event) {
      controller.animateCamera(CameraUpdate.newCameraPosition(_currentLocation));
    });
  }
}