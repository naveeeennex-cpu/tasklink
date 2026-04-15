import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/api_client.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/supabase_init.dart';

/// Authentication + current user state.
/// `null` user means logged out.
@immutable
class AuthState {
  const AuthState({
    this.user,
    this.loading = false,
    this.error,
    this.isNewUser = false,
  });

  final UserProfile? user;
  final bool loading;
  final String? error;
  final bool isNewUser;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserProfile? user,
    bool? loading,
    String? error,
    bool? isNewUser,
    bool clearError = false,
    bool clearUser = false,
  }) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
        isNewUser: isNewUser ?? this.isNewUser,
      );
}

class AuthController extends Notifier<AuthState> {
  @override
  AuthState build() {
    Future.microtask(_bootstrap);
    return const AuthState();
  }

  SupabaseClient? get _sb => SupabaseInit.clientOrNull;

  Future<void> _bootstrap() async {
    final sb = _sb;
    if (sb == null) return;
    final session = sb.auth.currentSession;
    if (session != null) {
      await _loadProfile();
    }
    sb.auth.onAuthStateChange.listen((data) async {
      if (data.session == null) {
        state = state.copyWith(clearUser: true);
      } else if (state.user == null) {
        await _loadProfile();
      }
    });
  }

  Future<void> _loadProfile() async {
    try {
      final data = await ApiClient.instance.getMe();
      state = state.copyWith(user: UserProfile.fromJson(data), clearError: true);
    } catch (_) {
      // Backend may not be reachable yet in local dev — fall back to the
      // Supabase user object so the app still routes correctly.
      final sb = _sb;
      final u = sb?.auth.currentUser;
      if (u != null) {
        state = state.copyWith(
          user: UserProfile(
            id: u.id,
            email: u.email ?? '',
            fullName: (u.userMetadata?['full_name'] as String?) ?? '',
            phone: u.userMetadata?['phone'] as String?,
            activeMode: UserMode.consumer,
          ),
        );
      }
    }
  }

  Future<void> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final sb = _sb;
    if (sb == null) {
      state = state.copyWith(error: 'Supabase not configured. See app/.env');
      return;
    }
    state = state.copyWith(loading: true, clearError: true);
    try {
      await sb.auth.signInWithPassword(email: email, password: password);
      await _loadProfile();
      state = state.copyWith(loading: false);
    } on AuthException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> signupWithEmail({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final sb = _sb;
    if (sb == null) {
      state = state.copyWith(error: 'Supabase not configured. See app/.env');
      return;
    }
    state = state.copyWith(loading: true, clearError: true);
    try {
      await sb.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'phone': phone},
      );
      await _loadProfile();
      state = state.copyWith(loading: false, isNewUser: true);
    } on AuthException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> signInWithGoogleIdToken(String idToken,
      {String? accessToken}) async {
    final sb = _sb;
    if (sb == null) {
      state = state.copyWith(error: 'Supabase not configured');
      return;
    }
    state = state.copyWith(loading: true, clearError: true);
    try {
      await sb.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
      await _loadProfile();
      state = state.copyWith(loading: false);
    } on AuthException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> sendPasswordReset(String email) async {
    final sb = _sb;
    if (sb == null) return;
    state = state.copyWith(loading: true, clearError: true);
    try {
      await sb.auth.resetPasswordForEmail(email);
      state = state.copyWith(loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> logout() async {
    await _sb?.auth.signOut();
    state = const AuthState();
  }

  void setActiveMode(UserMode mode) {
    if (state.user == null) return;
    state = state.copyWith(user: state.user!.copyWith(activeMode: mode));
    // Fire-and-forget server update.
    ApiClient.instance.setActiveMode(mode.value).catchError((_) {});
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
