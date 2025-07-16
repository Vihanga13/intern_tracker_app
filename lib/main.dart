import 'package:flutter/material.dart';
import 'Pages/login_screen.dart';
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
      debugShowCheckedModeBanner: false,      theme: ThemeData(        primarySwatch: MaterialColor(0xFF1E1E1E, {
          50: Color(0xFF4A4A4A),
          100: Color(0xFF3E3E3E),
          200: Color(0xFF333333),
          300: Color(0xFF2D2D2D),
          400: Color(0xFF252525),
          500: Color(0xFF1E1E1E),
          600: Color(0xFF1A1A1A),
          700: Color(0xFF151515),
          800: Color(0xFF101010),
          900: Color(0xFF0A0A0A),
        }),
        primaryColor: AppColors.primaryRoyalBlue,
        colorScheme: ColorScheme.dark(
          primary: AppColors.secondaryCoralOrange,
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
        brightness: Brightness.dark,
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
      home: const LoginScreen(),
    );
  }
}
