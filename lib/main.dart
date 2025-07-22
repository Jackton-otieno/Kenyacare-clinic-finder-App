import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'l10n/app_localizations.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

// Initialize notifications
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notifications
  const AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings = InitializationSettings(android: initializationSettingsAndroid);
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  
  runApp(const ClinicFinderApp());
}

class ClinicFinderApp extends StatelessWidget {
  const ClinicFinderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Clinic Finder',
      theme: ThemeData(primarySwatch: Colors.blue),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''), // English
        Locale('sw', ''), // Swahili
      ],
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;
  String? _selectedCounty;
  List<Map<String, dynamic>> _clinics = [];
  Database? _database;

  @override
  void initState() {
    super.initState();
    _initDatabase();
    _getCurrentLocation();
    _scheduleNotification();
  }

  // Initialize SQLite database for offline caching
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
            longitude REAL
          )
        ''');
        // Sample clinic data
        await db.insert('clinics', {
          'name': 'Sample Clinic',
          'county': 'Nairobi',
          'latitude': -1.286389,
          'longitude': 36.817223,
        });
      },
    );
  }

  // Get user's current location
  Future<void> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _currentPosition = position;
    });
    _fetchNearbyClinics();
  }

  // Fetch clinics within 5-10km or by county
  Future<void> _fetchNearbyClinics() async {
    if (_database == null || _currentPosition == null) return;

    final List<Map<String, dynamic>> clinics = await _database!.query('clinics');
    setState(() {
      _clinics = clinics.where((clinic) {
        if (_selectedCounty != null && clinic['county'] != _selectedCounty) return false;
        double distance = Geolocator.distanceBetween(
          _currentPosition!.latitude,
          _currentPosition!.longitude,
          clinic['latitude'],
          clinic['longitude'],
        );
        return distance <= 10000; // 10km radius
      }).toList();
    });
  }

  // Schedule appointment notification
  Future<void> _scheduleNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'appointment_channel',
      'Appointments',
      importance: Importance.high,
      priority: Priority.high,
    );
    const NotificationDetails notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      0,
      'Appointment Reminder',
      'Your appointment is tomorrow at 10 AM!',
      notificationDetails,
    );
  }

  // Book appointment (mock implementation)
  Future<void> _bookAppointment(String clinicName) async {
    // In a real app, this would integrate with an API for booking
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Appointment booked at $clinicName')),
    );
    await _scheduleNotification();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.appTitle)),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // County Picker
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: DropdownButton<String>(
                hint: const Text('Select County'),
                value: _selectedCounty,
                items: const [
                  'Nairobi', 'Mombasa', 'Kisumu', 'Nakuru', 'Eldoret', 'Kakamega', 'Kisii', 'Machakos', 'Meru', 'Nyeri',
                  'Kiambu', 'Kilifi', 'Kitui', 'Laikipia', 'Lamu', 'Mandera', 'Marsabit', 'Migori', 'Murang\'a', 'Nandi',
                  'Narok', 'Nyamira', 'Nyandarua', 'Samburu', 'Siaya', 'Taita Taveta', 'Tana River', 'Tharaka Nithi',
                  'Trans Nzoia', 'Turkana', 'Uasin Gishu', 'Vihiga', 'Wajir', 'West Pokot', 'Baringo', 'Bomet', 'Bungoma',
                  'Busia', 'Elgeyo Marakwet', 'Embu', 'Garissa', 'Homa Bay', 'Isiolo', 'Kajiado', 'Kericho', 'Kirinyaga'
                ].map((county) {
                  return DropdownMenuItem<String>(
                    value: county,
                    child: Text(county),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCounty = value;
                    _fetchNearbyClinics();
                  });
                },
              ),
            ),
            // Map View
            SizedBox(
              height: 300,
              child: _currentPosition == null
                  ? const Center(child: CircularProgressIndicator())
                  : FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                        initialZoom: 13.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                          subdomains: const ['a', 'b', 'c'],
                        ),
                        MarkerLayer(
                          markers: _clinics.map((clinic) {
                            return Marker(
                              point: LatLng(clinic['latitude'], clinic['longitude']),
                              child: const Icon(Icons.local_hospital, color: Colors.red),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
            ),
            // Clinic List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _clinics.length,
              itemBuilder: (context, index) {
                final clinic = _clinics[index];
                return ListTile(
                  title: Text(clinic['name']),
                  subtitle: Text(clinic['county']),
                  trailing: ElevatedButton(
                    onPressed: () => _bookAppointment(clinic['name']),
                    child: const Text('Book Appointment'),
                  ),
                );
              },
            ),
            // Health Hub Link
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HealthHubScreen()),
                );
              },
              child: Text(AppLocalizations.of(context)!.healthHub),
            ),
          ],
        ),
      ),
    );
  }
}

class HealthHubScreen extends StatelessWidget {
  const HealthHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppLocalizations.of(context)!.healthHub)),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Malaria Prevention', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Use mosquito nets and repellents.'),
            SizedBox(height: 16),
            Text('NHIF Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Visit nhif.or.ke for coverage details.'),
            SizedBox(height: 16),
            Text('Emergency Contacts', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Ambulance: 999'),
          ],
        ),
      ),
    );
  }
}