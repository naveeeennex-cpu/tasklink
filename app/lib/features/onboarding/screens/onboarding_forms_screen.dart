import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/enums.dart';
import '../../../core/router.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../design/widgets/lokal_button.dart';
import '../../../design/widgets/lokal_chip.dart';
import '../../../design/widgets/lokal_text_field.dart';
import '../controller/onboarding_controller.dart';

/// Dynamic per-category form. Walks the user through ONE category at a
/// time using a PageView so the flow is: category 1 form → category 2
/// form → … → Continue to verification.
class OnboardingFormsScreen extends ConsumerStatefulWidget {
  const OnboardingFormsScreen({super.key});

  @override
  ConsumerState<OnboardingFormsScreen> createState() =>
      _OnboardingFormsScreenState();
}

class _OnboardingFormsScreenState
    extends ConsumerState<OnboardingFormsScreen> {
  final _page = PageController();
  int _index = 0;

  late final List<ServiceCategory> _queue;

  @override
  void initState() {
    super.initState();
    _queue = ref
        .read(onboardingControllerProvider)
        .selected
        .toList(growable: false);
  }

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _onSaved() {
    if (_index < _queue.length - 1) {
      setState(() => _index++);
      _page.nextPage(
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
    } else {
      context.go(LokalRoutes.onboardingVerification);
    }
  }

  void _back() {
    if (_index == 0) {
      context.go(LokalRoutes.onboardingCategories);
      return;
    }
    setState(() => _index--);
    _page.previousPage(
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_queue.isEmpty) {
      return Scaffold(
        body: Center(
          child: LokalButton(
            label: 'Go back',
            fullWidth: false,
            onPressed: () => context.go(LokalRoutes.onboardingCategories),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: LokalColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: _back,
        ),
        title: Text(
          'Step ${_index + 1} of ${_queue.length}',
          style: LokalTypography.labelLg
              .copyWith(color: LokalColors.onSurfaceVariant),
        ),
      ),
      body: SafeArea(
        child: PageView(
          controller: _page,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final c in _queue) _FormForCategory(category: c, onSaved: _onSaved),
          ],
        ),
      ),
    );
  }
}

// ────────────────────────── Per-category forms ────────────────────────

class _FormForCategory extends StatelessWidget {
  const _FormForCategory({required this.category, required this.onSaved});
  final ServiceCategory category;
  final VoidCallback onSaved;

  @override
  Widget build(BuildContext context) {
    switch (category) {
      case ServiceCategory.rideDelivery:
        return _RideDeliveryForm(onSaved: onSaved);
      case ServiceCategory.techie:
        return _TechieForm(onSaved: onSaved);
      case ServiceCategory.supportPartner:
        return _SupportPartnerForm(onSaved: onSaved);
      case ServiceCategory.nonTech:
        return _NonTechForm(onSaved: onSaved);
    }
  }
}

class _FormShell extends StatelessWidget {
  const _FormShell({
    required this.title,
    required this.subtitle,
    required this.form,
    required this.body,
    required this.onContinue,
  });
  final String title;
  final String subtitle;
  final GlobalKey<FormState> form;
  final Widget body;
  final VoidCallback onContinue;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: LokalSpacing.lg),
      child: Form(
        key: form,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: LokalSpacing.md),
                  Text(title,
                      style: LokalTypography.displayMd
                          .copyWith(height: 1.05, fontSize: 36)),
                  const SizedBox(height: LokalSpacing.sm),
                  Text(subtitle,
                      style: LokalTypography.bodyLg
                          .copyWith(color: LokalColors.onSurfaceVariant)),
                  const SizedBox(height: LokalSpacing.xl),
                  body,
                ],
              ),
            ),
            LokalButton(
              label: 'Save & continue',
              onPressed: () {
                if (form.currentState?.validate() ?? false) onContinue();
              },
            ),
            const SizedBox(height: LokalSpacing.md),
          ],
        ),
      ),
    );
  }
}

// ── Ride & Delivery ─────────────────────────────────────────────────
class _RideDeliveryForm extends ConsumerStatefulWidget {
  const _RideDeliveryForm({required this.onSaved});
  final VoidCallback onSaved;
  @override
  ConsumerState<_RideDeliveryForm> createState() => _RideDeliveryFormState();
}

class _RideDeliveryFormState extends ConsumerState<_RideDeliveryForm> {
  final _form = GlobalKey<FormState>();
  final _vehicleNumber = TextEditingController();
  final _license = TextEditingController();
  String _vehicleType = 'bike';

