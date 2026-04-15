import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/controller/auth_controller.dart';
import '../features/auth/screens/forgot_password_screen.dart';
import '../features/auth/screens/get_started_screen.dart';
import '../features/auth/screens/login_screen.dart';
import '../features/auth/screens/otp_verification_screen.dart';
import '../features/auth/screens/signup_screen.dart';
import '../features/auth/screens/splash_screen.dart';
import '../features/auth/screens/welcome_screen.dart';
import '../features/home_customer/screens/customer_home_screen.dart';
import '../features/home_provider/screens/provider_home_screen.dart';
import '../features/mode/screens/mode_selection_screen.dart';
import '../features/onboarding/screens/onboarding_categories_screen.dart';
import '../features/onboarding/screens/onboarding_forms_screen.dart';
import '../features/onboarding/screens/onboarding_verification_screen.dart';

class LokalRoutes {
  LokalRoutes._();

  static const splash = '/';
  static const getStarted = '/get-started';
  static const welcome = '/welcome';
  static const login = '/login';
  static const signup = '/signup';
  static const verifyOtp = '/verify-otp';
  static const forgot = '/forgot-password';
  static const modeSelect = '/mode';
  static const customerHome = '/home/customer';
  static const providerHome = '/home/provider';
  static const onboardingCategories = '/onboarding/categories';
  static const onboardingForms = '/onboarding/forms';
  static const onboardingVerification = '/onboarding/verification';
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: LokalRoutes.splash,
    redirect: (context, state) {
      final auth = ref.read(authControllerProvider);
      final loc = state.matchedLocation;

      final isAuthPath = const {
        LokalRoutes.splash,
        LokalRoutes.getStarted,
        LokalRoutes.welcome,
        LokalRoutes.login,
        LokalRoutes.signup,
        LokalRoutes.verifyOtp,
        LokalRoutes.forgot,
      }.contains(loc);

      // Splash handles its own delay + decision.
      if (loc == LokalRoutes.splash) return null;

      if (!auth.isAuthenticated && !isAuthPath) {
        return LokalRoutes.welcome;
      }
      if (auth.isAuthenticated && isAuthPath) {
        return LokalRoutes.modeSelect;
      }
      return null;
    },
    routes: [
      GoRoute(path: LokalRoutes.splash, builder: (_, __) => const SplashScreen()),
      GoRoute(path: LokalRoutes.getStarted, builder: (_, __) => const GetStartedScreen()),
      GoRoute(path: LokalRoutes.welcome, builder: (_, __) => const WelcomeScreen()),
      GoRoute(path: LokalRoutes.login, builder: (_, __) => const LoginScreen()),
      GoRoute(path: LokalRoutes.signup, builder: (_, __) => const SignupScreen()),
      GoRoute(path: LokalRoutes.verifyOtp, builder: (_, __) => const OtpVerificationScreen()),
      GoRoute(path: LokalRoutes.forgot, builder: (_, __) => const ForgotPasswordScreen()),
      GoRoute(path: LokalRoutes.modeSelect, builder: (_, __) => const ModeSelectionScreen()),
      GoRoute(path: LokalRoutes.customerHome, builder: (_, __) => const CustomerHomeScreen()),
      GoRoute(path: LokalRoutes.providerHome, builder: (_, __) => const ProviderHomeScreen()),
      GoRoute(
        path: LokalRoutes.onboardingCategories,
        builder: (_, __) => const OnboardingCategoriesScreen(),
      ),
      GoRoute(
        path: LokalRoutes.onboardingForms,
        builder: (_, __) => const OnboardingFormsScreen(),
      ),
      GoRoute(
        path: LokalRoutes.onboardingVerification,
        builder: (_, __) => const OnboardingVerificationScreen(),
      ),
    ],
  );
});
