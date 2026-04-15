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

/// Page-wise signup wizard. Each step collects exactly one logical chunk:
/// 1. Name     2. Email     3. Phone     4. Password
class SignupScreen extends ConsumerStatefulWidget {
  const SignupScreen({super.key});

  @override
  ConsumerState<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends ConsumerState<SignupScreen> {
  final _page = PageController();
  int _step = 0;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  final _nameForm = GlobalKey<FormState>();
  final _emailForm = GlobalKey<FormState>();
  final _phoneForm = GlobalKey<FormState>();
  final _passwordForm = GlobalKey<FormState>();

  bool _obscure = true;

  @override
  void dispose() {
    _page.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _next() {
    final ok = switch (_step) {
      0 => _nameForm.currentState?.validate() ?? false,
      1 => _emailForm.currentState?.validate() ?? false,
      2 => _phoneForm.currentState?.validate() ?? false,
      _ => true,
    };
    if (!ok) return;
    if (_step < 3) {
      _page.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      setState(() => _step++);
    }
  }

  void _back() {
    if (_step == 0) {
      context.go(LokalRoutes.welcome);
      return;
    }
    _page.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
    setState(() => _step--);
  }

  Future<void> _submit() async {
    if (!(_passwordForm.currentState?.validate() ?? false)) return;
    await ref.read(authControllerProvider.notifier).signupWithEmail(
          fullName: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          password: _passwordCtrl.text,
        );
    if (!mounted) return;
    final auth = ref.read(authControllerProvider);
    if (auth.isAuthenticated) {
      context.go(LokalRoutes.modeSelect);
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(auth.error!)));
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
          onPressed: _back,
        ),
        title: _StepIndicator(step: _step, total: 4),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _page,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _Step(
                    title: 'What should\nwe call you?',
                    subtitle: 'Your name will show on your bookings.',
                    form: _nameForm,
                    child: LokalTextField(
                      label: 'Full name',
                      hint: 'e.g. Priya Sharma',
                      controller: _nameCtrl,
                      prefixIcon: Icons.person_outline_rounded,
                      autofillHints: const [AutofillHints.name],
                      validator: (v) => (v == null || v.trim().length < 2)
                          ? 'Enter your name'
                          : null,
                    ),
                  ),
                  _Step(
                    title: 'Your email',
                    subtitle: 'We’ll use this for login and receipts.',
                    form: _emailForm,
                    child: LokalTextField(
                      label: 'Email',
                      hint: 'you@lokal.app',
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.mail_outline_rounded,
                      autofillHints: const [AutofillHints.email],
                      validator: (v) => (v == null || !v.contains('@'))
                          ? 'Enter a valid email'
                          : null,
                    ),
                  ),
                  _Step(
                    title: 'Phone number',
                    subtitle: 'Needed to contact you about requests.',
                    form: _phoneForm,
                    child: LokalTextField(
                      label: 'Phone',
                      hint: '+91 98xxxxxxxx',
                      controller: _phoneCtrl,
                      keyboardType: TextInputType.phone,
                      prefixIcon: Icons.phone_iphone_rounded,
                      autofillHints: const [AutofillHints.telephoneNumber],
                      validator: (v) => (v == null || v.trim().length < 8)
                          ? 'Enter a valid phone'
                          : null,
                    ),
                  ),
                  _Step(
                    title: 'Set a password',
                    subtitle: 'At least 8 characters. Mix it up.',
                    form: _passwordForm,
                    child: LokalTextField(
                      label: 'Password',
                      hint: 'Min 8 characters',
                      controller: _passwordCtrl,
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
                        onPressed: () =>
                            setState(() => _obscure = !_obscure),
                      ),
                      validator: (v) => (v == null || v.length < 8)
                          ? 'Min 8 characters'
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                LokalSpacing.lg,
                LokalSpacing.md,
                LokalSpacing.lg,
                LokalSpacing.lg,
              ),
              child: LokalButton(
                label: _step == 3 ? 'Create account' : 'Continue',
                loading: auth.loading,
                onPressed: _step == 3 ? _submit : _next,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.title,
    required this.subtitle,
    required this.child,
    required this.form,
  });
  final String title;
  final String subtitle;
  final Widget child;
  final GlobalKey<FormState> form;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LokalSpacing.lg),
      child: Form(
        key: form,
        child: ListView(
          children: [
            const SizedBox(height: LokalSpacing.md),
            Text(title,
                style:
                    LokalTypography.displayMd.copyWith(height: 1.05, fontSize: 38)),
            const SizedBox(height: LokalSpacing.sm),
            Text(
              subtitle,
              style: LokalTypography.bodyLg
                  .copyWith(color: LokalColors.onSurfaceVariant),
            ),
            const SizedBox(height: LokalSpacing.xl),
            child,
          ],
        ),
      ),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.step, required this.total});
  final int step;
  final int total;
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(total, (i) {
        final active = i <= step;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 22 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active
                ? LokalColors.primary
                : LokalColors.outlineVariant.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(LokalRadius.pill),
          ),
        );
      }),
    );
  }
}
