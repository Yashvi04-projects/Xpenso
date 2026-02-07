import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';

class AccountsProvider with ChangeNotifier {
  final AccountRepository _repository;
  StreamSubscription? _subscription;

  AccountsProvider(this._repository) {
    _startListening();
  }

  List<Account> _accounts = [];
  double _totalNetWorth = 0;
  bool _isLoading = false;

  List<Account> get accounts => _accounts;
  double get totalNetWorth => _totalNetWorth;
  bool get isLoading => _isLoading;

  void _startListening() {
    _isLoading = true;
    notifyListeners();
    _subscription = _repository.watchAccounts().listen((accounts) {
      _accounts = accounts;
      _totalNetWorth = accounts.fold(0, (sum, item) => sum + item.balance);
      _isLoading = false;
      notifyListeners();
    }, onError: (e) {
      print("Error watching accounts: $e");
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> loadAccounts() async {
    // Redundant but keeping for compatibility
    final accounts = await _repository.getAccounts();
    _accounts = accounts;
    _totalNetWorth = accounts.fold(0, (sum, item) => sum + item.balance);
    notifyListeners();
  }

  Future<void> deleteAccount(String id) async {
    try {
      await _repository.deleteAccount(id);
    } catch (e) {
      print("Error deleting account: $e");
      rethrow;
    }
  }

  Future<void> updateAccount(Account account) async {
    try {
      await _repository.updateAccount(account);
    } catch (e) {
      print("Error updating account: $e");
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
