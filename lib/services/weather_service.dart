import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  static const _apiKey = 'API_KEY_KAMU';

  static Future<String> getWeather(double lat, double lon) async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$lat&lon=$lon&appid=$_apiKey&units=metric';

    final res = await http.get(Uri.parse(url));
    final data = json.decode(res.body);
    return data['weather'][0]['description'];
  }
}
