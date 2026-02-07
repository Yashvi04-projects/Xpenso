import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../features/expenses/domain/repositories/expense_repository.dart';
import '../providers/transactions_provider.dart';
import 'package:xpenso/features/dashboard/presentation/providers/dashboard_provider.dart';
import '../widgets/transaction_list_item.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TransactionsProvider(
         Provider.of<ExpenseRepository>(context, listen: false),
      ),
      child: const _TransactionsView(),
    );
  }
}

class _TransactionsView extends StatelessWidget {
  const _TransactionsView();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TransactionsProvider>(context);

    final theme = Theme.of(context);
    final headerColor = theme.colorScheme.onSurface;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: Icon(Icons.arrow_back, color: headerColor),
        centerTitle: true,
        title: Text('Transaction History', style: TextStyle(color: headerColor)),
        actions: [
          IconButton(
            icon: Icon(Icons.search, color: headerColor),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          // Filters
          SizedBox(
            height: 60,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                _buildFilterChip(context, 'October', isDropdown: true, isSelected: true),
                const SizedBox(width: 12),
                _buildFilterChip(context, 'Category', icon: Icons.category),
                const SizedBox(width: 12),
                _buildFilterChip(context, 'Account', icon: Icons.account_balance_wallet),
              ],
            ),
          ),
          
          const Divider(height: 1),

          // List
          Expanded(
            child: provider.isLoading 
              ? const Center(child: CircularProgressIndicator())
              : provider.sections.isEmpty
                  ? _buildEmptyState(context)
                  : ListView.builder(
                      itemCount: provider.sections.length,
                      itemBuilder: (context, index) {
                        final section = provider.sections[index];
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                             _buildSectionHeader(context, section),
                             ...section.items.map((e) => TransactionListItem(expense: e)),
                          ],
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, {bool isDropdown = false, bool isSelected = false, IconData? icon}) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFF1B4332) : theme.cardColor,
        borderRadius: BorderRadius.circular(20), // Pill shape as per design
        border: isSelected ? null : Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
             Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.textSecondaryLight),
             const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.white : theme.colorScheme.onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (isDropdown) ...[
             const SizedBox(width: 4),
             Icon(Icons.keyboard_arrow_down, size: 16, color: isSelected ? Colors.white : theme.colorScheme.onSurface),
          ]
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, TransactionSection section) {
     final theme = Theme.of(context);
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    final formatter = NumberFormat.simpleCurrency(name: dashboardProvider.currency, decimalDigits: 2);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final sectionDate = DateTime(section.date.year, section.date.month, section.date.day);

    String dateLabel;
    if (sectionDate == today) {
      dateLabel = "TODAY, ${DateFormat('MMM d').format(section.date).toUpperCase()}";
    } else if (sectionDate == yesterday) {
      dateLabel = "YESTERDAY, ${DateFormat('MMM d').format(section.date).toUpperCase()}";
    } else {
      dateLabel = DateFormat('EEE, MMM d').format(section.date).toUpperCase();
    }

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      color: theme.scaffoldBackgroundColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            dateLabel,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondaryLight,
              letterSpacing: 0.5,
            ),
          ),
          Text(
            "${formatter.format(section.totalAmount)} spent",
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondaryLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.receipt_long_outlined, size: 48, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            "No transactions yet",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            "Tap + to add a new expense",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
