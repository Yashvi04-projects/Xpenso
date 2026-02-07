import 'package:cloud_firestore/cloud_firestore.dart';

class Account {
  final String id;
  final String userId;
  final String name;
  final double balance;

  Account({
    required this.id,
    required this.userId,
    required this.name,
    required this.balance,
  });

  Account copyWith({
    String? id,
    String? userId,
    String? name,
    double? balance,
  }) {
    return Account(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'balance': balance,
    };
  }

  factory Account.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Account(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      balance: (data['balance'] as num).toDouble(),
    );
  }
}
