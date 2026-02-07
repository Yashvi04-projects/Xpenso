import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/expense.dart';

class FirebaseExpenseDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _expensesCollection => _firestore.collection('expenses');

  Stream<List<Expense>> getExpenses(String userId) {
    return _expensesCollection
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Expense.fromFirestore(doc)).toList();
    });
  }

  Future<void> addExpense(Expense expense) async {
    await _expensesCollection.add(expense.toFirestore());
  }

  Future<void> updateExpense(Expense expense) async {
    await _expensesCollection.doc(expense.id).update(expense.toFirestore());
  }

  Future<void> deleteExpense(String expenseId) async {
    await _expensesCollection.doc(expenseId).delete();
  }
}
