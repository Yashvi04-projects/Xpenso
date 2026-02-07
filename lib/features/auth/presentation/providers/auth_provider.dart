import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../domain/repositories/auth_repository.dart';

enum AuthStatus { authenticated, unauthenticated, authenticating }

class AuthProvider with ChangeNotifier {
  final AuthRepository _authRepository;
  AuthStatus _status = AuthStatus.unauthenticated;
  User? _user;
  String? _errorMessage;

  AuthProvider(this._authRepository) {
    _authRepository.authStateChanges.listen(_onAuthStateChanged);
  }

  AuthStatus get status => _status;
  User? get user => _user;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  void _onAuthStateChanged(User? user) {
    if (user == null) {
      _status = AuthStatus.unauthenticated;
    } else {
      _user = user;
      _status = AuthStatus.authenticated;
    }
    notifyListeners();
  }

  Future<bool> signIn(String email, String password) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();
      await _authRepository.signIn(email, password);
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> signUp(String email, String password, String name) async {
    try {
      _status = AuthStatus.authenticating;
      _errorMessage = null;
      notifyListeners();
      await _authRepository.signUp(email, password, name);
      return true;
    } catch (e) {
      _status = AuthStatus.unauthenticated;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  Future<bool> updateProfile({String? displayName, String? photoUrl}) async {
    try {
      _errorMessage = null;
      await _authRepository.updateProfile(displayName: displayName, photoUrl: photoUrl);
      _user = _authRepository.currentUser;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
