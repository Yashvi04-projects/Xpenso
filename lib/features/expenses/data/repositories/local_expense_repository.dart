import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';

class LocalExpenseRepository implements ExpenseRepository {
  final List<Expense> _expenses = [];

  // Singleton pattern to simulate persistent database across screens
  static final LocalExpenseRepository _instance = LocalExpenseRepository._internal();
  factory LocalExpenseRepository() => _instance;
  LocalExpenseRepository._internal();

  @override
  Future<void> addExpense(Expense expense) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    _expenses.add(expense);
  }

  @override
  Future<void> deleteExpense(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _expenses.removeWhere((element) => element.id == id);
  }

  @override
  Future<Expense?> getExpenseById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _expenses.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Expense>> getExpenses() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_expenses);
  }

  Future<List<Expense>> getExpensesByDateRange(DateTime start, DateTime end) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _expenses.where((expense) {
      return expense.date.isAfter(start) && expense.date.isBefore(end);
    }).toList();
  }

  @override
  Future<void> updateExpense(Expense expense) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _expenses.indexWhere((element) => element.id == expense.id);
    if (index != -1) {
      _expenses[index] = expense;
    }
  }

  @override
  Stream<List<Expense>> watchExpenses() {
    return Stream.value(_expenses);
  }
}
