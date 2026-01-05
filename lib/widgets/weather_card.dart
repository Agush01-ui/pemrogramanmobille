import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/weather_provider.dart';
import 'weather_animation.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({super.key});

  @override
  Widget build(BuildContext context) {
    final weather = context.watch<WeatherProvider>();

    if (weather.isLoading) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (weather.temperature == null) return const SizedBox();

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          /// 🌤️ ANIMASI CUACA
          if (weather.mainCondition == 'Rain')
            const RainAnimation()
          else if (weather.mainCondition == 'Clear')
            const SunAnimation(),

          const SizedBox(height: 8),

          /// INFO CUACA
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.network(
                'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                width: 60,
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${weather.temperature!.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                        fontSize: 26, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    weather.description ?? '',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  Text(
                    weather.city ?? '',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              )
            ],
          ),
        ],
      ),
    );
  }
}
