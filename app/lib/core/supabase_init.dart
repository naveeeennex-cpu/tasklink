import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';

/// Initialize Supabase if the env is configured. Silently no-ops when
/// keys are missing — the app still runs, auth calls will surface a
/// clean error when attempted.
class SupabaseInit {
  SupabaseInit._();

  static bool _initialized = false;
  static bool get isInitialized => _initialized;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    if (!Env.supabaseConfigured) return;
    await Supabase.initialize(
      url: Env.supabaseUrl,
      anonKey: Env.supabaseAnonKey,
      debug: false,
    );
    _initialized = true;
  }

  static SupabaseClient? get clientOrNull =>
      _initialized ? Supabase.instance.client : null;
}
