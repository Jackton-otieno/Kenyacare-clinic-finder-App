# AfyaMap Kenya - Hospital Locator App

A comprehensive Flutter application for locating healthcare facilities across Kenya with real-time availability, emergency services, and multilingual support.

## 🏥 Features

### Core Functionality
- **Interactive Map**: Real-time hospital locations with status indicators
- **Advanced Search**: Filter by hospital type, services, distance, and more
- **Emergency Mode**: Quick access to emergency-capable hospitals
- **Offline Support**: Cached data for use without internet connection
- **Multilingual**: Full support for English and Swahili

### Hospital Information
- **Real-time Data**: Bed availability, wait times, operational status
- **Comprehensive Details**: Contact info, services, specialties, operating hours
- **Reviews & Ratings**: User-generated reviews and ratings system
- **Insurance Information**: Accepted insurance providers

### Communication & Navigation
- **Direct Calling**: One-tap calling to hospitals and emergency numbers
- **Turn-by-turn Directions**: Integration with Google Maps, Apple Maps
- **Share Functionality**: Share hospital information via social media, messaging
- **Emergency Alerts**: Quick access to emergency services

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.16.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- Android device/emulator or iOS device/simulator

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/your-username/afyamap-kenya.git
   cd afyamap-kenya
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment**
   - Update `lib/config/supabase_config.dart` with your Supabase credentials
   - Ensure location permissions are configured in platform-specific files

4. **Run the application**
   ```bash
   flutter run
   ```

## 📱 Platform Support

- ✅ Android (API level 21+)
- ✅ iOS (iOS 12.0+)
- ✅ Web (Progressive Web App)
- ✅ Windows, macOS, Linux (Desktop support)

## 🏗️ Architecture

### Project Structure
```
lib/
├── config/           # Configuration files
├── l10n/            # Localization files (English/Swahili)
├── models/          # Data models
├── screens/         # UI screens
├── services/        # Business logic and API services
└── main.dart        # Application entry point
```

### Key Components

#### Models
- **Hospital**: Core hospital data model with comprehensive information
- **RealTimeHospitalData**: Live operational data (beds, wait times, status)
- **HospitalReview**: User reviews and ratings system

#### Services
- **HospitalService**: API integration with offline caching
- **LocationService**: GPS location and distance calculations
- **SupabaseService**: Backend data synchronization

#### Screens
- **HomeScreen**: Main map interface with search and filters
- **HospitalDetailScreen**: Comprehensive hospital information
- **HealthRecordsScreen**: Personal health record management

## 🔧 Configuration

### API Configuration
Update `lib/config/supabase_config.dart`:
```dart
class SupabaseConfig {
  static const String url = 'YOUR_SUPABASE_URL';
  static const String anonKey = 'YOUR_SUPABASE_ANON_KEY';
}
```

### Permissions
The app requires the following permissions:
- **Location**: For finding nearby hospitals
- **Phone**: For making calls to hospitals
- **Internet**: For real-time data updates
- **Storage**: For offline data caching

## 🌍 Localization

The app supports:
- **English** (en): Default language
- **Swahili** (sw): Full translation available

To add new languages:
1. Create new `.arb` files in `lib/l10n/`
2. Run `flutter gen-l10n` to generate localization files
3. Update supported locales in `main.dart`

## 🗄️ Data Sources

### Hospital Data
- **Primary**: AfyaMap API (https://api.afyamap.ke)
- **Fallback**: Local CSV data (`assets/data/kenya_hospitals.csv`)
- **Real-time**: Live operational status and availability

### Caching Strategy
- **In-memory**: Fast access to frequently used data
- **SharedPreferences**: Persistent offline storage
- **Automatic refresh**: Every 6 hours or manual refresh

## 🚨 Emergency Features

### Emergency Mode
- **Quick Toggle**: Filter to show only emergency-capable hospitals
- **Priority Display**: Emergency hospitals highlighted on map
- **Direct Access**: One-tap emergency calling

### Safety Features
- **Confirmation Dialogs**: For emergency calls
- **Offline Fallback**: Cached emergency contact information
- **Location Sharing**: Share current location with emergency contacts

## 🔒 Privacy & Security

- **Location Privacy**: Location data processed locally
- **Data Encryption**: Sensitive data encrypted in transit
- **Offline First**: Minimal data transmission required
- **User Consent**: Clear permission requests and explanations

## 🧪 Testing

Run tests with:
```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/
```

## 📦 Dependencies

### Core Dependencies
- `flutter_map`: Interactive map display
- `geolocator`: Location services
- `dio`: HTTP client for API calls
- `supabase_flutter`: Backend integration
- `shared_preferences`: Local data storage

### UI/UX Dependencies
- `flutter_localizations`: Internationalization
- `url_launcher`: External app integration
- `share_plus`: Social sharing functionality

### Development Dependencies
- `flutter_lints`: Code quality analysis
- `build_runner`: Code generation

## 🚀 Deployment

### Android
```bash
flutter build apk --release
# or for app bundle
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style
- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use `flutter analyze` to check code quality
- Ensure all tests pass before submitting

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

- **Documentation**: [Wiki](https://github.com/your-username/afyamap-kenya/wiki)
- **Issues**: [GitHub Issues](https://github.com/your-username/afyamap-kenya/issues)
- **Discussions**: [GitHub Discussions](https://github.com/your-username/afyamap-kenya/discussions)

## 🙏 Acknowledgments

- Kenya Ministry of Health for hospital data
- OpenStreetMap contributors for map data
- Flutter community for excellent packages
- Healthcare workers across Kenya

## 📊 Statistics

- **Hospitals Covered**: 8,000+ healthcare facilities
- **Counties**: All 47 counties in Kenya
- **Languages**: English, Swahili
- **Platforms**: Android, iOS, Web, Desktop

---

**Built with ❤️ for the people of Kenya**

*Improving healthcare accessibility through technology*
