import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationChannels {
  static const AndroidNotificationChannel dailyReminders = AndroidNotificationChannel(
    'daily_reminders',
    'Daily Reminders',
    description: 'Notifications to remind you to add your daily expenses.',
    importance: Importance.high,
  );

  static const AndroidNotificationChannel budgetAlerts = AndroidNotificationChannel(
    'budget_alerts',
    'Budget Alerts',
    description: 'Notifications when you exceed your category budget.',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  static const AndroidNotificationChannel monthlySummaries = AndroidNotificationChannel(
    'monthly_summaries',
    'Monthly Summaries',
    description: 'Notifications showing your spending summary for the previous month.',
    importance: Importance.defaultImportance,
  );
}
