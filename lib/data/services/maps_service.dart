import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geocoding/geocoding.dart';
import 'package:latlong2/latlong.dart';

class MapsService {
  // Reverse Geocoding: Koordinat -> Alamat
  Future<String> getAddressFromLatLng(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}';
      }
      return 'Lokasi tidak diketahui';
    } catch (e) {
      print('Error reverse geocoding: $e');
      return 'Gagal mendapatkan alamat';
    }
  }

  // Geocoding: Alamat -> Koordinat
  Future<Map<String, double>> getLatLngFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isNotEmpty) {
        return {
          'lat': locations.first.latitude,
          'lng': locations.first.longitude,
        };
      }
      throw Exception('Alamat tidak ditemukan');
    } catch (e) {
      print('Error geocoding: $e');
      rethrow;
    }
  }

  // **NEW METHOD: Search Address Suggestions**
  Future<List<Map<String, dynamic>>> searchAddressSuggestions(
      String query) async {
    if (query.length < 3) return [];

    try {
      final response = await http.get(
        Uri.parse('https://nominatim.openstreetmap.org/search?'
            'q=$query&format=json&addressdetails=1&limit=5'),
        headers: {'User-Agent': 'TodoListApp/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        return data.map<Map<String, dynamic>>((item) {
          return {
            'displayName': item['display_name'] as String,
            'lat': double.parse(item['lat'] as String),
            'lon': double.parse(item['lon'] as String),
            'type': item['type'] as String? ?? '',
          };
        }).toList();
      }
      return [];
    } catch (e) {
      print('Error search suggestions: $e');
      return [];
    }
  }

  // Get Route dari OSRM (Open Source Routing Machine)
  Future<List<LatLng>> getRoute(
    double startLat,
    double startLng,
    double endLat,
    double endLng,
    String profile, // walking, driving, cycling
  ) async {
    try {
      final response = await http.get(
        Uri.parse('https://router.project-osrm.org/route/v1/$profile/'
            '$startLng,$startLat;$endLng,$endLat'
            '?overview=full&geometries=geojson'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final routes = data['routes'] as List?;

        if (routes != null && routes.isNotEmpty) {
          final geometry = routes[0]['geometry']['coordinates'] as List?;

          if (geometry != null) {
            return geometry.map<LatLng>((coord) {
              return LatLng(
                  (coord[1] as num).toDouble(), (coord[0] as num).toDouble());
            }).toList();
          }
        }
      }
      return [];
    } catch (e) {
      print('Error getting route: $e');
      return [];
    }
  }

  // Hitung jarak antara dua titik (dalam km)
  double calculateDistance(LatLng point1, LatLng point2) {
    final Distance distance = Distance();
    return distance(point1, point2) / 1000; // dalam km
  }
}
