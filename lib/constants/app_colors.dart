import 'package:flutter/material.dart';

class AppColors {
  // Light Theme Colors
  static const Color lightBackground = Colors.white;
  static const Color lightSurface = Colors.white;
  static const Color lightText = Colors.black;
  static const Color lightTextSecondary = Color(0xFF666666);
  static const Color lightCardBackground = Colors.white;
  static const Color lightBorder = Color(0xFFE0E0E0);
  static const Color lightShadow = Color(0x1A000000);
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkText = Colors.white;
  static const Color darkTextSecondary = Color(0xFFB0B0B0);
  static const Color darkCardBackground = Color(0xFF2C2C2C);
  static const Color darkBorder = Color(0xFF404040);
  static const Color darkShadow = Color(0x33000000);
  
  // Common Colors
  static const Color primary = Color(0xFF2196F3);
  static const Color secondary = Color(0xFF03DAC6);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFFF5722);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);
  
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