import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sqflite/sqflite.dart';
import 'package:csv/csv.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:io';
import '../models/hospital.dart';
import '../models/real_time_data.dart';
import '../services/hospital_service.dart' as hospital_service;
import '../services/location_service.dart';
import '../screens/hospital_detail_screen.dart';
import '../screens/clinical_card_screen.dart';
import '../screens/health_records_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;
  String? _selectedCounty;
  List<Hospital> _hospitals = [];
  List<Map<String, dynamic>> _clinics = [];
  Database? _database;
  final MapController _mapController = MapController();
  final hospital_service.HospitalService _hospitalService =
      hospital_service.HospitalService();
  final LocationService _locationService = LocationService();
  bool _isLoading = true;
  bool _showEmergencyOnly = false;
  HospitalType? _selectedHospitalType;
  Map<String, RealTimeHospitalData> _realTimeData = {};
  final bool _showFilters = false;
  String _searchQuery = '';
  bool _isConnected = true;
  bool _isRefreshing = false;

  // Search and filter controllers
  final TextEditingController _searchController = TextEditingController();
  final List<HospitalService> _selectedServices = [];
  double _maxDistance = 50.0; // km

  @override
  void initState() {
    super.initState();
    _initDatabase();
    _initializeServices();
    _getCurrentLocation();
    _scheduleNotification();
    _searchController.addListener(_onSearchChanged);
    _checkConnectionStatus();
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  Future<void> _checkConnectionStatus() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      setState(() {
        _isConnected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;
      });
    } catch (_) {
      setState(() {
        _isConnected = false;
      });
    }
  }

  Future<void> _refreshData() async {
    if (!_isConnected) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No internet connection. Using cached data.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    setState(() {
      _isRefreshing = true;
    });

    try {
      await _hospitalService.forceRefresh();
      await _loadInitialData();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data refreshed successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isRefreshing = false;
      });
    }
  }

  Future<void> _initializeServices() async {
    try {
      await _hospitalService.initialize();
      await _loadHospitals();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error initializing services: $e')),
        );
      }
    }
  }

  Future<void> _loadHospitals() async {
    try {
      final hospitals = await _hospitalService.getAllHospitals();
      if (mounted) {
        setState(() {
          _hospitals = hospitals;
        });
        await _loadRealTimeData();
      }
    } catch (e) {
      // Fallback to CSV data if hospital service fails
      await _loadInitialData();
    }
  }

  Future<void> _loadRealTimeData() async {
    final realTimeDataMap = <String, RealTimeHospitalData>{};

    for (final hospital in _hospitals) {
      try {
        final realTimeData =
            await _hospitalService.getHospitalRealTimeData(hospital.id);
        if (realTimeData != null) {
          realTimeDataMap[hospital.id] = realTimeData;
        }
      } catch (e) {
        // Continue loading other hospitals if one fails
      }
    }

    if (mounted) {
      setState(() {
        _realTimeData = realTimeDataMap;
      });
    }
  }

  Future<void> _initDatabase() async {
    _database = await openDatabase(
      'clinic_finder.db',
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE clinics (
            id INTEGER PRIMARY KEY,
            name TEXT,
            county TEXT,
            latitude REAL,
            longitude REAL,
            level INTEGER,
            type TEXT
          )
        ''');
      },
    );
    await _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    if (_database == null) return;

    final count = Sqflite.firstIntValue(
        await _database!.rawQuery('SELECT COUNT(*) FROM clinics'));
    if (count != null && count > 0) return;

    if (mounted) {
      final csvData = await DefaultAssetBundle.of(context)
          .loadString('assets/data/kenya_hospitals.csv');
      final lines = csvData.split('\n');

      for (int i = 1; i < lines.length; i++) {
        final values = lines[i].split(',');
        if (values.length >= 6) {
          await _database!.insert('clinics', {
            'name': values[0].trim(),
            'county': values[1].trim(),
            'latitude': double.tryParse(values[2].trim()) ?? 0.0,
            'longitude': double.tryParse(values[3].trim()) ?? 0.0,
            'level': int.tryParse(values[4].trim()) ?? 1,
            'type': values[5].trim(),
          });
        }
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Location services are disabled')),
          );
        }
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Location permissions are denied')),
            );
          }
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Location permissions are permanently denied')),
          );
        }
        return;
      }

      Position position = await Geolocator.getCurrentPosition();
      if (mounted) {
        setState(() {
          _currentPosition = position;
          _isLoading = false;
        });

        _mapController.move(
            LatLng(position.latitude, position.longitude), 13.0);

        await _loadNearbyClinics();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error getting location: $e')),
        );
      }
    }
  }

  Future<void> _loadNearbyClinics() async {
    if (_database == null || _currentPosition == null) return;

    final clinics = await _database!.query('clinics');
    setState(() {
      _clinics = clinics;
    });
  }

  Future<void> _scheduleNotification() async {
    // Notification scheduling logic
  }

  List<Hospital> _getFilteredHospitals() {
    List<Hospital> filtered = _hospitals;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((hospital) {
        return hospital.name.toLowerCase().contains(query) ||
            hospital.nameSwahili.toLowerCase().contains(query) ||
            hospital.address.toLowerCase().contains(query);
      }).toList();
    }

    if (_selectedCounty != null) {
      filtered = filtered
          .where((hospital) => hospital.address
              .toLowerCase()
              .contains(_selectedCounty!.toLowerCase()))
          .toList();
    }

    if (_selectedHospitalType != null) {
      filtered = filtered
          .where((hospital) => hospital.type == _selectedHospitalType)
          .toList();
    }

    if (_showEmergencyOnly) {
      filtered =
          filtered.where((hospital) => hospital.isEmergencyCapable).toList();
    }

    return filtered;
  }

  List<Map<String, dynamic>> _getFilteredClinics() {
    if (_selectedCounty == null) return _clinics;
    return _clinics
        .where((clinic) => clinic['county'] == _selectedCounty)
        .toList();
  }

  bool _hasActiveFilters() {
    return _searchQuery.isNotEmpty ||
        _selectedHospitalType != null ||
        _selectedServices.isNotEmpty ||
        _showEmergencyOnly ||
        _maxDistance < 100.0;
  }

  void _clearAllFilters() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
      _selectedHospitalType = null;
      _selectedServices.clear();
      _showEmergencyOnly = false;
      _maxDistance = 50.0;
    });
  }

  void _toggleEmergencyMode() {
    setState(() {
      _showEmergencyOnly = !_showEmergencyOnly;
    });
  }

  void _zoomIn() {
    final currentZoom = _mapController.camera.zoom;
    final newZoom = (currentZoom + 1).clamp(5.0, 18.0);
    _mapController.move(_mapController.camera.center, newZoom);
  }

  void _zoomOut() {
    final currentZoom = _mapController.camera.zoom;
    final newZoom = (currentZoom - 1).clamp(5.0, 18.0);
    _mapController.move(_mapController.camera.center, newZoom);
  }

  Marker _buildHospitalMarker(Hospital hospital,
      [RealTimeHospitalData? realTimeData]) {
    return Marker(
      point: LatLng(hospital.latitude, hospital.longitude),
      width: 60,
      height: 60,
      child: GestureDetector(
        onTap: () => _showHospitalDetails(hospital),
        child: Icon(
          Icons.local_hospital,
          color: hospital.isEmergencyCapable ? Colors.red : Colors.blue,
          size: 30,
        ),
      ),
    );
  }

  Marker _buildClinicMarker(Map<String, dynamic> clinic) {
    return Marker(
      point: LatLng(
        clinic['latitude'] as double,
        clinic['longitude'] as double,
      ),
      width: 60,
      height: 60,
      child: GestureDetector(
        onTap: () => _showClinicDetails(clinic),
        child: const Icon(
          Icons.local_hospital,
          color: Colors.green,
          size: 30,
        ),
      ),
    );
  }

  void _showHospitalDetails(Hospital hospital) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HospitalDetailScreen(hospital: hospital),
      ),
    );
  }

  void _showClinicDetails(Map<String, dynamic> clinic) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(clinic['name']),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('County: ${clinic['county']}'),
            Text('Level: ${clinic['level']}'),
            Text('Type: ${clinic['type']}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showProfileDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profile'),
        content: const Text('Profile functionality coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showClinicList() {
    // Implementation for showing clinic list
  }

  void _showClinicalCard() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ClinicalCardScreen()),
    );
  }

  void _showHealthRecords() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HealthRecordsScreen()),
    );
  }

  void _showHealthHub() {
    // Implementation for health hub
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AfyaMap Kenya'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () => _showProfileDialog(),
            icon: const Icon(Icons.person),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Connection Status Bar
                if (!_isConnected)
                  Container(
                    width: double.infinity,
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    color: Colors.orange.shade100,
                    child: Row(
                      children: [
                        Icon(Icons.cloud_off,
                            color: Colors.orange.shade700, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Offline - Using cached data',
                            style: TextStyle(
                              color: Colors.orange.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () async {
                            await _checkConnectionStatus();
                            if (_isConnected) {
                              await _refreshData();
                            }
                          },
                          child: Text(
                            'Retry',
                            style: TextStyle(color: Colors.orange.shade700),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Search Section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          labelText: 'Search hospitals',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Found ${_getFilteredHospitals().length} hospitals',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          if (_hasActiveFilters())
                            TextButton(
                              onPressed: _clearAllFilters,
                              child: const Text('Clear Filters'),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Map Section
                Expanded(
                  child: Stack(
                    children: [
                      FlutterMap(
                        mapController: _mapController,
                        options: MapOptions(
                          initialCenter: _currentPosition != null
                              ? LatLng(_currentPosition!.latitude,
                                  _currentPosition!.longitude)
                              : const LatLng(-1.286389, 36.817223), // Nairobi
                          initialZoom: 13.0,
                          minZoom: 5.0,
                          maxZoom: 18.0,
                          interactionOptions: InteractionOptions(flags: InteractiveFlag.all),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.afyamap.kenya',
                          ),
                          MarkerLayer(
                            markers: [
                              // Current location marker
                              if (_currentPosition != null)
                                Marker(
                                  point: LatLng(_currentPosition!.latitude,
                                      _currentPosition!.longitude),
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.my_location,
                                    color: Colors.blue,
                                    size: 30,
                                  ),
                                ),
                              // Hospital markers
                              ..._getFilteredHospitals().map((hospital) {
                                final realTimeData = _realTimeData[hospital.id];
                                return _buildHospitalMarker(
                                    hospital, realTimeData);
                              }),
                              // Clinic markers (fallback)
                              ..._getFilteredClinics()
                                  .map((clinic) => _buildClinicMarker(clinic)),
                            ],
                          ),
                        ],
                      ),
                      // Zoom Controls
                      Positioned(
                        top: 16,
                        right: 16,
                        child: Column(
                          children: [
                            FloatingActionButton.small(
                              heroTag: "zoom_in",
                              onPressed: _zoomIn,
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              child: const Icon(Icons.add),
                            ),
                            const SizedBox(height: 8),
                            FloatingActionButton.small(
                              heroTag: "zoom_out",
                              onPressed: _zoomOut,
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black87,
                              child: const Icon(Icons.remove),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Tooltip(
            message: 'Emergency Mode',
            child: FloatingActionButton(
              heroTag: "emergency",
              onPressed: _toggleEmergencyMode,
              backgroundColor: _showEmergencyOnly ? Colors.red : Colors.grey,
              child: Icon(
                Icons.emergency,
                color: _showEmergencyOnly ? Colors.white : Colors.black54,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Tooltip(
            message: 'Current Location',
            child: FloatingActionButton(
              heroTag: "location",
              onPressed: _getCurrentLocation,
              backgroundColor: Colors.blue,
              child: const Icon(Icons.my_location, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Tooltip(
            message: 'Clinic List',
            child: FloatingActionButton(
              heroTag: "list",
              onPressed: () {
                _showClinicList();
              },
              backgroundColor: Colors.green,
              child: const Icon(Icons.list, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Tooltip(
            message: 'Clinical Card',
            child: FloatingActionButton(
              heroTag: "card",
              onPressed: () {
                _showClinicalCard();
              },
              backgroundColor: Colors.purple,
              child: const Icon(Icons.credit_card, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Tooltip(
            message: 'Health Records',
            child: FloatingActionButton(
              heroTag: "records",
              onPressed: () {
                _showHealthRecords();
              },
              backgroundColor: Colors.orange,
              child: const Icon(Icons.folder, color: Colors.white),
            ),
          ),
          const SizedBox(height: 8),
          Tooltip(
            message: 'Health Hub',
            child: FloatingActionButton(
              heroTag: "health",
              onPressed: () {
                _showHealthHub();
              },
              backgroundColor: Colors.teal,
              child: const Icon(Icons.health_and_safety, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
