import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.trustNavy,
      brightness: Brightness.light,
      primary: AppColors.trustNavy,
      secondary: AppColors.justiceGold,
      surface: AppColors.surfaceWhite,
      background: AppColors.backgroundOffWhite,
      error: AppColors.warningSoftRed,
      onPrimary: AppColors.surfaceWhite,
      onSecondary: AppColors.trustNavy,
      onSurface: AppColors.textDarkGrey,
      onBackground: AppColors.textDarkGrey,
      onError: AppColors.surfaceWhite,
    ),
    scaffoldBackgroundColor: AppColors.backgroundOffWhite,
  );

  return base.copyWith(
    // Complete Typography System
    textTheme: TextTheme(
      displayLarge: GoogleFonts.merriweather(
        fontSize: 57,
        fontWeight: FontWeight.w300,
        color: AppColors.textDarkGrey,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.merriweather(
        fontSize: 45,
        fontWeight: FontWeight.w300,
        color: AppColors.textDarkGrey,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.merriweather(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: AppColors.textDarkGrey,
        letterSpacing: 0,
        height: 1.22,
      ),
      headlineLarge: GoogleFonts.merriweather(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: AppColors.textDarkGrey,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.merriweather(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: AppColors.textDarkGrey,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.merriweather(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.textDarkGrey,
        letterSpacing: 0,
        height: 1.33,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.textDarkGrey,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textDarkGrey,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textDarkGrey,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.textDarkGrey,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textDarkGrey,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.textMediumGrey,
        letterSpacing: 0.4,
        height: 1.33,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.trustNavy,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.trustNavy,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.trustNavy,
        letterSpacing: 0.5,
        height: 1.27,
      ),
    ),

    // AppBar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.trustNavy,
      foregroundColor: AppColors.surfaceWhite,
      elevation: 0,
      shadowColor: AppColors.shadow,
      surfaceTintColor: AppColors.justiceGold,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.surfaceWhite,
        letterSpacing: 0,
        height: 1.27,
      ),
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      iconTheme: const IconThemeData(
        color: AppColors.surfaceWhite,
        size: 24,
      ),
      actionsIconTheme: const IconThemeData(
        color: AppColors.surfaceWhite,
        size: 24,
      ),
    ),

    // Bottom Navigation Bar Theme
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: AppColors.surfaceWhite,
      selectedItemColor: AppColors.trustNavy,
      unselectedItemColor: AppColors.textMediumGrey,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.trustNavy,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textMediumGrey,
      ),
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      landscapeLayout: BottomNavigationBarLandscapeLayout.centered,
    ),

    // Card Theme
    cardTheme: CardTheme(
      color: AppColors.surfaceWhite,
      elevation: 2,
      shadowColor: AppColors.shadow,
      surfaceTintColor: AppColors.trustNavy,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
        side: const BorderSide(color: AppColors.grey200, width: 0.5),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Elevated Button Theme (Primary Action)
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.trustNavy,
        foregroundColor: AppColors.surfaceWhite,
        elevation: 1,
        shadowColor: AppColors.shadow,
        surfaceTintColor: AppColors.justiceGold,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.justiceGold, width: 0),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
        ),
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.focused)) {
            return AppColors.justiceGold.withOpacity(0.12);
          }
          if (states.contains(MaterialState.hovered)) {
            return AppColors.justiceGold.withOpacity(0.08);
          }
          if (states.contains(MaterialState.pressed)) {
            return AppColors.justiceGold.withOpacity(0.16);
          }
          return null;
        }),
        side: MaterialStateProperty.resolveWith<BorderSide?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.focused)) {
            return const BorderSide(color: AppColors.justiceGold, width: 2);
          }
          return const BorderSide(color: AppColors.justiceGold, width: 0);
        }),
      ),
    ),

    // Outlined Button Theme (Secondary Action)
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: AppColors.justiceGold,
        foregroundColor: AppColors.trustNavy,
        elevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: AppColors.trustNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
          side: const BorderSide(color: AppColors.justiceGold, width: 1),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
        ),
      ).copyWith(
        overlayColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
          if (states.contains(MaterialState.focused)) {
            return AppColors.trustNavy.withOpacity(0.12);
          }
          if (states.contains(MaterialState.hovered)) {
            return AppColors.trustNavy.withOpacity(0.08);
          }
          if (states.contains(MaterialState.pressed)) {
            return AppColors.trustNavy.withOpacity(0.16);
          }
          return null;
        }),
      ),
    ),

    // Text Button Theme
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.trustNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
          height: 1.43,
        ),
      ),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.backgroundOffWhite,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.grey300, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.grey300, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.trustNavy, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.warningSoftRed, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.warningSoftRed, width: 2),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(4),
        borderSide: const BorderSide(color: AppColors.grey200, width: 1),
      ),
      hintStyle: GoogleFonts.inter(
        color: AppColors.textMediumGrey,
        fontSize: 14,
        fontWeight: FontWeight.w400,
      ),
      labelStyle: GoogleFonts.inter(
        color: AppColors.textMediumGrey,
        fontSize: 12,
        fontWeight: FontWeight.w400,
      ),
      floatingLabelStyle: GoogleFonts.inter(
        color: AppColors.justiceGold,
        fontSize: 12,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      isDense: false,
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: AppColors.grey200,
      thickness: 1,
      space: 1,
    ),

    // Icon Theme
    iconTheme: const IconThemeData(
      color: AppColors.textMediumGrey,
      size: 24,
    ),

    // List Tile Theme
    listTileTheme: ListTileThemeData(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textDarkGrey,
        height: 1.43,
      ),
      subtitleTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textMediumGrey,
        height: 1.43,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.surfaceWhite,
      selectedColor: AppColors.justiceGold.withOpacity(0.12),
      disabledColor: AppColors.grey100,
      labelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.trustNavy,
      ),
      secondaryLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.trustNavy,
      ),
      side: const BorderSide(color: AppColors.grey300),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // Navigation Bar Theme (Material 3)
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.surfaceWhite,
      elevation: 3,
      shadowColor: AppColors.shadow,
      surfaceTintColor: AppColors.trustNavy,
      indicatorColor: AppColors.justiceGold.withOpacity(0.12),
      labelTextStyle: MaterialStateProperty.resolveWith<TextStyle>((Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.trustNavy,
          );
        }
        return GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.textMediumGrey,
        );
      }),
      iconTheme: MaterialStateProperty.resolveWith<IconThemeData>((Set<MaterialState> states) {
        if (states.contains(MaterialState.selected)) {
          return const IconThemeData(
            color: AppColors.trustNavy,
            size: 24,
          );
        }
        return const IconThemeData(
          color: AppColors.textMediumGrey,
          size: 24,
        );
      }),
    ),

    // Segmented Button Theme
    segmentedButtonTheme: SegmentedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.trustNavy;
          }
          return AppColors.surfaceWhite;
        }),
        foregroundColor: MaterialStateProperty.resolveWith<Color>((Set<MaterialState> states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.surfaceWhite;
          }
          return AppColors.textMediumGrey;
        }),
        side: MaterialStateProperty.all(const BorderSide(color: AppColors.grey300)),
        shape: MaterialStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        textStyle: MaterialStateProperty.all(
          GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.1,
          ),
        ),
      ),
    ),
  );
}

