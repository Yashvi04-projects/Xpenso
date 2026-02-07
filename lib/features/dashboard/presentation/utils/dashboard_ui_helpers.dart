import 'package:flutter/material.dart';

class DashboardUIHelpers {
  static IconData getCategoryIcon(String categoryId) {
    // Map ID to icon (Ideally this should come from Category entity join)
    // For now, simple heuristics or relying on stored Category ID map
    switch (categoryId) {
      case '1': return Icons.restaurant; // Food
      case '2': return Icons.directions_car; // Travel
      case '3': return Icons.shopping_bag; // Shopping
      case '4': return Icons.receipt_long; // Bills
      case '5': return Icons.sports_esports; // Fun
      case '6': return Icons.medical_services; // Health
      default: return Icons.category;
    }
  }

  static Color getCategoryColor(String categoryId) {
    switch (categoryId) {
      case '1': return const Color(0xFFFFE0B2); // Orange Light
      case '2': return const Color(0xFFE1F5FE); // Blue Light
      case '3': return const Color(0xFFE1BEE7); // Purple Light
      case '4': return const Color(0xFFFFCDD2); // Red Light
      case '5': return const Color(0xFFF8BBD0); // Pink Light
      case '6': return const Color(0xFFB2DFDB); // Teal Light
      default: return Colors.grey.shade200;
    }
  }

   static Color getCategoryIconColor(String categoryId) {
    switch (categoryId) {
      case '1': return Colors.orange[800]!; 
      case '2': return Colors.blue[800]!; 
      case '3': return Colors.purple[800]!; 
      case '4': return Colors.red[800]!; 
      case '5': return Colors.pink[800]!; 
      case '6': return Colors.teal[800]!; 
      default: return Colors.grey[700]!;
    }
  }

  static String getCategoryName(String categoryId) {
     switch (categoryId) {
      case '1': return 'Food'; 
      case '2': return 'Travel'; 
      case '3': return 'Shopping'; 
      case '4': return 'Bills'; 
      case '5': return 'Fun'; 
      case '6': return 'Health'; 
      default: return 'Other';
    }
  }
}
