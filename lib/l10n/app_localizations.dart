import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_sw.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you'll need to edit this
/// file.
///
/// More information about this can be found on the [Internationalization
/// guide](https://flutter.dev/docs/development/accessibility-and-localization/internationalization)
/// page of the [Flutter documentation](https://flutter.dev/docs).
///
/// ## Supported locales
///
/// This application supports the following locales:
///
/// - English (`en`)
/// - Swahili (`sw`)
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('sw')
  ];

  /// The title of the application
  ///
  /// In en, this message translates to:
  /// **'AfyaMap Kenya'**
  String get appTitle;

  /// Label for county selection
  ///
  /// In en, this message translates to:
  /// **'Select County'**
  String get selectCounty;

  /// Button text for booking appointments
  ///
  /// In en, this message translates to:
  /// **'Book Appointment'**
  String get bookAppointment;

  /// Label for health hub section
  ///
  /// In en, this message translates to:
  /// **'Health Hub'**
  String get healthHub;

  /// Button text for getting directions
  ///
  /// In en, this message translates to:
  /// **'Directions'**
  String get directions;

  /// Button text for making a phone call
  ///
  /// In en, this message translates to:
  /// **'Call'**
  String get call;

  /// Button text for closing dialogs
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// Button text for emergency calls
  ///
  /// In en, this message translates to:
  /// **'Call Emergency'**
  String get callEmergency;

  /// Confirmation message for emergency calls
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to call emergency services?'**
  String get emergencyCallConfirmation;

  /// Button text for canceling actions
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// Button text for confirming actions
  ///
  /// In en, this message translates to:
  /// **'Confirm'**
  String get confirm;

  /// Button text for sharing content
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// Button text for opening website
  ///
  /// In en, this message translates to:
  /// **'Website'**
  String get website;

  /// Button text for sending email
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// Title for hospital details screen
  ///
  /// In en, this message translates to:
  /// **'Hospital Details'**
  String get hospitalDetails;

  /// Label for hospital services
  ///
  /// In en, this message translates to:
  /// **'Services'**
  String get services;

  /// Label for operating hours
  ///
  /// In en, this message translates to:
  /// **'Operating Hours'**
  String get operatingHours;

  /// Label for contact information
  ///
  /// In en, this message translates to:
  /// **'Contact Information'**
  String get contactInfo;

  /// Label for address
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get address;

  /// Label for phone number
  ///
  /// In en, this message translates to:
  /// **'Phone Number'**
  String get phoneNumber;

  /// Label for emergency number
  ///
  /// In en, this message translates to:
  /// **'Emergency Number'**
  String get emergencyNumber;

  /// Label for hospital rating
  ///
  /// In en, this message translates to:
  /// **'Rating'**
  String get rating;

  /// Label for hospital reviews
  ///
  /// In en, this message translates to:
  /// **'Reviews'**
  String get reviews;

  /// Label for accepted insurance
  ///
  /// In en, this message translates to:
  /// **'Accepted Insurance'**
  String get acceptedInsurance;

  /// Label for emergency services
  ///
  /// In en, this message translates to:
  /// **'Emergency'**
  String get emergency;

  /// Label for 24-hour availability
  ///
  /// In en, this message translates to:
  /// **'Available 24 Hours'**
  String get available24Hours;

  /// Label for ambulance service
  ///
  /// In en, this message translates to:
  /// **'Ambulance Service'**
  String get ambulanceService;

  /// Placeholder text for hospital search
  ///
  /// In en, this message translates to:
  /// **'Search hospitals'**
  String get searchHospitals;

  /// Message when no search results are found
  ///
  /// In en, this message translates to:
  /// **'No results found'**
  String get noResultsFound;

  /// Loading message
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// Generic error message
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// Button text for retrying actions
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// Label for offline status
  ///
  /// In en, this message translates to:
  /// **'Offline'**
  String get offline;

  /// Label for online status
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get online;

  /// Message when using cached data
  ///
  /// In en, this message translates to:
  /// **'Using cached data'**
  String get usingCachedData;

  /// Button text for refreshing data
  ///
  /// In en, this message translates to:
  /// **'Refresh Data'**
  String get refreshData;

  /// Success message for data refresh
  ///
  /// In en, this message translates to:
  /// **'Data refreshed successfully'**
  String get dataRefreshed;

  /// Error message for failed data refresh
  ///
  /// In en, this message translates to:
  /// **'Failed to refresh data'**
  String get refreshFailed;

  /// Error message for location permission denial
  ///
  /// In en, this message translates to:
  /// **'Location permission denied'**
  String get locationPermissionDenied;

  /// Error message for disabled location services
  ///
  /// In en, this message translates to:
  /// **'Location services disabled'**
  String get locationServicesDisabled;

  /// Button text for getting current location
  ///
  /// In en, this message translates to:
  /// **'Get Current Location'**
  String get getCurrentLocation;

  /// Label for emergency mode
  ///
  /// In en, this message translates to:
  /// **'Emergency Mode'**
  String get emergencyMode;

  /// Toggle text for showing emergency hospitals only
  ///
  /// In en, this message translates to:
  /// **'Show Emergency Only'**
  String get showEmergencyOnly;

  /// Button text for clearing filters
  ///
  /// In en, this message translates to:
  /// **'Clear Filters'**
  String get clearFilters;

  /// Label for filters
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filters;

  /// Label for hospital type filter
  ///
  /// In en, this message translates to:
  /// **'Hospital Type'**
  String get hospitalType;

  /// Label for distance filter
  ///
  /// In en, this message translates to:
  /// **'Distance'**
  String get distance;

  /// Abbreviation for kilometers
  ///
  /// In en, this message translates to:
  /// **'km'**
  String get km;

  /// Message showing number of hospitals found
  ///
  /// In en, this message translates to:
  /// **'Found {count} hospitals'**
  String foundHospitals(int count);

  /// Label for clinical card
  ///
  /// In en, this message translates to:
  /// **'Clinical Card'**
  String get clinicalCard;

  /// Label for health records
  ///
  /// In en, this message translates to:
  /// **'Health Records'**
  String get healthRecords;

  /// Label for user profile
  ///
  /// In en, this message translates to:
  /// **'Profile'**
  String get profile;

  /// Label for settings
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// Label for about section
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// Label for help section
  ///
  /// In en, this message translates to:
  /// **'Help'**
  String get help;

  /// Label for feedback
  ///
  /// In en, this message translates to:
  /// **'Feedback'**
  String get feedback;

  /// Label for reporting issues
  ///
  /// In en, this message translates to:
  /// **'Report Issue'**
  String get reportIssue;

  /// Label for app version
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// Label for privacy policy
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicy;

  /// Label for terms of service
  ///
  /// In en, this message translates to:
  /// **'Terms of Service'**
  String get termsOfService;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'sw'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'sw':
      return AppLocalizationsSw();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue on GitHub with a '
      'reproducible example of the issue and the full stacktrace.');
}
