import 'package:flutter/material.dart';

/// Ether Cinema Admin Panel — Premium Color Design System
/// Inspired by Linear, Vercel, Stripe, Supabase, Apple VisionOS
class AppColors {
  AppColors._();

  // ── Backgrounds ──────────────────────────────────────────────────────
  static const Color background   = Color(0xFF050608);
  static const Color surface      = Color(0xFF0F1117);
  static const Color surfaceHigh  = Color(0xFF161921);
  static const Color surfaceCard  = Color(0xFF13151C);

  // ── Glass ─────────────────────────────────────────────────────────────
  static const Color glass        = Color(0x14FFFFFF); // rgba(255,255,255,0.08)
  static const Color glassBorder  = Color(0x1FFFFFFF); // rgba(255,255,255,0.12)
  static const Color glassHover   = Color(0x22FFFFFF); // rgba(255,255,255,0.13)

  // ── Brand ─────────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF00D8FF); // Cyan
  static const Color secondary    = Color(0xFF7B61FF); // Purple
  static const Color accent       = Color(0xFF00FFC8); // Mint
  static const Color gold         = Color(0xFFFFD86A);

  // ── Semantic ──────────────────────────────────────────────────────────
  static const Color success      = Color(0xFF00E676);
  static const Color warning      = Color(0xFFFFC857);
  static const Color danger       = Color(0xFFFF4D6D);
  static const Color info         = Color(0xFF00D8FF);

  // ── Text ──────────────────────────────────────────────────────────────
  static const Color textPrimary  = Color(0xFFF0F2FF);
  static const Color textSecond   = Color(0xFF8B90A8);
  static const Color textMuted    = Color(0xFF4A4F6A);
  static const Color textDisabled = Color(0xFF2E3148);

  // ── Glow Shadows ──────────────────────────────────────────────────────
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

  // ── Gradients ─────────────────────────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00D8FF), Color(0xFF7B61FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF00FFC8), Color(0xFF00D8FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient goldGradient = LinearGradient(
    colors: [Color(0xFFFFD86A), Color(0xFFFF9F43)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient secondaryGradient = LinearGradient(
    colors: [Color(0xFF7B61FF), Color(0xFF4F46E5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient dangerGradient = LinearGradient(
    colors: [Color(0xFFFF4D6D), Color(0xFFFF6B35)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [Color(0xFF00E676), Color(0xFF00BFA5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient backgroundGradient = LinearGradient(
    colors: [Color(0xFF050608), Color(0xFF080B12), Color(0xFF050608)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Provider colors
  static const Color facebook = Color(0xFF1877F2);
  static const Color google   = Color(0xFF4285F4);
  static const Color email    = Color(0xFF8B90A8);
}
