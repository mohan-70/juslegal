import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static Future<void> initialize() async {
    await dotenv.load(fileName: ".env");
  }

  // App Information
  static String get appName => dotenv.env['APP_NAME'] ?? 'JusLegal';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static String get appBuildNumber => dotenv.env['APP_BUILD_NUMBER'] ?? '1';
  static String get supportEmail => dotenv.env['SUPPORT_EMAIL'] ?? 'support@juslegal.app';

  // URLs
  static String get privacyPolicyUrl => dotenv.env['PRIVACY_POLICY_URL'] ?? 'https://juslegal.app/privacy';
  static String get termsOfServiceUrl => dotenv.env['TERMS_OF_SERVICE_URL'] ?? 'https://juslegal.app/terms';
  static String get websiteUrl => dotenv.env['WEBSITE_URL'] ?? 'https://juslegal.app';

  // Legal Disclaimers
  static String get appTagline => dotenv.env['APP_TAGLINE'] ?? 'Know Your Rights. Take Action.';
  static String get onboardingDisclaimer => dotenv.env['ONBOARDING_DISCLAIMER'] ?? 
      'JusLegal provides general legal guidance based on Indian law. It does not replace professional legal advice. For complex or criminal matters, always consult a practicing advocate.';
  static String get resultDisclaimer => dotenv.env['RESULT_DISCLAIMER'] ?? 'ℹ️ General guidance only. Not legal advice.';
  static String get documentDisclaimer => dotenv.env['DOCUMENT_DISCLAIMER'] ?? 
      'This document was generated for reference purposes. Review carefully before sending.';

  // External Service URLs
  static String get cyberCrimeUrl => dotenv.env['CYBER_CRIME_URL'] ?? 'https://cybercrime.gov.in';
  static String get rbiComplaintUrl => dotenv.env['RBI_COMPLAINT_URL'] ?? 'https://cms.rbi.org.in';
  static String get dgcaUrl => dotenv.env['DGCA_URL'] ?? 'https://dgca.gov.in';
  static String get googleMapsUrl => dotenv.env['GOOGLE_MAPS_URL'] ?? 'https://www.google.com/maps/search';

  // Optional API Keys (for future use)
  static String? get apiKey => dotenv.env['API_KEY'];
  static String? get analyticsKey => dotenv.env['ANALYTICS_KEY'];

  // Validation
  static bool get isConfigured {
    return dotenv.env['SUPPORT_EMAIL'] != null && 
           dotenv.env['PRIVACY_POLICY_URL'] != null;
  }

  // Debug helper (comment out in production)
  static void printConfig() {
    // print('=== AppConfig ===');
    // print('App Name: $appName');
    // print('Version: $appVersion ($appBuildNumber)');
    // print('Support Email: $supportEmail');
    // print('Privacy Policy: $privacyPolicyUrl');
    // print('Terms of Service: $termsOfServiceUrl');
    // print('Website: $websiteUrl');
    // print('Configured: $isConfigured');
    // print('================');
  }
}
