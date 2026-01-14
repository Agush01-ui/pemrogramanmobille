import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../data/services/location_service.dart';
import '../../data/services/maps_service.dart';
import '../../providers/weather_provider.dart';

class MapScreen extends StatefulWidget {
  final double? initialLatitude;
  final double? initialLongitude;
  final String? todoTitle;
  final double? zoom;
  final bool? isFromTodo;

  const MapScreen({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
    this.todoTitle,
    this.zoom,
    this.isFromTodo = false,
  }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen>
    with SingleTickerProviderStateMixin {
  final LocationService _locationService = LocationService();
  final MapsService _mapsService = MapsService();
  final MapController _mapController = MapController();
  final TextEditingController _destinationController = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _animation;

  LatLng? _currentLocation;
  LatLng? _destinationLocation;
  String _address = 'Mendapatkan alamat...';
  bool _isLoading = true;
  bool _showRoute = false;
  List<LatLng> _polylinePoints = [];
  double _distance = 0.0;
  String _selectedTransport = 'walking';
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;
  String _estimatedTime = '';
  bool _showSearchResults = false;

  // Kecepatan rata-rata dalam km/jam untuk berbagai transportasi
  final Map<String, double> _averageSpeeds = {
    'walking': 5.0,
    'cycling': 15.0,
    'driving': 40.0,
  };

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _initializeWithTodoLocation();
  }

  void _initializeWithTodoLocation() async {
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      _destinationLocation = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );

      try {
        final address = await _mapsService.getAddressFromLatLng(
          widget.initialLatitude!,
          widget.initialLongitude!,
        );
        _address = address;
        _destinationController.text = address;
      } catch (e) {
        _address =
            'Lokasi: ${widget.initialLatitude}, ${widget.initialLongitude}';
        _destinationController.text = widget.todoTitle ?? 'Lokasi Tugas';
      }

      await _getCurrentLocation();

      if (widget.isFromTodo == true) {
        _mapController.move(_destinationLocation!, widget.zoom ?? 16.0);
      }
    } else {
      await _getCurrentLocation();
    }

    setState(() => _isLoading = false);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      final latLng = LatLng(position.latitude, position.longitude);

