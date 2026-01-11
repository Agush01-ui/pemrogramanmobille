import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/services/weather_service.dart';
import '../data/services/location_service.dart';
import '../data/models/weather_model.dart';

class WeatherProvider with ChangeNotifier {
  final WeatherService _weatherService = WeatherService();
  final LocationService _locationService = LocationService();

  WeatherModel? _weather;
  bool _isLoading = false;
  String _error = '';
  double? _latitude;
  double? _longitude;

  WeatherModel? get weather => _weather;
  bool get isLoading => _isLoading;
  String get error => _error;
  double? get latitude => _latitude;
  double? get longitude => _longitude;

  Future<void> loadWeather() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      final position = await _locationService.getCurrentLocation();
      _latitude = position.latitude;
      _longitude = position.longitude;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('last_lat', position.latitude);
      await prefs.setDouble('last_long', position.longitude);

      _weather = await _weatherService.fetchWeather(
          position.latitude, position.longitude);
    } catch (e) {
      _error = e.toString();
      print('Error loading weather: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Map<String, double>?> getLastLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final lat = prefs.getDouble('last_lat');
    final lng = prefs.getDouble('last_long');

    if (lat != null && lng != null) {
      return {'lat': lat, 'lng': lng};
    }
    return null;
  }
}
