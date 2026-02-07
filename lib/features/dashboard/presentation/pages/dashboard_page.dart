import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../features/expenses/domain/repositories/expense_repository.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/pages/profile_page.dart';
import '../providers/dashboard_provider.dart';
import '../utils/dashboard_ui_helpers.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _DashboardView();
  }
}

class _DashboardView extends StatelessWidget {
  const _DashboardView();

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DashboardProvider>(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        title: Row(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfilePage(),
                  ),
                );
              },
              child: const CircleAvatar(
                radius: 20,
                backgroundColor: Color(0xFFD4AF37), // Goldish color mock
              ),
            ), // Profile Pic Mock
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GOOD MORNING,',
                  style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.bold),
                ),
                Consumer<AuthProvider>(
                  builder: (context, auth, _) => Text(
                    auth.user?.displayName?.toUpperCase() ?? 'USER',
                    style: TextStyle(fontSize: 16, color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Bell Icon Removed as per request (or wire to Settings if preferred)
          // Keeping empty or adding spacing if needed
          const SizedBox(width: 16),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: provider.loadDashboardData,
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Total Balance Card
              _buildBalanceCard(provider),
              const SizedBox(height: 24),

              // Monthly Summary Title
              Text(
                'MONTHLY SUMMARY',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),
              
              // Summary Row
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context: context,
                      icon: Icons.north_east_rounded,
                      iconColor: Colors.white,
                      iconBg: const Color(0xFFFF8A80), // Light Red
                      label: 'SPENT',
                      amount: provider.totalSpent,
                      currency: provider.currency,
                      // Mock progress
                      progress: (provider.monthlyBudget > 0 ? provider.totalSpent / provider.monthlyBudget : 0.0).clamp(0.0, 1.0),
                      progressColor: Colors.redAccent,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      context: context,
                      icon: Icons.account_balance_outlined,
                      iconColor: const Color(0xFF2E7D32),
                      iconBg: const Color(0xFFE8F5E9), // Light Green
                      label: 'BUDGET',
                      amount: provider.monthlyBudget,
                      currency: provider.currency,
                      progress: 0.3, // Mock fixed progress for budget visual
                      progressColor: const Color(0xFF2E7D32),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'RECENT TRANSACTIONS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.0,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to full transactions
                          // Assuming we have a tab controller or can push a page
                          // Ideally switch tab, but pushing page works for "See All"
                          // If using MainNavigationPage, we might want to switch tabs. 
                          // But for now, let's push the ExpensesPage which serves as the full list.
                          Navigator.pushNamed(context, '/expenses');
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: isDark ? theme.colorScheme.surface : Colors.grey.shade200,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('See All', style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
                      ),
                    ],
                  ),
              const SizedBox(height: 16),

              // Transactions List
              if (provider.isLoading)
                 const Center(child: CircularProgressIndicator())
              else if (provider.recentExpenses.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Center(child: Text("No transactions yet", style: TextStyle(color: Colors.grey))),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: provider.recentExpenses.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final expense = provider.recentExpenses[index];
                    return _buildTransactionItem(context, expense);
                  },
                ),
               
               // Bottom Padding for FAB
               const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBalanceCard(DashboardProvider provider) {
    final formatter = NumberFormat.simpleCurrency(name: provider.currency, decimalDigits: 2);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B4332), // Dark Green
        borderRadius: BorderRadius.circular(24),
        image: const DecorationImage(
           image: AssetImage('assets/images/card_pattern.png'), // Placeholder or use CustomPaint later
           fit: BoxFit.cover,
           opacity: 0.1,
        ),
        boxShadow: [
           BoxShadow(
             color: const Color(0xFF1B4332).withOpacity(0.4),
             blurRadius: 12,
             offset: const Offset(0, 8),
           )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL BALANCE',
                style: TextStyle(
                   color: Colors.white.withOpacity(0.7),
                   fontSize: 12,
                   fontWeight: FontWeight.w600,
                   letterSpacing: 0.5,
                ),
              ),
              GestureDetector(
                onTap: () => provider.toggleBalanceVisibility(),
                child: Icon(
                  provider.balanceVisible 
                    ? Icons.visibility_outlined 
                    : Icons.visibility_off_outlined,
                  color: Colors.white54,
                  size: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            provider.balanceVisible 
              ? formatter.format(provider.totalBalance)
              : '${provider.currency} ••••••',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
             mainAxisAlignment: MainAxisAlignment.spaceBetween,
             children: [
               Container(
                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                 decoration: BoxDecoration(
                   color: Colors.white.withOpacity(0.2),
                   borderRadius: BorderRadius.circular(20),
                 ),
                 child: const Row(
                   children: [
                     Icon(Icons.arrow_upward, color: Colors.white, size: 14),
                     SizedBox(width: 4),
                     Text(
                       '+4.2%',
                       style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                     ),
                   ],
                 ),
               ),
               Text(
                 'Monthly growth',
                 style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
               ),
               // Mock Toggle
               Icon(Icons.toggle_on, color: Colors.white.withOpacity(0.4), size: 30),
             ],
           ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String label,
    required double amount,
    required double progress,
    required Color progressColor,
    required String currency,
  }) {
    final theme = Theme.of(context);
    final formatter = NumberFormat.simpleCurrency(name: currency, decimalDigits: 0);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
             color: Colors.black.withOpacity(0.02),
             blurRadius: 10,
             offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
             radius: 18,
             backgroundColor: iconBg,
             child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withOpacity(0.6), fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(amount),
            style: TextStyle(fontSize: 18, color: theme.colorScheme.onSurface, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: progress,
            backgroundColor: theme.brightness == Brightness.dark ? Colors.grey.shade800 : Colors.grey.shade100,
            valueColor: AlwaysStoppedAnimation<Color>(progressColor),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(BuildContext context, expense) {
     final theme = Theme.of(context);
     final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
     final formatter = NumberFormat.simpleCurrency(name: dashboardProvider.currency, decimalDigits: 0);
     
    return Dismissible(
      key: Key(expense.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.redAccent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context, 
          builder: (ctx) => AlertDialog(
            title: const Text('Delete Transaction'),
            content: const Text('Are you sure you want to delete this transaction?'),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Delete', style: TextStyle(color: Colors.red))),
            ],
          )
        );
      },
      onDismissed: (direction) async {
         // Delete logic
         final repo = Provider.of<ExpenseRepository>(context, listen: false);
         await repo.deleteExpense(expense.id);
         // Provider should auto-update via stream
      },
      child: InkWell(
        onTap: () {
           // Show Edit/Delete Options via BottomSheet
           showModalBottomSheet(
             context: context,
             shape: const RoundedRectangleBorder(
               borderRadius: BorderRadius.vertical(top: Radius.circular(20))
             ),
             builder: (ctx) => Wrap(
               children: [
                 ListTile(
                   leading: const Icon(Icons.edit),
                   title: const Text('Edit Transaction'),
                   onTap: () {
                     Navigator.pop(ctx);
                     // Navigate to Add Expense Page with arguments
                     Navigator.pushNamed(context, '/add_expense', arguments: expense);
                   },
                 ),
                 ListTile(
                   leading: const Icon(Icons.delete, color: Colors.red),
                   title: const Text('Delete Transaction', style: TextStyle(color: Colors.red)),
                   onTap: () async {
                     Navigator.pop(ctx);
                     final confirm = await showDialog<bool>(
                        context: context, 
                        builder: (dCtx) => AlertDialog(
                          title: const Text('Delete Transaction'),
                          content: const Text('Are you sure you want to delete this transaction?'),
                          actions: [
                            TextButton(onPressed: () => Navigator.of(dCtx).pop(false), child: const Text('Cancel')),
                            TextButton(
                              onPressed: () => Navigator.of(dCtx).pop(true), 
                              child: const Text('Delete', style: TextStyle(color: Colors.red))
                            ),
                          ],
                        )
                      );
                      
                      if (confirm == true) {
                        final repo = Provider.of<ExpenseRepository>(context, listen: false);
                         await repo.deleteExpense(expense.id);
                      }
                   },
                 ),
               ],
             ),
           );
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.dividerColor.withOpacity(0.1)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.01),
                blurRadius: 10,
                offset: const Offset(0, 2),
              )
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: DashboardUIHelpers.getCategoryColor(expense.categoryId),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  DashboardUIHelpers.getCategoryIcon(expense.categoryId),
                  color: DashboardUIHelpers.getCategoryIconColor(expense.categoryId),
                  size: 20,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.note.isNotEmpty ? expense.note : DashboardUIHelpers.getCategoryName(expense.categoryId),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      DateFormat('Today, hh:mm a').format(expense.date),
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '-${formatter.format(expense.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DashboardUIHelpers.getCategoryName(expense.categoryId).toUpperCase(),
                    style: TextStyle(
                        fontSize: 10,
                        color: theme.colorScheme.onSurface.withOpacity(0.6),
                        fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
