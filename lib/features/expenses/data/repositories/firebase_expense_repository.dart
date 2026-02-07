import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/expense.dart';
import '../../domain/repositories/expense_repository.dart';
import '../datasources/firebase_expense_datasource.dart';

class FirebaseExpenseRepositoryImpl implements ExpenseRepository {
  final FirebaseExpenseDataSource _dataSource;
  final AuthRepository _authRepository;

  FirebaseExpenseRepositoryImpl(this._dataSource, this._authRepository);

  String get _userId {
    final user = _authRepository.currentUser;
    if (user == null) throw Exception('User must be logged in to perform this action.');
    return user.uid;
  }

  @override
  Future<void> addExpense(Expense expense) {
    return _dataSource.addExpense(expense.copyWith(userId: _userId));
  }

  @override
  Future<void> updateExpense(Expense expense) {
    return _dataSource.updateExpense(expense);
  }

  @override
  Future<void> deleteExpense(String id) {
    return _dataSource.deleteExpense(id);
  }

  @override
  Future<Expense?> getExpenseById(String id) {
    // Implementing this via getExpenses and filtering for now, or could add specialized method to DataSource
    return Future.value(null); // Not critical for now
  }

  @override
  Future<List<Expense>> getExpenses() async {
    // Convert stream to future for one-time fetch
    return _dataSource.getExpenses(_userId).first;
  }

  @override
  Stream<List<Expense>> watchExpenses() {
    return _dataSource.getExpenses(_userId);
  }
}
