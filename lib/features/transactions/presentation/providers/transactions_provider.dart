import 'dart:async';
import 'package:flutter/material.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';

class TransactionSection {
  final DateTime date;
  final double totalAmount; 
  final List<Expense> items;

  TransactionSection({
    required this.date,
    required this.totalAmount,
    required this.items,
  });
}

class TransactionsProvider with ChangeNotifier {
  final ExpenseRepository _repository;
  StreamSubscription? _subscription;

  TransactionsProvider(this._repository) {
    _startListening();
  }

  List<TransactionSection> _sections = [];
  bool _isLoading = false;

  List<TransactionSection> get sections => _sections;
  bool get isLoading => _isLoading;

  void _startListening() {
    _isLoading = true;
    notifyListeners();

    _subscription = _repository.watchExpenses().listen((expenses) {
      _processExpenses(expenses);
      _isLoading = false;
      notifyListeners();
    }, onError: (error) {
      print("Transactions Stream Error: $error");
      _isLoading = false;
      notifyListeners();
    });
  }

  // Filters
  DateTime? _filterMonth;
  String? _filterCategoryId;
  String? _filterAccountId;
  String? _searchQuery;

  // Setters
  void setFilterMonth(DateTime? month) {
    _filterMonth = month;
    _refreshFromCache();
  }

  void setFilterCategory(String? categoryId) {
    _filterCategoryId = categoryId;
    _refreshFromCache();
  }

  void setFilterAccount(String? accountId) {
    _filterAccountId = accountId;
    _refreshFromCache();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.isEmpty ? null : query.toLowerCase();
    _refreshFromCache();
  }

  // Cache last expenses to re-process without refetching stream
  List<Expense> _cachedExpenses = [];

  void _processExpenses(List<Expense> expenses) {
    _cachedExpenses = expenses;
    
    // Sort Newest first
    var filtered = List<Expense>.from(expenses);
    filtered.sort((a, b) => b.date.compareTo(a.date));

    // Apply Filters
    if (_filterMonth != null) {
      filtered = filtered.where((e) => e.date.year == _filterMonth!.year && e.date.month == _filterMonth!.month).toList();
    }
    if (_filterCategoryId != null) {
      filtered = filtered.where((e) => e.categoryId == _filterCategoryId).toList();
    }
    if (_filterAccountId != null) {
      filtered = filtered.where((e) => e.accountId == _filterAccountId).toList();
    }
    if (_searchQuery != null) {
      filtered = filtered.where((e) => e.note.toLowerCase().contains(_searchQuery!)).toList();
    }

    final Map<String, List<Expense>> grouped = {};

    for (var expense in filtered) {
      final dateKey = _getDateKey(expense.date);
      if (!grouped.containsKey(dateKey)) {
        grouped[dateKey] = [];
      }
      grouped[dateKey]!.add(expense);
    }

    _sections = grouped.entries.map((entry) {
      final date = entry.value.first.date;
      final total = entry.value.fold(0.0, (sum, item) => sum + item.amount);
      return TransactionSection(
        date: date,
        totalAmount: total,
        items: entry.value,
      );
    }).toList();
    
    // Ensure sections are sorted
    _sections.sort((a,b) => b.date.compareTo(a.date));
  }

  void _refreshFromCache() {
    _processExpenses(_cachedExpenses);
    notifyListeners();
  }

  String _getDateKey(DateTime date) {
    return "${date.year}-${date.month}-${date.day}";
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
