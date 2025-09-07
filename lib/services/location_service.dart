import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Position? _lastKnownPosition;
  DateTime? _lastLocationUpdate;

  /// Get current location with proper permission handling
  Future<Position?> getCurrentLocation({bool forceRefresh = false}) async {
    try {
      // Check if we have a recent cached location and don't need to force refresh
      if (!forceRefresh &&
          _lastKnownPosition != null &&
          _lastLocationUpdate != null &&
          DateTime.now().difference(_lastLocationUpdate!).inMinutes < 5) {
        return _lastKnownPosition;
      }

      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw LocationServiceDisabledException(
            'Location services are disabled');
      }

      // Check and request permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw LocationPermissionDeniedException(
              'Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw LocationPermissionDeniedException(
            'Location permissions are permanently denied, we cannot request permissions.');
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      // Cache the position
      _lastKnownPosition = position;
      _lastLocationUpdate = DateTime.now();

      return position;
    } catch (e) {
      // Try to return last known position if available
      if (_lastKnownPosition != null) {
        return _lastKnownPosition;
      }
      rethrow;
    }
  }

  /// Get last known position without requesting new location
  Position? getLastKnownPosition() {
    return _lastKnownPosition;
  }

  /// Check if location permissions are granted
  Future<bool> hasLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// Request location permissions
  Future<bool> requestLocationPermission() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever) {
        // Open app settings for user to manually enable permissions
        await Geolocator.openAppSettings();
        return false;
      }

      return permission == LocationPermission.always ||
          permission == LocationPermission.whileInUse;
    } catch (e) {
      return false;
    }
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Open location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Calculate distance between two points in kilometers
  double calculateDistance(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
          startLatitude,
          startLongitude,
          endLatitude,
          endLongitude,
        ) /
        1000; // Convert meters to kilometers
  }

  /// Get location stream for real-time updates
  Stream<Position> getLocationStream({
    LocationAccuracy accuracy = LocationAccuracy.high,
    int distanceFilter = 10, // meters
    Duration interval = const Duration(seconds: 5),
  }) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: accuracy,
        distanceFilter: distanceFilter,
      ),
    );
  }

  /// Check if a point is within a radius of another point
  bool isWithinRadius(
    double centerLat,
    double centerLng,
    double pointLat,
    double pointLng,
    double radiusKm,
  ) {
    double distance =
        calculateDistance(centerLat, centerLng, pointLat, pointLng);
    return distance <= radiusKm;
  }

  /// Get bearing between two points
  double getBearing(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.bearingBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Format distance for display
  String formatDistance(double distanceKm) {
    if (distanceKm < 1) {
      return '${(distanceKm * 1000).round()}m';
    } else if (distanceKm < 10) {
      return '${distanceKm.toStringAsFixed(1)}km';
    } else {
      return '${distanceKm.round()}km';
    }
  }

  /// Get location accuracy description
  String getAccuracyDescription(double accuracy) {
    if (accuracy <= 5) return 'Excellent';
    if (accuracy <= 10) return 'Good';
    if (accuracy <= 20) return 'Fair';
    return 'Poor';
  }

  /// Clear cached location data
  void clearCache() {
    _lastKnownPosition = null;
    _lastLocationUpdate = null;
  }

  /// Get location status for debugging
  Future<LocationStatus> getLocationStatus() async {
    bool serviceEnabled = await isLocationServiceEnabled();
    bool permissionGranted = await hasLocationPermission();
    Position? lastPosition = getLastKnownPosition();

    return LocationStatus(
      serviceEnabled: serviceEnabled,
      permissionGranted: permissionGranted,
      lastKnownPosition: lastPosition,
      lastUpdate: _lastLocationUpdate,
    );
  }
}

class LocationStatus {
  final bool serviceEnabled;
  final bool permissionGranted;
  final Position? lastKnownPosition;
  final DateTime? lastUpdate;

  LocationStatus({
    required this.serviceEnabled,
    required this.permissionGranted,
    this.lastKnownPosition,
    this.lastUpdate,
  });

  bool get isReady => serviceEnabled && permissionGranted;
  bool get hasRecentLocation =>
      lastKnownPosition != null &&
      lastUpdate != null &&
      DateTime.now().difference(lastUpdate!).inMinutes < 10;

  @override
  String toString() {
    return 'LocationStatus(serviceEnabled: $serviceEnabled, permissionGranted: $permissionGranted, hasRecentLocation: $hasRecentLocation)';
  }
}

class LocationServiceDisabledException implements Exception {
  final String message;
  LocationServiceDisabledException(this.message);

  @override
  String toString() => 'LocationServiceDisabledException: $message';
}

class LocationPermissionDeniedException implements Exception {
  final String message;
  LocationPermissionDeniedException(this.message);

  @override
  String toString() => 'LocationPermissionDeniedException: $message';
}
