import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../design/widgets/lokal_button.dart';
import '../controller/auth_controller.dart';

/// Six-box OTP input. Auto-advances as the user types, auto-submits
/// when all six digits are entered. Includes a 30-second resend cooldown.
class OtpVerificationScreen extends ConsumerStatefulWidget {
  const OtpVerificationScreen({super.key});

  @override
  ConsumerState<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState extends ConsumerState<OtpVerificationScreen> {
  final _controllers = List.generate(6, (_) => TextEditingController());
  final _focusNodes = List.generate(6, (_) => FocusNode());

  Timer? _cooldown;
  int _cooldownSecs = 0;

  @override
  void initState() {
    super.initState();
    _startCooldown();
  }

  @override
  void dispose() {
    _cooldown?.cancel();
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  void _onDigitChanged(int index, String value) {
    if (value.isEmpty) return;
    // If the user pasted a full code into one box, spread it.
    if (value.length > 1) {
      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
      for (var i = 0; i < 6; i++) {
        _controllers[i].text = i < digits.length ? digits[i] : '';
      }
      final lastFilled = digits.length.clamp(0, 6) - 1;
      if (lastFilled >= 0) {
        FocusScope.of(context).requestFocus(_focusNodes[lastFilled]);
      }
      setState(() {});
      if (_code.length == 6) _submit();
      return;
    }
    if (index < 5) {
      FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
    } else {
      _focusNodes[index].unfocus();
    }
    setState(() {});
    if (_code.length == 6) _submit();
  }

  void _onBackspace(int index) {
    if (index > 0 && _controllers[index].text.isEmpty) {
      FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
      _controllers[index - 1].clear();
      setState(() {});
    }
  }

  Future<void> _submit() async {
    final code = _code;
    if (code.length != 6) return;
    final email = ref.read(authControllerProvider).pendingEmail;
    if (email == null) {
      context.go(LokalRoutes.signup);
      return;
    }
    final ok = await ref.read(authControllerProvider.notifier).verifyOtp(
          email: email,
          token: code,
        );
    if (!mounted) return;
    if (ok) {
      context.go(LokalRoutes.modeSelect);
    } else {
      final err = ref.read(authControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'Invalid or expired code')),
      );
      // Clear so the user can retype.
      for (final c in _controllers) {
        c.clear();
      }
      FocusScope.of(context).requestFocus(_focusNodes[0]);
      setState(() {});
    }
  }

  void _startCooldown() {
    _cooldown?.cancel();
    setState(() => _cooldownSecs = 30);
    _cooldown = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) {
        t.cancel();
        return;
      }
      setState(() {
        _cooldownSecs--;
        if (_cooldownSecs <= 0) t.cancel();
      });
    });
  }

  Future<void> _resend() async {
    if (_cooldownSecs > 0) return;
    await ref.read(authControllerProvider.notifier).resendSignupOtp();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('A fresh code is on its way.')),
    );
    _startCooldown();
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authControllerProvider);
    final email = auth.pendingEmail ?? 'your inbox';
    return Scaffold(
      backgroundColor: LokalColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go(LokalRoutes.signup),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: LokalSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: LokalSpacing.md),
              Text('Verify your\nemail',
                  style: LokalTypography.displayMd
                      .copyWith(height: 1.05, fontSize: 40)),
              const SizedBox(height: LokalSpacing.sm),
              Text.rich(
                TextSpan(
                  text: 'We sent a 6-digit code to\n',
                  style: LokalTypography.bodyLg
                      .copyWith(color: LokalColors.onSurfaceVariant),
                  children: [
                    TextSpan(
                      text: email,
                      style: LokalTypography.bodyLg.copyWith(
                        color: LokalColors.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: LokalSpacing.xxl),

              // 6-box input
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (i) => _OtpBox(
                    controller: _controllers[i],
                    focusNode: _focusNodes[i],
                    onChanged: (v) => _onDigitChanged(i, v),
                    onBackspace: () => _onBackspace(i),
                  ),
                ),
              ),

              const SizedBox(height: LokalSpacing.xxl),

              LokalButton(
                label: 'Verify & continue',
                loading: auth.loading,
                onPressed: _code.length == 6 ? _submit : null,
              ),

              const SizedBox(height: LokalSpacing.lg),
              Center(
                child: _cooldownSecs > 0
                    ? Text(
                        'Resend code in $_cooldownSecs s',
                        style: LokalTypography.bodyMd.copyWith(
                          color: LokalColors.onSurfaceVariant,
                        ),
                      )
                    : TextButton(
                        onPressed: _resend,
                        child: Text(
                          'Resend code',
                          style: LokalTypography.labelLg
                              .copyWith(color: LokalColors.primary),
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

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onBackspace,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    final filled = controller.text.isNotEmpty;
    return SizedBox(
      width: 48,
      height: 58,
      child: KeyboardListener(
        focusNode: FocusNode(),
        onKeyEvent: (event) {
          if (event is KeyDownEvent &&
              event.logicalKey == LogicalKeyboardKey.backspace &&
              controller.text.isEmpty) {
            onBackspace();
          }
        },
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          style: LokalTypography.headlineMd,
          decoration: InputDecoration(
            counterText: '',
            filled: true,
            fillColor: filled
                ? LokalColors.surfaceContainerLowest
                : LokalColors.surfaceContainerLow,
            contentPadding: EdgeInsets.zero,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LokalRadius.md),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(LokalRadius.md),
              borderSide: BorderSide(
                color: LokalColors.primary.withValues(alpha: 0.5),
                width: 1.5,
              ),
            ),
          ),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
