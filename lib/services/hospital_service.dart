import 'package:dio/dio.dart';
import 'dart:io';
import 'dart:convert';
import '../models/hospital.dart' as hospital_model;
import '../models/real_time_data.dart';
import '../models/hospital_review.dart';
import 'location_service.dart';

class HospitalServiceException implements Exception {
  final String message;
  HospitalServiceException(this.message);

  @override
  String toString() => 'HospitalServiceException: $message';
}

class HospitalService {
  static final HospitalService _instance = HospitalService._internal();
  factory HospitalService() => _instance;
  HospitalService._internal();

  final Dio _dio = Dio();
  final LocationService _locationService = LocationService();

  // In-memory caching for fast access only
  final Map<String, hospital_model.Hospital> _hospitalsCache = {};
  final Map<String, RealTimeHospitalData> _realTimeDataCache = {};
  final Map<String, List<HospitalReview>> _reviewsCache = {};
  final Map<String, HospitalRatingSummary> _ratingSummaryCache = {};

  bool _isInitialized = false;

  /// Initialize the hospital service
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Configure Dio
      _dio.options.baseUrl = 'https://api.afyamap.ke';
      _dio.options.connectTimeout = const Duration(seconds: 10);
      _dio.options.receiveTimeout = const Duration(seconds: 10);

