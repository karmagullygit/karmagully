import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F5F7);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF1A1A2E);
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightCardBackground = Colors.white;
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightShadow = Color(0x1A000000);

  // Dark Theme Colors - Purple/Violet Gradient Theme (matching website)
  static const Color darkBackground = Color(0xFF0A0A1E);
  static const Color darkSurface = Color(0xFF1A1A2E);
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Color(0xFFB0B0C0);
  static const Color darkCardBackground = Color(0xFF1E1E30);
  static const Color darkBorder = Color(0xFF2E2E48);
  static const Color darkShadow = Color(0x33000000);

  // Purple/Violet Gradient Colors (matching website)
  static const Color primaryPurple = Color(0xFF7B2CBF);
  static const Color secondaryPurple = Color(0xFF9D4EDD);
  static const Color accentPurple = Color(0xFFC77DFF);
  static const Color lightPurple = Color(0xFFE0AAFF);

  // Gradient Colors
  static const Color gradientStart = Color(0xFF5B0DAE);
  static const Color gradientMiddle = Color(0xFF7B2CBF);
  static const Color gradientEnd = Color(0xFF9D4EDD);

  // Common Colors
  static const Color primary = Color(0xFF7B2CBF);
  static const Color secondary = Color(0xFF9D4EDD);
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color info = Color(0xFF3B82F6);

  // Neon/Glow Colors for accents
  static const Color neonPurple = Color(0xFFBF40BF);
  static const Color neonPink = Color(0xFFFF6EC7);
  static const Color neonBlue = Color(0xFF00D9FF);

  // Dynamic Colors based on theme
  static Color getBackgroundColor(bool isDarkMode) {
    return isDarkMode ? darkBackground : lightBackground;
  }

  static Color getSurfaceColor(bool isDarkMode) {
    return isDarkMode ? darkSurface : lightSurface;
  }

  static Color getTextColor(bool isDarkMode) {
    return isDarkMode ? darkText : lightText;
  }

  static Color getTextSecondaryColor(bool isDarkMode) {
    return isDarkMode ? darkTextSecondary : lightTextSecondary;
  }

  static Color getCardBackgroundColor(bool isDarkMode) {
    return isDarkMode ? darkCardBackground : lightCardBackground;
  }

  static Color getBorderColor(bool isDarkMode) {
    return isDarkMode ? darkBorder : lightBorder;
  }

  static Color getShadowColor(bool isDarkMode) {
    return isDarkMode ? darkShadow : lightShadow;
  }
}
