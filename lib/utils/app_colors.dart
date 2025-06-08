import 'package:flutter/material.dart';

/// AppColors is a utility class that defines the app's color scheme and gradients.
/// This ensures consistent colors throughout the application and makes it easy
/// to update the app's theme by modifying colors in one place.
class AppColors {
  // Primary colors used throughout the app
  /// Primary color - Royal Blue for app bar, buttons, main accents
  static const Color primaryRoyalBlue = Color(0xFF007BFF);
  
  /// Secondary/Button color - Coral Orange for buttons and highlights
  static const Color secondaryCoralOrange = Color(0xFFFF6B35);
  
  /// Background color - Clean Light for main background
  static const Color backgroundLight = Color(0xFFFAFAFA);
  
  /// Surface/Card background - Pure White for card background
  static const Color cardBackground = Color(0xFFFFFFFF);
  
  /// Text primary color - Strong readable black
  static const Color textPrimary = Color(0xFF1C1C1E);
  
  /// Text secondary color - Neutral support tone for subtext, labels
  static const Color textSecondary = Color(0xFF6B7280);
  
  /// Button text color - White for contrast
  static const Color buttonText = Color(0xFFFFFFFF);
  
  /// Success color - Calm Green for success indication
  static const Color successCalmGreen = Color(0xFF27AE60);
  
  /// Error color - Rich Red for error/warning
  static const Color errorRichRed = Color(0xFFE74C3C);
  
  // Legacy color names for backward compatibility
  static const Color primaryDarkBlue = primaryRoyalBlue;
  static const Color primaryDeepCyan = primaryRoyalBlue;
  static const Color secondaryTeal = secondaryCoralOrange;
  static const Color accentMustardYellow = secondaryCoralOrange;
  static const Color successGreen = successCalmGreen;
  static const Color successOliveGreen = successCalmGreen;
  static const Color errorRed = errorRichRed;
  static const Color errorRedClay = errorRichRed;
  
  /// Primary gradient using Royal Blue and lighter blue tones
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF007BFF), Color(0xFF0056CC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Secondary gradient with coral orange tones
  static const secondaryGradient = LinearGradient(
    colors: [Color(0xFFFF6B35), Color(0xFFFF8C69)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Color palette for different work types in the app
  /// These colors work well with the new Royal Blue and Coral Orange theme
  static const workTypeColors = [
    Color(0xFFE74C3C), // Rich Red - Used for urgent or important tasks
    Color(0xFF27AE60), // Calm Green - Used for development tasks
    Color(0xFF1ABC9C), // Teal - Used for planning tasks
    Color(0xFF8E44AD), // Purple - Used for research tasks
    Color(0xFFF39C12), // Orange - Used for in-progress or pending tasks
    Color(0xFF34495E), // Dark Gray - Used for documentation tasks
    Color(0xFFE91E63), // Pink - Used for design tasks
    Color(0xFF95A5A6), // Light Gray - Used for miscellaneous tasks
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