      final address = await _mapsService.getAddressFromLatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _currentLocation = latLng;
        if (_destinationLocation == null) {
          _address = address;
        }
      });

      if (_destinationLocation != null && _currentLocation != null) {
        _calculateRoute();
      } else {
        _mapController.move(latLng, widget.zoom ?? 15.0);
      }
    } catch (e) {
      setState(() {
        _address = 'Gagal mendapatkan lokasi';
      });
    }
  }

  void _calculateEstimatedTime() {
    if (_distance <= 0) {
      setState(() {
        _estimatedTime = '';
      });
      return;
    }

    final speed = _averageSpeeds[_selectedTransport] ?? 5.0;
    final hours = _distance / speed;
    final totalMinutes = (hours * 60).ceil();

    if (totalMinutes < 60) {
      _estimatedTime = '$totalMinutes menit';
    } else {
      final hoursPart = (totalMinutes / 60).floor();
      final minutesPart = totalMinutes % 60;

      if (minutesPart == 0) {
        _estimatedTime = '$hoursPart jam';
      } else {
        _estimatedTime = '$hoursPart jam $minutesPart menit';
      }
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.length < 3) {
      setState(() {
        _searchResults = [];
        _showSearchResults = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
      _showSearchResults = true;
    });

    try {
      final results = await _mapsService.searchAddressSuggestions(query);
      setState(() {
        _searchResults = results;
        _isSearching = false;
      });
    } catch (e) {
      setState(() {
        _isSearching = false;
      });
    }
  }

  Future<void> _selectSearchResult(Map<String, dynamic> result) async {
    final latLng = LatLng(result['lat'], result['lon']);

    setState(() {
      _destinationLocation = latLng;
      _destinationController.text = result['displayName'];
      _searchResults = [];
      _showSearchResults = false;
    });

    _animationController.reset();
    _animationController.forward();

    if (_currentLocation != null) {
      final centerLat = (_currentLocation!.latitude + latLng.latitude) / 2;
      final centerLng = (_currentLocation!.longitude + latLng.longitude) / 2;
      _mapController.move(LatLng(centerLat, centerLng), 14.0);
    } else {
      _mapController.move(latLng, 14.0);
    }

    _calculateRoute();
  }

  Future<void> _calculateRoute() async {
    if (_currentLocation == null || _destinationLocation == null) return;

    try {
      final routePoints = await _mapsService.getRoute(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        _destinationLocation!.latitude,
        _destinationLocation!.longitude,
        _selectedTransport,
      );

      if (routePoints.isNotEmpty) {
        setState(() {
          _polylinePoints = routePoints;
          _distance = _mapsService.calculateDistanceKm(
            _currentLocation!,
            _destinationLocation!,
          );
          _showRoute = true;
        });

        _calculateEstimatedTime();
        _animationController.reset();
        _animationController.forward();
      } else {
        _calculateStraightLineDistance();
      }
    } catch (e) {
      _calculateStraightLineDistance();
    }
  }

  void _calculateStraightLineDistance() {
    if (_currentLocation == null || _destinationLocation == null) return;

    final Distance distance = Distance();
    final double km = distance(
          LatLng(_currentLocation!.latitude, _currentLocation!.longitude),
          LatLng(
              _destinationLocation!.latitude, _destinationLocation!.longitude),
        ) /
        1000;

    setState(() {
      _distance = km;
      _showRoute = true;
      _polylinePoints = [_currentLocation!, _destinationLocation!];
    });

    _calculateEstimatedTime();
    _animationController.reset();
    _animationController.forward();
  }

  void _clearDestination() {
    setState(() {
      _destinationLocation = null;
      _destinationController.clear();
      _showRoute = false;
      _polylinePoints.clear();
      _distance = 0.0;
      _searchResults = [];
      _estimatedTime = '';
      _showSearchResults = false;
    });
  }

  void _onMapTap(LatLng latLng) async {
    _animationController.reset();
    _animationController.forward();

    final address = await _mapsService.getAddressFromLatLng(
      latLng.latitude,
      latLng.longitude,
    );

    setState(() {
      _destinationLocation = latLng;
      _destinationController.text = address;
    });

    _calculateRoute();
  }

  // Compact Search Bar dengan toggle
  Widget _buildCompactSearchBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 20,
      left: 16,
      right: 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar Minimalis
          Material(
            color: Colors.transparent,
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey.shade900.withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
                border: Border.all(
                  color: isDarkMode
                      ? Colors.grey.shade700.withOpacity(0.3)
                      : Colors.grey.shade300.withOpacity(0.5),
                  width: 1,
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    Icon(
                      Icons.search,
                      color: const Color(0xFF9F7AEA),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _destinationController,
                        decoration: InputDecoration(
                          hintText: widget.todoTitle != null
                              ? 'Cari lokasi lain...'
                              : 'Cari alamat...',
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade500,
                            fontSize: 14,
                          ),
                          isDense: true,
                        ),
                        style: TextStyle(
                          fontSize: 15,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        onChanged: (value) {
                          _searchAddress(value);
                        },
                        onTap: () {
                          setState(() {
                            _showSearchResults = true;
                          });
                        },
                      ),
                    ),
                    if (_destinationController.text.isNotEmpty)
                      IconButton(
                        icon: Icon(Icons.clear, size: 18),
                        color: Colors.red,
                        onPressed: () {
                          _destinationController.clear();
                          _clearDestination();
                        },
                        padding: EdgeInsets.zero,
                        constraints: BoxConstraints(),
                      ),
                  ],
                ),
              ),
            ),
          ),

          // Info Lokasi Tugas (minimalis)
          if (widget.todoTitle != null && _estimatedTime.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: const Color(0xFF9F7AEA).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF9F7AEA).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.task_alt,
                    color: const Color(0xFF9F7AEA),
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      widget.todoTitle!,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.timer,
                    size: 12,
                    color: const Color(0xFF9F7AEA),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _estimatedTime,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF9F7AEA),
                    ),
                  ),
                ],
              ),
            ),

          // Hasil Pencarian (collapse/expand)
          if (_showSearchResults && _searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.3,
              ),
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey.shade900.withOpacity(0.95)
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Header hasil pencarian
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade100,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(12),
                        topRight: Radius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Hasil Pencarian',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDarkMode
                                ? Colors.grey.shade300
                                : Colors.grey.shade700,
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 16),
                          color: Colors.grey,
                          onPressed: () {
                            setState(() {
                              _showSearchResults = false;
                            });
                          },
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  // Daftar hasil
                  Expanded(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: _searchResults.length,
                      itemBuilder: (context, index) {
                        final result = _searchResults[index];
                        return Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _selectSearchResult(result),
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: index < _searchResults.length - 1
                                    ? Border(
                                        bottom: BorderSide(
                                          color: isDarkMode
                                              ? Colors.grey.shade800
                                              : Colors.grey.shade200,
                                          width: 0.5,
                                        ),
                                      )
                                    : null,
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.place,
                                    color: const Color(0xFF9F7AEA),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          result['displayName'],
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                            color: isDarkMode
                                                ? Colors.white
                                                : Colors.black,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Floating info panel yang muncul di bawah
  Widget _buildFloatingInfoPanel() {
    if (!_showRoute || _destinationLocation == null) return const SizedBox();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    String transportText;
    Color transportColor;
    IconData transportIcon;

    switch (_selectedTransport) {
      case 'walking':
        transportText = 'Jalan';
        transportColor = const Color(0xFF4CAF50);
        transportIcon = Icons.directions_walk;
        break;
      case 'driving':
        transportText = 'Mobil';
        transportColor = const Color(0xFFF44336);
        transportIcon = Icons.directions_car;
        break;
      case 'cycling':
        transportText = 'Sepeda';
        transportColor = const Color(0xFF2196F3);
        transportIcon = Icons.directions_bike;
        break;
      default:
        transportText = _selectedTransport;
        transportColor = const Color(0xFF9F7AEA);
        transportIcon = Icons.directions;
    }

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 80,
      left: 16,
      right: 16,
      child: ScaleTransition(
        scale: _animation,
        child: Material(
          color: Colors.transparent,
          child: GestureDetector(
            onVerticalDragUpdate: (details) {
              // Bisa ditambahkan gesture untuk dismiss
            },
            child: Container(
              decoration: BoxDecoration(
                color: isDarkMode
                    ? Colors.grey.shade900.withOpacity(0.95)
                    : Colors.white.withOpacity(0.95),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
                border: Border.all(
                  color: transportColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Header dengan tombol close
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: transportColor.withOpacity(0.05),
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(16),
                        topRight: Radius.circular(16),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: transportColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            transportIcon,
                            color: transportColor,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Rute ke ${widget.todoTitle != null ? 'Lokasi Tugas' : 'Tujuan'}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 18),
                          color: Colors.grey,
                          onPressed: _clearDestination,
                          padding: EdgeInsets.zero,
                          constraints: BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
                  // Konten
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Jarak',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${_distance.toStringAsFixed(1)} km',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: transportColor,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Estimasi Waktu',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDarkMode
                                    ? Colors.grey.shade400
                                    : Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _estimatedTime,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: transportColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Floating transport selector
  Widget _buildFloatingTransportSelector() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 20,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.grey.shade900.withOpacity(0.8)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDarkMode
                  ? Colors.grey.shade700.withOpacity(0.3)
                  : Colors.grey.shade300.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTransportButton(
                icon: Icons.directions_walk,
                isSelected: _selectedTransport == 'walking',
                color: const Color(0xFF4CAF50),
                onTap: () {
                  setState(() => _selectedTransport = 'walking');
                  if (_destinationLocation != null) _calculateRoute();
                },
              ),
              Container(
                height: 30,
                width: 1,
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
              _buildTransportButton(
                icon: Icons.directions_bike,
                isSelected: _selectedTransport == 'cycling',
                color: const Color(0xFF2196F3),
                onTap: () {
                  setState(() => _selectedTransport = 'cycling');
                  if (_destinationLocation != null) _calculateRoute();
                },
              ),
              Container(
                height: 30,
                width: 1,
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
              _buildTransportButton(
                icon: Icons.directions_car,
                isSelected: _selectedTransport == 'driving',
                color: const Color(0xFFF44336),
                onTap: () {
                  setState(() => _selectedTransport = 'driving');
                  if (_destinationLocation != null) _calculateRoute();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTransportButton({
    required IconData icon,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? color : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isSelected ? Colors.white : color,
            size: 18,
          ),
        ),
      ),
    );
  }

  // Floating location info
  Widget _buildFloatingLocationInfo() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final hasWeather = context.watch<WeatherProvider>().weather != null;

    return Positioned(
      top: MediaQuery.of(context).padding.top + 80,
      left: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.grey.shade900.withOpacity(0.8)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDarkMode
                  ? Colors.grey.shade700.withOpacity(0.3)
                  : Colors.grey.shade300.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Consumer<WeatherProvider>(
              builder: (context, weatherProvider, child) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Alamat singkat
                    ConstrainedBox(
                      constraints: BoxConstraints(maxWidth: 200),
                      child: Text(
                        _address,
                        style: TextStyle(
                          fontSize: 12,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Cuaca
                    if (hasWeather) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.thermostat,
                            size: 12,
                            color: const Color(0xFFFF9800),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${weatherProvider.weather!.temperature}°C',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Icon(
                            Icons.air,
                            size: 12,
                            color: const Color(0xFF4CAF50),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${weatherProvider.weather!.windSpeed} km/h',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDarkMode ? Colors.white : Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  // Floating map controls
  Widget _buildFloatingMapControls() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 80,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? Colors.grey.shade900.withOpacity(0.8)
                : Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            border: Border.all(
              color: isDarkMode
                  ? Colors.grey.shade700.withOpacity(0.3)
                  : Colors.grey.shade300.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildControlButton(
                icon: Icons.my_location,
                color: const Color(0xFF2196F3),
                onPressed: _getCurrentLocation,
                tooltip: 'Lokasi Saya',
              ),
              Container(
                width: 36,
                height: 1,
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
              _buildControlButton(
                icon: Icons.add,
                color: const Color(0xFF4CAF50),
                onPressed: () {
                  final currentZoom = _mapController.zoom;
                  _mapController.move(_mapController.center, currentZoom + 1);
                },
                tooltip: 'Zoom In',
              ),
              Container(
                width: 36,
                height: 1,
                color: isDarkMode ? Colors.grey.shade800 : Colors.grey.shade200,
              ),
              _buildControlButton(
                icon: Icons.remove,
                color: const Color(0xFFF44336),
                onPressed: () {
                  final currentZoom = _mapController.zoom;
                  _mapController.move(_mapController.center, currentZoom - 1);
                },
                tooltip: 'Zoom Out',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required Color color,
    required VoidCallback onPressed,
    required String tooltip,
  }) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 36,
            height: 36,
            padding: const EdgeInsets.all(6),
            child: Icon(
              icon,
              color: color,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }

  // Floating Action Button untuk konfirmasi lokasi
  Widget _buildConfirmButton() {
    if (widget.isFromTodo == true) return const SizedBox();

    return Positioned(
      bottom: MediaQuery.of(context).padding.bottom + 20,
      left: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF9F7AEA),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF9F7AEA).withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            onTap: () {
              if (_destinationLocation == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: const Text('Pilih lokasi terlebih dahulu'),
                    backgroundColor: Colors.orange,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
                return;
              }

              Navigator.pop(context, {
                'address': _destinationController.text,
                'lat': _destinationLocation!.latitude,
                'lng': _destinationLocation!.longitude,
                'estimatedTime': _estimatedTime,
                'distance': _distance,
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Pilih',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Peta (fullscreen)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: widget.initialLatitude != null &&
                      widget.initialLongitude != null
                  ? LatLng(widget.initialLatitude!, widget.initialLongitude!)
                  : LatLng(-6.200000, 106.816666),
              zoom: widget.zoom ?? 15.0,
              interactiveFlags: InteractiveFlag.all,
              onTap: (tapPosition, latLng) => _onMapTap(latLng),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.todolistapp',
              ),
              if (_showRoute && _polylinePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _polylinePoints,
                      color: const Color(0xFF9F7AEA).withOpacity(0.7),
                      strokeWidth: 4.0,
                      gradientColors: [
                        const Color(0xFF9F7AEA),
                        const Color(0xFFF48FB1),
                      ],
                    ),
                  ],
                ),
              if (_currentLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _currentLocation!,
                      width: 40.0,
                      height: 40.0,
                      builder: (ctx) => Container(
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.red,
                            width: 2,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              if (_destinationLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _destinationLocation!,
                      width: 40.0,
                      height: 40.0,
                      builder: (ctx) => Container(
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.green,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: widget.todoTitle != null
                              ? const Icon(
                                  Icons.task_alt,
                                  color: Colors.green,
                                  size: 20,
                                )
                              : const Icon(
                                  Icons.flag,
                                  color: Colors.green,
                                  size: 20,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // UI Overlays
          _buildCompactSearchBar(), // Search bar minimalis di atas
          _buildFloatingLocationInfo(), // Info lokasi floating kiri atas

          // Kontrol dan info panel (tampil bergantian)
          if (!_showRoute)
            _buildFloatingMapControls() // Map controls (tampil saat tidak ada rute)
          else
            _buildFloatingInfoPanel(), // Info panel rute (tampil saat ada rute)

          _buildFloatingTransportSelector(), // Transport selector bawah kanan
          _buildConfirmButton(), // Tombol konfirmasi bawah kiri

          // Loading overlay
          if (_isLoading)
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF9F7AEA),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Loading...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
