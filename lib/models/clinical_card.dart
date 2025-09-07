class ClinicalCard {
  final String id;
  final String userId;
  final String cardNumber;
  final String bloodType;
  final String allergies;
  final String chronicConditions;
  final String emergencyContact;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClinicalCard({
    required this.id,
    required this.userId,
    required this.cardNumber,
    required this.bloodType,
    required this.allergies,
    required this.chronicConditions,
    required this.emergencyContact,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClinicalCard.fromJson(Map<String, dynamic> json) {
    return ClinicalCard(
      id: json['id'],
      userId: json['user_id'],
      cardNumber: json['card_number'],
      bloodType: json['blood_type'],
      allergies: json['allergies'],
      chronicConditions: json['chronic_conditions'],
      emergencyContact: json['emergency_contact'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'card_number': cardNumber,
      'blood_type': bloodType,
      'allergies': allergies,
      'chronic_conditions': chronicConditions,
      'emergency_contact': emergencyContact,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
