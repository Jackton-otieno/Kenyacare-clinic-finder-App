import 'package:flutter/material.dart';
import '../services/supabase_service.dart';
import '../models/clinical_card.dart';
import '../models/user.dart' as app;

class ClinicalCardScreen extends StatefulWidget {
  const ClinicalCardScreen({super.key});

  @override
  State<ClinicalCardScreen> createState() => _ClinicalCardScreenState();
}

class _ClinicalCardScreenState extends State<ClinicalCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bloodTypeController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _chronicConditionsController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  // New controller for medicine suggestions
  final _medicineSuggestionController = TextEditingController();

  app.User? _user;
  ClinicalCard? _clinicalCard;
  bool _isLoading = true;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();

    // Add listeners to update medicine suggestions when relevant fields change
    _bloodTypeController.addListener(_updateMedicineSuggestions);
    _allergiesController.addListener(_updateMedicineSuggestions);
    _chronicConditionsController.addListener(_updateMedicineSuggestions);
  }

  void _updateMedicineSuggestions() {
    // Simple example logic for medicine suggestions based on blood type, allergies, and chronic conditions
    final bloodType = _bloodTypeController.text.toLowerCase();
    final allergies = _allergiesController.text.toLowerCase();
    final chronic = _chronicConditionsController.text.toLowerCase();

    List<String> suggestions = [];

    if (bloodType.isNotEmpty) {
      if (bloodType == 'a+') {
        suggestions.add('Medicine A1, Medicine A2');
      } else if (bloodType == 'b+') {
        suggestions.add('Medicine B1, Medicine B2');
      } else {
        suggestions.add('General Medicine X');
      }
    }

    if (allergies.contains('penicillin')) {
      suggestions.add('Avoid Penicillin-based medicines');
    }

    if (chronic.contains('diabetes')) {
      suggestions.add('Check blood sugar levels regularly');
    }

    setState(() {
      _medicineSuggestionController.text = suggestions.join('\n');
    });
  }

  @override
  void dispose() {
    _bloodTypeController.removeListener(_updateMedicineSuggestions);
    _allergiesController.removeListener(_updateMedicineSuggestions);
    _chronicConditionsController.removeListener(_updateMedicineSuggestions);

    _bloodTypeController.dispose();
    _allergiesController.dispose();
    _chronicConditionsController.dispose();
    _emergencyContactController.dispose();
    _medicineSuggestionController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      print('Loading user data...');
      final user = await SupabaseService().getCurrentUser();
      print('User loaded: ${user?.email ?? 'No user'}');

      if (mounted) {
        setState(() {
          _user = user;
        });

        if (user != null) {
          print('Loading clinical card for user: ${user.id}');
          await _loadClinicalCard(user.id);
        } else {
          print('No user found - user might not be authenticated');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Please log in to view clinical card')),
            );
          }
        }
      }
    } catch (e) {
      print('Error in _loadUserData: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load user data: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _loadClinicalCard(String userId) async {
    try {
      print('Fetching clinical card for user ID: $userId');
      final card = await SupabaseService().getClinicalCard(userId);
      print('Clinical card result: ${card != null ? 'Found' : 'Not found'}');

      if (mounted) {
        setState(() {
          _clinicalCard = card;

          if (card != null) {
            print('Populating form fields with clinical card data');
            _bloodTypeController.text = card.bloodType;
            _allergiesController.text = card.allergies;
            _chronicConditionsController.text = card.chronicConditions;
            _emergencyContactController.text = card.emergencyContact;
          } else {
            print('No clinical card found - user can create a new one');
          }
        });
      }
    } catch (e) {
      print('Error in _loadClinicalCard: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load clinical card: $e')),
        );
      }
    }
  }

  Future<void> _saveClinicalCard() async {
    if (!_formKey.currentState!.validate()) return;

    if (_user == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final cardData = ClinicalCard(
        id: _clinicalCard?.id ?? '',
        userId: _user!.id,
        cardNumber: _clinicalCard?.cardNumber ??
            'CL-${DateTime.now().millisecondsSinceEpoch}',
        bloodType: _bloodTypeController.text,
        allergies: _allergiesController.text,
        chronicConditions: _chronicConditionsController.text,
        emergencyContact: _emergencyContactController.text,
        createdAt: _clinicalCard?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      ClinicalCard savedCard;
      if (_clinicalCard == null) {
        savedCard = await SupabaseService().createClinicalCard(cardData);
      } else {
        savedCard = await SupabaseService().updateClinicalCard(cardData);
      }

      if (mounted) {
        setState(() {
          _clinicalCard = savedCard;
          _isEditing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Clinical card saved successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to save clinical card')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clinical Card'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          if (_clinicalCard != null && !_isEditing)
            IconButton(
              onPressed: () {
                setState(() {
                  _isEditing = true;
                });
              },
              icon: const Icon(Icons.edit),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_clinicalCard != null)
                        Text(
                          'Card Number: ${_clinicalCard!.cardNumber}',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _bloodTypeController,
                        decoration: const InputDecoration(
                          labelText: 'Blood Type',
                          border: OutlineInputBorder(),
                        ),
                        enabled: _isEditing,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _allergiesController,
                        decoration: const InputDecoration(
                          labelText: 'Allergies',
                          border: OutlineInputBorder(),
                        ),
                        enabled: _isEditing,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _chronicConditionsController,
                        decoration: const InputDecoration(
                          labelText: 'Chronic Conditions',
                          border: OutlineInputBorder(),
                        ),
                        enabled: _isEditing,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _emergencyContactController,
                        decoration: const InputDecoration(
                          labelText: 'Emergency Contact',
                          border: OutlineInputBorder(),
                        ),
                        enabled: _isEditing,
                      ),
                      const SizedBox(height: 20),
                      // New medicine suggestion field
                      TextFormField(
                        controller: _medicineSuggestionController,
                        decoration: const InputDecoration(
                          labelText: 'Medicine Suggestions',
                          border: OutlineInputBorder(),
                        ),
                        enabled: false,
                        maxLines: 3,
                      ),
                      const SizedBox(height: 30),
                      if (_isEditing)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _saveClinicalCard,
                            child: const Text('Save Clinical Card'),
                          ),
                        ),
                      if (_clinicalCard == null && !_isEditing)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () {
                              setState(() {
                                _isEditing = true;
                              });
                            },
                            child: const Text('Create Clinical Card'),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}
