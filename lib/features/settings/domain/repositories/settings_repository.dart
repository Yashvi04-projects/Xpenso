import '../entities/user_settings.dart';

abstract class SettingsRepository {
  Future<UserSettings> getUserSettings();
  Future<void> updateUserSettings(UserSettings settings);
  Stream<UserSettings> watchUserSettings();
}
