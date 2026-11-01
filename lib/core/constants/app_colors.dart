import 'package:flutter/material.dart';

/// Design tokens specified for MyGarage automotive interface.
class AppColors {
  AppColors._();

  // Background & Surfaces
  static const Color background = Color(0xFF0B1017);
  static const Color surface = Color(0xFF19212D);
  static const Color elevatedSurface = Color(0xFF222D3A);
  static const Color cardBorder = Color(0x1FFFFFFF);
  static const Color cardBorderActive = Color(0x4036E1BD);

  // Accent & Brand
  static const Color accent = Color(0xFF36E1BD);
  static const Color accentDim = Color(0x3336E1BD);
  static const Color accentGlow = Color(0x6636E1BD);

  // Typography
  static const Color primaryText = Color(0xFFF5F7FA);
  static const Color secondaryText = Color(0xFF9AA8B7);
  static const Color tertiaryText = Color(0xFF627181);

  // Issue Priorities
  static const Color critical = Color(0xFFFF5252);
  static const Color criticalDim = Color(0x33FF5252);

  static const Color high = Color(0xFFFF9F43);
  static const Color highDim = Color(0x33FF9F43);

  static const Color medium = Color(0xFFFFD166);
  static const Color mediumDim = Color(0x33FFD166);

  static const Color low = Color(0xFF7C9BB5);
  static const Color lowDim = Color(0x337C9BB5);

  // Issue Status
  static const Color statusOpen = Color(0xFFFF9F43);
  static const Color statusInProgress = Color(0xFF54A0FF);
  static const Color statusResolved = Color(0xFF1DD1A1);

  // Status & Alerts
  static const Color warning = Color(0xFFFF9F43);
  static const Color warningDim = Color(0x33FF9F43);

  // Gradients
  static const LinearGradient heroCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF202B39),
      Color(0xFF131A24),
    ],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF36E1BD),
      Color(0xFF10AC84),
    ],
  );
}
