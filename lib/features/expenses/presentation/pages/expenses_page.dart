import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/repositories/expense_repository.dart';
import '../../../../features/transactions/presentation/providers/transactions_provider.dart';
import '../../../../features/transactions/presentation/widgets/transaction_list_item.dart';
import '../../../../features/dashboard/presentation/providers/dashboard_provider.dart';
import '../../../../features/categories/presentation/providers/categories_provider.dart';
import '../../../../features/accounts/presentation/providers/accounts_provider.dart';
import '../../../../features/categories/domain/repositories/category_repository.dart';
import '../../../../features/accounts/domain/repositories/account_repository.dart';
import '../../../../features/settings/presentation/providers/settings_provider.dart';

class ExpensesPage extends StatelessWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context) {
    // We reuse TransactionsProvider here as it now has the logic we need
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => TransactionsProvider(
            Provider.of<ExpenseRepository>(ctx, listen: false),
          ),
        ),
        ChangeNotifierProvider(
           create: (ctx) => CategoriesProvider(
             Provider.of<CategoryRepository>(ctx, listen: false),
             Provider.of<ExpenseRepository>(ctx, listen: false),
           )..loadBudgets(), 
        ),
         ChangeNotifierProvider(
           create: (ctx) => AccountsProvider(
             Provider.of<AccountRepository>(ctx, listen: false),
           )..loadAccounts(), 
        ),
      ],
      child: const _ExpensesView(),
    );
  }
}

class _ExpensesView extends StatefulWidget {
  const _ExpensesView();

  @override
  State<_ExpensesView> createState() => _ExpensesViewState();
}

class _ExpensesViewState extends State<_ExpensesView> {
  bool _isSearchVisible = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new, color: headerColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: _isSearchVisible 
          ? TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Search by note...',
                border: InputBorder.none,
              ),
              onChanged: (val) => provider.setSearchQuery(val),
            )
          : Text('Expenses', style: TextStyle(color: headerColor, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search, color: headerColor),
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                   _searchController.clear();
                   provider.setSearchQuery('');
                }
              });
            },
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
                _buildMonthFilter(context, provider),
                const SizedBox(width: 12),
                _buildCategoryFilter(context, provider),
                const SizedBox(width: 12),
                _buildAccountFilter(context, provider),
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
                             ...section.items.map((e) => TransactionListItem(
                               expense: e,
                               currency: Provider.of<SettingsProvider>(context).settings?.currency ?? 'INR',
                             )),
                          ],
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthFilter(BuildContext context, TransactionsProvider provider) {
     return _buildDropdownButton<DateTime?>(
       context: context,
       label: 'Month',
       value: null, // We don't really store selected month in a way that maps easily to a simple dropdown list of ALL months without generating them. 
                    // For simplicity, let's just use a picker or a fixed list of last 12 months.
       items: List.generate(12, (index) {
         final date = DateTime.now().subtract(Duration(days: 30 * index));
         return DropdownMenuItem(
           value: DateTime(date.year, date.month),
           child: Text(DateFormat('MMMM yyyy').format(date)),
         );
       }),
       onChanged: (val) => provider.setFilterMonth(val),
       icon: Icons.calendar_today,
     );
  }

  Widget _buildCategoryFilter(BuildContext context, TransactionsProvider provider) {
    final catProvider = Provider.of<CategoriesProvider>(context);
    return _buildDropdownButton<String?>(
      context: context,
      label: 'Category',
      value: null,
      items: [
        const DropdownMenuItem(value: null, child: Text("All Categories")),
        ...catProvider.budgets.map((b) => DropdownMenuItem(
          value: b.category.id, 
          child: Text(b.category.name),
        )),
      ],
      onChanged: (val) => provider.setFilterCategory(val),
      icon: Icons.category,
    );
  }

  Widget _buildAccountFilter(BuildContext context, TransactionsProvider provider) {
    final accProvider = Provider.of<AccountsProvider>(context);
    return _buildDropdownButton<String?>(
      context: context,
      label: 'Account',
      value: null,
      items: [
        const DropdownMenuItem(value: null, child: Text("All Accounts")),
        ...accProvider.accounts.map((a) => DropdownMenuItem(
          value: a.id, 
          child: Text(a.name),
        )),
      ],
      onChanged: (val) => provider.setFilterAccount(val),
      icon: Icons.account_balance_wallet,
    );
  }

  Widget _buildDropdownButton<T>({
    required BuildContext context, 
    required String label, 
    required T value, 
    required List<DropdownMenuItem<T>> items, 
    required ValueChanged<T?> onChanged,
    IconData? icon,
  }) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value, 
          hint: Row(
            children: [
              if (icon != null) ...[Icon(icon, size: 16, color: AppColors.textSecondaryLight), const SizedBox(width: 8)],
              Text(label, style: TextStyle(color: theme.colorScheme.onSurface, fontSize: 13, fontWeight: FontWeight.w600)),
            ],
          ),
          items: items,
          onChanged: onChanged,
          borderRadius: BorderRadius.circular(16),
          dropdownColor: theme.cardColor,
          elevation: 4,
          icon: const Icon(Icons.keyboard_arrow_down, size: 16),
        ),
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
            "No transactions found",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
