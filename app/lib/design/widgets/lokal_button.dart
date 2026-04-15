import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

enum LokalButtonVariant { primary, secondary, ghost }

/// Pill-shaped button with gradient on primary for "liquid depth".
class LokalButton extends StatelessWidget {
  const LokalButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = LokalButtonVariant.primary,
    this.icon,
    this.fullWidth = true,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final LokalButtonVariant variant;
  final IconData? icon;
  final bool fullWidth;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == LokalButtonVariant.primary;
    final isSecondary = variant == LokalButtonVariant.secondary;

    final Color fg = isPrimary
        ? LokalColors.onPrimary
        : isSecondary
            ? LokalColors.onSurface
            : LokalColors.primary;

    final child = loading
        ? SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.4, color: fg),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 20, color: fg),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: LokalTypography.labelLg.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ],
          );

    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(LokalRadius.pill),
        onTap: loading ? null : onPressed,
        child: Ink(
          height: 56,
          decoration: BoxDecoration(
            gradient: isPrimary
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [LokalColors.primary, LokalColors.primaryContainer],
                  )
                : null,
            color: isPrimary
                ? null
                : isSecondary
                    ? LokalColors.secondaryContainer
                    : Colors.transparent,
            borderRadius: BorderRadius.circular(LokalRadius.pill),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: LokalColors.primary.withValues(alpha: 0.22),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Center(child: child),
        ),
      ),
    );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}