  @override
  void dispose() {
    _vehicleNumber.dispose();
    _license.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormShell(
      title: 'Ride & Delivery',
      subtitle: 'Tell us about the vehicle you’ll use.',
      form: _form,
      onContinue: () {
        ref.read(onboardingControllerProvider.notifier).saveForm(
              ServiceCategory.rideDelivery,
              {
                'vehicle_type': _vehicleType,
                'vehicle_number': _vehicleNumber.text.trim(),
                'license_number': _license.text.trim(),
              },
            );
        widget.onSaved();
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Vehicle type', style: LokalTypography.labelLg),
          const SizedBox(height: LokalSpacing.sm),
          Wrap(
            spacing: LokalSpacing.sm,
            runSpacing: LokalSpacing.sm,
            children: [
              for (final t in const ['bike', 'auto', 'car', 'van'])
                LokalChip(
                  label: t.toUpperCase(),
                  selected: _vehicleType == t,
                  onTap: () => setState(() => _vehicleType = t),
                ),
            ],
          ),
          const SizedBox(height: LokalSpacing.lg),
          LokalTextField(
            label: 'Vehicle number',
            hint: 'TN 01 AB 1234',
            controller: _vehicleNumber,
            validator: (v) =>
                (v == null || v.length < 5) ? 'Enter vehicle number' : null,
          ),
          const SizedBox(height: LokalSpacing.md),
          LokalTextField(
            label: 'Driving license number',
            hint: 'TN0420240000000',
            controller: _license,
            validator: (v) => (v == null || v.length < 6)
                ? 'Enter a valid license number'
                : null,
          ),
          const SizedBox(height: LokalSpacing.md),
          const _UploadRow(
              label: 'RC document', hint: 'PDF or photo of RC book'),
          const SizedBox(height: LokalSpacing.sm),
          const _UploadRow(
              label: 'Insurance', hint: 'Upload the current insurance cert'),
        ],
      ),
    );
  }
}

// ── Techie ──────────────────────────────────────────────────────────
class _TechieForm extends ConsumerStatefulWidget {
  const _TechieForm({required this.onSaved});
  final VoidCallback onSaved;
  @override
  ConsumerState<_TechieForm> createState() => _TechieFormState();
}

class _TechieFormState extends ConsumerState<_TechieForm> {
  final _form = GlobalKey<FormState>();
  final _portfolio = TextEditingController();
  final _rate = TextEditingController();
  final _years = TextEditingController();
  final Set<String> _skills = {};

  static const _allSkills = [
    'Flutter',
    'React',
    'Python',
    'Figma',
    'Node.js',
    'AI/ML',
    'Next.js',
    'WordPress',
    'SEO',
  ];

