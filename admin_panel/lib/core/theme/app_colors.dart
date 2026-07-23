import 'package:flutter/material.dart';

/// Ether Cinema — World-Class OTT Design System Colors (Glassmorphism 2.0)
class AppColors {
  AppColors._();

  // ── Backgrounds & Surfaces ───────────────────────────────────────────
  static const Color background   = Color(0xFF050608); // Luxury Black
  static const Color surface      = Color(0xFF0E1118); // Secondary Surface
  static const Color surfaceHigh  = Color(0xFF151A24); // Cards & Floating Panels
  static const Color surfaceCard  = Color(0xFF151A24);

  // ── Glass 2.0 ────────────────────────────────────────────────────────
  static const Color glass        = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color glassBorder  = Color(0x1FFFFFFF); // rgba(255,255,255,0.12)
  static const Color glassHover   = Color(0x28FFFFFF); // rgba(255,255,255,0.16)

  // ── Brand Accents ───────────────────────────────────────────────────
  static const Color primary      = Color(0xFF00CFFF); // Electric Blue
  static const Color secondary    = Color(0xFF7A5CFF); // Royal Purple
  static const Color accent       = Color(0xFF00FFC8); // Mint Accent
  static const Color gold         = Color(0xFFFFD66B); // Luxury Gold

  // ── Semantic Colors ─────────────────────────────────────────────────
  static const Color success      = Color(0xFF31D07F);
  static const Color warning      = Color(0xFFFFB84D);
  static const Color danger       = Color(0xFFFF5C73);
  static const Color info         = Color(0xFF00CFFF);

  // ── Typography Colors ────────────────────────────────────────────────
  static const Color textPrimary  = Color(0xFFFFFFFF);
  static const Color textSecond   = Color(0xFFA8B3C7);
  static const Color textMuted    = Color(0xFF4A4F6A);
  static const Color textDisabled = Color(0xFF2E3148);

  // ── Glow Effects ────────────────────────────────────────────────────
  static BoxShadow glowCyan({double blur = 24, double spread = 0, double opacity = 0.35}) =>
      BoxShadow(color: primary.withOpacity(opacity), blurRadius: blur, spreadRadius: spread);

  static BoxShadow glowPurple({double blur = 24, double spread = 0, double opacity = 0.35}) =>
      BoxShadow(color: secondary.withOpacity(opacity), blurRadius: blur, spreadRadius: spread);

  static BoxShadow glowMint({double blur = 24, double spread = 0, double opacity = 0.35}) =>
      BoxShadow(color: accent.withOpacity(opacity), blurRadius: blur, spreadRadius: spread);

  static BoxShadow glowGold({double blur = 24, double spread = 0, double opacity = 0.35}) =>
      BoxShadow(color: gold.withOpacity(opacity), blurRadius: blur, spreadRadius: spread);

  static BoxShadow softShadow() =>
      BoxShadow(color: Colors.black.withOpacity(0.45), blurRadius: 32, offset: const Offset(0, 8));

  // ── Gradients ───────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00CFFF), Color(0xFF7A5CFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00FFC8), Color(0xFF00CFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD66B), Color(0xFFFF9F43)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF7A5CFF), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFFF5C73), Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF31D07F), Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF050608), Color(0xFF0E1118), Color(0xFF050608)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Provider colors
  static const Color facebook = Color(0xFF1877F2);
  static const Color google   = Color(0xFF4285F4);
  static const Color email    = Color(0xFFA8B3C7);
}
