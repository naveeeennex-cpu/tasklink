import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/enums.dart';
import '../../../core/router.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../design/widgets/lokal_button.dart';
import '../controller/onboarding_controller.dart';

class OnboardingCategoriesScreen extends ConsumerWidget {
  const OnboardingCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(onboardingControllerProvider);
    final controller = ref.read(onboardingControllerProvider.notifier);

    return Scaffold(
      backgroundColor: LokalColors.surface,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => context.go(LokalRoutes.modeSelect),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: LokalSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: LokalSpacing.md),
              Text('Become\nan Earner',
                  style: LokalTypography.displayMd
                      .copyWith(height: 1.05, fontSize: 40)),
              const SizedBox(height: LokalSpacing.sm),
              Text(
                'Pick every way you can help your\nneighbourhood. You can do more than one.',
                style: LokalTypography.bodyLg
                    .copyWith(color: LokalColors.onSurfaceVariant),
              ),
              const SizedBox(height: LokalSpacing.lg),
              Expanded(
                child: ListView(
                  children: [
                    _CategoryTile(
                      icon: Icons.electric_scooter_rounded,
                      tint: const Color(0xFF004AC6),
                      title: 'Ride & Delivery',
                      subtitle:
                          'Drive rides, deliver food, groceries, packages.',
                      selected:
                          state.selected.contains(ServiceCategory.rideDelivery),
                      onTap: () =>
                          controller.toggleCategory(ServiceCategory.rideDelivery),
                    ),
                    const SizedBox(height: LokalSpacing.md),
                    _CategoryTile(
                      icon: Icons.code_rounded,
                      tint: const Color(0xFF2563EB),
                      title: 'Techie',
                      subtitle:
                          'Web, app, design, AI — use your skills for hire.',
                      selected: state.selected.contains(ServiceCategory.techie),
                      onTap: () =>
                          controller.toggleCategory(ServiceCategory.techie),
                    ),
                    const SizedBox(height: LokalSpacing.md),
                    _CategoryTile(
                      icon: Icons.favorite_rounded,
                      tint: const Color(0xFF943700),
                      title: 'Support Partner',
                      subtitle:
                          'Walks, shopping trips, company — get paid to be kind.',
                      selected: state.selected
                          .contains(ServiceCategory.supportPartner),
                      onTap: () => controller
                          .toggleCategory(ServiceCategory.supportPartner),
                    ),
                    const SizedBox(height: LokalSpacing.md),
                    _CategoryTile(
                      icon: Icons.handyman_rounded,
                      tint: const Color(0xFF191C1E),
                      title: 'Non-Tech Services',
                      subtitle:
                          'Plumber, electrician, AC repair, cleaning, and more.',
                      selected:
                          state.selected.contains(ServiceCategory.nonTech),
                      onTap: () =>
                          controller.toggleCategory(ServiceCategory.nonTech),
                    ),
                  ],
                ),
              ),
              LokalButton(
                label: state.selected.isEmpty
                    ? 'Select at least one'
                    : 'Continue (${state.selected.length})',
                onPressed: state.selected.isEmpty
                    ? null
                    : () => context.go(LokalRoutes.onboardingForms),
              ),
              const SizedBox(height: LokalSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  const _CategoryTile({
    required this.icon,
    required this.tint,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });
  final IconData icon;
  final Color tint;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(LokalRadius.xl),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(LokalSpacing.md + 4),
          decoration: BoxDecoration(
            color: LokalColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(LokalRadius.xl),
            boxShadow: [
              BoxShadow(
                color: selected
                    ? tint.withValues(alpha: 0.25)
                    : LokalColors.ambientShadow,
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
            border: Border.all(
              width: 2,
              color: selected ? tint : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: tint.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(LokalRadius.md),
                ),
                child: Icon(icon, color: tint, size: 26),
              ),
              const SizedBox(width: LokalSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: LokalTypography.headlineSm.copyWith(fontSize: 16)),
                    const SizedBox(height: 2),
                    Text(subtitle, style: LokalTypography.bodySm),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: selected ? tint : Colors.transparent,
                  border: Border.all(
                    color: selected
                        ? tint
                        : LokalColors.outlineVariant.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(LokalRadius.sm),
                ),
                child: selected
                    ? const Icon(Icons.check_rounded,
                        size: 16, color: Colors.white)
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
