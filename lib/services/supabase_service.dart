import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../models/user.dart' as app;
import '../models/clinical_card.dart';
import '../models/health_record.dart';

class SupabaseService {
  static SupabaseService? _instance;
  static final SupabaseClient _supabase = Supabase.instance.client;

  SupabaseService._internal();

  factory SupabaseService() {
    _instance ??= SupabaseService._internal();
    return _instance!;
  }

  static SupabaseClient get client => _supabase;

  // Authentication methods
  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
  }) async {
    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {
          'full_name': fullName,
          'phone_number': phoneNumber,
        },
      );
      return response;
    } catch (error) {
      return AuthResponse();
    }
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response;
    } catch (error) {
      return AuthResponse();
    }
  }

  Future<void> signOut() async {
    await _supabase.auth.signOut();
  }

  // User methods
  Future<app.User?> getCurrentUser() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) return null;

      final user = session.user;

      DateTime createdAt;
      if (user.createdAt is DateTime) {
        createdAt = user.createdAt as DateTime;
      } else {
        createdAt = DateTime.parse(user.createdAt as String);
      }

      return app.User(
        id: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] ?? '',
        phoneNumber: user.userMetadata?['phone_number'] ?? '',
        createdAt: createdAt,
      );
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Clinical card methods
  Future<ClinicalCard?> getClinicalCard(String userId) async {
    try {
      final response = await _supabase
          .from('clinical_cards')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;
      return ClinicalCard.fromJson(response);
    } catch (e) {
      print('Error getting clinical card: $e');
      return null;
    }
  }

  Future<ClinicalCard> createClinicalCard(ClinicalCard card) async {
    try {
      final response = await _supabase
          .from('clinical_cards')
          .insert(card.toJson())
          .select()
          .single();
      return ClinicalCard.fromJson(response);
    } catch (e) {
      print('Error creating clinical card: $e');
      rethrow;
    }
  }

  Future<ClinicalCard> updateClinicalCard(ClinicalCard card) async {
    try {
      final response = await _supabase
          .from('clinical_cards')
          .update(card.toJson())
          .eq('id', card.id)
          .select()
          .single();
      return ClinicalCard.fromJson(response);
    } catch (e) {
      print('Error updating clinical card: $e');
      rethrow;
    }
  }

  // Health record methods
  Future<List<HealthRecord>> getHealthRecords(String userId) async {
    final response = await _supabase
        .from('health_records')
        .select()
        .eq('user_id', userId)
        .order('visit_date', ascending: false);
    return response.map((record) => HealthRecord.fromJson(record)).toList();
  }

  Future<HealthRecord> addHealthRecord(HealthRecord record) async {
    final response = await _supabase
        .from('health_records')
        .insert(record.toJson())
        .select()
        .single();
    return HealthRecord.fromJson(response);
  }

  // Appointment methods
  Future<Map<String, dynamic>> bookAppointment({
    required String userId,
    required String clinicId,
    required DateTime appointmentDate,
    required String reason,
  }) async {
    final response = await _supabase
        .from('appointments')
        .insert({
          'user_id': userId,
          'clinic_id': clinicId,
          'appointment_date': appointmentDate.toIso8601String(),
          'reason': reason,
          'status': 'confirmed',
        })
        .select()
        .single();
    return response;
  }

  Future<List<Map<String, dynamic>>> getUserAppointments(String userId) async {
    final response = await _supabase
        .from('appointments')
        .select()
        .eq('user_id', userId)
        .order('appointment_date');
    return response;
  }
}
