import 'package:flutter/material.dart';

import '../tokens/colors.dart';
import '../tokens/spacing.dart';

/// Breathable white card — xl radius, ambient tinted shadow, no borders.
class LokalCard extends StatelessWidget {
  const LokalCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(LokalSpacing.lg),
    this.radius = LokalRadius.xl,
    this.color,
    this.onTap,
    this.elevated = true,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final VoidCallback? onTap;
  final bool elevated;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? LokalColors.surfaceContainerLowest;
    final radiusObj = BorderRadius.circular(radius);

    final content = Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radiusObj,
        boxShadow: elevated
            ? [
                BoxShadow(
                  color: LokalColors.ambientShadow,
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
              ]
            : null,
      ),
      padding: padding,
      child: child,
    );

    if (onTap == null) return content;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: radiusObj,
        onTap: onTap,
        child: content,
      ),
    );
  }
}
