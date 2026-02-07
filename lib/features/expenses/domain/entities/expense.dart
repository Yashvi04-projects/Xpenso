import 'package:cloud_firestore/cloud_firestore.dart';

class Expense {
  final String id;
  final String userId;
  final double amount;
  final String categoryId;
  final String accountId;
  final DateTime date;
  final String note;

  Expense({
    required this.id,
    required this.userId,
    required this.amount,
    required this.categoryId,
    required this.accountId,
    required this.date,
    required this.note,
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'amount': amount,
      'categoryId': categoryId,
      'accountId': accountId,
      'date': Timestamp.fromDate(date),
      'note': note,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  factory Expense.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Expense(
      id: doc.id,
      userId: data['userId'] ?? '',
      amount: (data['amount'] as num).toDouble(),
      categoryId: data['categoryId'] ?? '',
      accountId: data['accountId'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      note: data['note'] ?? '',
    );
  }

  Expense copyWith({
    String? id,
    String? userId,
    double? amount,
    String? categoryId,
    String? accountId,
    DateTime? date,
    String? note,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      accountId: accountId ?? this.accountId,
      date: date ?? this.date,
      note: note ?? this.note,
    );
  }
}
