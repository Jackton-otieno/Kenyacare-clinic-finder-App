class Hospital {
  final String id;
  final String name;
  final String nameSwahili;
  final String address;
  final double latitude;
  final double longitude;
  final String phoneNumber;
  final String? emergencyNumber;
  final String? email;
  final String? website;
  final HospitalType type;
  final HospitalOwnership ownership;
  final HospitalLevel level;
  final List<HospitalService> services;
  final List<MedicalSpecialty> specialties;
  final int? bedCapacity;
  final Map<String, String> operatingHours;
  final Map<String, AccreditationStatus> accreditation;
  final List<String> supportedLanguages;
  final String? imageUrl;
  final double averageRating;
  final int totalReviews;
  final bool isEmergencyCapable;
  final bool is24Hours;
  final bool hasAmbulanceService;
  final bool hasPharmacy;
  final bool hasLaboratory;
  final bool hasRadiology;
  final bool acceptsInsurance;
  final List<String> insuranceProviders;
  final DateTime? lastUpdated;
  final double? distance;

  const Hospital({
    required this.id,
    required this.name,
    required this.nameSwahili,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.phoneNumber,
    this.emergencyNumber,
    this.email,
    this.website,
    required this.type,
    required this.ownership,
    required this.level,
    required this.services,
    required this.specialties,
    this.bedCapacity,
    required this.operatingHours,
    required this.accreditation,
    required this.supportedLanguages,
    this.imageUrl,
    this.averageRating = 0.0,
    this.totalReviews = 0,
    this.isEmergencyCapable = false,
    this.is24Hours = false,
    this.hasAmbulanceService = false,
    this.hasPharmacy = false,
    this.hasLaboratory = false,
    this.hasRadiology = false,
    this.acceptsInsurance = false,
    this.insuranceProviders = const [],
    this.lastUpdated,
    this.distance,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'nameSwahili': nameSwahili,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'phoneNumber': phoneNumber,
      'emergencyNumber': emergencyNumber,
      'email': email,
      'website': website,
      'type': type.index,
      'ownership': ownership.index,
      'level': level.index,
      'services': services.map((e) => e.index).toList(),
      'specialties': specialties.map((e) => e.index).toList(),
      'bedCapacity': bedCapacity,
      'operatingHours': operatingHours,
      'accreditation':
          accreditation.map((key, value) => MapEntry(key, value.index)),
      'supportedLanguages': supportedLanguages,
      'imageUrl': imageUrl,
      'averageRating': averageRating,
      'totalReviews': totalReviews,
      'isEmergencyCapable': isEmergencyCapable,
      'is24Hours': is24Hours,
      'hasAmbulanceService': hasAmbulanceService,
      'hasPharmacy': hasPharmacy,
      'hasLaboratory': hasLaboratory,
      'hasRadiology': hasRadiology,
      'acceptsInsurance': acceptsInsurance,
      'insuranceProviders': insuranceProviders,
      'lastUpdated': lastUpdated?.toIso8601String(),
      'distance': distance,
    };
  }

  factory Hospital.fromJson(Map<String, dynamic> json) {
    return Hospital(
      id: json['id'],
      name: json['name'],
      nameSwahili: json['nameSwahili'],
      address: json['address'],
      latitude: json['latitude'].toDouble(),
      longitude: json['longitude'].toDouble(),
      phoneNumber: json['phoneNumber'],
      emergencyNumber: json['emergencyNumber'],
      email: json['email'],
      website: json['website'],
      type: HospitalType.values[json['type']],
      ownership: HospitalOwnership.values[json['ownership']],
      level: HospitalLevel.values[json['level']],
      services: (json['services'] as List)
          .map((e) => HospitalService.values[e])
          .toList(),
      specialties: (json['specialties'] as List)
          .map((e) => MedicalSpecialty.values[e])
          .toList(),
      bedCapacity: json['bedCapacity'],
      operatingHours: Map<String, String>.from(json['operatingHours']),
      accreditation: (json['accreditation'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, AccreditationStatus.values[value]),
      ),
      supportedLanguages: List<String>.from(json['supportedLanguages']),
      imageUrl: json['imageUrl'],
      averageRating: json['averageRating']?.toDouble() ?? 0.0,
      totalReviews: json['totalReviews'] ?? 0,
      isEmergencyCapable: json['isEmergencyCapable'] ?? false,
      is24Hours: json['is24Hours'] ?? false,
      hasAmbulanceService: json['hasAmbulanceService'] ?? false,
      hasPharmacy: json['hasPharmacy'] ?? false,
      hasLaboratory: json['hasLaboratory'] ?? false,
      hasRadiology: json['hasRadiology'] ?? false,
      acceptsInsurance: json['acceptsInsurance'] ?? false,
      insuranceProviders: List<String>.from(json['insuranceProviders'] ?? []),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
      distance: json['distance']?.toDouble(),
    );
  }

  Hospital copyWith({
    String? id,
    String? name,
    String? nameSwahili,
    String? address,
    double? latitude,
    double? longitude,
    String? phoneNumber,
    String? emergencyNumber,
    String? email,
    String? website,
    HospitalType? type,
    HospitalOwnership? ownership,
    HospitalLevel? level,
    List<HospitalService>? services,
    List<MedicalSpecialty>? specialties,
    int? bedCapacity,
    Map<String, String>? operatingHours,
    Map<String, AccreditationStatus>? accreditation,
    List<String>? supportedLanguages,
    String? imageUrl,
    double? averageRating,
    int? totalReviews,
    bool? isEmergencyCapable,
    bool? is24Hours,
    bool? hasAmbulanceService,
    bool? hasPharmacy,
    bool? hasLaboratory,
    bool? hasRadiology,
    bool? acceptsInsurance,
    List<String>? insuranceProviders,
    DateTime? lastUpdated,
    double? distance,
  }) {
    return Hospital(
      id: id ?? this.id,
      name: name ?? this.name,
      nameSwahili: nameSwahili ?? this.nameSwahili,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      emergencyNumber: emergencyNumber ?? this.emergencyNumber,
      email: email ?? this.email,
      website: website ?? this.website,
      type: type ?? this.type,
      ownership: ownership ?? this.ownership,
      level: level ?? this.level,
      services: services ?? this.services,
      specialties: specialties ?? this.specialties,
      bedCapacity: bedCapacity ?? this.bedCapacity,
      operatingHours: operatingHours ?? this.operatingHours,
      accreditation: accreditation ?? this.accreditation,
      supportedLanguages: supportedLanguages ?? this.supportedLanguages,
      imageUrl: imageUrl ?? this.imageUrl,
      averageRating: averageRating ?? this.averageRating,
      totalReviews: totalReviews ?? this.totalReviews,
      isEmergencyCapable: isEmergencyCapable ?? this.isEmergencyCapable,
      is24Hours: is24Hours ?? this.is24Hours,
      hasAmbulanceService: hasAmbulanceService ?? this.hasAmbulanceService,
      hasPharmacy: hasPharmacy ?? this.hasPharmacy,
      hasLaboratory: hasLaboratory ?? this.hasLaboratory,
      hasRadiology: hasRadiology ?? this.hasRadiology,
      acceptsInsurance: acceptsInsurance ?? this.acceptsInsurance,
      insuranceProviders: insuranceProviders ?? this.insuranceProviders,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      distance: distance ?? this.distance,
    );
  }

  String get displayName => name;
  String get localizedName => nameSwahili.isNotEmpty ? nameSwahili : name;

  bool get hasEmergencyServices =>
      isEmergencyCapable && emergencyNumber != null;
  bool get isCurrentlyOpen {
    final now = DateTime.now();
    final dayName = _getDayName(now.weekday);
    final hours = operatingHours[dayName];

    if (hours == null || hours.toLowerCase() == 'closed') return false;
    if (hours.toLowerCase() == '24 hours' || is24Hours) return true;

    // Parse hours like "08:00-17:00"
    final parts = hours.split('-');
    if (parts.length != 2) return false;

    try {
      final openTime = _parseTime(parts[0].trim());
      final closeTime = _parseTime(parts[1].trim());
      final currentTime = now.hour * 60 + now.minute;

      return currentTime >= openTime && currentTime <= closeTime;
    } catch (e) {
      return false;
    }
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }

  int _parseTime(String timeStr) {
    final parts = timeStr.split(':');
    if (parts.length != 2) throw const FormatException('Invalid time format');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}

enum HospitalType {
  general,
  specialized,
  teaching,
  referral,
  district,
  private,
  mission,
  military,
}

enum HospitalOwnership {
  public,
  private,
  faithBased,
  ngo,
  military,
  corporate,
}

enum HospitalLevel {
  level1,
  level2,
  level3,
  level4,
  level5,
  level6,
}

enum HospitalService {
  emergency,
  outpatient,
  inpatient,
  surgery,
  maternity,
  pediatrics,
  icu,
  laboratory,
  radiology,
  pharmacy,
  ambulance,
  bloodBank,
  dialysis,
  physiotherapy,
  mentalHealth,
  dental,
  ophthalmology,
  oncology,
  cardiology,
  orthopedics,
}

enum MedicalSpecialty {
  generalMedicine,
  surgery,
  pediatrics,
  obstetrics,
  gynecology,
  orthopedics,
  cardiology,
  neurology,
  psychiatry,
  dermatology,
  ophthalmology,
  ent,
  urology,
  oncology,
  radiology,
  pathology,
  anesthesiology,
  emergencyMedicine,
  familyMedicine,
  internalMedicine,
}

enum AccreditationStatus {
  accredited,
  provisionallyAccredited,
  notAccredited,
  pending,
  expired,
}
