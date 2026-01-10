import 'dart:convert';
import 'package:http/http.dart' as http;

class PlacesService {
  final String apiKey = 'YOUR_API_KEY';

  Future<List<Map<String, dynamic>>> findNearby(
    double lat,
    double lon,
    String type,
  ) async {
    final url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=$lat,$lon'
        '&radius=2000'
        '&type=$type'
        '&key=$apiKey';

    final res = await http.get(Uri.parse(url));
    final data = jsonDecode(res.body);

    if (data['status'] != 'OK') return [];

    return List<Map<String, dynamic>>.from(data['results'].map((e) => {
          'name': e['name'],
          'placeId': e['place_id'],
          'rating': e['rating'],
          'vicinity': e['vicinity'],
        }));
  }
}
