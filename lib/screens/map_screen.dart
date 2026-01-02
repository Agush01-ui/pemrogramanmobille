import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';

import '../providers/location_provider.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? _mapController;

  static const double radius = 500; // meter

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<LocationProvider>().getCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final location = context.watch<LocationProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map & Radius Lokasi'),
      ),
      body: location.isLoading
          ? const Center(child: CircularProgressIndicator())
          : location.position == null
              ? const Center(child: Text('Lokasi tidak tersedia'))
              : _buildMap(location),
    );
  }

  Widget _buildMap(LocationProvider location) {
    final latLng = LatLng(
      location.position!.latitude,
      location.position!.longitude,
    );

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: latLng,
        zoom: 15,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      onMapCreated: (controller) => _mapController = controller,
      markers: {
        Marker(
          markerId: const MarkerId('user'),
          position: latLng,
          infoWindow: const InfoWindow(title: 'Lokasi Anda'),
        ),
      },
      circles: {
        Circle(
          circleId: const CircleId('radius'),
          center: latLng,
          radius: radius,
          strokeWidth: 2,
          strokeColor: Colors.blue,
          fillColor: Colors.blue.withOpacity(0.2),
        ),
      },
    );
  }
}
