import 'package:flutter/material.dart';
import '../../domain/entities/category.dart';
import '../../domain/repositories/category_repository.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';

class CategoryBudget {
  final Category category;
  final double spent;

  CategoryBudget({required this.category, required this.spent});

  double get progress => category.monthlyLimit > 0 ? (spent / category.monthlyLimit).clamp(0.0, 1.0) : 0.0;
  double get remaining => category.monthlyLimit - spent;
  bool get isOverBudget => spent > category.monthlyLimit;
  double get percent => category.monthlyLimit > 0 ? (spent / category.monthlyLimit) * 100 : 0.0;
}

class CategoriesProvider with ChangeNotifier {
  final CategoryRepository _categoryRepository;
  final ExpenseRepository _expenseRepository;

  CategoriesProvider(this._categoryRepository, this._expenseRepository);

  List<CategoryBudget> _budgets = [];
  double _totalBudget = 0;
  double _totalSpent = 0;
  bool _isLoading = false;

  List<CategoryBudget> get budgets => _budgets;
  double get totalBudget => _totalBudget;
  double get totalSpent => _totalSpent;
  bool get isLoading => _isLoading;

  Future<void> loadBudgets() async {
    _isLoading = true;
    notifyListeners();

    try {
      final categories = await _categoryRepository.getCategories();
      final expenses = await _expenseRepository.getExpenses();
      
      final now = DateTime.now();
      
      _budgets = categories.map((cat) {
        // Calculate real spent for this category in current month
        final spent = expenses.where((e) => 
          e.categoryId == cat.id && 
          e.date.year == now.year && 
          e.date.month == now.month
        ).fold(0.0, (sum, e) => sum + e.amount);
        
        return CategoryBudget(category: cat, spent: spent);
      }).toList();

      _totalBudget = _budgets.fold(0, (sum, item) => sum + item.category.monthlyLimit);
      _totalSpent = _budgets.fold(0, (sum, item) => sum + item.spent);

    } catch (e) {
      print("Error loading budgets: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addCategory(Category category) async {
    await _categoryRepository.addCategory(category);
    await loadBudgets(); // Refresh to include new category
  }

  Future<void> updateCategory(Category category) async {
    await _categoryRepository.updateCategory(category);
    await loadBudgets();
  }

  Future<void> deleteCategory(String id) async {
    await _categoryRepository.deleteCategory(id);
    await loadBudgets();
  }
}
