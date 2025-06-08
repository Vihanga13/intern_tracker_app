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
      debugShowCheckedModeBanner: false,      theme: ThemeData(        primarySwatch: MaterialColor(0xFF000000, {
          50: Color(0xFFE0E0E0),
          100: Color(0xFFBDBDBD),
          200: Color(0xFF9E9E9E),
          300: Color(0xFF757575),
          400: Color(0xFF616161),
          500: Color(0xFF000000),
          600: Color(0xFF424242),
          700: Color(0xFF303030),
          800: Color(0xFF212121),
          900: Color(0xFF000000),
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
