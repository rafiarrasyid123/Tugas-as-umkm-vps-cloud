import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Palet Warna Neo-Brutalism Tech Cloud
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFF0F172A); // Slate 900
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textMuted = Color(0xFF64748B);
  static const Color primary = Color(0xFF4F46E5); // Indigo
  static const Color primaryLight = Color(0xFFEEF2FF);
  static const Color accent = Color(0xFF06B6D4); // Cyan
  static const Color accentSoft = Color(0xFFE0F2FE);
  static const Color success = Color(0xFF10B981); // Emerald
  static const Color danger = Color(0xFFEF4444); // Red

  // Dekorasi Khas Neo-Brutalism (Border tebal + Shadow padat tanpa blur)
  static BoxDecoration neoDecoration({
    Color color = surface,
    double radius = 12,
    double borderWidth = 2.0,
    Offset shadowOffset = const Offset(3, 3),
    Color borderColor = border,
    Color shadowColor = border,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: borderColor, width: borderWidth),
      boxShadow: [
        BoxShadow(
          color: shadowColor,
          offset: shadowOffset,
          blurRadius: 0,
        ),
      ],
    );
  }

  static ThemeData get theme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: background,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: GoogleFonts.inter(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: border,
        thickness: 1.5,
        space: 1,
      ),
    );
  }
}
