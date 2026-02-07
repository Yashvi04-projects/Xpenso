import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';
import '../providers/accounts_provider.dart';
import 'package:xpenso/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'add_account_page.dart';
import '../../../../features/settings/presentation/pages/settings_page.dart';

class AccountsPage extends StatelessWidget {
  const AccountsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AccountsProvider(
         Provider.of<AccountRepository>(context, listen: false),
      ),
      child: const _AccountsView(),
    );
  }
}

class _AccountsView extends StatelessWidget {
  const _AccountsView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final provider = Provider.of<AccountsProvider>(context);
    final dashboardProvider = Provider.of<DashboardProvider>(context, listen: false);
    final formatter = NumberFormat.simpleCurrency(name: dashboardProvider.currency, decimalDigits: 0);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        toolbarHeight: 0,
         // We build custom header below matching design
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: provider.loadAccounts,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'My Accounts',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Manage your finances',
                          style: TextStyle(
                            fontSize: 14,
                            color: theme.colorScheme.onSurface.withOpacity(0.6),
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        // Assuming using basic Navigator for now as routes might not be set up
                         Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsPage()));
                      },
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: theme.cardColor,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.settings, color: theme.colorScheme.onSurface),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),

                // Net Worth Card
                _buildNetWorthCard(provider.totalNetWorth, formatter),

                const SizedBox(height: 24),

                // Add Account Dotted Button
                InkWell(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddAccountPage(),
                      ),
                    );
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 60,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.green.withOpacity(0.5),
                        style: BorderStyle.solid, 
                        width: 1,
                      ),
                    ),
                    // Using visual trick for dotted border or just a clean look for now
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle, color: isDark ? theme.colorScheme.primary : const Color(0xFF1B4332), size: 24),
                        const SizedBox(width: 8),
                        Text(
                          'Add new account',
                          style: TextStyle(
                            color: isDark ? theme.colorScheme.primary : const Color(0xFF1B4332),
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // List Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Your Assets',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    Text(
                      '${provider.accounts.length} ACCOUNTS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Accounts List
                if (provider.isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ListView.separated(
                     shrinkWrap: true,
                     physics: const NeverScrollableScrollPhysics(),
                     itemCount: provider.accounts.length,
                     separatorBuilder: (context, index) => const SizedBox(height: 16),
                     itemBuilder: (context, index) {
                       return _buildAccountItem(context, provider.accounts[index], formatter);
                     },
                  ),
                  
                  // Space for Bottom Nav
                  const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNetWorthCard(double total, NumberFormat formatter) {
     return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFF1B4332), // Deep Green matching BalanceCard
        borderRadius: BorderRadius.circular(24),
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
          Text(
            'TOTAL NET WORTH',
            style: TextStyle(
               color: Colors.white.withOpacity(0.7),
               fontSize: 12,
               fontWeight: FontWeight.w600,
               letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            formatter.format(total),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
             decoration: BoxDecoration(
               color: Colors.white.withOpacity(0.2),
               borderRadius: BorderRadius.circular(20),
             ),
             child: const Row(
               mainAxisSize: MainAxisSize.min,
               children: [
                 Icon(Icons.trending_up, color: Colors.white, size: 16),
                 SizedBox(width: 8),
                 Text(
                   '+₹14,200 this month',
                   style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                 ),
               ],
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildAccountItem(BuildContext context, Account account, NumberFormat formatter) {
     final theme = Theme.of(context);
    IconData icon;
    Color iconBg;
    Color iconColor;
    String subLabel;

    // Simple heurustics for Icon/Label based on name
    if (account.name.toLowerCase().contains('cash')) {
      icon = Icons.money;
      iconBg = Colors.green.shade50;
      iconColor = Colors.green.shade800;
      subLabel = 'MAIN WALLET';
    } else if (account.name.toLowerCase().contains('savings')) {
      icon = Icons.account_balance;
      iconBg = Colors.grey.shade100;
      iconColor = Colors.grey.shade800;
      subLabel = 'PRIMARY BANK';
    } else if (account.name.toLowerCase().contains('card')) {
      icon = Icons.credit_card;
      iconBg = Colors.grey.shade100;
      iconColor = Colors.grey.shade800;
      subLabel = 'CREDIT LINE';
    } else if (account.name.toLowerCase().contains('portfolio') || account.name.toLowerCase().contains('invest')) {
      icon = Icons.analytics_outlined;
      iconBg = Colors.grey.shade100;
      iconColor = Colors.grey.shade800;
      subLabel = 'INVESTMENTS';
    } else {
      icon = Icons.account_balance_wallet;
      iconBg = Colors.blue.shade50;
      iconColor = Colors.blue.shade800;
      subLabel = 'ACCOUNT';
    }

    return InkWell(
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (ctx) => Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.edit),
                title: const Text('Edit Account'),
                onTap: () {
                  Navigator.pop(ctx);
                  // Assuming AddAccountPage can handle editing if passed an account, 
                  // or we need to create one. For now, I'll navigate to AddAccountPage 
                  // and modifying it might be another task if it doesn't support edit.
                  // Let's assume we pass arguments or just show a TODO snackbar if strictly not supported yet.
                  // BETTER: Just Navigate to AddAccountPage but we need to check if it supports args.
                  // Since I can't see AddAccountPage, I'll implement Delete fully and Edit as a placeholder 
                  // or I will implement a quick Dialog for editing name/balance if needed.
                  // Let's try navigating to AddAccountPage with arguments.
                  Navigator.push(
                    context, 
                    MaterialPageRoute(builder: (_) => AddAccountPage(accountToEdit: account))
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text('Delete Account', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final shouldDelete = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Delete Account?'),
                      content: const Text('This will delete the account and its associated data permanently.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true), 
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  
                  if (shouldDelete == true) {
                     await Provider.of<AccountsProvider>(context, listen: false).deleteAccount(account.id);
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
          boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.02),
               blurRadius: 10,
               offset: const Offset(0, 4),
             )
          ],
        ),
        child: Row(
          children: [
             Container(
               width: 50,
               height: 50,
               decoration: BoxDecoration(
                 color: iconBg,
                 borderRadius: BorderRadius.circular(16),
               ),
               child: Icon(icon, color: iconColor, size: 24),
             ),
             const SizedBox(width: 16),
             Expanded(
               child: Column(
                 crossAxisAlignment: CrossAxisAlignment.start,
                 children: [
                   Text(
                     account.name,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Balance: ${formatter.format(account.balance)}',
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
                    formatter.format(account.balance),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subLabel,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
