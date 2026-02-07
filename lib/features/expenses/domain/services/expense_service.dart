import '../../../categories/domain/repositories/category_repository.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../../core/notifications/notification_service.dart';
import 'package:flutter/foundation.dart';
import '../entities/expense.dart';
import '../repositories/expense_repository.dart';

class ExpenseService {
  final ExpenseRepository _expenseRepository;
  final CategoryRepository _categoryRepository;
  final AccountRepository _accountRepository;
  final NotificationService _notificationService;

  ExpenseService(
    this._expenseRepository,
    this._categoryRepository,
    this._accountRepository,
    this._notificationService,
  );

  Future<void> addExpense(Expense expense) async {
    // 1. Add the expense
    await _expenseRepository.addExpense(expense);

    // 2. Update the account balance
    final account = await _accountRepository.getAccountById(expense.accountId);
    if (account != null) {
      final newBalance = account.balance - expense.amount;
      await _accountRepository.updateAccountBalance(expense.accountId, newBalance);
    }

    // 3. Check for budget limit in the expense's category
    _checkBudgetLimit(expense.categoryId);
  }

  Future<void> _checkBudgetLimit(String categoryId) async {
    try {
      final categories = await _categoryRepository.getCategories();
      final category = categories.firstWhere((c) => c.id == categoryId);
      
      final expenses = await _expenseRepository.getExpenses();
      
      final now = DateTime.now();
      final currentMonthExpenses = expenses.where((e) => 
        e.categoryId == categoryId && 
        e.date.year == now.year && 
        e.date.month == now.month
      );

      final totalSpent = currentMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);

      if (totalSpent > category.monthlyLimit) {
        await _notificationService.showBudgetAlert(categoryName: category.name);
      }
    } catch (e) {
      // Log error but don't crash the app for a notification failure
      print('Error checking budget: $e');
    }
  }

  Future<void> scheduleMonthlySummary() async {
    try {
      final expenses = await _expenseRepository.getExpenses();
      final now = DateTime.now();
      final lastMonth = now.month == 1 ? 12 : now.month - 1;
      final year = now.month == 1 ? now.year - 1 : now.year;

      final lastMonthExpenses = expenses.where((e) => 
        e.date.year == year && e.date.month == lastMonth
      );

      if (lastMonthExpenses.isEmpty) return;

      final totalSpent = lastMonthExpenses.fold(0.0, (sum, e) => sum + e.amount);
      
      // Group by category to find top category
      final Map<String, double> categorySums = {};
      for (var e in lastMonthExpenses) {
        categorySums[e.categoryId] = (categorySums[e.categoryId] ?? 0) + e.amount;
      }

      String topCategoryId = '';
      double maxSpent = 0;
      categorySums.forEach((id, sum) {
        if (sum > maxSpent) {
          maxSpent = sum;
          topCategoryId = id;
        }
      });

      final categories = await _categoryRepository.getCategories();
      final topCategory = categories.firstWhere((c) => c.id == topCategoryId, orElse: () => categories.first);

      await _notificationService.scheduleMonthlySummary(
        id: 2,
        totalSpent: totalSpent,
        topCategory: topCategory.name,
      );
    } catch (e) {
      print('Error scheduling monthly summary: $e');
    }
  }
}
