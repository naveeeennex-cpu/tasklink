import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router.dart';
import '../../../design/tokens/colors.dart';
import '../../../design/tokens/spacing.dart';
import '../../../design/tokens/typography.dart';
import '../controller/auth_controller.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _anim = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1400), _decide);
  }

  void _decide() {
    if (!mounted) return;
    final auth = ref.read(authControllerProvider);
    context.go(
      auth.isAuthenticated ? LokalRoutes.modeSelect : LokalRoutes.getStarted,
    );
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: LokalColors.surface,
      body: Center(
        child: FadeTransition(
          opacity: _anim,
          child: ScaleTransition(
            scale: Tween(begin: 0.9, end: 1.0).animate(
              CurvedAnimation(parent: _anim, curve: Curves.easeOutBack),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [LokalColors.primary, LokalColors.primaryContainer],
                    ),
                    borderRadius: BorderRadius.circular(LokalRadius.lg),
                    boxShadow: [
                      BoxShadow(
                        color: LokalColors.primary.withValues(alpha: 0.35),
                        blurRadius: 32,
                        offset: const Offset(0, 16),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.waving_hand_rounded,
                      color: LokalColors.onPrimary, size: 40),
                ),
                const SizedBox(height: LokalSpacing.lg),
                Text('LOKAL', style: LokalTypography.displayMd),
                const SizedBox(height: LokalSpacing.xs),
                Text(
                  'Helping hands, just around the corner.',
                  style: LokalTypography.bodyLg
                      .copyWith(color: LokalColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
