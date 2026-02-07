import 'package:flutter/material.dart';
import '../../../expenses/domain/entities/expense.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';

class InsightData {
  final String categoryId;
  final double amount;
  final double percentage;

  InsightData(this.categoryId, this.amount, this.percentage);
}

class InsightsProvider with ChangeNotifier {
  final ExpenseRepository _repository;

  InsightsProvider(this._repository);

  bool _isLoading = false;
  double _totalSpent = 0;
  List<InsightData> _categoryBreakdown = [];
  final Map<String, double> _monthlyTrend = {};
  
  bool get isLoading => _isLoading;
  double get totalSpent => _totalSpent;
  List<InsightData> get categoryBreakdown => _categoryBreakdown;
  Map<String, double> get monthlyTrend => _monthlyTrend;

  String _timeframe = 'Monthly';
  String get timeframe => _timeframe;

  void setTimeframe(String tf) {
    _timeframe = tf;
    loadInsights(); 
  }

  Future<void> loadInsights() async {
    _isLoading = true;
    notifyListeners();

    try {
      final expenses = await _repository.getExpenses();
      
      // Filter by timeframe (simulated for now, could be more complex date filtering)
      final now = DateTime.now();
      List<Expense> filteredExpenses = expenses;
      
      if (_timeframe == 'Monthly') {
        filteredExpenses = expenses.where((e) => e.date.year == now.year && e.date.month == now.month).toList();
      } else if (_timeframe == 'Weekly') {
        final lastWeek = now.subtract(const Duration(days: 7));
        filteredExpenses = expenses.where((e) => e.date.isAfter(lastWeek)).toList();
      }

      // Calculate Total
      _totalSpent = filteredExpenses.fold(0, (sum, item) => sum + item.amount);

      // Group by Category
      final Map<String, double> grouped = {};
      for (var e in filteredExpenses) {
        grouped[e.categoryId] = (grouped[e.categoryId] ?? 0) + e.amount;
      }

      // Create Breakdown
      _categoryBreakdown = grouped.entries.map((e) {
        return InsightData(e.key, e.value, _totalSpent > 0 ? (e.value / _totalSpent) * 100 : 0.0);
      }).toList();
      
      // Sort by amount desc
      _categoryBreakdown.sort((a, b) => b.amount.compareTo(a.amount));
      
      _generateSmartInsight();

    } catch (e) {
      print("Error loading insights: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _smartInsight = "Add more expenses to see personalized insights!";
  String get smartInsight => _smartInsight;

  void _generateSmartInsight() {
    if (_categoryBreakdown.isEmpty) {
      _smartInsight = "No spending data available for this period.";
      return;
    }

    final top = _categoryBreakdown.first;
    // Simple logic: if top category is > 50% of total
    if (top.percentage > 50) {
      _smartInsight = "Your spending is heavily concentrated in one category. Consider diversifying your budget.";
    } else {
      _smartInsight = "Your spending looks balanced this period. Keep it up!";
    }
  }
}
