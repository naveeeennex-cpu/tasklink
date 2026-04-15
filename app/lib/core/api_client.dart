import 'package:dio/dio.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env.dart';
import 'models/route_info.dart';
import 'supabase_init.dart';

/// Dio HTTP client for the FastAPI backend.
///
/// An interceptor injects `Authorization: Bearer <access_token>` from the
/// current Supabase session automatically, so call sites don't juggle
/// tokens.
class ApiClient {
  ApiClient._internal() : _dio = _buildDio();

  static final ApiClient instance = ApiClient._internal();

  final Dio _dio;

  static Dio _buildDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: '${Env.backendUrl}/api/v1',
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    );
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final client = SupabaseInit.clientOrNull;
          final Session? session = client?.auth.currentSession;
          if (session != null) {
            options.headers['Authorization'] = 'Bearer ${session.accessToken}';
          }
          handler.next(options);
        },
        onError: (e, handler) {
          handler.next(e);
        },
      ),
    );
    return dio;
  }

  Dio get dio => _dio;

  // ── Users ─────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getMe() async {
    final r = await _dio.get('/users/me');
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<void> setActiveMode(String mode) async {
    await _dio.patch('/users/me/mode', queryParameters: {'mode': mode});
  }

  // ── Service profiles ──────────────────────────────────────────────
  Future<List<Map<String, dynamic>>> listProfiles() async {
    final r = await _dio.get('/profiles');
    return (r.data as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<Map<String, dynamic>> createProfile(Map<String, dynamic> details) async {
    final r = await _dio.post('/profiles', data: {'details': details});
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<Map<String, dynamic>> updateProfile(
    String category, {
    Map<String, dynamic>? details,
    bool? isActive,
  }) async {
    final body = <String, dynamic>{};
    if (details != null) body['details'] = details;
    if (isActive != null) body['is_active'] = isActive;
    final r = await _dio.patch('/profiles/$category', data: body);
    return Map<String, dynamic>.from(r.data as Map);
  }

  // ── Service requests ──────────────────────────────────────────────
  Future<Map<String, dynamic>> createRequest(Map<String, dynamic> body) async {
    final r = await _dio.post('/requests', data: body);
    return Map<String, dynamic>.from(r.data as Map);
  }

  Future<List<Map<String, dynamic>>> myRequests() async {
    final r = await _dio.get('/requests/mine');
    return (r.data as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  Future<List<Map<String, dynamic>>> providerFeed(String category) async {
    final r = await _dio.get('/requests/feed',
        queryParameters: {'category': category});
    return (r.data as List).map((e) => Map<String, dynamic>.from(e)).toList();
  }

  // ── Maps proxy ────────────────────────────────────────────────────
  Future<List<dynamic>> placesAutocomplete(String query,
      {double? lat, double? lng}) async {
    final r = await _dio.get('/maps/places/autocomplete', queryParameters: {
      'q': query,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
    });
    return r.data as List;
  }

  Future<List<dynamic>> geocode(String address) async {
    final r = await _dio.get('/maps/geocode',
        queryParameters: {'address': address});
    return r.data as List;
  }

  Future<List<dynamic>> reverseGeocode(double lat, double lng) async {
    final r = await _dio.get('/maps/reverse-geocode',
        queryParameters: {'lat': lat, 'lng': lng});
    return r.data as List;
  }

  /// Fetch the shortest route between two geocoordinates via the backend
  /// proxy. Google Directions returns up to 3 alternative routes; the
  /// backend already picks the one with smallest total distance.
  Future<RouteInfo> routeShortest({
    required double oLat,
    required double oLng,
    required double dLat,
    required double dLng,
    String mode = 'driving',
  }) async {
    final r = await _dio.get('/maps/route/shortest', queryParameters: {
      'o_lat': oLat,
      'o_lng': oLng,
      'd_lat': dLat,
      'd_lng': dLng,
      'mode': mode,
    });
    return RouteInfo.fromJson(Map<String, dynamic>.from(r.data as Map));
  }
}

