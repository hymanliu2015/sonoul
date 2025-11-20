import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppThemes {
  // 全局圆角
  static const double borderRadius = 20.0;
  static const double cardRadius = 24.0;
  static const double buttonHeight = 56.0;

  static final RoundedRectangleBorder _shapeLarge = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(borderRadius),
  );
  static final RoundedRectangleBorder _shapeCard = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(cardRadius),
  );

  // ==================== 亮模式主题 ====================
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.greenPrimary,
      brightness: Brightness.light,
      primary: AppColors.greenPrimary,
      surface: AppColors.background,        // ← 改为 surface
    ),

    fontFamily: 'Roboto',

    scaffoldBackgroundColor: AppColors.background,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.tranColor,
      elevation: 0,
      centerTitle: true,
      foregroundColor: AppColors.textPrimary,
      scrolledUnderElevation: 0,
    ),

    cardTheme: CardThemeData(
      shape: _shapeCard,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      surfaceTintColor: AppColors.greenPrimary.withValues(alpha: 0.08),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.greenPrimary,
        foregroundColor: Colors.white,
        elevation: 6,
        shadowColor: AppColors.greenPrimary.withValues(alpha: 0.4),
        shape: _shapeLarge,
        minimumSize: const Size(double.infinity, buttonHeight),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.greenPrimary,
        shape: _shapeLarge,
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.05),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),

    dialogTheme: DialogThemeData(
      shape: _shapeLarge,
      backgroundColor: Colors.white.withValues(alpha: 0.95),
    ),

    bottomSheetTheme: const BottomSheetThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.white,
      modalBackgroundColor: AppColors.tranColor,
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.greenPrimary,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.greenPrimary,
      foregroundColor: Colors.white,
      shape: const StadiumBorder(),
    ),
  );

  // ==================== 暗模式主题 ====================
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.greenPrimary,
      brightness: Brightness.dark,
      primary: AppColors.greenLight,
      surface: AppColors.backgroundDark,     // ← 改为 surface
    ),

    fontFamily: 'Roboto',

    scaffoldBackgroundColor: AppColors.backgroundDark,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.tranColor,
      elevation: 0,
      centerTitle: true,
      foregroundColor: Colors.white,
      scrolledUnderElevation: 0,
    ),

    cardTheme: CardThemeData(
      shape: _shapeCard,
      elevation: 8,
      shadowColor: Colors.black.withValues(alpha: 0.3),
      surfaceTintColor: AppColors.greenLight.withValues(alpha: 0.12),
    ),

    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.greenLight,
        foregroundColor: Colors.black87,
        elevation: 6,
        shadowColor: AppColors.greenLight.withValues(alpha: 0.4),
        shape: _shapeLarge,
        minimumSize: const Size(double.infinity, buttonHeight),
        textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
      ),
    ),

    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.white.withValues(alpha: 0.08),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
    ),

    dialogTheme: DialogThemeData(
      shape: _shapeLarge,
      backgroundColor: Colors.white.withValues(alpha: 0.1),
    ),

    bottomSheetTheme: BottomSheetThemeData(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      backgroundColor: Colors.black.withValues(alpha: 0.4),
    ),

    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.greenLight,
    ),

    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.greenLight,
      foregroundColor: Colors.black87,
      shape: const StadiumBorder(),
    ),
  );
}