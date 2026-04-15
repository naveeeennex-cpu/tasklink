import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Typed accessor over the `.env` file. All secrets/config must be read
/// through this class — never hardcoded, never read from dotenv directly.
class Env {
  Env._();

  static Future<void> load() async {
    await dotenv.load(fileName: '.env');
  }

  static String get backendUrl =>
      dotenv.maybeGet('BACKEND_URL') ?? 'http://10.0.2.2:8000';

  static String get supabaseUrl =>
      dotenv.maybeGet('SUPABASE_URL') ?? '';

  static String get supabaseAnonKey =>
      dotenv.maybeGet('SUPABASE_ANON_KEY') ?? '';

  static bool get supabaseConfigured =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      !supabaseUrl.contains('YOUR-PROJECT');
}
