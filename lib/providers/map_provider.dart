import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/location_service.dart';

class MapProvider extends ChangeNotifier {
  final LocationService locationService;

  MapProvider({required this.locationService});

  LatLng? currentPosition;
  double radius = 500;
  bool isLoading = false;

  Future<void> loadLocation() async {
    isLoading = true;
    notifyListeners();

    final position = await locationService.getCurrentPosition();
    currentPosition = LatLng(
      position.latitude,
      position.longitude,
    );

    isLoading = false;
    notifyListeners();
  }

  void updateRadius(double value) {
    radius = value;
    notifyListeners();
  }

  Set<Circle> get circles {
    if (currentPosition == null) return {};
    return {
      Circle(
        circleId: const CircleId('radius'),
        center: currentPosition!,
        radius: radius,
        fillColor: Colors.blue.withOpacity(0.25),
        strokeColor: Colors.blue,
        strokeWidth: 2,
      ),
    };
  }
}
