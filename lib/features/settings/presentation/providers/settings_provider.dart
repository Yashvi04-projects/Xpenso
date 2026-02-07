import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/settings_repository.dart';
import '../../../expenses/domain/repositories/expense_repository.dart';
import '../../../accounts/domain/repositories/account_repository.dart';
import '../../../categories/domain/repositories/category_repository.dart';
import '../../../../core/notifications/notification_service.dart';
import '../../../../core/theme/theme_provider.dart';

class SettingsProvider with ChangeNotifier {
  final SettingsRepository _settingsRepo;
  final ExpenseRepository _expenseRepo;
  final AccountRepository _accountRepo;
  final CategoryRepository _categoryRepo;
  final NotificationService _notificationService;
  final ThemeProvider _themeProvider;

  UserSettings? _settings;
  StreamSubscription? _settingsSubscription;

  SettingsProvider(
    this._settingsRepo,
    this._expenseRepo,
    this._accountRepo,
    this._categoryRepo,
    this._notificationService,
    this._themeProvider,
  ) {
    _listenToSettings();
  }

  UserSettings? get settings => _settings;
  bool get isDarkMode => _themeProvider.themeMode == ThemeMode.dark;

  void _listenToSettings() {
    _settingsSubscription = _settingsRepo.watchUserSettings().listen((settings) {
      _settings = settings;
      _updateNotifications();
      notifyListeners();
    });
  }

  void _updateNotifications() {
    if (_settings == null) return;

    if (_settings!.dailyReminders) {
      final timeParts = _settings!.reminderTime.split(':');
      final hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      _notificationService.scheduleDailyReminder(
        id: 1,
        hour: hour,
        minute: minute,
        playSound: _settings!.notificationSound == 'default',
      );
    } else {
      // Logic to cancel specific notification if service supports it
      // For now we just don't schedule
    }
  }

  Future<void> updateMonthlyBudget(double budget) async {
    if (_settings == null) return;
    await _settingsRepo.updateUserSettings(_settings!.copyWith(monthlyBudget: budget));
  }

  Future<void> updateCurrency(String currency) async {
    if (_settings == null) return;
    await _settingsRepo.updateUserSettings(_settings!.copyWith(currency: currency));
  }

  Future<void> toggleDailyReminders(bool value) async {
    if (_settings == null) return;
    await _settingsRepo.updateUserSettings(_settings!.copyWith(dailyReminders: value));
  }

  Future<void> updateReminderTime(TimeOfDay time) async {
    if (_settings == null) return;
    final timeStr = "${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}";
    await _settingsRepo.updateUserSettings(_settings!.copyWith(reminderTime: timeStr));
  }

  Future<void> toggleBudgetAlerts(bool value) async {
    if (_settings == null) return;
    await _settingsRepo.updateUserSettings(_settings!.copyWith(budgetAlerts: value));
  }

  Future<void> toggleCategoryBudget(bool value) async {
    if (_settings == null) return;
    await _settingsRepo.updateUserSettings(_settings!.copyWith(categoryBudgetToggle: value));
  }

  Future<void> updateNotificationSound(String sound) async {
    if (_settings == null) return;
    await _settingsRepo.updateUserSettings(_settings!.copyWith(notificationSound: sound));
  }

  void toggleTheme() {
    _themeProvider.toggleTheme();
    notifyListeners();
  }

  // --- Data Management ---

  Future<void> exportToCSV() async {
    final expenses = await _expenseRepo.getExpenses();
    List<List<dynamic>> rows = [];
    rows.add(["Date", "Category", "Account", "Amount", "Note"]);

    final categories = await _categoryRepo.getCategories();
    final accounts = await _accountRepo.getAccounts();

    for (var e in expenses) {
      final cat = categories.firstWhere((c) => c.id == e.categoryId, orElse: () => categories.first).name;
      final acc = accounts.firstWhere((a) => a.id == e.accountId, orElse: () => accounts.first).name;
      rows.add([
        DateFormat('yyyy-MM-dd HH:mm').format(e.date),
        cat,
        acc,
        e.amount,
        e.note,
      ]);
    }

    String csv = const ListToCsvConverter().convert(rows);
    final directory = await getTemporaryDirectory();
    final path = "${directory.path}/expenses_export_${DateTime.now().millisecondsSinceEpoch}.csv";
    final file = File(path);
    await file.writeAsString(csv);

    await Share.shareXFiles([XFile(path)], text: 'My Xpenso Expenses CSV');
  }

  Future<void> exportToPDF() async {
    final expenses = await _expenseRepo.getExpenses();
    final categories = await _categoryRepo.getCategories();
    final accounts = await _accountRepo.getAccounts();

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text("Xpenso Expense Report")),
            pw.Table.fromTextArray(
            headers: ["Date", "Category", "Account", "Amount", "Note"],
            data: expenses.map((e) {
              final cat = categories.firstWhere((c) => c.id == e.categoryId, orElse: () => categories.first).name;
              final acc = accounts.firstWhere((a) => a.id == e.accountId, orElse: () => accounts.first).name;
              return [
                DateFormat('yyyy-MM-dd').format(e.date),
                cat,
                acc,
                e.amount.toString(),
                e.note,
              ];
            }).toList(),
          ),
        ],
      ),
    );

    final directory = await getTemporaryDirectory();
    final path = "${directory.path}/expenses_export_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final file = File(path);
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([XFile(path)], text: 'My Xpenso Expenses PDF');
  }

  Future<void> resetAllData() async {
    try {
      // 1. Delete all expenses
      final expenses = await _expenseRepo.getExpenses();
      for (var e in expenses) {
        await _expenseRepo.deleteExpense(e.id);
      }
      
      // 2. Reset account balances to 0
      final accounts = await _accountRepo.getAccounts();
      for (var a in accounts) {
         await _accountRepo.updateAccountBalance(a.id, 0);
      }

      // 3. Reset Category Limits? (Optional but "All Data" might imply this)
      // For now, let's stick to Expenses + Account Balances as that's the core "financial data".
      // If categories are custom, we might want to delete them if they were user added, but standard ones should stay.
      // Assuming standard categories for now.

      notifyListeners();
    } catch (e) {
      print("Error resetting data: $e");
      rethrow;
    }
  }

  Future<void> clearCache() async {
    // For Firestore, this clears the local cache
    await FirebaseFirestore.instance.clearPersistence();
    notifyListeners();
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    super.dispose();
  }
}
