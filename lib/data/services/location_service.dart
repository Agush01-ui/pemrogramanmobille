import 'package:geolocator/geolocator.dart';

class LocationService {
  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception(
          'Layanan lokasi tidak aktif. Aktifkan GPS terlebih dahulu.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Izin lokasi ditolak. Mohon aktifkan di pengaturan.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Izin lokasi ditolak permanen. Mohon aktifkan di pengaturan aplikasi.');
    }

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      timeLimit: Duration(seconds: 15),
    );
  }
}
