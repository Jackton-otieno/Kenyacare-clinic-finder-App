class SupabaseConfig {
  // Replace these with your actual Supabase project credentials
  // You can find these in your Supabase project dashboard at https://supabase.com
  static const String url = 'https://vudypciuqcsaovlcnlxs.supabase.co';
  static const String anonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ1ZHlwY2l1cWNzYW92bGNubHhzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTcwNjU2MTgsImV4cCI6MjA3MjY0MTYxOH0.mrAlJobZiIHv8zQOtqVqj_lcYiE3GvH_awa-LfW0CDc';

  // Optional: Add other configuration constants
  static const String bucketName = 'hospital-images';
  static const Duration timeout = Duration(seconds: 30);

  // Environment-specific configurations
  static bool get isProduction => const bool.fromEnvironment('dart.vm.product');

  static String get apiUrl =>
      isProduction ? 'https://api.afyamap.ke' : 'https://api-dev.afyamap.ke';
}
