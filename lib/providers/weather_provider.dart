import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'location_provider.dart';

class WeatherProvider extends ChangeNotifier {
  static const String apiKey = 'b92e83b12fc7f359cb1ef9a57810171d';

  String city = '';
  String description = '';
  String icon = '';
  String mainCondition = ''; // ⬅️ PENTING UNTUK ANIMASI
  double temperature = 0;

  bool isLoading = true;
  bool fromCache = false;

  double? _lastLat;
  double? _lastLon;

  WeatherProvider() {
    loadCache();
  }

  /// ================= REALTIME LOCATION =================
  void listenLocation(LocationProvider location) {
    location.addListener(() {
      final pos = location.position;
      if (pos == null) return;

      /// ⛔ JANGAN FETCH JIKA LOKASI SAMA
      if (_lastLat == pos.latitude && _lastLon == pos.longitude) return;

      _lastLat = pos.latitude;
      _lastLon = pos.longitude;

      fetchWeather(pos.latitude, pos.longitude);
    });
  }

  /// ================= CACHE =================
  Future<void> loadCache() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('weather_cache')) return;

    final data = json.decode(prefs.getString('weather_cache')!);

    city = data['city'];
    description = data['description'];
    icon = data['icon'];
    mainCondition = data['mainCondition'];
    temperature = data['temperature'];

    isLoading = false;
    fromCache = true;
    notifyListeners();
  }

  Future<void> saveCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'weather_cache',
      json.encode({
        'city': city,
        'description': description,
        'icon': icon,
        'mainCondition': mainCondition,
        'temperature': temperature,
        'time': DateTime.now().toIso8601String(),
      }),
    );
  }

  /// ================= FETCH =================
  Future<void> fetchWeather(double lat, double lon) async {
    isLoading = true;
    notifyListeners();

    final url = 'https://api.openweathermap.org/data/2.5/weather'
        '?lat=$lat&lon=$lon&units=metric&appid=$apiKey';

    final res = await http.get(Uri.parse(url));
    final data = json.decode(res.body);

    city = data['name'];
    description = data['weather'][0]['description'];
    icon = data['weather'][0]['icon'];
    mainCondition = data['weather'][0]['main']; // ⬅️ KUNCI ANIMASI
    temperature = data['main']['temp'].toDouble();

    isLoading = false;
    fromCache = false;

    await saveCache();
    notifyListeners();
  }
}
