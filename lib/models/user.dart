class User {
  final String id;
  final String email;
  final String fullName;
  final String phoneNumber;
  final DateTime createdAt;

  User({
    required this.id,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      fullName: json['full_name'],
      phoneNumber: json['phone_number'],
      createdAt: json['created_at'] is String 
        ? DateTime.parse(json['created_at']) 
        : json['created_at'] as DateTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'phone_number': phoneNumber,
      'created_at': createdAt is String ? createdAt : createdAt.toIso8601String(),
    };
  }
}
