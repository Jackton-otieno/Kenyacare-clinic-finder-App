class RealTimeHospitalData {
  final String hospitalId;
  final int generalBedsAvailable;
  final int generalBedsTotal;
  final int icuBedsAvailable;
  final int icuBedsTotal;
  final int emergencyBedsAvailable;
  final int emergencyBedsTotal;
  final int emergencyWaitTime;
  final int outpatientWaitTime;
  final OperationalStatus operationalStatus;
  final EmergencyLevel emergencyLevel;
  final Map<String, ServiceStatus> serviceStatus;
  final Map<String, int> staffAvailability;
  final Map<String, EquipmentStatus> equipmentStatus;
  final DateTime lastUpdated;
  final String? notes;

  const RealTimeHospitalData({
    required this.hospitalId,
    required this.generalBedsAvailable,
    required this.generalBedsTotal,
    required this.icuBedsAvailable,
    required this.icuBedsTotal,
    required this.emergencyBedsAvailable,
    required this.emergencyBedsTotal,
    required this.emergencyWaitTime,
    required this.outpatientWaitTime,
    required this.operationalStatus,
    required this.emergencyLevel,
    required this.serviceStatus,
    required this.staffAvailability,
    required this.equipmentStatus,
    required this.lastUpdated,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'hospitalId': hospitalId,
      'generalBedsAvailable': generalBedsAvailable,
      'generalBedsTotal': generalBedsTotal,
      'icuBedsAvailable': icuBedsAvailable,
      'icuBedsTotal': icuBedsTotal,
      'emergencyBedsAvailable': emergencyBedsAvailable,
      'emergencyBedsTotal': emergencyBedsTotal,
      'emergencyWaitTime': emergencyWaitTime,
      'outpatientWaitTime': outpatientWaitTime,
      'operationalStatus': operationalStatus.index,
      'emergencyLevel': emergencyLevel.index,
      'serviceStatus':
          serviceStatus.map((key, value) => MapEntry(key, value.index)),
      'staffAvailability': staffAvailability,
      'equipmentStatus':
          equipmentStatus.map((key, value) => MapEntry(key, value.index)),
      'lastUpdated': lastUpdated.toIso8601String(),
      'notes': notes,
    };
  }

  factory RealTimeHospitalData.fromJson(Map<String, dynamic> json) {
    return RealTimeHospitalData(
      hospitalId: json['hospitalId'],
      generalBedsAvailable: json['generalBedsAvailable'],
      generalBedsTotal: json['generalBedsTotal'],
      icuBedsAvailable: json['icuBedsAvailable'],
      icuBedsTotal: json['icuBedsTotal'],
      emergencyBedsAvailable: json['emergencyBedsAvailable'],
      emergencyBedsTotal: json['emergencyBedsTotal'],
      emergencyWaitTime: json['emergencyWaitTime'],
      outpatientWaitTime: json['outpatientWaitTime'],
      operationalStatus: OperationalStatus.values[json['operationalStatus']],
      emergencyLevel: EmergencyLevel.values[json['emergencyLevel']],
      serviceStatus: (json['serviceStatus'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, ServiceStatus.values[value]),
      ),
      staffAvailability: Map<String, int>.from(json['staffAvailability']),
      equipmentStatus: (json['equipmentStatus'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, EquipmentStatus.values[value]),
      ),
      lastUpdated: DateTime.parse(json['lastUpdated']),
      notes: json['notes'],
    );
  }

  RealTimeHospitalData copyWith({
    String? hospitalId,
    int? generalBedsAvailable,
    int? generalBedsTotal,
    int? icuBedsAvailable,
    int? icuBedsTotal,
    int? emergencyBedsAvailable,
    int? emergencyBedsTotal,
    int? emergencyWaitTime,
    int? outpatientWaitTime,
    OperationalStatus? operationalStatus,
    EmergencyLevel? emergencyLevel,
    Map<String, ServiceStatus>? serviceStatus,
    Map<String, int>? staffAvailability,
    Map<String, EquipmentStatus>? equipmentStatus,
    DateTime? lastUpdated,
    String? notes,
  }) {
    return RealTimeHospitalData(
      hospitalId: hospitalId ?? this.hospitalId,
      generalBedsAvailable: generalBedsAvailable ?? this.generalBedsAvailable,
      generalBedsTotal: generalBedsTotal ?? this.generalBedsTotal,
      icuBedsAvailable: icuBedsAvailable ?? this.icuBedsAvailable,
      icuBedsTotal: icuBedsTotal ?? this.icuBedsTotal,
      emergencyBedsAvailable:
          emergencyBedsAvailable ?? this.emergencyBedsAvailable,
      emergencyBedsTotal: emergencyBedsTotal ?? this.emergencyBedsTotal,
      emergencyWaitTime: emergencyWaitTime ?? this.emergencyWaitTime,
      outpatientWaitTime: outpatientWaitTime ?? this.outpatientWaitTime,
      operationalStatus: operationalStatus ?? this.operationalStatus,
      emergencyLevel: emergencyLevel ?? this.emergencyLevel,
      serviceStatus: serviceStatus ?? this.serviceStatus,
      staffAvailability: staffAvailability ?? this.staffAvailability,
      equipmentStatus: equipmentStatus ?? this.equipmentStatus,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      notes: notes ?? this.notes,
    );
  }

  double get generalBedOccupancyRate {
    if (generalBedsTotal == 0) return 0.0;
    return (generalBedsTotal - generalBedsAvailable) / generalBedsTotal;
  }

  double get icuBedOccupancyRate {
    if (icuBedsTotal == 0) return 0.0;
    return (icuBedsTotal - icuBedsAvailable) / icuBedsTotal;
  }

  double get emergencyBedOccupancyRate {
    if (emergencyBedsTotal == 0) return 0.0;
    return (emergencyBedsTotal - emergencyBedsAvailable) / emergencyBedsTotal;
  }

  bool get hasAvailableBeds {
    return generalBedsAvailable > 0 ||
        icuBedsAvailable > 0 ||
        emergencyBedsAvailable > 0;
  }

  bool get isOperational {
    return operationalStatus == OperationalStatus.fullyOperational ||
        operationalStatus == OperationalStatus.limitedServices;
  }

  String get statusDescription {
    switch (operationalStatus) {
      case OperationalStatus.fullyOperational:
        return 'Fully Operational';
      case OperationalStatus.limitedServices:
        return 'Limited Services';
      case OperationalStatus.emergencyOnly:
        return 'Emergency Only';
      case OperationalStatus.closed:
        return 'Closed';
      case OperationalStatus.maintenance:
        return 'Under Maintenance';
    }
  }

  String get emergencyLevelDescription {
    switch (emergencyLevel) {
      case EmergencyLevel.normal:
        return 'Normal';
      case EmergencyLevel.busy:
        return 'Busy';
      case EmergencyLevel.critical:
        return 'Critical';
      case EmergencyLevel.overwhelmed:
        return 'Overwhelmed';
    }
  }
}

enum OperationalStatus {
  fullyOperational,
  limitedServices,
  emergencyOnly,
  closed,
  maintenance,
}

enum EmergencyLevel {
  normal,
  busy,
  critical,
  overwhelmed,
}

enum ServiceStatus {
  available,
  limited,
  unavailable,
  maintenance,
}

enum EquipmentStatus {
  operational,
  limited,
  outOfService,
  maintenance,
}
