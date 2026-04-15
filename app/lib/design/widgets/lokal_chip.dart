import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';
import '../tokens/typography.dart';

/// Pill-shaped selectable chip.
class LokalChip extends StatelessWidget {
  const LokalChip({
    super.key,
    required this.label,
    this.selected = false,
    this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(LokalRadius.pill),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: LokalSpacing.md + 2,
            vertical: LokalSpacing.sm + 2,
          ),
          decoration: BoxDecoration(
            color: selected
                ? LokalColors.primaryContainer
                : LokalColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(LokalRadius.pill),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon,
                    size: 16,
                    color: selected
                        ? LokalColors.onPrimary
                        : LokalColors.onSurface),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: LokalTypography.labelLg.copyWith(
                  color: selected
                      ? LokalColors.onPrimary
                      : LokalColors.onSurface,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
