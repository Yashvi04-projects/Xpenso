import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../domain/entities/user_settings.dart';
import '../../domain/repositories/settings_repository.dart';

class FirestoreSettingsRepository implements SettingsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthRepository _authRepository;

  FirestoreSettingsRepository(this._authRepository);

  String get _userId {
    final user = _authRepository.currentUser;
    if (user == null) throw Exception('Auth required');
    return user.uid;
  }

  @override
  Future<UserSettings> getUserSettings() async {
    final doc = await _firestore.collection('user_settings').doc(_userId).get();
    
    if (!doc.exists) {
      // Create default settings
      final defaultSettings = UserSettings(userId: _userId);
      await _firestore.collection('user_settings').doc(_userId).set(defaultSettings.toFirestore());
      return defaultSettings;
    }
    
    return UserSettings.fromFirestore(doc);
  }

  @override
  Future<void> updateUserSettings(UserSettings settings) async {
    await _firestore.collection('user_settings').doc(_userId).set(
      settings.toFirestore(),
      SetOptions(merge: true),
    );
  }

  @override
  Stream<UserSettings> watchUserSettings() {
    return _firestore.collection('user_settings').doc(_userId).snapshots().map((doc) {
      if (!doc.exists) {
        return UserSettings(userId: _userId);
      }
      return UserSettings.fromFirestore(doc);
    });
  }
}
