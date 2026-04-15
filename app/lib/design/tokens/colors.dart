import 'package:flutter/material.dart';

/// LOKAL color tokens — "Soft Minimalism" palette.
/// Derived directly from the design system doc. Do not introduce raw hex
/// values outside this file; always reference a token.
class LokalColors {
  LokalColors._();

  // Brand
  static const Color primary = Color(0xFF004AC6);
  static const Color primaryContainer = Color(0xFF2563EB);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Surface foundations — tonal layering, no borders
  static const Color surface = Color(0xFFF7F9FB);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF1F4F8);
  static const Color surfaceContainerHigh = Color(0xFFE7ECF2);
  static const Color surfaceBright = Color(0xFFFFFFFF);

  // Accents
  static const Color secondaryContainer = Color(0xFFDEE3EC);
  static const Color onSecondaryFixed = Color(0xFF191C1E);
  static const Color tertiary = Color(0xFF943700); // editorial sparks / alerts

  // Text
  static const Color onSurface = Color(0xFF191C1E); // soft-black — never #000
  static const Color onSurfaceVariant = Color(0xFF6B7280);
  static const Color outlineVariant = Color(0xFFCBD2DC);

  // Provider-home dark palette (from the second reference screen)
  static const Color darkSurface = Color(0xFF0F1115);
  static const Color darkSurfaceContainer = Color(0xFF1A1D23);
  static const Color darkSurfaceContainerHigh = Color(0xFF242932);
  static const Color onDarkSurface = Color(0xFFF7F9FB);
  static const Color onDarkSurfaceVariant = Color(0xFF9BA3AF);
  static const Color success = Color(0xFF22C55E); // "ONLINE" pill

  // Ambient shadow tint (never plain black)
  static Color get ambientShadow => onSecondaryFixed.withValues(alpha: 0.06);
}
