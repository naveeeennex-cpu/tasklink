import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../design/widgets/lokal_button.dart';
import '../../../design/widgets/lokal_text_field.dart';
import '../controller/auth_controller.dart';

/// Single-screen signup — name, email, phone, password all on one page.
/// On submit the app either lands on mode selection (email confirm off)
/// or the OTP verification screen (email confirm on).
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final outcome =
        await ref.read(authControllerProvider.notifier).signupWithEmail(
              fullName: _name.text.trim(),
              email: _email.text.trim(),
              phone: _phone.text.trim(),
              password: _password.text,
            );
    if (!mounted) return;

    switch (outcome) {
      case SignupOutcome.loggedIn:
        context.go(LokalRoutes.modeSelect);
      case SignupOutcome.otpSent:
        context.go(LokalRoutes.verifyOtp);
      case SignupOutcome.error:
        final err = ref.read(authControllerProvider).error;
        if (err != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(err)),
          );
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      backgroundColor: LokalColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go(LokalRoutes.welcome),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: LokalSpacing.lg),
            children: [
              const SizedBox(height: LokalSpacing.md),
              Text('Create your\naccount',
                  style: LokalTypography.displayMd
                      .copyWith(height: 1.05, fontSize: 40)),
              const SizedBox(height: LokalSpacing.sm),
              Text(
                "It takes 30 seconds. We’ll email you a\n6-digit code to verify.",
                style: LokalTypography.bodyLg
                    .copyWith(color: LokalColors.onSurfaceVariant),
              ),
              const SizedBox(height: LokalSpacing.xl),

              LokalTextField(
                label: 'Full name',
                hint: 'e.g. Priya Sharma',
                controller: _name,
                prefixIcon: Icons.person_outline_rounded,
                autofillHints: const [AutofillHints.name],
                validator: (v) => (v == null || v.trim().length < 2)
                    ? 'Enter your name'
                    : null,
              ),
              const SizedBox(height: LokalSpacing.md),

              LokalTextField(
                label: 'Email',
                hint: 'you@lokal.app',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.mail_outline_rounded,
                autofillHints: const [AutofillHints.email],
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Enter a valid email'
                    : null,
              ),
              const SizedBox(height: LokalSpacing.md),

              LokalTextField(
                label: 'Phone',
                hint: '+91 98xxxxxxxx',
                controller: _phone,
                keyboardType: TextInputType.phone,
                prefixIcon: Icons.phone_iphone_rounded,
                autofillHints: const [AutofillHints.telephoneNumber],
                validator: (v) => (v == null || v.trim().length < 8)
                    ? 'Enter a valid phone'
                    : null,
              ),
              const SizedBox(height: LokalSpacing.md),

              LokalTextField(
                label: 'Password',
                hint: 'At least 8 characters',
                controller: _password,
                obscure: _obscure,
                prefixIcon: Icons.lock_outline_rounded,
                autofillHints: const [AutofillHints.newPassword],
                suffix: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    size: 20,
                    color: LokalColors.onSurfaceVariant,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                validator: (v) =>
                    (v == null || v.length < 8) ? 'Min 8 characters' : null,
              ),

              const SizedBox(height: LokalSpacing.xl),

              LokalButton(
                label: 'Create account',
                loading: auth.loading,
                onPressed: _submit,
              ),
              const SizedBox(height: LokalSpacing.md),
              Center(
                child: TextButton(
                  onPressed: () => context.go(LokalRoutes.login),
                  child: Text.rich(
                    TextSpan(
                      text: 'Already have an account?  ',
                      style: LokalTypography.bodyMd.copyWith(
                        color: LokalColors.onSurfaceVariant,
                      ),
                      children: [
                        TextSpan(
                          text: 'Log in',
                          style: LokalTypography.bodyMd.copyWith(
                            color: LokalColors.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
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
