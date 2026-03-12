import 'package:flutter/material.dart';

class AppColors {
  // Primary Brand Colors
  static const Color trustNavy = Color(0xFF1B2B6B); // Deep Navy
  static const Color justiceGold = Color(0xFFF5A623); // Gold/Amber
  static const Color backgroundOffWhite = Color(0xFFF8F9FC); // Off-white
  static const Color successEmerald = Color(0xFF2ECC71); // Emerald
  static const Color warningSoftRed = Color(0xFFE74C3C); // Soft Red
  static const Color surfaceWhite = Color(0xFFFFFFFF); // White
  static const Color textDarkGrey = Color(0xFF1A1A2E); // Dark Grey
  static const Color textMediumGrey = Color(0xFF6B7280); // Medium Grey

  // Extended Color Palette
  static const Color navyLight = Color(0xFF2C3E7C); // Lighter Navy
  static const Color navyDark = Color(0xFF0F1A4A); // Darker Navy
  static const Color goldLight = Color(0xFFF7B955); // Lighter Gold
  static const Color goldDark = Color(0xFFE09512); // Darker Gold
  static const Color emeraldLight = Color(0xFF4DD68A); // Lighter Emerald
  static const Color emeraldDark = Color(0xFF25A259); // Darker Emerald
  static const Color redLight = Color(0xFFF17068); // Lighter Red
  static const Color redDark = Color(0xFFC0392B); // Darker Red

  // Neutral Colors
  static const Color grey50 = Color(0xFFF9FAFB);
  static const Color grey100 = Color(0xFFF3F4F6);
  static const Color grey200 = Color(0xFFE5E7EB);
  static const Color grey300 = Color(0xFFD1D5DB);
  static const Color grey400 = Color(0xFF9CA3AF);
  static const Color grey500 = Color(0xFF6B7280);
  static const Color grey600 = Color(0xFF4B5563);
  static const Color grey700 = Color(0xFF374151);
  static const Color grey800 = Color(0xFF1F2937);
  static const Color grey900 = Color(0xFF111827);

  // Semantic Colors
  static const Color primary = trustNavy;
  static const Color secondary = justiceGold;
  static const Color accent = justiceGold;
  static const Color success = successEmerald;
  static const Color warning = warningSoftRed;
  static const Color error = warningSoftRed;
  static const Color background = backgroundOffWhite;
  static const Color surface = surfaceWhite;
  static const Color onPrimary = surfaceWhite;
  static const Color onSecondary = trustNavy;
  static const Color onSurface = textDarkGrey;
  static const Color onBackground = textDarkGrey;

  // Border and Utility Colors
  static const Color border = grey200;
  static const Color borderFocus = trustNavy;
  static const Color borderActive = justiceGold;
  static const Color divider = grey200;
  static const Color shadow = Color(0x0A1B2B6B); // Navy shadow with opacity
  static const Color shadowGold = Color(0x0AF5A623); // Gold shadow with opacity

  // Status Colors
  static const Color caseOpen = trustNavy;
  static const Color caseInProgress = justiceGold;
  static const Color caseResolved = successEmerald;
  static const Color caseRejected = warningSoftRed;

  // Verification Colors
  static const Color verifiedBadge = successEmerald;
  static const Color verifiedBackground = Color(0xFFE8F8F0);
  static const Color aiBadge = textMediumGrey;
  static const Color aiBackground = grey100;

  // Gradient Definitions
  static const LinearGradient heroGradient = LinearGradient(
    colors: [trustNavy, navyLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [justiceGold, goldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient successGradient = LinearGradient(
    colors: [successEmerald, emeraldLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [surfaceWhite, grey50],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const LinearGradient bannerGradient = LinearGradient(
    colors: [trustNavy, navyLight],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  // Dark Theme Colors (optional)
  static const Color darkBackground = Color(0xFF0F172A);
  static const Color darkSurface = Color(0xFF1E293B);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFFCBD5E1);
}
