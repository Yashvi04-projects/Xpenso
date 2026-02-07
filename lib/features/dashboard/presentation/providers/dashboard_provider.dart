import 'dart:async';
import 'package:flutter/material.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../settings/domain/repositories/settings_repository.dart';
import '../../../../core/notifications/notification_service.dart';

class DashboardProvider with ChangeNotifier {
  final ExpenseRepository _expenseRepository;
  final AccountRepository _accountRepository;
  final SettingsRepository _settingsRepository;
  
  final NotificationService _notificationService;
  
  StreamSubscription? _expenseSubscription;
  StreamSubscription? _settingsSubscription;
  StreamSubscription? _accountSubscription;
  
  bool _hasNotifiedBudget = false;

  DashboardProvider(
    this._expenseRepository,
    this._accountRepository,
    this._settingsRepository,
    this._notificationService,
  ) {
    _startListening();
  }

  // ... (existing properties)
  List<Expense> _recentExpenses = [];
  double _totalSpent = 0;
  double _monthlyBudget = 50000;
  double _totalBalance = 0;
  String _currency = 'INR';
  bool _isLoading = true;
  bool _balanceVisible = true;
  bool _budgetAlertsEnabled = true;

  // ... (getters)
  List<Expense> get recentExpenses => _recentExpenses;
  double get totalSpent => _totalSpent;
  double get monthlyBudget => _monthlyBudget;
  double get totalBalance => _totalBalance;
  String get currency => _currency;
  bool get isLoading => _isLoading;
  bool get balanceVisible => _balanceVisible;

  void _startListening() {
    _isLoading = true;
    notifyListeners();

    // Listen to expenses
    _expenseSubscription = _expenseRepository.watchExpenses().listen((allExpenses) {
      _processExpenses(allExpenses);
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print("Dashboard Expense Stream Error: $error");
      _isLoading = false;
      notifyListeners();
    });

    // Listen to settings for budget, visibility and currency
    _settingsSubscription = _settingsRepository.watchUserSettings().listen((settings) {
      _monthlyBudget = settings.monthlyBudget;
      _balanceVisible = settings.balanceVisible;
      _currency = settings.currency;
      _budgetAlertsEnabled = settings.budgetAlerts;
      notifyListeners();
    }, onError: (error) {
      print("Dashboard Settings Stream Error: $error");
    });
    
    // Listen to accounts for total balance
    _accountSubscription = _accountRepository.watchAccounts().listen((accounts) {
      _totalBalance = accounts.fold(0, (sum, account) => sum + account.balance);
      notifyListeners();
    }, onError: (error) {
      print("Dashboard Accounts Stream Error: $error");
    });
  }

  void _processExpenses(List<Expense> allExpenses) {
    final now = DateTime.now();
    final currentMonthExpenses = allExpenses.where((e) {
      return e.date.year == now.year && e.date.month == now.month;
    }).toList();

    _totalSpent = currentMonthExpenses.fold(0, (sum, item) => sum + item.amount);
    
    // Check Budget Logic
    if (_budgetAlertsEnabled && _monthlyBudget > 0 && _totalSpent > _monthlyBudget) {
       if (!_hasNotifiedBudget) {
         _notificationService.showBudgetAlert(categoryName: "Total Monthly");
         _hasNotifiedBudget = true;
       }
    } else {
       // Reset if back under budget (e.g. deleted expense or increased budget)
       if (_totalSpent <= _monthlyBudget) {
         _hasNotifiedBudget = false;
       }
    }
    
    // Sort and take top 5
    final sorted = List<Expense>.from(allExpenses);
    sorted.sort((a, b) => b.date.compareTo(a.date));
    _recentExpenses = sorted.take(5).toList();
  }

  Future<void> toggleBalanceVisibility() async {
    // Optimistic Update: Change local state immediately so UI feels responsive
    _balanceVisible = !_balanceVisible;
    notifyListeners();

    try {
      final settings = await _settingsRepository.getUserSettings();
      await _settingsRepository.updateUserSettings(
        settings.copyWith(balanceVisible: _balanceVisible),
      );
    } catch (e) {
      print("Error syncing balance visibility to Firestore: $e");
      // We don't roll back because it's a minor UI preference and we want it to feel "workable"
    }
  }

  Future<void> loadDashboardData() async {
    // Data is already handled by streams, but RefreshIndicator expects a Future.
    return Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  void dispose() {
    _expenseSubscription?.cancel();
    _settingsSubscription?.cancel();
    _accountSubscription?.cancel();
    super.dispose();
  }
}
