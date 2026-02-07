import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/account.dart';
import '../../domain/repositories/account_repository.dart';

class FirestoreAccountRepository implements AccountRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthRepository _authRepository;

  FirestoreAccountRepository(this._authRepository);

  String get _userId {
    final user = _authRepository.currentUser;
    if (user == null) throw Exception('Auth required');
    return user.uid;
  }

  @override
  Future<List<Account>> getAccounts() async {
    final snapshot = await _firestore.collection('accounts')
        .where('userId', isEqualTo: _userId)
        .get();

    if (snapshot.docs.isEmpty) {
      await _seedDefaultAccounts();
      return getAccounts();
    }

    return snapshot.docs.map((doc) => Account.fromFirestore(doc)).toList();
  }

  @override
  Stream<List<Account>> watchAccounts() {
    return _firestore.collection('accounts')
        .where('userId', isEqualTo: _userId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Account.fromFirestore(doc)).toList());
  }

  @override
  Future<void> addAccount(Account account) async {
    await _firestore.collection('accounts').add({
      'userId': _userId,
      'name': account.name,
      'balance': account.balance,
    });
  }

  @override
  Future<void> updateAccount(Account account) async {
    await _firestore.collection('accounts').doc(account.id).update({
      'name': account.name,
      'balance': account.balance,
    });
  }

  @override
  Future<void> deleteAccount(String id) async {
    await _firestore.collection('accounts').doc(id).delete();
  }

  @override
  Future<Account?> getAccountById(String id) async {
    final doc = await _firestore.collection('accounts').doc(id).get();
    if (doc.exists) {
      return Account.fromFirestore(doc);
    }
    return null;
  }

  @override
  Future<void> updateAccountBalance(String id, double newBalance) async {
    await _firestore.collection('accounts').doc(id).update({
      'balance': newBalance,
    });
  }

  Future<void> _seedDefaultAccounts() async {
     final defaults = [
      {'name': 'HDFC Card', 'balance': 25000.0},
      {'name': 'Cash Wallet', 'balance': 1500.0},
    ];

    final batch = _firestore.batch();
    for (var item in defaults) {
      final docRef = _firestore.collection('accounts').doc();
      batch.set(docRef, {
        'userId': _userId,
        'name': item['name'],
        'balance': item['balance'],
      });
    }
    await batch.commit();
  }
}
