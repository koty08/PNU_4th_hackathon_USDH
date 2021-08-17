import 'dart:convert';
import 'package:http/http.dart' as http;

// import 'constants.dart';
import 'place.dart';

const API_KEY = "AIzaSyCU2qNxdkqmp0chBXCFabtclmT2XYu966U";

class GoogleMapServices {
  final String? sessionToken;

  GoogleMapServices({this.sessionToken});

  Future<List> getSuggestions(String query) async {
    final String baseUrl =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json';
    String type = 'establishment';
    String strUrl =
        '$baseUrl?input=$query&key=$API_KEY&type=$type&language=ko&components=country:kr&sessiontoken=$sessionToken';

    var url = Uri.parse(strUrl);
    print('Autocomplete(sessionToken): $sessionToken');

    final http.Response response = await http.get(url);
    final responseData = json.decode(response.body);
    final predictions = responseData['predictions'];

    List<Place> suggestions = [];

    for (int i = 0; i < predictions.length; i++) {
      final place = Place.fromJson(predictions[i]);
      suggestions.add(place);
    }

    return suggestions;
  }

  Future<PlaceDetail> getPlaceDetail(String placeId, String token) async {
    final String baseUrl =
        'https://maps.googleapis.com/maps/api/place/details/json';
    String strUrl =
        '$baseUrl?key=$API_KEY&place_id=$placeId&language=ko&sessiontoken=$token';
    Uri url = Uri.parse(strUrl);

    print('Place Detail(sessionToken): $sessionToken');
    final http.Response response = await http.get(url);
    final responseData = json.decode(response.body);
    final result = responseData['result'];

    final PlaceDetail placeDetail = PlaceDetail.fromJson(result);
    print(placeDetail.toMap());

    return placeDetail;
  }

  static Future<String> getAddrFromLocation(double lat, double lng) async {
    final String baseUrl = 'https://maps.googleapis.com/maps/api/geocode/json';
    String strUrl = '$baseUrl?latlng=$lat,$lng&key=$API_KEY&language=ko';
    Uri url = Uri.parse(strUrl);

    final http.Response response = await http.get(url);
    final responseData = json.decode(response.body);
    final formattedAddr = responseData['results'][0]['formatted_address'];
    print(formattedAddr);

    return formattedAddr;
  }

  static String getStaticMap(double latitude, double longitude) {
    return 'https://maps.googleapis.com/maps/api/staticmap?center=&$latitude,$longitude&zoom=16&size=600x300&maptype=roadmap&markers=color:red%7Clabel:C%7C$latitude,$longitude&key=$API_KEY';
  }
}