      _isInitialized = true;
    } catch (e) {
      throw HospitalServiceException(
          'Failed to initialize hospital service: $e');
    }
  }

  /// Ensure service is initialized
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  /// Check internet connectivity
  Future<bool> _isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  /// Fetch hospitals from API
  Future<List<hospital_model.Hospital>> _fetchHospitalsFromAPI() async {
    try {
      final response = await _dio.get('/hospitals');
      final List<dynamic> data = response.data;
      return data
          .map((json) => hospital_model.Hospital.fromJson(json))
          .toList();
    } catch (e) {
      // Return sample data for testing
      return _getSampleHospitals();
    }
  }

  /// Cache hospitals in memory
  void _cacheHospitals(List<hospital_model.Hospital> hospitals) {
    _hospitalsCache.clear();
    for (final hospital in hospitals) {
      _hospitalsCache[hospital.id] = hospital;
    }
  }

  /// Get sample hospitals for testing
  List<hospital_model.Hospital> _getSampleHospitals() {
    return [
      const hospital_model.Hospital(
        id: '1',
        name: 'Kenyatta National Hospital',
        nameSwahili: 'Hospitali ya Kitaifa ya Kenyatta',
        address: 'Hospital Road, Nairobi',
        latitude: -1.3014,
        longitude: 36.8073,
        phoneNumber: '+254-20-2726300',
        emergencyNumber: '+254-20-2726300',
        email: 'info@knh.or.ke',
        website: 'https://knh.or.ke',
        type: hospital_model.HospitalType.general,
        ownership: hospital_model.HospitalOwnership.public,
        level: hospital_model.HospitalLevel.level6,
        services: [
          hospital_model.HospitalService.emergency,
          hospital_model.HospitalService.surgery,
          hospital_model.HospitalService.laboratory,
        ],
        specialties: [],
        operatingHours: {},
        accreditation: {},
        supportedLanguages: ['English', 'Swahili'],
        isEmergencyCapable: true,
        is24Hours: true,
        hasAmbulanceService: true,
        insuranceProviders: ['NHIF', 'AAR', 'Jubilee'],
        averageRating: 4.2,
        totalReviews: 156,
      ),
    ];
  }

  /// Get all hospitals with optional filtering
  Future<List<hospital_model.Hospital>> getAllHospitals({
    String? county,
    hospital_model.HospitalType? type,
    hospital_model.HospitalOwnership? ownership,
    List<hospital_model.HospitalService>? requiredServices,
    bool emergencyOnly = false,
  }) async {
    await _ensureInitialized();

    try {
      List<hospital_model.Hospital> hospitals;

      // Try to get from API first
      hospitals = await _fetchHospitalsFromAPI();
      _cacheHospitals(hospitals);

      // Apply filters
      return _filterHospitals(
        hospitals,
        county: county,
        type: type,
        ownership: ownership,
        requiredServices: requiredServices,
        emergencyOnly: emergencyOnly,
      );
    } catch (e) {
      // Fallback to cached data on error
      final cachedHospitals = _hospitalsCache.values.toList();
      return _filterHospitals(
        cachedHospitals,
        county: county,
        type: type,
        ownership: ownership,
        requiredServices: requiredServices,
        emergencyOnly: emergencyOnly,
      );
    }
  }

  List<hospital_model.Hospital> _filterHospitals(
    List<hospital_model.Hospital> hospitals, {
    String? county,
    hospital_model.HospitalType? type,
    hospital_model.HospitalOwnership? ownership,
    List<hospital_model.HospitalService>? requiredServices,
    bool emergencyOnly = false,
  }) {
    return hospitals.where((hospital) {
      if (county != null &&
          !hospital.address.toLowerCase().contains(county.toLowerCase())) {
        return false;
      }
      if (type != null && hospital.type != type) {
        return false;
      }
      if (ownership != null && hospital.ownership != ownership) {
        return false;
      }
      if (emergencyOnly && !hospital.isEmergencyCapable) {
        return false;
      }

      if (requiredServices != null && requiredServices.isNotEmpty) {
        for (final service in requiredServices) {
          if (!hospital.services.contains(service)) {
            return false;
          }
        }
      }

      return true; // All hospitals are considered active by default
    }).toList();
  }

  /// Get nearby hospitals within specified radius
  Future<List<hospital_model.Hospital>> getNearbyHospitals(
    double latitude,
    double longitude, {
    double radiusKm = 25.0,
    String? county,
    hospital_model.HospitalType? type,
    List<hospital_model.HospitalService>? requiredServices,
    bool emergencyOnly = false,
  }) async {
    final allHospitals = await getAllHospitals(
      county: county,
      type: type,
      requiredServices: requiredServices,
      emergencyOnly: emergencyOnly,
    );

    // Filter by distance and sort by proximity
    final nearbyHospitals = allHospitals
        .where((hospital) => _locationService.isWithinRadius(
              latitude,
              longitude,
              hospital.latitude,
              hospital.longitude,
              radiusKm,
            ))
        .toList();

    // Sort by distance
    nearbyHospitals.sort((a, b) {
      final distanceA = _locationService.calculateDistance(
          latitude, longitude, a.latitude, a.longitude);
      final distanceB = _locationService.calculateDistance(
          latitude, longitude, b.latitude, b.longitude);
      return distanceA.compareTo(distanceB);
    });

    return nearbyHospitals;
  }

  /// Get hospital real-time data
  Future<RealTimeHospitalData?> getHospitalRealTimeData(
      String hospitalId) async {
    await _ensureInitialized();

    // Check cache first
    if (_realTimeDataCache.containsKey(hospitalId)) {
      return _realTimeDataCache[hospitalId];
    }

    try {
      if (await _isConnected()) {
        final response = await _dio.get('/hospitals/$hospitalId/realtime');
        final data = RealTimeHospitalData.fromJson(response.data);
        _realTimeDataCache[hospitalId] = data;
        return data;
      }
    } catch (e) {
      // Return null if no cached data
      return null;
    }

    return null;
  }

  /// Get hospital reviews
  Future<List<HospitalReview>> getHospitalReviews(String hospitalId) async {
    await _ensureInitialized();

    // Check cache first
    if (_reviewsCache.containsKey(hospitalId)) {
      return _reviewsCache[hospitalId]!;
    }

    try {
      if (await _isConnected()) {
        final response = await _dio.get('/hospitals/$hospitalId/reviews');
        final List<dynamic> data = response.data;
        final reviews =
            data.map((json) => HospitalReview.fromJson(json)).toList();
        _reviewsCache[hospitalId] = reviews;
        return reviews;
      }
    } catch (e) {
      // Return empty list if no cached data
      return [];
    }

    return [];
  }

  /// Force refresh hospital data cache
  Future<void> forceRefresh() async {
    await _ensureInitialized();
    final hospitals = await _fetchHospitalsFromAPI();
    _cacheHospitals(hospitals);
  }

  /// Submit a hospital review
  Future<bool> submitHospitalReview(HospitalReview review) async {
    await _ensureInitialized();

    try {
      if (await _isConnected()) {
        final response = await _dio.post(
          '/hospitals/${review.hospitalId}/reviews',
          data: review.toJson(),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          // Update cache with new review
          final hospitalId = review.hospitalId;
          final currentReviews = _reviewsCache[hospitalId] ?? [];
          _reviewsCache[hospitalId] = [...currentReviews, review];
          return true;
        }
      }
    } catch (e) {
      // Log or handle error if needed
    }
    return false;
  }
}
