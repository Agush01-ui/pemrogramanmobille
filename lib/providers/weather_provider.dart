import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class WeatherProvider extends ChangeNotifier {
  String? weather;

  Future<void> fetch(double lat, double lon) async {
    weather = await WeatherService.getWeather(lat, lon);
    notifyListeners();
  }
}
