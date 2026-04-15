import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../design/widgets/lokal_button.dart';
import '../controller/auth_controller.dart';
import '../services/google_auth_service.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _googleBusy = false;

  Future<void> _continueWithGoogle() async {
    if (_googleBusy) return;
    setState(() => _googleBusy = true);
    try {
      final result = await GoogleAuthService.instance.signIn();
      if (result == null) {
        setState(() => _googleBusy = false);
        return; // cancelled
      }
      await ref.read(authControllerProvider.notifier).signInWithGoogleIdToken(
            result.idToken,
            accessToken: result.accessToken,
          );
      if (!mounted) return;
      final auth = ref.read(authControllerProvider);
      if (auth.isAuthenticated) {
        context.go(LokalRoutes.modeSelect);
      } else if (auth.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(auth.error!)),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google sign-in failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _googleBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LokalColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: LokalSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: LokalSpacing.xl),
              Text('Welcome to\nLOKAL',
                  style: LokalTypography.displayMd
                      .copyWith(height: 1.05, fontSize: 42)),
              const SizedBox(height: LokalSpacing.sm),
              Text(
                'Sign in to request services or start\noffering your own.',
                style: LokalTypography.bodyLg
                    .copyWith(color: LokalColors.onSurfaceVariant),
              ),
              const Spacer(),
              LokalButton(
                label: 'Log in',
                onPressed: () => context.go(LokalRoutes.login),
              ),
              const SizedBox(height: LokalSpacing.md),
              LokalButton(
                label: 'Create an account',
                variant: LokalButtonVariant.secondary,
                onPressed: () => context.go(LokalRoutes.signup),
              ),
              const SizedBox(height: LokalSpacing.lg),
              Row(
                children: [
                  const Expanded(child: _Divider()),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: LokalSpacing.md),
                    child: Text('or',
                        style: LokalTypography.labelMd
                            .copyWith(color: LokalColors.onSurfaceVariant)),
                  ),
                  const Expanded(child: _Divider()),
                ],
              ),
              const SizedBox(height: LokalSpacing.lg),
              LokalButton(
                label: 'Continue with Google',
                variant: LokalButtonVariant.secondary,
                icon: Icons.g_mobiledata_rounded,
                loading: _googleBusy,
                onPressed: _continueWithGoogle,
              ),
              const SizedBox(height: LokalSpacing.lg),
              Center(
                child: Text.rich(
                  TextSpan(
                    text: 'By continuing you agree to our ',
                    style: LokalTypography.caption,
                    children: [
                      TextSpan(
                        text: 'Terms',
                        style: LokalTypography.caption.copyWith(
                          color: LokalColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const TextSpan(text: '  •  '),
                      TextSpan(
                        text: 'Privacy',
                        style: LokalTypography.caption.copyWith(
                          color: LokalColors.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: LokalSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Container(
        height: 1,
        color: LokalColors.outlineVariant.withValues(alpha: 0.4),
      );
}
