import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tokens/colors.dart';
import 'tokens/typography.dart';

class LokalTheme {
  LokalTheme._();

  static ThemeData get light {
    final textTheme = TextTheme(
      displayLarge: LokalTypography.displayLg,
      displayMedium: LokalTypography.displayMd,
      headlineLarge: LokalTypography.headlineLg,
      headlineMedium: LokalTypography.headlineMd,
      headlineSmall: LokalTypography.headlineSm,
      titleMedium: LokalTypography.titleMd,
      bodyLarge: LokalTypography.bodyLg,
      bodyMedium: LokalTypography.bodyMd,
      bodySmall: LokalTypography.bodySm,
      labelLarge: LokalTypography.labelLg,
      labelMedium: LokalTypography.labelMd,
      labelSmall: LokalTypography.caption,
    );

    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: LokalColors.surface,
      colorScheme: const ColorScheme.light(
        primary: LokalColors.primary,
        onPrimary: LokalColors.onPrimary,
        primaryContainer: LokalColors.primaryContainer,
        onPrimaryContainer: LokalColors.onPrimary,
        secondary: LokalColors.primaryContainer,
        onSecondary: LokalColors.onPrimary,
        secondaryContainer: LokalColors.secondaryContainer,
        onSecondaryContainer: LokalColors.onSurface,
        surface: LokalColors.surface,
        onSurface: LokalColors.onSurface,
        surfaceContainerLowest: LokalColors.surfaceContainerLowest,
        surfaceContainerLow: LokalColors.surfaceContainerLow,
        surfaceContainerHigh: LokalColors.surfaceContainerHigh,
        tertiary: LokalColors.tertiary,
        onTertiary: LokalColors.onPrimary,
        outlineVariant: LokalColors.outlineVariant,
        error: Color(0xFFBA1A1A),
        onError: Colors.white,
      ),
      textTheme: GoogleFonts.interTextTheme(textTheme),
      appBarTheme: AppBarTheme(
        backgroundColor: LokalColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
        centerTitle: false,
        titleTextStyle: LokalTypography.headlineSm,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
