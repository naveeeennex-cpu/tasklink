import 'package:google_sign_in/google_sign_in.dart';

/// Wraps `google_sign_in` for the LOKAL auth flow.
///
/// The `serverClientId` below is the **Web** OAuth client ID (client_type 3)
/// from google-services.json — Supabase needs a Web-type client for the
/// `sign_in_with_id_token` exchange to succeed.
///
/// Returned token strings should be forwarded to
/// [AuthController.signInWithGoogleIdToken].
class GoogleAuthService {
  GoogleAuthService._();
  static final GoogleAuthService instance = GoogleAuthService._();

  // Web OAuth client from google-services.json (oauth_client client_type = 3)
  static const _serverClientId =
      '594414222454-leq90b0c39cobg35krqdavdirkghdoej.apps.googleusercontent.com';

  final _signIn = GoogleSignIn.instance;
  bool _initialized = false;

  Future<void> _ensureInit() async {
    if (_initialized) return;
    await _signIn.initialize(serverClientId: _serverClientId);
    _initialized = true;
  }

  /// Prompts the user, returns the ID token (and optional access token)
  /// or `null` if the user cancelled.
  Future<GoogleAuthResult?> signIn() async {
    await _ensureInit();
    GoogleSignInAccount? account;
    try {
      account = await _signIn.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) return null;
      rethrow;
    }
    final auth = account.authentication;
    final idToken = auth.idToken;
    if (idToken == null) {
      throw StateError('Google returned no ID token — check serverClientId.');
    }
    return GoogleAuthResult(idToken: idToken);
  }

  Future<void> signOut() async {
    try {
      await _signIn.signOut();
    } catch (_) {
      // ignore
    }
  }
}

class GoogleAuthResult {
  const GoogleAuthResult({required this.idToken, this.accessToken});
  final String idToken;
  final String? accessToken;
}
