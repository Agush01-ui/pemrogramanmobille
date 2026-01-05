import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/location_provider.dart';
import '../providers/weather_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _controller;

  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      final location = context.read<LocationProvider>();
      final weather = context.read<WeatherProvider>();

      location.getCurrentLocation();

      location.addListener(() {
        final pos = location.position;
        if (pos != null) {
          weather.fetchWeather(pos.latitude, pos.longitude);
          _controller?.animateCamera(
            CameraUpdate.newLatLng(
              LatLng(pos.latitude, pos.longitude),
            ),
          );
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationProvider>();
    final weather = context.watch<WeatherProvider>();

    if (location.position == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final latLng = LatLng(
      location.position!.latitude,
      location.position!.longitude,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Google Maps + Cuaca')),
      body: Stack(
        children: [
          /// ================= MAP =================
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: latLng,
              zoom: 15,
            ),
            myLocationEnabled: true,
            circles: {
              Circle(
                circleId: const CircleId('radius'),
                center: latLng,
                radius: 500,
                fillColor: Colors.blue.withOpacity(0.2),
                strokeColor: Colors.blue,
                strokeWidth: 2,
              ),
            },
            markers: {
              Marker(
                markerId: const MarkerId('me'),
                position: latLng,
                infoWindow: const InfoWindow(title: 'Lokasi Anda'),
              ),
            },
            onMapCreated: (c) => _controller = c,
          ),

          /// ================= WEATHER CARD =================
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: weather.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Row(
                        children: [
                          Image.network(
                            'https://openweathermap.org/img/wn/${weather.icon}@2x.png',
                            width: 48,
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                weather.city,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                '${weather.temperature.toStringAsFixed(1)}°C • ${weather.description}',
                              ),
                            ],
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
