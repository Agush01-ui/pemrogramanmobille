import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/weather_model.dart';

class WeatherService {
  static const String apiKey = 'b52b805ef736c81843746a28ee98744c';
  static const String baseUrl =
      'https://api.openweathermap.org/data/2.5/weather';

  Future<Weather> getWeatherByLocation(double lat, double lon) async {
    final url = '$baseUrl?lat=$lat&lon=$lon&appid=$apiKey&units=metric&lang=id';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return Weather.fromJson(json.decode(response.body));
    } else {
      throw Exception('Gagal mengambil data cuaca');
    }
  }
}
