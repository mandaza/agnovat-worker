import 'package:flutter/material.dart';

/// Agnovat app color palette
/// Based on the approved color scheme
class AppColors {
  AppColors._();

  // Primary Color Palette
  static const Color deepBrown = Color(0xFF5A3111);
  static const Color burntOrange = Color(0xFF954406);
  static const Color goldenAmber = Color(0xFFD68630);
  static const Color tealBlue = Color(0xFF3E717E);
  static const Color deepOcean = Color(0xFF10465E);
  static const Color midnightNavy = Color(0xFF0B2839);

  // Primary Theme Colors (Deep Brown as main brand color)
  static const Color primary = deepBrown; // Main brand color
  static const Color primaryLight = Color(0xFF8B5A3C); // Lighter shade of brown
  static const Color primaryDark = Color(0xFF3D1F0A); // Darker shade of brown

  // Secondary Theme Colors (Golden Amber for accents)
  static const Color secondary = goldenAmber; // Accent & CTAs
  static const Color secondaryLight = Color(0xFFE5A154); // Lighter amber
  static const Color secondaryDark = burntOrange; // Darker orange

  // Tertiary Colors (Teal/Ocean for info and alternative actions)
  static const Color tertiary = tealBlue; // For info/alternative actions
  static const Color tertiaryLight = Color(0xFF5C9AA8);
  static const Color tertiaryDark = deepOcean;

  // Semantic Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFC107);
  static const Color error = Color(0xFFF44336);
  static const Color info = tealBlue;

  // Neutral Colors (Light Theme)
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color grey50 = Color(0xFFFAFAFA);
  static const Color grey100 = Color(0xFFF5F5F5);
  static const Color grey200 = Color(0xFFEEEEEE);
  static const Color grey300 = Color(0xFFE0E0E0);
  static const Color grey400 = Color(0xFFBDBDBD);
  static const Color grey500 = Color(0xFF9E9E9E);
  static const Color grey600 = Color(0xFF757575);
  static const Color grey700 = Color(0xFF616161);
  static const Color grey800 = Color(0xFF424242);
  static const Color grey900 = Color(0xFF212121);

  // Background Colors
  static const Color backgroundLight = white;
  static const Color backgroundDark = midnightNavy;
  static const Color surfaceLight = grey50;
  static const Color surfaceDark = Color(0xFF1A3545);

  // Text Colors
  static const Color textPrimary = grey900;
  static const Color textSecondary = grey600;
  static const Color textDisabled = grey400;
  static const Color textOnPrimary = white;
  static const Color textOnSecondary = midnightNavy;
  static const Color textOnDark = white;

  // Border Colors
  static const Color borderLight = grey300;
  static const Color borderDark = grey700;

  // Shadow Colors
  static const Color shadowLight = Color(0x1A000000);
  static const Color shadowDark = Color(0x3D000000);
}
