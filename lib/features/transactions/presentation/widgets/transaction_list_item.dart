import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../features/dashboard/presentation/utils/dashboard_ui_helpers.dart';
import '../../../../features/expenses/domain/entities/expense.dart';
import 'package:intl/intl.dart';

class TransactionListItem extends StatelessWidget {
  final Expense expense;
  final String currency;

  const TransactionListItem({super.key, required this.expense, required this.currency});

  @override
  Widget build(BuildContext context) {
    final formatter = NumberFormat.simpleCurrency(name: currency, decimalDigits: 2);
    // For now assume expense amounts are positive and display as expense
    final amountColor = AppColors.textPrimaryLight;
    final amountPrefix = '-';

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: InkWell(
        onTap: () => _showTransactionDetails(context, formatter),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 8,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              // Icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: DashboardUIHelpers.getCategoryColor(expense.categoryId).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  DashboardUIHelpers.getCategoryIcon(expense.categoryId),
                  color: DashboardUIHelpers.getCategoryIconColor(expense.categoryId),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              
              // Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.note.isNotEmpty ? expense.note : DashboardUIHelpers.getCategoryName(expense.categoryId),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "${DashboardUIHelpers.getCategoryName(expense.categoryId).toUpperCase()} • ${DateFormat('MMM d').format(expense.date)}", 
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Amount & Menu
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$amountPrefix${formatter.format(expense.amount)}",
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: amountColor,
                    ),
                  ),
                  const SizedBox(width: 4),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert, size: 18, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.4)),
                    padding: EdgeInsets.zero,
                    onSelected: (value) {
                       if (value == 'edit') {
                         Navigator.pushNamed(context, '/add_expense', arguments: expense);
                       } else if (value == 'delete') {
                         // Call delete on provider
                         // Note: We need access to provider or repository here. 
                         // Ideally simpler to let parent handle or use Provider.of<ExpenseRepository>
                         // But for now, let's keep it simple:
                         // We can cannot easily delete from here without context of provider.
                         // But we can show confirmation and use Provider.of logic if available.
                         _showDeleteConfirmation(context);
                       }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Row(children: [Icon(Icons.edit, size: 16), SizedBox(width: 8), Text("Edit")])),
                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, size: 16, color: Colors.red), SizedBox(width: 8), Text("Delete", style: TextStyle(color: Colors.red))])),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTransactionDetails(BuildContext context, NumberFormat formatter) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               Container(
                 padding: const EdgeInsets.all(16),
                 decoration: BoxDecoration(
                   color: DashboardUIHelpers.getCategoryColor(expense.categoryId).withOpacity(0.1),
                   shape: BoxShape.circle,
                 ),
                 child: Icon(
                   DashboardUIHelpers.getCategoryIcon(expense.categoryId),
                   color: DashboardUIHelpers.getCategoryIconColor(expense.categoryId),
                   size: 32,
                 ),
               ),
               const SizedBox(height: 16),
               Text(
                 formatter.format(expense.amount),
                 style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
               ),
               const SizedBox(height: 8),
               Text(
                 expense.note.isNotEmpty ? expense.note : DashboardUIHelpers.getCategoryName(expense.categoryId),
                 style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7)),
                 textAlign: TextAlign.center,
               ),
               const SizedBox(height: 24),
               const Divider(),
               ListTile(
                 title: const Text("Date", style: TextStyle(fontSize: 12, color: Colors.grey)),
                 subtitle: Text(DateFormat('EEEE, d MMMM y, hh:mm a').format(expense.date), style: const TextStyle(fontWeight: FontWeight.w500)),
                 contentPadding: EdgeInsets.zero,
                 dense: true,
               ),
               ListTile(
                 title: const Text("Category", style: TextStyle(fontSize: 12, color: Colors.grey)),
                 subtitle: Text(DashboardUIHelpers.getCategoryName(expense.categoryId), style: const TextStyle(fontWeight: FontWeight.w500)),
                 contentPadding: EdgeInsets.zero,
                 dense: true,
               ),
               // Account info if we had it easily accessible (accountId -> name)
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
      // Logic for delete will need ExpenseRepository
      // Assuming we can access it via Provider
      /* 
      showDialog(...) and call repo.deleteExpense(expense.id)
      */
  }
}

