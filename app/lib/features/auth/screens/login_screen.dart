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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    await ref.read(authControllerProvider.notifier).loginWithEmail(
          email: _email.text.trim(),
          password: _password.text,
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
              Text('Welcome back', style: LokalTypography.displayMd),
              const SizedBox(height: LokalSpacing.xs),
              Text(
                'Log in to continue',
                style: LokalTypography.bodyLg
                    .copyWith(color: LokalColors.onSurfaceVariant),
              ),
              const SizedBox(height: LokalSpacing.xl),
              LokalTextField(
                label: 'Email',
                hint: 'you@lokal.app',
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                prefixIcon: Icons.mail_outline_rounded,
                autofillHints: const [AutofillHints.email],
                validator: (v) =>
                    (v == null || !v.contains('@')) ? 'Enter a valid email' : null,
              ),
              const SizedBox(height: LokalSpacing.md),
              LokalTextField(
                label: 'Password',
                hint: 'Your password',
                controller: _password,
                obscure: _obscure,
                prefixIcon: Icons.lock_outline_rounded,
                autofillHints: const [AutofillHints.password],
                suffix: IconButton(
                  icon: Icon(
                    _obscure
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: LokalColors.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                validator: (v) => (v == null || v.length < 8)
                    ? 'Min 8 characters'
                    : null,
              ),
              const SizedBox(height: LokalSpacing.sm),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => context.go(LokalRoutes.forgot),
                  child: Text(
                    'Forgot password?',
                    style: LokalTypography.labelLg
                        .copyWith(color: LokalColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: LokalSpacing.md),
              LokalButton(
                label: 'Log in',
                loading: auth.loading,
                onPressed: _submit,
              ),
              const SizedBox(height: LokalSpacing.lg),
              Center(
                child: TextButton(
                  onPressed: () => context.go(LokalRoutes.signup),
                  child: Text.rich(
                    TextSpan(
                      text: "New to LOKAL?  ",
                      style: LokalTypography.bodyMd.copyWith(
                        color: LokalColors.onSurfaceVariant,
                      ),
                      children: [
                        TextSpan(
                          text: 'Create an account',
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
            ],
          ),
        ),
      ),
    );
  }
}
