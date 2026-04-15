import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

/// LOKAL typography — Plus Jakarta Sans for editorial moments, Inter for
/// functional data. Contrast through scale/color, never mixed weights at
/// the same size.
class LokalTypography {
  LokalTypography._();

  static TextStyle _jakarta(
    double size, {
    FontWeight weight = FontWeight.w700,
    double letterSpacingPct = -0.02,
    Color color = LokalColors.onSurface,
    double height = 1.15,
  }) =>
      GoogleFonts.plusJakartaSans(
        fontSize: size,
        fontWeight: weight,
        letterSpacing: size * letterSpacingPct,
        color: color,
        height: height,
      );

  static TextStyle _inter(
    double size, {
    FontWeight weight = FontWeight.w500,
    Color color = LokalColors.onSurface,
    double height = 1.5,
  }) =>
      GoogleFonts.inter(
        fontSize: size,
        fontWeight: weight,
        color: color,
        height: height,
      );

  // Display & Headline — Plus Jakarta Sans
  static TextStyle get displayLg => _jakarta(48, weight: FontWeight.w800);
  static TextStyle get displayMd => _jakarta(36, weight: FontWeight.w800);
  static TextStyle get headlineLg => _jakarta(28, weight: FontWeight.w700);
  static TextStyle get headlineMd => _jakarta(22, weight: FontWeight.w700);
  static TextStyle get headlineSm => _jakarta(18, weight: FontWeight.w700);
  static TextStyle get titleMd => _jakarta(16, weight: FontWeight.w700, height: 1.3);

  // Body & Labels — Inter
  static TextStyle get bodyLg => _inter(16, weight: FontWeight.w500);
  static TextStyle get bodyMd => _inter(14, weight: FontWeight.w500);
  static TextStyle get bodySm => _inter(13, weight: FontWeight.w500, color: LokalColors.onSurfaceVariant);
  static TextStyle get labelLg => _inter(14, weight: FontWeight.w600);
  static TextStyle get labelMd => _inter(12, weight: FontWeight.w600, color: LokalColors.onSurfaceVariant);
  static TextStyle get caption => _inter(11, weight: FontWeight.w500, color: LokalColors.onSurfaceVariant);
}
