import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'notification_channels.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    tz.initializeTimeZones();
    
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        // Handle notification tap logic here if needed
      },
    );

    // Create channels for Android
    final androidImplementation = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    
    if (androidImplementation != null) {
      await androidImplementation.createNotificationChannel(NotificationChannels.dailyReminders);
      await androidImplementation.createNotificationChannel(NotificationChannels.budgetAlerts);
      await androidImplementation.createNotificationChannel(NotificationChannels.monthlySummaries);
    }
  }

  Future<void> scheduleDailyReminder({
    required int id, 
    required int hour, 
    required int minute,
    bool playSound = true,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      id,
      "Don't forget to add today's expenses 💰",
      "Keeping track helps you stay on budget!",
      _nextInstanceOfTime(hour, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChannels.dailyReminders.id,
          NotificationChannels.dailyReminders.name,
          channelDescription: NotificationChannels.dailyReminders.description,
          importance: Importance.max,
          playSound: playSound,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentSound: playSound,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,

      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  Future<void> showBudgetAlert({required String categoryName}) async {
    await _notificationsPlugin.show(
      DateTime.now().millisecond,
      "Budget Alert 💸",
      "You've exceeded your $categoryName budget!",
      NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChannels.budgetAlerts.id,
          NotificationChannels.budgetAlerts.name,
          channelDescription: NotificationChannels.budgetAlerts.description,
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  Future<void> scheduleMonthlySummary({
    required int id,
    required double totalSpent,
    required String topCategory,
  }) async {
    // Schedule for the 1st of next month at 9 AM
    final now = DateTime.now();
    var nextMonth = DateTime(now.year, now.month + 1, 1, 9, 0);
    
    await _notificationsPlugin.zonedSchedule(
      id,
      "Monthly Summary 📊",
      "Last month you spent ₹${totalSpent.toStringAsFixed(0)}. Highest spending: $topCategory",
      tz.TZDateTime.from(nextMonth, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          NotificationChannels.monthlySummaries.id,
          NotificationChannels.monthlySummaries.name,
          channelDescription: NotificationChannels.monthlySummaries.description,
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,

      matchDateTimeComponents: DateTimeComponents.dayOfMonthAndTime,
    );
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }
}
