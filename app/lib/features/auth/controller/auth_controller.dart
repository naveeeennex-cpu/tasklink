import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/api_client.dart';
import '../../../core/models/enums.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/supabase_init.dart';

/// Outcome of a signup attempt. Drives how the UI routes next.
enum SignupOutcome {
  /// Email confirmation is OFF in Supabase — user is already logged in,
  /// straight to mode selection.
  loggedIn,

  /// Email confirmation is ON — Supabase sent a 6-digit OTP. The UI
  /// must navigate to the OTP verification screen.
  otpSent,

  /// Signup call failed. Check `AuthState.error` for details.
  error,
}

@immutable
class AuthState {
  const AuthState({
    this.user,
    this.loading = false,
    this.error,
    this.isNewUser = false,
    this.pendingEmail,
  });

  final UserProfile? user;
  final bool loading;
  final String? error;
  final bool isNewUser;

  /// Email address awaiting OTP verification — kept between the signup
  /// screen and the OTP verification screen so the user only types it
  /// once.
  final String? pendingEmail;

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    UserProfile? user,
    bool? loading,
    String? error,
    bool? isNewUser,
    String? pendingEmail,
    bool clearError = false,
    bool clearUser = false,
    bool clearPendingEmail = false,
  }) =>
      AuthState(
        user: clearUser ? null : (user ?? this.user),
        loading: loading ?? this.loading,
        error: clearError ? null : (error ?? this.error),
        isNewUser: isNewUser ?? this.isNewUser,
        pendingEmail: clearPendingEmail
            ? null
            : (pendingEmail ?? this.pendingEmail),
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

  /// Sign up with email/password.
  ///
  /// Returns:
  /// * [SignupOutcome.loggedIn] when Supabase's "Confirm email" is OFF —
  ///   the user is signed in immediately and routing should jump to the
  ///   mode selection screen.
  /// * [SignupOutcome.otpSent] when confirmation is ON — Supabase has
  ///   emailed a 6-digit code. Routing should show the OTP screen,
  ///   which then calls [verifyOtp].
  /// * [SignupOutcome.error] on failure.
  Future<SignupOutcome> signupWithEmail({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final sb = _sb;
    if (sb == null) {
      state = state.copyWith(error: 'Supabase not configured. See app/.env');
      return SignupOutcome.error;
    }
    state = state.copyWith(loading: true, clearError: true);
    try {
      final response = await sb.auth.signUp(
        email: email,
        password: password,
        data: {'full_name': fullName, 'phone': phone},
      );
      if (response.session != null) {
        await _loadProfile();
        state = state.copyWith(loading: false, isNewUser: true);
        return SignupOutcome.loggedIn;
      }
      // No session → awaiting email OTP confirmation.
      state = state.copyWith(
        loading: false,
        isNewUser: true,
        pendingEmail: email,
      );
      return SignupOutcome.otpSent;
    } on AuthException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
      return SignupOutcome.error;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return SignupOutcome.error;
    }
  }

  /// Verify the 6-digit OTP that Supabase emailed after [signupWithEmail].
  Future<bool> verifyOtp({
    required String email,
    required String token,
  }) async {
    final sb = _sb;
    if (sb == null) return false;
    state = state.copyWith(loading: true, clearError: true);
    try {
      await sb.auth.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
      );
      await _loadProfile();
      state = state.copyWith(loading: false, clearPendingEmail: true);
      return true;
    } on AuthException catch (e) {
      state = state.copyWith(loading: false, error: e.message);
      return false;
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
      return false;
    }
  }

  /// Resend the signup OTP to the pending email.
  Future<void> resendSignupOtp() async {
    final sb = _sb;
    final email = state.pendingEmail;
    if (sb == null || email == null) return;
    try {
      await sb.auth.resend(type: OtpType.signup, email: email);
    } catch (e) {
      state = state.copyWith(error: e.toString());
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
    ApiClient.instance.setActiveMode(mode.value).catchError((_) {});
  }

  void clearError() => state = state.copyWith(clearError: true);
}

final authControllerProvider =
    NotifierProvider<AuthController, AuthState>(AuthController.new);
