import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../features/dashboard/presentation/utils/dashboard_ui_helpers.dart';
import '../providers/insights_provider.dart';
import 'package:intl/intl.dart';

class CategoryBreakdownItem extends StatelessWidget {
  final InsightData data;

  const CategoryBreakdownItem({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.currency(symbol: '₹', decimalDigits: 2, locale: 'en_IN');
    final name = DashboardUIHelpers.getCategoryName(data.categoryId);
    // Custom Subtitle logic based on name
    String subtitle = "General";
    if (name == 'Rent & Utilities') {
      subtitle = "Rent, Utilities";
    } else if (name == 'Food') {
      subtitle = "Groceries, Delivery";
    } else if (name == 'Travel') {
      subtitle = "Fuel, Metro, Cab";
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: DashboardUIHelpers.getCategoryColor(data.categoryId), // Using helper's light color
              shape: BoxShape.circle,
            ),
            child: Icon(
              DashboardUIHelpers.getCategoryIcon(data.categoryId),
              color: const Color(0xFF1B4332), // Dark green icon for insights page specific look? Or standard. Stitch uses white icon on dark bg in breakdown usually, or colored on light.
              // Let's stick to standard helper logic but maybe force dark green for consistency with image
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimaryLight),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatter.format(data.amount),
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textPrimaryLight),
              ),
              Text(
                "${data.percentage.toStringAsFixed(0)}%",
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondaryLight),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
