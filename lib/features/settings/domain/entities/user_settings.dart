import 'package:cloud_firestore/cloud_firestore.dart';

class UserSettings {
  final String userId;
  final double monthlyBudget;
  final bool balanceVisible;
  final bool dailyReminders;
  final String reminderTime; // Format: "HH:mm"
  final bool budgetAlerts;
  final bool categoryBudgetToggle;
  final String currency; // e.g., "INR", "USD"
  final String notificationSound; // "default", "silent"

  UserSettings({
    required this.userId,
    this.monthlyBudget = 50000.0,
    this.balanceVisible = true,
    this.dailyReminders = true,
    this.reminderTime = "21:00",
    this.budgetAlerts = true,
    this.categoryBudgetToggle = true,
    this.currency = "INR",
    this.notificationSound = "default",
  });

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'monthlyBudget': monthlyBudget,
      'balanceVisible': balanceVisible,
      'dailyReminders': dailyReminders,
      'reminderTime': reminderTime,
      'budgetAlerts': budgetAlerts,
      'categoryBudgetToggle': categoryBudgetToggle,
      'currency': currency,
      'notificationSound': notificationSound,
    };
  }

  factory UserSettings.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserSettings(
      userId: data['userId'] ?? '',
      monthlyBudget: (data['monthlyBudget'] as num?)?.toDouble() ?? 50000.0,
      balanceVisible: data['balanceVisible'] ?? true,
      dailyReminders: data['dailyReminders'] ?? true,
      reminderTime: data['reminderTime'] ?? "21:00",
      budgetAlerts: data['budgetAlerts'] ?? true,
      categoryBudgetToggle: data['categoryBudgetToggle'] ?? true,
      currency: data['currency'] ?? "INR",
      notificationSound: data['notificationSound'] ?? "default",
    );
  }

  UserSettings copyWith({
    String? userId,
    double? monthlyBudget,
    bool? balanceVisible,
    bool? dailyReminders,
    String? reminderTime,
    bool? budgetAlerts,
    bool? categoryBudgetToggle,
    String? currency,
    String? notificationSound,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,
      monthlyBudget: monthlyBudget ?? this.monthlyBudget,
      balanceVisible: balanceVisible ?? this.balanceVisible,
      dailyReminders: dailyReminders ?? this.dailyReminders,
      reminderTime: reminderTime ?? this.reminderTime,
      budgetAlerts: budgetAlerts ?? this.budgetAlerts,
      categoryBudgetToggle: categoryBudgetToggle ?? this.categoryBudgetToggle,
      currency: currency ?? this.currency,
      notificationSound: notificationSound ?? this.notificationSound,
    );
  }
}
