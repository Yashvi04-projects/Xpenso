import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/firebase_auth_datasource.dart';

class FirebaseAuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource _dataSource;

  FirebaseAuthRepositoryImpl(this._dataSource);

  @override
  Stream<User?> get authStateChanges => _dataSource.authStateChanges;

  @override
  User? get currentUser => _dataSource.currentUser;

  @override
  Future<UserCredential> signIn(String email, String password) {
    return _dataSource.signIn(email, password);
  }

  @override
  Future<UserCredential> signUp(String email, String password, String name) {
    return _dataSource.signUp(email, password, name);
  }

  @override
  Future<void> signOut() {
    return _dataSource.signOut();
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoUrl}) {
    return _dataSource.updateProfile(displayName: displayName, photoUrl: photoUrl);
  }
}
