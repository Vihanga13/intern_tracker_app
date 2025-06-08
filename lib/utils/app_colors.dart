import 'package:flutter/material.dart';

/// AppColors is a utility class that defines the app's color scheme and gradients.
/// This ensures consistent colors throughout the application and makes it easy
/// to update the app's theme by modifying colors in one place.
class AppColors {  // Primary colors used throughout the app - Dark Theme
  /// Primary color - Dark Blue for app bar, buttons, main accents
  static const Color primaryRoyalBlue = Color(0xFF1E1E1E);
  
  /// Secondary/Button color - Accent color for buttons and highlights
  static const Color secondaryCoralOrange = Color(0xFF3F51B5);
  
  /// Background color - Dark background
  static const Color backgroundLight = Color(0xFF121212);
  
  /// Surface/Card background - Dark card background
  static const Color cardBackground = Color(0xFF1E1E1E);
  
  /// Text primary color - Light for dark theme
  static const Color textPrimary = Color(0xFFFFFFFF);
  
  /// Text secondary color - Medium gray for subtext, labels
  static const Color textSecondary = Color(0xFFB0B0B0);
  
  /// Button text color - White for contrast
  static const Color buttonText = Color(0xFFFFFFFF);
  
  /// Success color - Green for success indication
  static const Color successCalmGreen = Color(0xFF4CAF50);
  
  /// Error color - Red for error/warning
  static const Color errorRichRed = Color(0xFFF44336);
    // Legacy color names for backward compatibility
  static const Color primaryDarkBlue = primaryRoyalBlue;
  static const Color primaryDeepCyan = primaryRoyalBlue;
  static const Color secondaryTeal = secondaryCoralOrange;
  static const Color accentMustardYellow = secondaryCoralOrange;
  static const Color successGreen = successCalmGreen;
  static const Color successOliveGreen = successCalmGreen;
  static const Color errorRed = errorRichRed;
  static const Color errorRedClay = errorRichRed;
    /// Primary gradient using dark theme colors
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF1E1E1E), Color(0xFF2D2D2D)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Secondary gradient with accent colors
  static const secondaryGradient = LinearGradient(
    colors: [Color(0xFF3F51B5), Color(0xFF5C6BC0)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Color palette for different work types in the app - Dark Theme
  /// These colors use vibrant colors that work well on dark backgrounds
  static const workTypeColors = [
    Color(0xFF3F51B5), // Indigo - Used for urgent or important tasks
    Color(0xFF2196F3), // Blue - Used for development tasks
    Color(0xFF009688), // Teal - Used for planning tasks
    Color(0xFF4CAF50), // Green - Used for research tasks
    Color(0xFFFF9800), // Orange - Used for in-progress or pending tasks
    Color(0xFFE91E63), // Pink - Used for documentation tasks
    Color(0xFF9C27B0), // Purple - Used for design tasks
    Color(0xFF607D8B), // Blue Gray - Used for miscellaneous tasks
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
