import 'package:flutter/material.dart';
import '../../domain/entities/expense.dart';
import '../../domain/services/expense_service.dart';
import '../../../categories/domain/entities/category.dart';
import '../../../accounts/domain/entities/account.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../accounts/domain/repositories/account_repository.dart';

class AddExpenseProvider with ChangeNotifier {
  final ExpenseService _service;
  final CategoryRepository _categoryRepo;
  final AccountRepository _accountRepo;

  AddExpenseProvider(this._service, this._categoryRepo, this._accountRepo) {
    _loadInitialData();
  }

  // State
  String _amountStr = '0';
  String _note = '';
  DateTime _selectedDate = DateTime.now(); 
  String? _selectedCategoryId;
  String? _selectedAccountId;
  
  List<Category> _categories = [];
  List<Account> _accounts = [];
  bool _isLoading = true;

  // Getters
  String get amountStr => _amountStr;
  String get note => _note;
  DateTime get selectedDate => _selectedDate;
  String? get selectedCategoryId => _selectedCategoryId;
  String? get selectedAccountId => _selectedAccountId;
  List<Category> get categories => _categories;
  List<Account> get accounts => _accounts;
  bool get isLoading => _isLoading;

  bool get isValid => 
      double.tryParse(_amountStr) != null && 
      double.parse(_amountStr) > 0 &&
      _selectedCategoryId != null &&
      _selectedAccountId != null;

  void reset() {
    _amountStr = '0';
    _note = '';
    _selectedDate = DateTime.now();
    if (_categories.isNotEmpty) _selectedCategoryId = _categories.first.id;
    if (_accounts.isNotEmpty) _selectedAccountId = _accounts.first.id;
    notifyListeners();
  }

  Future<void> _loadInitialData() async {
    _isLoading = true;
    notifyListeners();
    try {
      _categories = await _categoryRepo.getCategories();
      _accounts = await _accountRepo.getAccounts();
      if (_categories.isNotEmpty) _selectedCategoryId = _categories.first.id;
      if (_accounts.isNotEmpty) _selectedAccountId = _accounts.first.id;
    } catch (e) {
      print("Error loading add-expense data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCategory(String id) {
    _selectedCategoryId = id;
    notifyListeners();
  }

  void setAccount(String id) {
    _selectedAccountId = id;
    notifyListeners();
  }

  void setDate(DateTime date) {
    _selectedDate = DateTime(date.year, date.month, date.day, _selectedDate.hour, _selectedDate.minute);
    notifyListeners();
  }

  void setTime(TimeOfDay time) {
    _selectedDate = DateTime(_selectedDate.year, _selectedDate.month, _selectedDate.day, time.hour, time.minute);
    notifyListeners();
  }

  void updateNote(String val) {
    _note = val;
    notifyListeners();
  }

  // Calculator State
  double? _firstOperand;
  String? _operator;
  bool _shouldResetDisplay = false;

  void onKeyPress(String value) {
    if (value == 'backspace') {
      if (_shouldResetDisplay) return; // Don't backspace result
      _amountStr = _amountStr.length > 1 ? _amountStr.substring(0, _amountStr.length - 1) : '0';
    } else if (value == 'C') {
      _amountStr = '0';
      _firstOperand = null;
      _operator = null;
    } else if (['+', '-', '×', '÷'].contains(value)) {
      _handleOperator(value);
    } else if (value == '=') {
      _calculateResult();
      _operator = null; // Clear operator after result
    } else if (value == '.') {
      if (_shouldResetDisplay) {
        _amountStr = '0.';
        _shouldResetDisplay = false;
      } else if (!_amountStr.contains('.')) {
        _amountStr += value;
      }
    } else {
      if (_shouldResetDisplay) {
        _amountStr = value;
        _shouldResetDisplay = false;
      } else {
        _amountStr = _amountStr == '0' ? value : (_amountStr.length < 10 ? _amountStr + value : _amountStr);
      }
    }
    notifyListeners();
  }

  void _handleOperator(String newOp) {
    if (_firstOperand == null) {
      _firstOperand = double.tryParse(_amountStr);
    } else if (_operator != null && !_shouldResetDisplay) {
      _calculateResult();
    }
    _operator = newOp;
    _shouldResetDisplay = true;
  }

  void _calculateResult() {
    if (_firstOperand == null || _operator == null) return;
    
    final secondOperand = double.tryParse(_amountStr) ?? 0;
    double result = 0;

    switch (_operator) {
      case '+':
        result = _firstOperand! + secondOperand;
        break;
      case '-':
        result = _firstOperand! - secondOperand;
        break;
      case '×':
        result = _firstOperand! * secondOperand;
        break;
      case '÷':
        if (secondOperand != 0) {
          result = _firstOperand! / secondOperand;
        } else {
          result = 0; // Handle division by zero gracefully
        }
        break;
    }

    // Format result to remove trailing .0
    if (result % 1 == 0) {
      _amountStr = result.toInt().toString();
    } else {
      _amountStr = result.toStringAsFixed(2);
    }
    
    _firstOperand = result; // Store result for next operation
    _shouldResetDisplay = true;
  }

  Future<bool> saveExpense() async {
    if (!isValid) return false;
    try {
      final newExpense = Expense(
        id: '', userId: '', 
        amount: double.parse(_amountStr),
        categoryId: _selectedCategoryId!,
        accountId: _selectedAccountId!,
        date: _selectedDate,
        note: _note,
      );
      await _service.addExpense(newExpense);
      return true;
    } catch (e) {
      print("Error saving expense: $e");
      return false;
    }
  }
}
