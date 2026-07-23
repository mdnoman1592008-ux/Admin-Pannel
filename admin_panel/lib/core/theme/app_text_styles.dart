import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Ether Cinema Admin Panel — Premium Typography System
/// Primary: Inter Variable | Fallback: SF Pro Display
class AppTextStyles {
  AppTextStyles._();

  // ── Display ───────────────────────────────────────────────────────────
  static TextStyle display1() => GoogleFonts.inter(
        fontSize: 56,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -2.5,
        height: 1.1,
      );

  static TextStyle display2() => GoogleFonts.inter(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -1.5,
        height: 1.15,
      );

  // ── Headings ──────────────────────────────────────────────────────────
  static TextStyle h1() => GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimary,
        letterSpacing: -1.0,
        height: 1.2,
      );

  static TextStyle h2() => GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.5,
        height: 1.3,
      );

  static TextStyle h3() => GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.3,
        height: 1.4,
      );

  static TextStyle h4() => GoogleFonts.inter(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
        letterSpacing: -0.2,
        height: 1.4,
      );

  // ── Body ──────────────────────────────────────────────────────────────
  static TextStyle bodyLg() => GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.6,
      );

  static TextStyle body() => GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.6,
      );

  static TextStyle bodySm() => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecond,
        height: 1.5,
      );

  // ── Labels ────────────────────────────────────────────────────────────
  static TextStyle labelLg() => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecond,
        letterSpacing: 0.1,
        height: 1.4,
      );

  static TextStyle label() => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.textMuted,
        letterSpacing: 0.5,
        height: 1.4,
      );

  static TextStyle labelCaps() => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 1.2,
        height: 1.4,
      );

  // ── Mono ──────────────────────────────────────────────────────────────
  static TextStyle mono() => GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.primary,
        height: 1.6,
      );

  static TextStyle monoSm() => GoogleFonts.jetBrainsMono(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecond,
        height: 1.5,
      );

  // ── Special ───────────────────────────────────────────────────────────
  static TextStyle kpiValue() => GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w800,
        color: AppColors.textPrimary,
        letterSpacing: -1.5,
        height: 1.0,
      );

  static TextStyle kpiLabel() => GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecond,
        letterSpacing: 0.3,
      );

  static TextStyle navItem() => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecond,
        letterSpacing: -0.1,
      );

  static TextStyle navItemActive() => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.primary,
        letterSpacing: -0.1,
      );

  static TextStyle tableHeader() => GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        color: AppColors.textMuted,
        letterSpacing: 0.8,
      );

  static TextStyle tableCell() => GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimary,
        height: 1.4,
      );

  static TextStyle badge() => GoogleFonts.inter(
        fontSize: 10,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        height: 1.0,
      );
}
