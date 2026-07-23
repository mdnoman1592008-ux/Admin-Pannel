import 'package:flutter/material.dart';
import 'app_colors.dart';

class GlassDecorations {
  static BoxDecoration glassCard({
    double borderRadius = 24.0,
    Color fillColor = AppColors.glassFill,
    Color borderColor = AppColors.glassBorder,
    List<BoxShadow>? shadows,
  }) {
    return BoxDecoration(
      color: fillColor,
      borderRadius: BorderRadius.circular(borderRadius),
      border: Border.all(color: borderColor, width: 1.0),
      boxShadow: shadows ??
          [
            const BoxShadow(
              color: Color(0x59000000),
              blurRadius: 32,
              offset: Offset(0, 8),
            ),
          ],
    );
  }
}
