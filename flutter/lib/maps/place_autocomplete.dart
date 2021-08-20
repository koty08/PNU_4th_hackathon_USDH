// @dart=2.9
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

  @override
  void initState() {
    super.initState();
    _markers.add(
        Marker(
          markerId: MarkerId('testMarker'),
          position: LatLng(35.23159301295487, 129.08395882267462),
          infoWindow: InfoWindow(title: 'My position', snippet: 'Where am I?'),
        ));
  }

  void _moveCamera() async {
    if (_markers.length > 0) {
      setState(() {
        _markers.clear();
      });
    }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Places Autocomplete'),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 32.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget> [
              SizedBox(
                height: 45.0,
                child: Image.asset('assets/images/powered_by_google.png'),
              ),
              TypeAheadField(
                debounceDuration: Duration(milliseconds: 500),
                textFieldConfiguration: TextFieldConfiguration(
                  controller: _searchController,
                  autofocus: true,
                  decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Search places...'
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
              SizedBox(height: 20),
              Container(
                  width: double.infinity,
                  height: 350,
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
            ],
          ),
        ),
      ),
    );
  }
}