import 'package:flutter/material.dart';
import 'Pages/home_screen.dart';
import 'utils/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Intern Progress Tracker',
      debugShowCheckedModeBanner: false,      theme: ThemeData(
        primarySwatch: MaterialColor(0xFF007BFF, {
          50: Color(0xFFE3F2FD),
          100: Color(0xFFBBDEFB),
          200: Color(0xFF90CAF9),
          300: Color(0xFF64B5F6),
          400: Color(0xFF42A5F5),
          500: Color(0xFF007BFF),
          600: Color(0xFF1E88E5),
          700: Color(0xFF1976D2),
          800: Color(0xFF1565C0),
          900: Color(0xFF0D47A1),
        }),
        primaryColor: AppColors.primaryRoyalBlue,
        colorScheme: ColorScheme.light(
          primary: AppColors.primaryRoyalBlue,
          secondary: AppColors.secondaryCoralOrange,
          surface: AppColors.cardBackground,
          background: AppColors.backgroundLight,
          error: AppColors.errorRichRed,
          onPrimary: AppColors.buttonText,
          onSecondary: AppColors.textPrimary,
          onSurface: AppColors.textPrimary,
          onBackground: AppColors.textPrimary,
          onError: AppColors.buttonText,
        ),
        brightness: Brightness.light,
        fontFamily: 'SF Pro Display',
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.primaryRoyalBlue,
          foregroundColor: AppColors.buttonText,
          elevation: 0,
        ),
        cardTheme: CardTheme(
          color: AppColors.cardBackground,
          elevation: 2,
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
      ),
      home: const HomePage(),
    );
  }
}
