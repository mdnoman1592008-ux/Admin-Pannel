import 'package:flutter/material.dart';

/// Ether Cinema Design System Luxury Dark Palette & Color Tokens
class AppColors {
  // Luxury Backgrounds & Surfaces
  static const Color background = Color(0xFF050505); // Luxury Deep Black (#050505)
  static const Color luxuryBackground = Color(0xFF050608); // Alternative Dark Tint (#050608)
  static const Color surface = Color(0xFF131313); // Elevated Surface (#131313 / #0E1118)
  static const Color card = Color(0xFF151A24); // Luxury Floating Card (#151A24)
  static const Color surfaceContainerLow = Color(0xFF1C1B1B);
  static const Color surfaceContainer = Color(0xFF201F1F);
  static const Color surfaceContainerHigh = Color(0xFF2A2A2A);
  static const Color surfaceContainerHighest = Color(0xFF353534);
  static const Color surfaceBright = Color(0xFF3A3939);

  // Primary (Electric Blue Accent #00D4FF / #00CFFF)
  static const Color primary = Color(0xFFA8E8FF);
  static const Color primaryContainer = Color(0xFF00D4FF);
  static const Color electricBlue = Color(0xFF00CFFF);
  static const Color onPrimary = Color(0xFF003642);
  static const Color onPrimaryContainer = Color(0xFF00586B);

  // Secondary (Royal Purple Accent #7000FF / #7A5CFF)
  static const Color secondary = Color(0xFFD1BCFF);
  static const Color secondaryContainer = Color(0xFF7000FF);
  static const Color royalPurple = Color(0xFF7A5CFF);
  static const Color onSecondary = Color(0xFF3C0090);
  static const Color onSecondaryContainer = Color(0xFFDDCDFF);

  // Tertiary (Luxury Gold Accent #FFD66B)
  static const Color tertiary = Color(0xFFFFDD4C);
  static const Color tertiaryContainer = Color(0xFFE4C000);
  static const Color luxuryGold = Color(0xFFFFD66B);
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
    colors: [Color(0xFFFFD66B), Color(0xFFE4C000)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );
}
