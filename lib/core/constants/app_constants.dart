import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (Based on "WealthWise" reference image)
  static const Color primary = Color(0xFF00D05E); // Vibrant Green
  static const Color primaryVariant = Color(0xFF00A84B);
  
  // Secondary / Accents
  static const Color secondary = Color(0xFF09090B); // Dark Black/Navy
  static const Color accent = Color(0xFFD4F7E2); // Light Green Tint
  
  // Backgrounds
  static const Color backgroundLight = Color(0xFFF8F9FA); // Very light grey
  static const Color surfaceLight = Color(0xFFFFFFFF);
  
  static const Color backgroundDark = Color(0xFF121212);
  static const Color surfaceDark = Color(0xFF1E1E1E);

  // Text
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF6B7280); // Grey text
  
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFA1A1AA);

  // Status
  static const Color error = Color(0xFFFF4D4D);
  static const Color success = Color(0xFF00D05E);
  static const Color warning = Color(0xFFFFC107);
}

class AppStrings {
  static const String appName = 'Xpenso';
  static const String appTagline = 'Master your finances seamlessly'; // Derived from "Master your finances..."
  
  static const String dashboard = 'Dashboard';
  static const String expenses = 'Expenses';
  static const String categories = 'Categories';
  static const String accounts = 'Accounts';
  static const String insights = 'Insights';
  static const String settings = 'Settings';
}
