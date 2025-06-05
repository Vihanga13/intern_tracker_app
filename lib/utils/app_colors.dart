import 'package:flutter/material.dart';

class AppColors {
  // Primary colors
  static const Color primaryBlue = Color(0xFF667eea);
  static const Color accentGreen = Color(0xFF4ECDC4);
  static const Color accentPurple = Color(0xFF764ba2);
  static const Color accentOrange = Color(0xFFFECA57);

  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const secondaryGradient = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const workTypeColors = [
    Color(0xFFFF6B6B), // Red
    Color(0xFF4ECDC4), // Teal
    Color(0xFF45B7D1), // Blue
    Color(0xFF96CEB4), // Green
    Color(0xFFFECA57), // Yellow
    Color(0xFF6C5CE7), // Purple
    Color(0xFFFF9FF3), // Pink
    Color(0xFFF54EA2), // Magenta
  ];

  static Color getWorkTypeColor(String workType, int index) {
    return workTypeColors[index % workTypeColors.length];
  }
}
