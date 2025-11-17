import 'package:k3h_erp_app/core/encryption_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageManager {
  static final LocalStorageManager _instance = LocalStorageManager._internal();
  late SharedPreferences _preferences;

  // Private constructor
  LocalStorageManager._internal();

  // Factory constructor to return the singleton instance
  factory LocalStorageManager() {
    return _instance;
  }

  // Initialize SharedPreferences
  Future<void> init() async {
    _preferences = await SharedPreferences.getInstance();
  }

  /// Retrieves a decrypted string value associated with the given key.
  String? getString(String key) {
    final encryptedValue = _preferences.getString(key);
    if (encryptedValue == null) return null;
    return EncryptionManager.decryptData(encryptedValue);
  }

  /// Encrypts and stores a string value with the given key.
  Future<bool> setString(String key, String value) async {
    final encryptedValue = EncryptionManager.encryptData(value);
    return await _preferences.setString(key, encryptedValue);
  }

  /// Removes a key-value pair from storage.
  Future<bool> remove(String key) async {
    return await _preferences.remove(key);
  }

  /// Removes All
  Future<bool> removeAll() async {
    return await _preferences.clear();
  }
}