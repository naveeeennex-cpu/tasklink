import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/enums.dart';
import '../../../core/router.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../design/widgets/lokal_button.dart';
import '../../auth/controller/auth_controller.dart';
import '../../profiles/controller/profiles_controller.dart';

class ModeSelectionScreen extends ConsumerStatefulWidget {
  const ModeSelectionScreen({super.key});

  @override
  ConsumerState<ModeSelectionScreen> createState() =>
      _ModeSelectionScreenState();
}

class _ModeSelectionScreenState extends ConsumerState<ModeSelectionScreen> {
  UserMode? _selected;

  @override
  void initState() {
    super.initState();
    // Prefetch profiles so the toggle can make an instant decision later.
    Future.microtask(
      () => ref.read(profilesControllerProvider.notifier).refresh(),
    );
  }

  void _continue() {
    if (_selected == null) return;
    ref.read(authControllerProvider.notifier).setActiveMode(_selected!);
    if (_selected == UserMode.consumer) {
      context.go(LokalRoutes.customerHome);
    } else {
      final profiles = ref.read(profilesControllerProvider);
      final needsOnboarding =
          (profiles.asData?.value ?? const []).isEmpty;
      context.go(needsOnboarding
          ? LokalRoutes.onboardingCategories
          : LokalRoutes.providerHome);
    }
  }

  @override
  Widget build(BuildContext context) {
    final name = ref.watch(authControllerProvider).user?.fullName.split(' ').first ?? 'there';
    return Scaffold(
      backgroundColor: LokalColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: LokalSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: LokalSpacing.xl),
              Text('Hi $name 👋',
                  style: LokalTypography.headlineMd),
              const SizedBox(height: LokalSpacing.sm),
              Text(
                'How are you using LOKAL\nright now?',
                style: LokalTypography.displayMd
                    .copyWith(height: 1.05, fontSize: 38),
              ),
              const SizedBox(height: LokalSpacing.xl),
              _ModeCard(
                selected: _selected == UserMode.consumer,
                icon: Icons.shopping_bag_rounded,
                title: 'I need help',
                subtitle:
                    'Book rides, find experts, and get things done nearby.',
                tint: LokalColors.primaryContainer,
                onTap: () => setState(() => _selected = UserMode.consumer),
              ),
              const SizedBox(height: LokalSpacing.md),
              _ModeCard(
                selected: _selected == UserMode.provider,
                icon: Icons.work_outline_rounded,
                title: 'I want to offer help',
                subtitle:
                    'Earn by driving, fixing, coding, or walking — on your time.',
                tint: LokalColors.tertiary,
                onTap: () => setState(() => _selected = UserMode.provider),
              ),
              const Spacer(),
              LokalButton(
                label: 'Continue',
                onPressed: _selected == null ? null : _continue,
              ),
              const SizedBox(height: LokalSpacing.sm),
              Center(
                child: TextButton(
                  onPressed: () async {
                    await ref.read(authControllerProvider.notifier).logout();
                    if (!context.mounted) return;
                    context.go(LokalRoutes.welcome);
                  },
                  child: Text('Log out',
                      style: LokalTypography.labelLg
                          .copyWith(color: LokalColors.onSurfaceVariant)),
                ),
              ),
              const SizedBox(height: LokalSpacing.sm),
            ],
          ),
        ),
      ),
    );
  }
}

class _ModeCard extends StatelessWidget {
  const _ModeCard({
    required this.selected,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.tint,
    required this.onTap,
  });

  final bool selected;
  final IconData icon;
  final String title;
  final String subtitle;
  final Color tint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(LokalRadius.xl),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          padding: const EdgeInsets.all(LokalSpacing.lg),
          decoration: BoxDecoration(
            color: LokalColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(LokalRadius.xl),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? tint.withValues(alpha: 0.25)
                    : LokalColors.ambientShadow,
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              color: selected ? tint : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(LokalRadius.lg),
                ),
                child: Icon(icon, color: tint, size: 28),
              ),
              const SizedBox(width: LokalSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: LokalTypography.headlineSm),
                    const SizedBox(height: 2),
                    Text(subtitle, style: LokalTypography.bodySm),
                  ],
                ),
              ),
              AnimatedScale(
                scale: selected ? 1 : 0,
                duration: const Duration(milliseconds: 180),
                child: Icon(Icons.check_circle_rounded, color: tint, size: 24),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
