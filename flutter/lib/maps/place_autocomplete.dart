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
                  },
                ),
              ),
              SizedBox(height: 10),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(onPressed: () {}, child: Text("블루베리 안경")),
                  SizedBox(width: 10),
                  ElevatedButton(onPressed: () {}, child: Text("부산은행")),
                  SizedBox(width: 10),
                  ElevatedButton(onPressed: () {}, child: Text("부산대역 3출")),
                ],
              ),
              SizedBox(height: 10),
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.white,
                    onPrimary: Colors.blue,
                  ),
                  onPressed: () {},
                  child: Text('여기로 결정!'))
            ],
          ),
        ),
      ),
    );
  }
}