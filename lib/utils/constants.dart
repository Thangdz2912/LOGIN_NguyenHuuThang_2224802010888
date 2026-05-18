import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2196F3);
  static const secondary = Color(0xFFFF9800);
  static const success = Color(0xFF4CAF50);
  static const error = Color(0xFFE53935);
  static const textDark = Color(0xFF212121);
  static const textLight = Color(0xFF757575);
  static const backgroundLight = Color(0xFFF5F5F5);
  static const white = Color(0xFFFFFFFF);
}

class AppTextStyles {
  static const title = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textDark,
  );

  static const heading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textDark,
  );

  static const body = TextStyle(
    fontSize: 16,
    color: AppColors.textDark,
  );

  static const bodyLight = TextStyle(
    fontSize: 14,
    color: AppColors.textLight,
  );
}