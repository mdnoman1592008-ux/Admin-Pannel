import 'package:flutter/material.dart';

/// Ether Cinema Design System Color Palette
class AppColors {
  // Backgrounds & Surfaces
  static const Color background = Color(0xFF050505);
  static const Color surface = Color(0xFF131313);
  static const Color surfaceContainerLow = Color(0xFF1C1B1B);
  static const Color surfaceContainer = Color(0xFF201F1F);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest = Color(0xFF353534);
  static const Color surfaceBright = Color(0xFF3A3939);

  // Primary (Electric Cyan / Blue Glow)
  static const Color primary = Color(0xFFA8E8FF);
  static const Color primaryContainer = Color(0xFF00D4FF);
  static const Color onPrimary = Color(0xFF003642);
  static const Color onPrimaryContainer = Color(0xFF00586B);

  // Secondary (Royal Purple)
  static const Color secondary = Color(0xFFD1BCFF);
  static const Color secondaryContainer = Color(0xFF7000FF);
  static const Color onSecondary = Color(0xFF3C0090);
  static const Color onSecondaryContainer = Color(0xFFDDCDFF);

  // Tertiary (Luxury Gold)
  static const Color tertiary = Color(0xFFFFDD4C);
  static const Color tertiaryContainer = Color(0xFFE4C000);
  static const Color onTertiary = Color(0xFF3A3000);
  static const Color tertiaryFixed = Color(0xFFFFE16D);

  // Neutral & Outline
  static const Color onBackground = Color(0xFFE5E2E1);
  static const Color onSurface = Color(0xFFE5E2E1);
  static const Color onSurfaceVariant = Color(0xFFBBC9CF);
  static const Color outline = Color(0xFF859398);
  static const Color outlineVariant = Color(0xFF3C494E);

  // Glass Specular Effects
  static const Color glassBorder = Color(0x33FFFFFF);
  static const Color glassFill = Color(0x0DFFFFFF);
  static const Color glassGlowBlue = Color(0x6600D4FF);
  static const Color glassGlowPurple = Color(0x667000FF);

  // Gradients
  static const LinearGradient liquidGradient = LinearGradient(
    colors: [Color(0xFF00D4FF), Color(0xFF7000FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient luxuryGoldGradient = LinearGradient(
    colors: [Color(0xFFFFE16D), Color(0xFFE4C000)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
