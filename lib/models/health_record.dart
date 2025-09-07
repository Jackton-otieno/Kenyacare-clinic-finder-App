class HealthRecord {
  final String id;
  final String userId;
  final String diagnosis;
  final String treatment;
  final String prescription;
  final DateTime visitDate;
  final DateTime createdAt;

  HealthRecord({
    required this.id,
    required this.userId,
    required this.diagnosis,
    required this.treatment,
    required this.prescription,
    required this.visitDate,
    required this.createdAt,
  });

  factory HealthRecord.fromJson(Map<String, dynamic> json) {
    return HealthRecord(
      id: json['id'],
      userId: json['user_id'],
      diagnosis: json['diagnosis'],
      treatment: json['treatment'],
      prescription: json['prescription'],
      visitDate: DateTime.parse(json['visit_date']),
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'diagnosis': diagnosis,
      'treatment': treatment,
      'prescription': prescription,
      'visit_date': visitDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }
}
