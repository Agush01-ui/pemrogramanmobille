import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class LocationProvider extends ChangeNotifier {
  Position? _position;
  StreamSubscription<Position>? _subscription;
  bool _isLoading = true;

  Position? get position => _position;
  bool get isLoading => _isLoading;

  /// ================= STREAM REALTIME =================
  Future<void> startLocationStream() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    _subscription?.cancel();

    _subscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 50, // update tiap 50 meter
      ),
    ).listen((Position position) {
      _position = position;
      _isLoading = false;
      notifyListeners();
    });
  }

  /// ================= ALIAS UNTUK MAP =================
  Future<void> getCurrentLocation() async {
    await startLocationStream();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
