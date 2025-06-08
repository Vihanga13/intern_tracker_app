import 'package:flutter/material.dart';

/// AppColors is a utility class that defines the app's color scheme and gradients.
/// This ensures consistent colors throughout the application and makes it easy
/// to update the app's theme by modifying colors in one place.
class AppColors {  // Primary colors used throughout the app - Black and White Theme
  /// Primary color - Black for app bar, buttons, main accents
  static const Color primaryRoyalBlue = Color(0xFF000000);
  
  /// Secondary/Button color - Dark Gray for buttons and highlights
  static const Color secondaryCoralOrange = Color(0xFF424242);
  
  /// Background color - White for main background
  static const Color backgroundLight = Color(0xFFFFFFFF);
  
  /// Surface/Card background - Light Gray for card background
  static const Color cardBackground = Color(0xFFF5F5F5);
  
  /// Text primary color - Black
  static const Color textPrimary = Color(0xFF000000);
  
  /// Text secondary color - Dark Gray for subtext, labels
  static const Color textSecondary = Color(0xFF757575);
  
  /// Button text color - White for contrast
  static const Color buttonText = Color(0xFFFFFFFF);
  
  /// Success color - Dark Gray for success indication
  static const Color successCalmGreen = Color(0xFF424242);
  
  /// Error color - Black for error/warning
  static const Color errorRichRed = Color(0xFF000000);
    // Legacy color names for backward compatibility
  static const Color primaryDarkBlue = primaryRoyalBlue;
  static const Color primaryDeepCyan = primaryRoyalBlue;
  static const Color secondaryTeal = secondaryCoralOrange;
  static const Color accentMustardYellow = secondaryCoralOrange;
  static const Color successGreen = successCalmGreen;
  static const Color successOliveGreen = successCalmGreen;
  static const Color errorRed = errorRichRed;
  static const Color errorRedClay = errorRichRed;
  
  /// Primary gradient using Black and Dark Gray tones
  static const primaryGradient = LinearGradient(
    colors: [Color(0xFF000000), Color(0xFF424242)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Secondary gradient with dark gray tones
  static const secondaryGradient = LinearGradient(
    colors: [Color(0xFF424242), Color(0xFF757575)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  /// Color palette for different work types in the app - Black and White Theme
  /// These colors use different shades of gray and black for work type distinction
  static const workTypeColors = [
    Color(0xFF000000), // Black - Used for urgent or important tasks
    Color(0xFF212121), // Very Dark Gray - Used for development tasks
    Color(0xFF424242), // Dark Gray - Used for planning tasks
    Color(0xFF616161), // Medium Dark Gray - Used for research tasks
    Color(0xFF757575), // Medium Gray - Used for in-progress or pending tasks
    Color(0xFF9E9E9E), // Light Gray - Used for documentation tasks
    Color(0xFF424242), // Dark Gray - Used for design tasks
    Color(0xFF757575), // Medium Gray - Used for miscellaneous tasks
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
