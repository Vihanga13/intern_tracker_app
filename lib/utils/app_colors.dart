import 'package:flutter/material.dart';

/// AppColors is a utility class that defines the app's color scheme and gradients.
/// This ensures consistent colors throughout the application and makes it easy
/// to update the app's theme by modifying colors in one place.
class AppColors {
  // Primary colors used throughout the app
  /// Main brand color, used for primary elements and actions
  static const Color primaryBlue = Color(0xFF667eea);
  
  /// Used for success states, confirmations, and environmental elements
  static const Color accentGreen = Color(0xFF4ECDC4);
  
  /// Used for secondary actions and depth in gradients
  static const Color accentPurple = Color(0xFF764ba2);
  
  /// Used for warnings, highlights, and attention-grabbing elements
  static const Color accentOrange = Color(0xFFFECA57);

  /// Primary gradient used for backgrounds and important UI elements
  /// Creates a smooth transition from blue to purple
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Secondary gradient used for cards and less prominent elements
  /// Creates a calming transition from teal to darker green
  static const secondaryGradient = LinearGradient(
    colors: [Color(0xFF4ECDC4), Color(0xFF44A08D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Color palette for different work types in the app
  /// These colors are used to distinguish between different categories
  /// of work entries in charts, lists, and other UI elements
  static const workTypeColors = [
    Color(0xFFFF6B6B), // Red - Used for urgent or important tasks
    Color(0xFF4ECDC4), // Teal - Used for development tasks
    Color(0xFF45B7D1), // Blue - Used for planning tasks
    Color(0xFF96CEB4), // Green - Used for completed or successful tasks
    Color(0xFFFECA57), // Yellow - Used for in-progress or pending tasks
    Color(0xFF6C5CE7), // Purple - Used for research tasks
    Color(0xFFFF9FF3), // Pink - Used for design tasks
    Color(0xFFF54EA2), // Magenta - Used for miscellaneous tasks
  ];

  /// Returns a color from the workTypeColors array based on the work type
  /// Uses modulo operator to ensure we never go out of bounds of the array
  /// [workType] - The type of work (unused currently but kept for future use)
  /// [index] - The index to use for color selection
  /// Returns a Color from the workTypeColors array
  static Color getWorkTypeColor(String workType, int index) {
    return workTypeColors[index % workTypeColors.length];
  }
}
