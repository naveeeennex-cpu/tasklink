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

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  bool _sent = false;

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    await ref
        .read(authControllerProvider.notifier)
        .sendPasswordReset(_email.text.trim());
    if (!mounted) return;
    setState(() => _sent = true);
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    return Scaffold(
      backgroundColor: LokalColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go(LokalRoutes.login),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: LokalSpacing.lg),
          child: _sent
              ? _SuccessBody(email: _email.text.trim())
              : Form(
                  key: _form,
                  child: ListView(
                    children: [
                      const SizedBox(height: LokalSpacing.md),
                      Text('Reset your\npassword',
                          style: LokalTypography.displayMd
                              .copyWith(height: 1.05, fontSize: 40)),
                      const SizedBox(height: LokalSpacing.sm),
                      Text(
                        'Enter your email and we’ll send you a\nreset link.',
                        style: LokalTypography.bodyLg
                            .copyWith(color: LokalColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: LokalSpacing.xl),
                      LokalTextField(
                        label: 'Email',
                        controller: _email,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.mail_outline_rounded,
                        validator: (v) => (v == null || !v.contains('@'))
                            ? 'Enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: LokalSpacing.lg),
                      LokalButton(
                        label: 'Send reset link',
                        loading: auth.loading,
                        onPressed: _submit,
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}

class _SuccessBody extends StatelessWidget {
  const _SuccessBody({required this.email});
  final String email;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            color: LokalColors.primaryContainer.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(LokalRadius.lg),
          ),
          child: const Icon(Icons.mark_email_read_rounded,
              size: 40, color: LokalColors.primary),
        ),
        const SizedBox(height: LokalSpacing.lg),
        Text('Check your inbox', style: LokalTypography.headlineLg),
        const SizedBox(height: LokalSpacing.sm),
        Text(
          'If an account exists for\n$email\nwe’ve sent a reset link.',
          textAlign: TextAlign.center,
          style: LokalTypography.bodyLg
              .copyWith(color: LokalColors.onSurfaceVariant),
        ),
        const SizedBox(height: LokalSpacing.xl),
        LokalButton(
          label: 'Back to login',
          onPressed: () => context.go(LokalRoutes.login),
        ),
      ],
    );
  }
}
