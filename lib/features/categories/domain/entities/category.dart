import 'package:cloud_firestore/cloud_firestore.dart';

class Category {
  final String id;
  final String userId;
  final String name;
  final double monthlyLimit;
  final String? icon;
  final int? color;

  Category({
    required this.id,
    required this.userId,
    required this.name,
    required this.monthlyLimit,
    this.icon,
    this.color,
  });

  Category copyWith({
    String? id,
    String? userId,
    String? name,
    double? monthlyLimit,
    String? icon,
    int? color,
  }) {
    return Category(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      icon: icon ?? this.icon,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'name': name,
      'monthlyLimit': monthlyLimit,
      'icon': icon,
      'color': color,
    };
  }

  factory Category.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Category(
      id: doc.id,
      userId: data['userId'] ?? '',
      name: data['name'] ?? '',
      monthlyLimit: (data['monthlyLimit'] as num).toDouble(),
      icon: data['icon'],
      color: data['color'],
    );
  }
}
