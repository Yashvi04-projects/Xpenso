import '../entities/account.dart';

abstract class AccountRepository {
  Future<void> addAccount(Account account);
  Future<void> updateAccount(Account account);
  Future<void> deleteAccount(String id);
  Future<Account?> getAccountById(String id);
  Future<List<Account>> getAccounts();
  Stream<List<Account>> watchAccounts();
  Future<void> updateAccountBalance(String id, double newBalance);
}
