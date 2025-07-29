import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Zen and minimalist
  static const Color background = Color(0xFFFAFAFA); // Warm white
  static const Color surface = Color(0xFFFFFFFF); // Pure white
  static const Color surfaceElevated = Color(0xFFF5F5F5); // Slightly elevated

  // Text Colors - Soft and readable
  static const Color textPrimary = Color(0xFF2D2D2D); // Warm dark gray
  static const Color textSecondary = Color(0xFF757575); // Medium gray
  static const Color textTertiary = Color(0xFFBDBDBD); // Light gray

  // Accent Colors - Minimal and calming
  static const Color accent = Color(0xFF6B73FF); // Soft purple
  static const Color accentSoft = Color(0xFFF0F1FF); // Very light purple

  // Semantic Colors - Subtle
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color error = Color(0xFFE57373); // Softer red

  // Dividers and Borders - Almost invisible
  static const Color divider = Color(0xFFF0F0F0);
  static const Color borderLight = Color(0xFFE8E8E8);

  // Shadows - Very subtle
  static const Color shadowColor = Color(0x08000000);
}

class AppSpacing {
  // Consistent spacing system
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
}

class AppRadius {
  // Consistent border radius
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
}

class AppTextStyles {
  // Consistent typography
  static const TextStyle heading1 = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.2,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.textPrimary,
    height: 1.5,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
    height: 1.4,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w400,
    color: AppColors.textTertiary,
    height: 1.4,
  );

  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
    height: 1.4,
  );
}

class AppShadows {
  // Subtle shadows for zen aesthetic
  static const List<BoxShadow> soft = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 8,
      offset: Offset(0, 2),
    ),
  ];

  static const List<BoxShadow> medium = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> large = [
    BoxShadow(
      color: AppColors.shadowColor,
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}

class AppTheme {
  // Main theme configuration
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.light,
        surface: AppColors.surface,
        background: AppColors.background,
      ),
      scaffoldBackgroundColor: AppColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        titleTextStyle: AppTextStyles.heading3,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: const BorderSide(color: AppColors.divider, width: 1),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.accent,
        foregroundColor: Colors.white,
        elevation: 4,
      ),
      dividerColor: AppColors.divider,
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.heading1,
        headlineMedium: AppTextStyles.heading2,
        headlineSmall: AppTextStyles.heading3,
        bodyLarge: AppTextStyles.bodyLarge,
        bodyMedium: AppTextStyles.bodyMedium,
        bodySmall: AppTextStyles.bodySmall,
        labelSmall: AppTextStyles.caption,
        labelMedium: AppTextStyles.label,
      ),
    );
  }
}
