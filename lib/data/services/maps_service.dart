import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class MapsService {
  // ===============================
  // REVERSE GEOCODING
  // ===============================
  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return [place.street, place.subLocality, place.locality]
            .where((e) => e != null && e!.isNotEmpty)
            .join(', ');
      }
      return 'Lokasi tidak diketahui';
    } catch (e) {
      return 'Gagal mendapatkan alamat';
    }
  }

  // ===============================
  // GEOCODING (ALAMAT → KOORDINAT)
  // ===============================
  Future<LatLng?> getLatLngFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return LatLng(
          locations.first.latitude,
          locations.first.longitude,
        );
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  // ===============================
  // SEARCH ALAMAT (AUTOCOMPLETE)
  // ===============================
  Future<List<Map<String, dynamic>>> searchAddressSuggestions(
      String query) async {
    if (query.length < 3) return [];

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search'
          '?q=$query&format=json&addressdetails=1&limit=5',
        ),
        headers: {'User-Agent': 'TodoListApp/1.0'},
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        return data.map((item) {
          return {
            'displayName': item['display_name'],
            'lat': double.parse(item['lat']),
            'lon': double.parse(item['lon']),
          };
        }).toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ===============================
  // ROUTING (OSRM)
  // ===============================
  Future<List<LatLng>> getRoute(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
    String profile,
  ) async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://router.project-osrm.org/route/v1/$profile/'
          '$startLng,$startLat;$endLng,$endLat'
          '?overview=full&geometries=geojson',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;

        return coords
            .map((c) => LatLng(c[1].toDouble(), c[0].toDouble()))
            .toList();
      }
      return [];
    } catch (_) {
      return [];
    }
  }

  // ===============================
  // HITUNG JARAK (KM)
  // ===============================
  double calculateDistanceKm(LatLng a, LatLng b) {
    final Distance distance = Distance();
    return distance(a, b) / 1000;
  }

  // ===============================
  // CEK MASUK RADIUS TODO
  // ===============================
  bool isInsideRadius({
    required LatLng user,
    required LatLng todo,
    double radiusMeter = 100,
  }) {
    final Distance distance = Distance();
    return distance(user, todo) <= radiusMeter;
  }
}
