import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/router.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../design/widgets/lokal_button.dart';
import '../../../design/widgets/lokal_text_field.dart';
import '../controller/onboarding_controller.dart';

class OnboardingVerificationScreen extends ConsumerStatefulWidget {
  const OnboardingVerificationScreen({super.key});

  @override
  ConsumerState<OnboardingVerificationScreen> createState() =>
      _OnboardingVerificationScreenState();
}

class _OnboardingVerificationScreenState
    extends ConsumerState<OnboardingVerificationScreen> {
  final _form = GlobalKey<FormState>();
  final _accountName = TextEditingController();
  final _upi = TextEditingController();
  File? _idPhoto;
  File? _selfie;
  final _picker = ImagePicker();

  @override
  void dispose() {
    _accountName.dispose();
    _upi.dispose();
    super.dispose();
  }

  Future<void> _pickIdPhoto() async {
    final f = await _picker.pickImage(source: ImageSource.camera,
        imageQuality: 70, maxWidth: 1600);
    if (f != null) setState(() => _idPhoto = File(f.path));
  }

  Future<void> _pickSelfie() async {
    final f = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        imageQuality: 70);
    if (f != null) setState(() => _selfie = File(f.path));
  }

  Future<void> _submit() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    ref.read(onboardingControllerProvider.notifier).saveVerification({
      'account_name': _accountName.text.trim(),
      'upi_id': _upi.text.trim(),
      if (_idPhoto != null) 'id_photo_path': _idPhoto!.path,
      if (_selfie != null) 'selfie_path': _selfie!.path,
    });
    final ok = await ref.read(onboardingControllerProvider.notifier).submit();
    if (!mounted) return;
    if (ok) {
      ref.read(onboardingControllerProvider.notifier).reset();
      context.go(LokalRoutes.providerHome);
    } else {
      final err = ref.read(onboardingControllerProvider).error;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(err ?? 'Could not save profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final submitting = ref.watch(onboardingControllerProvider).submitting;
    return Scaffold(
      backgroundColor: LokalColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go(LokalRoutes.onboardingForms),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _form,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: LokalSpacing.lg),
            children: [
              const SizedBox(height: LokalSpacing.md),
              Text('One last\nverification',
                  style: LokalTypography.displayMd
                      .copyWith(height: 1.05, fontSize: 36)),
              const SizedBox(height: LokalSpacing.sm),
              Text(
                'These keep LOKAL safe for everyone.\nDone once — used across every service.',
                style: LokalTypography.bodyLg
                    .copyWith(color: LokalColors.onSurfaceVariant),
              ),
              const SizedBox(height: LokalSpacing.xl),
              _UploadSlot(
                title: 'Government ID',
                subtitle: 'Aadhaar, driving license, or passport',
                icon: Icons.badge_outlined,
                file: _idPhoto,
                onPick: _pickIdPhoto,
              ),
              const SizedBox(height: LokalSpacing.md),
              _UploadSlot(
                title: 'Selfie',
                subtitle: 'Matches the face on your ID',
                icon: Icons.face_retouching_natural_rounded,
                file: _selfie,
                onPick: _pickSelfie,
              ),
              const SizedBox(height: LokalSpacing.xl),
              Text('Payment details', style: LokalTypography.headlineSm),
              const SizedBox(height: LokalSpacing.md),
              LokalTextField(
                label: 'Account holder name',
                hint: 'As on your bank / UPI',
                controller: _accountName,
                validator: (v) =>
                    (v == null || v.trim().length < 2) ? 'Enter a name' : null,
              ),
              const SizedBox(height: LokalSpacing.md),
              LokalTextField(
                label: 'UPI ID',
                hint: 'yourname@upi',
                controller: _upi,
                validator: (v) => (v == null || !v.contains('@'))
                    ? 'Enter a valid UPI id'
                    : null,
              ),
              const SizedBox(height: LokalSpacing.xl),
              LokalButton(
                label: 'Finish & go to Earner Home',
                loading: submitting,
                onPressed: _submit,
              ),
              const SizedBox(height: LokalSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _UploadSlot extends StatelessWidget {
  const _UploadSlot({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.file,
    required this.onPick,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final File? file;
  final VoidCallback onPick;

  @override
  Widget build(BuildContext context) {
    final done = file != null;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPick,
        borderRadius: BorderRadius.circular(LokalRadius.xl),
        child: Container(
          padding: const EdgeInsets.all(LokalSpacing.md + 4),
          decoration: BoxDecoration(
            color: LokalColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(LokalRadius.xl),
            boxShadow: [
              BoxShadow(
                color: LokalColors.ambientShadow,
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
            border: Border.all(
              width: 2,
              color: done ? LokalColors.primary : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: done
                      ? LokalColors.primary.withValues(alpha: 0.12)
                      : LokalColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(LokalRadius.md),
                ),
                child: Icon(
                  done ? Icons.check_rounded : icon,
                  color: done
                      ? LokalColors.primary
                      : LokalColors.onSurfaceVariant,
                  size: 26,
                ),
              ),
              const SizedBox(width: LokalSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: LokalTypography.headlineSm
                            .copyWith(fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(done ? 'Captured' : subtitle,
                        style: LokalTypography.bodySm),
                  ],
                ),
              ),
              const Icon(Icons.camera_alt_outlined,
                  color: LokalColors.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}
