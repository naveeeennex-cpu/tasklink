import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../../../design/widgets/lokal_button.dart';

class GetStartedScreen extends StatelessWidget {
  const GetStartedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LokalColors.surface,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(LokalSpacing.lg),
          child: Column(
            children: [
              const Spacer(),
              // Editorial hero image — a stack of rounded cards evoking
              // "services around you" without using a single sourced photo.
              Expanded(
                flex: 6,
                child: _HeroCollage(),
              ),
              const SizedBox(height: LokalSpacing.xl),
              Text(
                'Your city, on\nyour side.',
                textAlign: TextAlign.center,
                style: LokalTypography.displayMd
                    .copyWith(height: 1.05, fontSize: 40),
              ),
              const SizedBox(height: LokalSpacing.md),
              Text(
                'Rides, repairs, tech help and a friendly\nwalk — all from people nearby.',
                textAlign: TextAlign.center,
                style: LokalTypography.bodyLg.copyWith(
                  color: LokalColors.onSurfaceVariant,
                  height: 1.5,
                ),
              ),
              const Spacer(flex: 2),
              LokalButton(
                label: 'Get started',
                onPressed: () => context.go(LokalRoutes.welcome),
              ),
              const SizedBox(height: LokalSpacing.md),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroCollage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        return Stack(
          children: [
            // Backdrop soft blob
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      LokalColors.primaryContainer.withValues(alpha: 0.18),
                      Colors.transparent,
                    ],
                    radius: 0.9,
                  ),
                ),
              ),
            ),
            // Back card — blue gradient "ride"
            Positioned(
              top: 20,
              right: 0,
              width: w * 0.58,
              child: _Tile(
                height: 160,
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [LokalColors.primary, LokalColors.primaryContainer],
                ),
                child: const _TileContent(
                  icon: Icons.electric_scooter_rounded,
                  title: 'Instant Ride',
                  subtitle: 'Matched in seconds',
                  color: Colors.white,
                ),
              ),
            ),
            // Front card — white "expert"
            Positioned(
              top: 140,
              left: 0,
              width: w * 0.56,
              child: _Tile(
                height: 170,
                color: LokalColors.surfaceContainerLowest,
                child: const _TileContent(
                  icon: Icons.design_services_rounded,
                  title: 'Expert Help',
                  subtitle: 'Design • Code • More',
                ),
              ),
            ),
            // Chip — tertiary accent
            Positioned(
              top: 80,
              left: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: LokalColors.tertiary,
                  borderRadius: BorderRadius.circular(LokalRadius.pill),
                ),
                child: Text(
                  'FAST DELIVERY',
                  style: LokalTypography.labelMd.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.child,
    this.height = 140,
    this.color,
    this.gradient,
  });
  final Widget child;
  final double height;
  final Color? color;
  final Gradient? gradient;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: color,
        gradient: gradient,
        borderRadius: BorderRadius.circular(LokalRadius.xl),
        boxShadow: [
          BoxShadow(
            color: LokalColors.ambientShadow,
            blurRadius: 28,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      padding: const EdgeInsets.all(LokalSpacing.lg),
      child: child,
    );
  }
}

class _TileContent extends StatelessWidget {
  const _TileContent({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.color = LokalColors.onSurface,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Icon(icon, size: 30, color: color),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: LokalTypography.headlineSm.copyWith(color: color)),
            const SizedBox(height: 2),
            Text(subtitle,
                style: LokalTypography.bodySm.copyWith(
                  color: color == Colors.white
                      ? Colors.white70
                      : LokalColors.onSurfaceVariant,
                )),
          ],
        ),
      ],
    );
  }
}
