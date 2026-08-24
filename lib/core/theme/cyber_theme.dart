import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class CyberTheme {
  static bool isLight = false;

  // Theme Colors - Cyberpunk Red Palette
  static Color get neonBlue => isLight ? const Color(0xFF007AFF) : const Color(0xFFFF1E27); // iOS Blue or Neon Red Accent
  static Color get electricPurple => isLight ? const Color(0xFF1F3A60) : const Color(0xFF800000); // Deep Blue or Deep Crimson
  static Color get cyberPink => isLight ? const Color(0xFF3498DB) : const Color(0xFFFF5252); // Bright Blue or Bright Red-Orange
  static Color get darkMetallic => isLight ? const Color(0xFFF1F5F9) : const Color(0xFF020204); // Light Gray or Deep Obsidian Black
  static Color get cardBack => isLight ? const Color(0x0F000000) : const Color(0x15FFFFFF);
  static Color get cyanGlow => isLight ? const Color(0xFF0056B3) : const Color(0xFFFF3333); // Blue Glow or Red Glow
  static Color get textMain => isLight ? const Color(0xFF0F172A) : const Color(0xFFE2E8F0);
  static Color get textMuted => isLight ? const Color(0xFF475569) : const Color(0xFF94A3B8);

  // Gradient definitions
  static LinearGradient get cyberGradient => LinearGradient(
    colors: [neonBlue, electricPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get accentGradient => LinearGradient(
    colors: [cyberPink, electricPurple],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static LinearGradient get hologramGradient => LinearGradient(
    colors: [neonBlue.withOpacity(isLight ? 0.05 : 0.20), electricPurple.withOpacity(isLight ? 0.01 : 0.05)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Glow Shadows
  static List<BoxShadow> neonGlow({Color? color, double blurRadius = 8}) {
    final c = color ?? neonBlue;
    return [
      BoxShadow(
        color: c.withOpacity(isLight ? 0.15 : 0.5),
        blurRadius: blurRadius,
        spreadRadius: 1,
      ),
      BoxShadow(
        color: c.withOpacity(isLight ? 0.05 : 0.2),
        blurRadius: blurRadius * 2,
        spreadRadius: 2,
      ),
    ];
  }

  // Futuristic Typography helper methods
  static TextStyle titleStyle({double fontSize = 24, Color? color}) {
    Color resolvedColor = color ?? textMain;
    if (isLight && (resolvedColor == Colors.white || resolvedColor == textMain)) {
      resolvedColor = textMain;
    }
    return GoogleFonts.orbitron(
      fontSize: fontSize,
      fontWeight: FontWeight.bold,
      color: resolvedColor,
      letterSpacing: 2.0,
      shadows: isLight ? null : [
        Shadow(
          color: neonBlue.withOpacity(0.8),
          blurRadius: 12,
        ),
      ],
    );
  }

  static TextStyle headingStyle({double fontSize = 18, Color? color}) {
    Color resolvedColor = color ?? textMain;
    if (isLight && (resolvedColor == Colors.white || resolvedColor == textMain)) {
      resolvedColor = textMain;
    }
    return GoogleFonts.orbitron(
      fontSize: fontSize,
      fontWeight: FontWeight.w600,
      color: resolvedColor,
      letterSpacing: 1.5,
    );
  }

  static TextStyle bodyStyle({double fontSize = 14, Color? color}) {
    Color resolvedColor = color ?? textMain;
    if (isLight && (resolvedColor == Colors.white || resolvedColor == textMain)) {
      resolvedColor = textMain;
    }
    return GoogleFonts.spaceGrotesk(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: resolvedColor,
    );
  }

  static TextStyle monospaceStyle({double fontSize = 12, Color? color}) {
    Color resolvedColor = color ?? cyanGlow;
    if (isLight && (resolvedColor == Colors.white || resolvedColor == cyanGlow)) {
      resolvedColor = cyanGlow;
    }
    return GoogleFonts.shareTechMono(
      fontSize: fontSize,
      fontWeight: FontWeight.w400,
      color: resolvedColor,
    );
  }
}
