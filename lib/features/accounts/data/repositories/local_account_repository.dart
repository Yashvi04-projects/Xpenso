import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';

class LocalAccountRepository implements AccountRepository {
  // Mock Data matching the Stitch UI Image
  final List<Account> _accounts = [
    Account(id: '1', userId: 'local_user', name: 'Physical Cash', balance: 45000),
    Account(id: '2', userId: 'local_user', name: 'HDFC Savings', balance: 820000),
    Account(id: '3', userId: 'local_user', name: 'Visa Card ...4492', balance: 380000),
    Account(id: '4', userId: 'local_user', name: 'Groww Portfolio', balance: 0),
  ];

  static final LocalAccountRepository _instance = LocalAccountRepository._internal();
  factory LocalAccountRepository() => _instance;
  LocalAccountRepository._internal();

  @override
  Future<void> addAccount(Account account) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _accounts.add(account);
  }

  @override
  Future<void> deleteAccount(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _accounts.removeWhere((element) => element.id == id);
  }

  @override
  Future<Account?> getAccountById(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    try {
      return _accounts.firstWhere((element) => element.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<Account>> getAccounts() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_accounts);
  }

  @override
  Stream<List<Account>> watchAccounts() {
     // Return a stream that emits the current state and then stays open
     return Stream.value(_accounts);
  }

  @override
  Future<void> updateAccount(Account account) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _accounts.indexWhere((element) => element.id == account.id);
    if (index != -1) {
      _accounts[index] = account;
    }
  }

  @override
  Future<void> updateAccountBalance(String id, double newBalance) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _accounts.indexWhere((element) => element.id == id);
    if (index != -1) {
      final old = _accounts[index];
      _accounts[index] = Account(id: old.id, userId: old.userId, name: old.name, balance: newBalance);
    }
  }
}
