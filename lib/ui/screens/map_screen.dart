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
  final bool?
      isFromTodo; // TAMBAHAN: Flag untuk menentukan jika datang dari todo

  const MapScreen({
    Key? key,
    this.initialLatitude,
    this.initialLongitude,
    this.todoTitle,
    this.zoom,
    this.isFromTodo = false, // Default false
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

    // TAMBAHAN: Inisialisasi dengan lokasi dari todo jika ada
    _initializeWithTodoLocation();
  }

  // TAMBAHAN: Fungsi untuk inisialisasi dengan lokasi todo
  void _initializeWithTodoLocation() async {
    if (widget.initialLatitude != null && widget.initialLongitude != null) {
      // Set destination location dari todo
      _destinationLocation = LatLng(
        widget.initialLatitude!,
        widget.initialLongitude!,
      );

      // Dapatkan alamat dari lokasi todo
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
        _destinationController.text = 'Lokasi Tugas';
      }

      // Dapatkan lokasi saat ini dan hitung rute
      await _getCurrentLocation();

      // Jika isFromTodo true, set center ke lokasi todo
      if (widget.isFromTodo == true) {
        _mapController.move(_destinationLocation!, widget.zoom ?? 15.0);
      }
    } else {
      // Jika tidak ada lokasi todo, ambil lokasi saat ini
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

      // TAMBAHAN: Jika ada lokasi todo, hitung rute
      if (_destinationLocation != null && _currentLocation != null) {
        _calculateRoute();
      } else {
        _mapController.move(latLng, widget.zoom ?? 15.0);
      }
    } catch (e) {
      setState(() {
        _address = 'Gagal mendapatkan lokasi: $e';
      });
    }
  }

  Future<void> _searchAddress(String query) async {
    if (query.length < 3) {
      setState(() {
        _searchResults = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
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
    });

    if (_currentLocation != null) {
      final centerLat = (_currentLocation!.latitude + latLng.latitude) / 2;
      final centerLng = (_currentLocation!.longitude + latLng.longitude) / 2;
      _mapController.move(LatLng(centerLat, centerLng), 13.0);
    } else {
      _mapController.move(latLng, 13.0);
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
      } else {
        _calculateStraightLineDistance();
      }
    } catch (e) {
      print('Error calculating route: $e');
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
  }

  void _clearDestination() {
    setState(() {
      _destinationLocation = null;
      _destinationController.clear();
      _showRoute = false;
      _polylinePoints.clear();
      _distance = 0.0;
      _searchResults = [];
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

  // TAMBAHAN: Widget untuk menampilkan judul todo jika ada
  Widget _buildTodoHeader() {
    if (widget.todoTitle == null) return const SizedBox();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      top: 90,
      left: 16,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF9F7AEA).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.task_alt,
                  color: Color(0xFF9F7AEA),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Lokasi Tugas',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      widget.todoTitle!,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      maxLines: 1,
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
  }

  Widget _buildSearchBar() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final topPosition = widget.todoTitle != null ? 150.0 : 16.0;

    return Positioned(
      top: topPosition,
      left: 16,
      right: 16,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          color: isDarkMode ? Colors.grey.shade900 : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                children: [
                  const SizedBox(width: 8),
                  Icon(Icons.search,
                      color: isDarkMode
                          ? Colors.grey.shade300
                          : Colors.grey.shade600),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _destinationController,
                      decoration: InputDecoration(
                        hintText: 'Cari alamat tujuan...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                            color: isDarkMode
                                ? Colors.grey.shade400
                                : Colors.grey.shade600),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                      onChanged: (value) {
                        _searchAddress(value);
                      },
                      onSubmitted: (value) {
                        if (value.isNotEmpty) {
                          _searchAddress(value);
                        }
                      },
                    ),
                  ),
                  if (_destinationController.text.isNotEmpty)
                    IconButton(
                      icon: const Icon(Icons.clear, color: Colors.red),
                      onPressed: () {
                        _destinationController.clear();
                        _clearDestination();
                      },
                    ),
                  const SizedBox(width: 8),
                ],
              ),
              if (_isSearching)
                const Padding(
                  padding: EdgeInsets.all(8),
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF9F7AEA),
                    ),
                  ),
                ),
              if (_searchResults.isNotEmpty)
                Container(
                  constraints: const BoxConstraints(maxHeight: 200),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                      ),
                    ],
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final result = _searchResults[index];
                      return Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            _selectSearchResult(result);
                          },
                          borderRadius: BorderRadius.circular(8),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: index < _searchResults.length - 1
                                  ? Border(
                                      bottom: BorderSide(
                                        color: isDarkMode
                                            ? Colors.grey.shade700
                                            : Colors.grey.shade300,
                                        width: 0.5,
                                      ),
                                    )
                                  : null,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.location_on,
                                  color: isDarkMode
                                      ? Colors.grey.shade300
                                      : const Color(0xFF9F7AEA),
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        result['displayName'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color: isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${result['lat'].toStringAsFixed(4)}, ${result['lon'].toStringAsFixed(4)}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: isDarkMode
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade600,
                                        ),
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
      ),
    );
  }

  Widget _buildTransportSelector() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final topPosition = widget.todoTitle != null ? 230.0 : 110.0;

    return Positioned(
      top: topPosition,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildTransportButton(
                icon: Icons.directions_walk,
                label: 'Jalan',
                isSelected: _selectedTransport == 'walking',
                color: const Color(0xFF4CAF50),
                onTap: () {
                  setState(() => _selectedTransport = 'walking');
                  if (_destinationLocation != null) _calculateRoute();
                },
              ),
              _buildTransportButton(
                icon: Icons.directions_bike,
                label: 'Sepeda',
                isSelected: _selectedTransport == 'cycling',
                color: const Color(0xFF2196F3),
                onTap: () {
                  setState(() => _selectedTransport = 'cycling');
                  if (_destinationLocation != null) _calculateRoute();
                },
              ),
              _buildTransportButton(
                icon: Icons.directions_car,
                label: 'Mobil',
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
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? color
                      : (isDarkMode
                          ? Colors.grey.shade800
                          : Colors.grey.shade200),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : (isDarkMode
                          ? Colors.grey.shade300
                          : Colors.grey.shade700),
                  size: 20,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: isSelected
                      ? color
                      : (isDarkMode
                          ? Colors.grey.shade300
                          : Colors.grey.shade700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRouteInfoCard() {
    if (!_showRoute || _destinationLocation == null) return const SizedBox();

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    String transportText;
    Color transportColor;
    IconData transportIcon;

    switch (_selectedTransport) {
      case 'walking':
        transportText = 'Jalan Kaki';
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
      bottom: 120,
      left: 16,
      right: 16,
      child: ScaleTransition(
        scale: _animation,
        child: Material(
          color: Colors.transparent,
          child: Container(
            decoration: BoxDecoration(
              color: isDarkMode ? Colors.grey.shade900 : Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: transportColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              transportIcon,
                              color: transportColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.todoTitle != null
                                    ? 'Rute ke Lokasi Tugas'
                                    : 'Rute ke Tujuan',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      isDarkMode ? Colors.white : Colors.black,
                                ),
                              ),
                              Text(
                                transportText,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDarkMode
                                      ? Colors.grey.shade400
                                      : Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.red,
                            size: 16,
                          ),
                        ),
                        onPressed: _clearDestination,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Jarak Tempuh',
                            style: TextStyle(
                              fontSize: 12,
                              color: isDarkMode
                                  ? Colors.grey.shade400
                                  : Colors.grey.shade600,
                            ),
                          ),
                          Text(
                            '${_distance.toStringAsFixed(2)} km',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: isDarkMode
                                  ? Colors.white
                                  : const Color(0xFF3B417A),
                            ),
                          ),
                        ],
                      ),
                      ElevatedButton.icon(
                        onPressed: _calculateRoute,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF9F7AEA),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                        icon: const Icon(Icons.refresh, size: 16),
                        label: const Text(
                          'Hitung Ulang',
                          style: TextStyle(fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final topPosition = widget.todoTitle != null ? 230.0 : 110.0;

    return Positioned(
      top: topPosition,
      left: 16,
      right: 90,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Color(0xFF2196F3),
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _address,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: isDarkMode ? Colors.white : Colors.black,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Consumer<WeatherProvider>(
                  builder: (context, weatherProvider, child) {
                    if (weatherProvider.weather == null) {
                      return const SizedBox();
                    }
                    return Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF9800).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.thermostat,
                            color: Color(0xFFFF9800),
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${weatherProvider.weather!.temperature}°C',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.air,
                            color: Color(0xFF4CAF50),
                            size: 14,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${weatherProvider.weather!.windSpeed} km/h',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDarkMode ? Colors.white : Colors.black,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMapControls() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      bottom: 100,
      right: 16,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade900 : Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            children: [
              _buildControlButton(
                icon: Icons.my_location,
                color: const Color(0xFF2196F3),
                onPressed: _getCurrentLocation,
                tooltip: 'Lokasi Saya',
              ),
              const SizedBox(height: 8),
              _buildControlButton(
                icon: Icons.add,
                color: const Color(0xFF4CAF50),
                onPressed: () {
                  final currentZoom = _mapController.zoom;
                  _mapController.move(_mapController.center, currentZoom + 1);
                },
                tooltip: 'Zoom In',
              ),
              const SizedBox(height: 8),
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
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDarkMode ? Colors.grey.shade800 : color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
      ),
    );
  }

  // TAMBAHAN: Fungsi untuk menentukan judul AppBar
  String _getAppBarTitle() {
    if (widget.todoTitle != null) {
      return 'Lokasi: ${widget.todoTitle}';
    }
    return 'Peta & Navigasi';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.map, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 12),
            Text(
              _getAppBarTitle(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.white,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF9F7AEA),
                Color(0xFF667EEA),
              ],
            ),
          ),
        ),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        actions: [
          if (widget.isFromTodo == true)
            IconButton(
              icon: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child:
                    const Icon(Icons.arrow_back, size: 20, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
              tooltip: 'Kembali',
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              center: widget.initialLatitude != null &&
                      widget.initialLongitude != null
                  ? LatLng(widget.initialLatitude!, widget.initialLongitude!)
                  : LatLng(-6.200000, 106.816666),
              zoom: widget.zoom ?? 12.0,
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
                      color: const Color(0xFF9F7AEA).withOpacity(0.8),
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
                      width: 60.0,
                      height: 60.0,
                      builder: (ctx) => ScaleTransition(
                        scale: Tween(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.elasticOut,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red,
                              width: 2,
                            ),
                          ),
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 30,
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
                      width: 60.0,
                      height: 60.0,
                      builder: (ctx) => ScaleTransition(
                        scale: Tween(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Curves.elasticOut,
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.2),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.green,
                              width: 2,
                            ),
                          ),
                          child: widget.todoTitle != null
                              ? const Icon(
                                  Icons.task_alt,
                                  color: Colors.green,
                                  size: 30,
                                )
                              : const Icon(
                                  Icons.flag,
                                  color: Colors.green,
                                  size: 30,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
          if (_isLoading)
            Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: isDarkMode ? Colors.grey.shade900 : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(
                      color: Color(0xFF9F7AEA),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.todoTitle != null
                          ? 'Memuat lokasi tugas...'
                          : 'Mengambil lokasi...',
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          _buildTodoHeader(), // TAMBAHAN
          _buildSearchBar(),
          _buildLocationCard(),
          _buildTransportSelector(),
          _buildRouteInfoCard(),
          _buildMapControls(),
        ],
      ),
      floatingActionButton: widget.isFromTodo == true
          ? null // Sembunyikan FAB jika dari todo
          : FloatingActionButton(
              onPressed: () {
                if (_destinationLocation == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Silakan pilih lokasi terlebih dahulu'),
                    ),
                  );
                  return;
                }

                Navigator.pop(context, {
                  'address': _destinationController.text,
                  'lat': _destinationLocation!.latitude,
                  'lng': _destinationLocation!.longitude,
                });
              },
              backgroundColor: const Color(0xFF9F7AEA),
              foregroundColor: Colors.white,
              elevation: 4,
              child: const Icon(Icons.check),
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
