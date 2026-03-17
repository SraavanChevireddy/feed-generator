import 'package:flutter/material.dart';

abstract final class AppColors {
  // Primary palette
  static const Color primary = Color(0xFF6C5CE7);
  static const Color primaryLight = Color(0xFFA29BFE);
  static const Color primaryDark = Color(0xFF4834D4);

  // Accent palette
  static const Color accent = Color(0xFFFF6B6B);
  static const Color accentLight = Color(0xFFFF8787);

  // Surface colors
  static const Color surfaceLight = Color(0xFFF8F9FE);
  static const Color surfaceDark = Color(0xFF1A1A2E);
  static const Color cardLight = Colors.white;
  static const Color cardDark = Color(0xFF16213E);

  // Background
  static const Color backgroundLight = Color(0xFFF0F0F7);
  static const Color backgroundDark = Color(0xFF0F0F23);

  // Text
  static const Color textPrimaryLight = Color(0xFF2D3436);
  static const Color textSecondaryLight = Color(0xFF636E72);
  static const Color textPrimaryDark = Color(0xFFF5F6FA);
  static const Color textSecondaryDark = Color(0xFFB2BEC3);

  // Semantic
  static const Color success = Color(0xFF00B894);
  static const Color warning = Color(0xFFFDCB6E);
  static const Color error = Color(0xFFE17055);
  static const Color info = Color(0xFF74B9FF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, Color(0xFFA29BFE)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accent, Color(0xFFFD79A8)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkOverlayGradient = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