  @override
  void dispose() {
    _portfolio.dispose();
    _rate.dispose();
    _years.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormShell(
      title: 'Techie profile',
      subtitle: 'What can you build for someone nearby?',
      form: _form,
      onContinue: () {
        if (_skills.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Pick at least one skill')),
          );
          return;
        }
        ref.read(onboardingControllerProvider.notifier).saveForm(
          ServiceCategory.techie,
          {
            'skills': _skills.toList(),
            'sub_skills': <String>[],
            'portfolio_url': _portfolio.text.trim(),
            'years_experience': int.tryParse(_years.text) ?? 0,
            'hourly_rate_inr': int.tryParse(_rate.text),
          },
        );
        widget.onSaved();
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Skills', style: LokalTypography.labelLg),
          const SizedBox(height: LokalSpacing.sm),
          Wrap(
            spacing: LokalSpacing.sm,
            runSpacing: LokalSpacing.sm,
            children: [
              for (final s in _allSkills)
                LokalChip(
                  label: s,
                  selected: _skills.contains(s),
                  onTap: () => setState(() =>
                      _skills.contains(s) ? _skills.remove(s) : _skills.add(s)),
                ),
            ],
          ),
          const SizedBox(height: LokalSpacing.lg),
          LokalTextField(
            label: 'Portfolio URL',
            hint: 'https://github.com/you',
            controller: _portfolio,
            keyboardType: TextInputType.url,
          ),
          const SizedBox(height: LokalSpacing.md),
          Row(
            children: [
              Expanded(
                child: LokalTextField(
                  label: 'Years exp.',
                  hint: '3',
                  controller: _years,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: LokalSpacing.md),
              Expanded(
                child: LokalTextField(
                  label: 'Rate (₹/hr)',
                  hint: '500',
                  controller: _rate,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Support Partner ─────────────────────────────────────────────────
class _SupportPartnerForm extends ConsumerStatefulWidget {
  const _SupportPartnerForm({required this.onSaved});
  final VoidCallback onSaved;
  @override
  ConsumerState<_SupportPartnerForm> createState() =>
      _SupportPartnerFormState();
}

class _SupportPartnerFormState extends ConsumerState<_SupportPartnerForm> {
  final _form = GlobalKey<FormState>();
  final _rate = TextEditingController();
  final Set<String> _languages = {};
  final Set<String> _personality = {};
  final Set<String> _prefs = {};

  static const _langs = [
    'English',
    'Tamil',
    'Hindi',
    'Telugu',
    'Kannada',
    'Malayalam'
  ];
  static const _tags = ['Calm', 'Chatty', 'Patient', 'Playful', 'Caring'];
  static const _preferences = ['Walks', 'Shopping', 'Talk', 'Reading', 'Tea'];

  @override
  void dispose() {
    _rate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormShell(
      title: 'Support partner',
      subtitle: 'A little about you — helps people choose their match.',
      form: _form,
      onContinue: () {
        ref.read(onboardingControllerProvider.notifier).saveForm(
          ServiceCategory.supportPartner,
          {
            'languages': _languages.toList(),
            'personality_tags': _personality.toList(),
            'preferences': _prefs.toList(),
            'hourly_rate_inr': int.tryParse(_rate.text),
          },
        );
        widget.onSaved();
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Languages', style: LokalTypography.labelLg),
          const SizedBox(height: LokalSpacing.sm),
          Wrap(
            spacing: LokalSpacing.sm,
            runSpacing: LokalSpacing.sm,
            children: [
              for (final l in _langs)
                LokalChip(
                  label: l,
                  selected: _languages.contains(l),
                  onTap: () => setState(() => _languages.contains(l)
                      ? _languages.remove(l)
                      : _languages.add(l)),
                ),
            ],
          ),
          const SizedBox(height: LokalSpacing.lg),
          Text('Personality', style: LokalTypography.labelLg),
          const SizedBox(height: LokalSpacing.sm),
          Wrap(
            spacing: LokalSpacing.sm,
            runSpacing: LokalSpacing.sm,
            children: [
              for (final t in _tags)
                LokalChip(
                  label: t,
                  selected: _personality.contains(t),
                  onTap: () => setState(() => _personality.contains(t)
                      ? _personality.remove(t)
                      : _personality.add(t)),
                ),
            ],
          ),
          const SizedBox(height: LokalSpacing.lg),
          Text('What you enjoy', style: LokalTypography.labelLg),
          const SizedBox(height: LokalSpacing.sm),
          Wrap(
            spacing: LokalSpacing.sm,
            runSpacing: LokalSpacing.sm,
            children: [
              for (final p in _preferences)
                LokalChip(
                  label: p,
                  selected: _prefs.contains(p),
                  onTap: () => setState(() => _prefs.contains(p)
                      ? _prefs.remove(p)
                      : _prefs.add(p)),
                ),
            ],
          ),
          const SizedBox(height: LokalSpacing.lg),
          LokalTextField(
            label: 'Hourly rate (₹)',
            hint: '250',
            controller: _rate,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
    );
  }
}

// ── Non-Tech ────────────────────────────────────────────────────────
class _NonTechForm extends ConsumerStatefulWidget {
  const _NonTechForm({required this.onSaved});
  final VoidCallback onSaved;
  @override
  ConsumerState<_NonTechForm> createState() => _NonTechFormState();
}

class _NonTechFormState extends ConsumerState<_NonTechForm> {
  final _form = GlobalKey<FormState>();
  final _years = TextEditingController();
  final _visit = TextEditingController();
  final _hourly = TextEditingController();
  String _trade = 'plumber';

  static const _trades = [
    'plumber',
    'electrician',
    'ac_repair',
    'cleaning',
    'carpenter',
    'painter'
  ];

  @override
  void dispose() {
    _years.dispose();
    _visit.dispose();
    _hourly.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _FormShell(
      title: 'Non-tech services',
      subtitle: 'Which trade do you practice?',
      form: _form,
      onContinue: () {
        ref.read(onboardingControllerProvider.notifier).saveForm(
          ServiceCategory.nonTech,
          {
            'trade': _trade,
            'years_experience': int.tryParse(_years.text) ?? 0,
            'visit_fee_inr': int.tryParse(_visit.text),
            'hourly_rate_inr': int.tryParse(_hourly.text),
          },
        );
        widget.onSaved();
      },
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Trade', style: LokalTypography.labelLg),
          const SizedBox(height: LokalSpacing.sm),
          Wrap(
            spacing: LokalSpacing.sm,
            runSpacing: LokalSpacing.sm,
            children: [
              for (final t in _trades)
                LokalChip(
                  label: t.replaceAll('_', ' ').toUpperCase(),
                  selected: _trade == t,
                  onTap: () => setState(() => _trade = t),
                ),
            ],
          ),
          const SizedBox(height: LokalSpacing.lg),
          LokalTextField(
            label: 'Years of experience',
            hint: '5',
            controller: _years,
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: LokalSpacing.md),
          Row(
            children: [
              Expanded(
                child: LokalTextField(
                  label: 'Visit fee (₹)',
                  hint: '150',
                  controller: _visit,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: LokalSpacing.md),
              Expanded(
                child: LokalTextField(
                  label: 'Hourly (₹)',
                  hint: '400',
                  controller: _hourly,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Upload row placeholder (real pick happens in verification screen) ─
class _UploadRow extends StatelessWidget {
  const _UploadRow({required this.label, required this.hint});
  final String label;
  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(LokalSpacing.md),
      decoration: BoxDecoration(
        color: LokalColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(LokalRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: LokalColors.primaryContainer.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(LokalRadius.sm),
            ),
            child: const Icon(Icons.upload_file_rounded,
                color: LokalColors.primary, size: 20),
          ),
          const SizedBox(width: LokalSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: LokalTypography.labelLg),
                Text(hint, style: LokalTypography.bodySm),
              ],
            ),
          ),
          Text('Optional',
              style: LokalTypography.caption
                  .copyWith(color: LokalColors.onSurfaceVariant)),
        ],
      ),
    );
  }
}
