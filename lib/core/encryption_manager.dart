import 'package:encrypt/encrypt.dart';

class EncryptionManager {
  // Example key and IV (replace or generate dynamically for production)
  static const String _encryptionKey = "encryPtion@12345";
  static const String _encryptionIV = "teSt@Encryption@";

  // Validating key length (AES allows 16, 24, 32 bytes only)
  static final Key _key = Key.fromUtf8(
    _encryptionKey.padRight(32).substring(0, 32),
  );
  static final IV _iv = IV.fromUtf8(
    _encryptionIV.padRight(16).substring(0, 16),
  );

  // Encryptor setup with AES in CBC mode
  static final Encrypter _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

  /// Encrypts the given plain text using AES encryption.
  static String encryptData(String plainText) {
    try {
      if (plainText.isEmpty) {
        throw ArgumentError('Plain text cannot be empty.');
      }
      final encrypted = _encrypter.encrypt(plainText, iv: _iv);
      return encrypted.base64
          .replaceAll('+', '-')
          .replaceAll('/', '_')
          .replaceAll('=', '');
    } catch (e) {
      // Log or handle the error appropriately
      return '';
    }
  }

  /// Decrypts the given base64 encoded string back to plain text.
  static String decryptData(String encryptedText) {
    try {
      if (encryptedText.isEmpty) {
        throw ArgumentError('Encrypted text cannot be empty.');
      }
      final base64String = encryptedText
          .replaceAll('-', '+')
          .replaceAll('_', '/')
          .padRight((encryptedText.length + 3) & ~3, '=');
      final decrypted = _encrypter.decrypt(
        Encrypted.from64(base64String),
        iv: _iv,
      );
      return decrypted;
    } catch (e) {
      // Log or handle the error appropriately
      return '';
    }
  }
}