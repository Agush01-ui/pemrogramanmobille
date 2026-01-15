// lib/ui/screens/location_picker_screen.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationPickerScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? initialLocationName;

  const LocationPickerScreen({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
    this.initialLocationName,
  }) : super(key: key);

  @override
  _LocationPickerScreenState createState() => _LocationPickerScreenState();
}

class _LocationPickerScreenState extends State<LocationPickerScreen> {
  late MapController _mapController;
  LatLng? _selectedLocation;
  String? _locationName;
  bool _isLoading = false;
  LatLng _currentLocation = const LatLng(-6.2088, 106.8456);
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _mapController = MapController();

    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _selectedLocation = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );
      _locationName = widget.initialLocationName;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoading = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showLocationServiceError();
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showLocationPermissionError();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showLocationPermissionError();
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        if (_selectedLocation == null) {
          _selectedLocation = _currentLocation;
        }
      });

      await _getLocationName(_selectedLocation!);

      _mapController.move(_selectedLocation!, 15.0);
    } catch (e) {
      print("Error getting location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Gagal mendapatkan lokasi: $e")),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _getLocationName(LatLng location) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        location.latitude,
        location.longitude,
      );

      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address = '';

        if (place.street != null && place.street!.isNotEmpty) {
          address += place.street!;
        }
        if (place.subLocality != null && place.subLocality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.subLocality!;
        }
        if (place.locality != null && place.locality!.isNotEmpty) {
          if (address.isNotEmpty) address += ', ';
          address += place.locality!;
        }

        setState(() {
          _locationName = address.isNotEmpty ? address : 'Lokasi terpilih';
        });
      } else {
        setState(() {
          _locationName =
              '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
        });
      }
    } catch (e) {
      print("Error getting location name: $e");
      setState(() {
        _locationName =
            '${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}';
      });
    }
  }

  void _showLocationServiceError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Layanan Lokasi Dimatikan'),
        content: const Text(
            'Silakan aktifkan layanan lokasi di pengaturan perangkat Anda.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showLocationPermissionError() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Izin Lokasi Ditolak'),
        content: const Text(
            'Aplikasi memerlukan izin lokasi untuk memilih lokasi tugas.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _onMapTap(LatLng location) async {
    setState(() {
      _selectedLocation = location;
    });

    await _getLocationName(location);
    _mapController.move(location, _mapController.zoom);
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        final location = locations.first;
        final latLng = LatLng(location.latitude, location.longitude);

        setState(() {
          _selectedLocation = latLng;
        });

        _mapController.move(latLng, 15.0);
        await _getLocationName(latLng);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lokasi "$query" tidak ditemukan')),
        );
      }
    } catch (e) {
      print("Error searching location: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal mencari lokasi: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Lokasi Tugas'),
        actions: [
          if (_selectedLocation != null)
            IconButton(
              icon: const Icon(Icons.check, color: Colors.white),
              onPressed: () {
                Navigator.pop(context, {
                  'latitude': _selectedLocation!.latitude,
                  'longitude': _selectedLocation!.longitude,
                  'locationName': _locationName,
                });
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: _selectedLocation ?? _currentLocation,
              zoom: 15.0,
              interactiveFlags: InteractiveFlag.all,
              onTap: (tapPosition, latLng) => _onMapTap(latLng),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.uastodo',
              ),
              if (_selectedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _selectedLocation!,
                      width: 50,
                      height: 50,
                      builder: (ctx) => Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.red,
                            width: 3,
                          ),
                        ),
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // Search Bar
          Positioned(
            top: 10,
            left: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Cari lokasi...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16),
                      ),
                      onSubmitted: (value) => _searchLocation(value),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: () => _searchLocation(_searchController.text),
                  ),
                ],
              ),
            ),
          ),

          // Selected Location Info
          if (_selectedLocation != null && _locationName != null)
            Positioned(
              bottom: 80,
              left: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lokasi Terpilih:',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _locationName!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Lat: ${_selectedLocation!.latitude.toStringAsFixed(4)}, '
                      'Lng: ${_selectedLocation!.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Current Location Button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: Colors.blue),
            ),
          ),

          if (_isLoading) const Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
