import 'package:flutter/material.dart';

abstract class AppColors {
  // Backgrounds
  static const Color background = Color(0xFF0F0F1A);
  static const Color surface = Color(0xFF1A1A2E);
  static const Color card = Color(0xFF252542);
  static const Color cardElevated = Color(0xFF2D2D50);

  // Brand
  static const Color primary = Color(0xFF7C3AED);
  static const Color primaryLight = Color(0xFF9F67E4);
  static const Color primaryDark = Color(0xFF5B21B6);
  static const Color primaryContainer = Color(0xFF3B1F7A);

  // Financial
  static const Color income = Color(0xFF10B981);
  static const Color incomeLight = Color(0xFF34D399);
  static const Color expense = Color(0xFFEF4444);
  static const Color expenseLight = Color(0xFFF87171);
  static const Color transfer = Color(0xFF3B82F6);

  // Text
  static const Color textPrimary = Color(0xFFE2E8F0);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textDisabled = Color(0xFF475569);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // UI
  static const Color divider = Color(0xFF2D2D4E);
  static const Color border = Color(0xFF3D3D60);
  static const Color overlay = Color(0x80000000);

  // Status
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF3B82F6);

  // Category palette (cores para categorias)
  static const List<Color> categoryColors = [
    Color(0xFF7C3AED),
    Color(0xFF10B981),
    Color(0xFFEF4444),
    Color(0xFF3B82F6),
    Color(0xFFF59E0B),
    Color(0xFF8B5CF6),
    Color(0xFF06B6D4),
    Color(0xFFEC4899),
    Color(0xFF84CC16),
    Color(0xFFFF6B35),
    Color(0xFF14B8A6),
    Color(0xFFF43F5E),
  ];
}