// Dark Theme (Optional)
ThemeData buildAppDarkTheme() {
  final base = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.trustNavy,
      brightness: Brightness.dark,
      primary: AppColors.justiceGold,
      secondary: AppColors.justiceGold,
      surface: AppColors.darkSurface,
      background: AppColors.darkBackground,
      error: AppColors.warningSoftRed,
      onPrimary: AppColors.trustNavy,
      onSecondary: AppColors.trustNavy,
      onSurface: AppColors.darkTextPrimary,
      onBackground: AppColors.darkTextPrimary,
      onError: AppColors.surfaceWhite,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
  );

  return base.copyWith(
    textTheme: TextTheme(
      displayLarge: GoogleFonts.merriweather(
        fontSize: 57,
        fontWeight: FontWeight.w300,
        color: AppColors.darkTextPrimary,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.merriweather(
        fontSize: 45,
        fontWeight: FontWeight.w300,
        color: AppColors.darkTextPrimary,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.merriweather(
        fontSize: 36,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextPrimary,
        letterSpacing: 0,
        height: 1.22,
      ),
      headlineLarge: GoogleFonts.merriweather(
        fontSize: 32,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextPrimary,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.merriweather(
        fontSize: 28,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextPrimary,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.merriweather(
        fontSize: 24,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextPrimary,
        letterSpacing: 0,
        height: 1.33,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.darkTextPrimary,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.darkTextPrimary,
        letterSpacing: 0.15,
        height: 1.5,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.darkTextPrimary,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextPrimary,
        letterSpacing: 0.5,
        height: 1.5,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextPrimary,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.darkTextSecondary,
        letterSpacing: 0.4,
        height: 1.33,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.justiceGold,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.justiceGold,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: AppColors.justiceGold,
        letterSpacing: 0.5,
        height: 1.27,
      ),
    ),
  );
}
