class SupabaseConfig {
  static const String supabaseUrl = 'https://vwfriffzafrklnwkqfns.supabase.co';
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ3ZnJpZmZ6YWZya2xud2txZm5zIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTMwODkzMDEsImV4cCI6MjEwODY2NTMwMX0.eL3qPU3s3Oo62mtuA5T7e-ma_PFM9SPNSO59nfEI_3o';

  /// Indicates if the application is running in local offline demo mode (default)
  /// or connected directly to Supabase cloud.
  static bool get isConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      supabaseUrl != 'https://YOUR_SUPABASE_PROJECT.supabase.co' &&
      supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY';
}
