import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/models/enums.dart';
import '../../../core/router.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../auth/controller/auth_controller.dart';
import '../../profiles/controller/profiles_controller.dart';

/// Top-bar toggle that flips between Consumer ↔ Provider. When a consumer
/// who has no service profiles flips to Provider, the app routes them
/// into onboarding instead of Provider Home.
class ModeToggle extends ConsumerWidget {
  const ModeToggle({super.key, this.dark = false});

  final bool dark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(
      authControllerProvider.select((s) => s.user?.activeMode ?? UserMode.consumer),
    );

    final bgColor = dark
        ? LokalColors.darkSurfaceContainer
        : LokalColors.surfaceContainerHigh;
    final pillColor = dark
        ? LokalColors.surfaceContainerLowest
        : LokalColors.surfaceContainerLowest;
    final activeText = dark ? LokalColors.darkSurface : LokalColors.onSurface;
    final inactiveText = dark
        ? LokalColors.onDarkSurfaceVariant
        : LokalColors.onSurfaceVariant;

    void flip(UserMode target) {
      if (target == mode) return;
      ref.read(authControllerProvider.notifier).setActiveMode(target);
      if (target == UserMode.consumer) {
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

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(LokalRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Seg(
            label: 'Consumer',
            selected: mode == UserMode.consumer,
            activeText: activeText,
            inactiveText: inactiveText,
            pillColor: pillColor,
            onTap: () => flip(UserMode.consumer),
          ),
          _Seg(
            label: 'Earner',
            selected: mode == UserMode.provider,
            activeText: activeText,
            inactiveText: inactiveText,
            pillColor: pillColor,
            onTap: () => flip(UserMode.provider),
          ),
        ],
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.activeText,
    required this.inactiveText,
    required this.pillColor,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color activeText;
  final Color inactiveText;
  final Color pillColor;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
            horizontal: LokalSpacing.md, vertical: LokalSpacing.xs + 2),
        decoration: BoxDecoration(
          color: selected ? pillColor : Colors.transparent,
          borderRadius: BorderRadius.circular(LokalRadius.pill),
        ),
        child: Text(
          label,
          style: LokalTypography.labelLg.copyWith(
            color: selected ? activeText : inactiveText,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
