import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';

/// Secure storage service for sensitive data
/// Uses encrypted storage on both iOS (Keychain) and Android (EncryptedSharedPreferences)
class SecureStorageService {
  static final SecureStorageService _instance = SecureStorageService._internal();
  factory SecureStorageService() => _instance;
  SecureStorageService._internal();

  final _logger = Logger();

  late final FlutterSecureStorage _storage;

  /// Initialize secure storage with platform-specific options
  void initialize() {
    _storage = const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
        // Use AES encryption
        resetOnError: true,
      ),
      iOptions: IOSOptions(
        // Use Keychain with highest security
        accessibility: KeychainAccessibility.first_unlock,
        // Don't sync to iCloud
        synchronizable: false,
      ),
    );
  }

  // Storage keys
  static const String _keyUserId = 'clerk_user_id';
  static const String _keyUserName = 'clerk_user_name';
  static const String _keyUserEmail = 'clerk_user_email';
  static const String _keyUserImageUrl = 'clerk_user_image_url';
  static const String _keySessionToken = 'clerk_session_token';
  static const String _keySessionId = 'clerk_session_id';
  static const String _keyLastLogin = 'last_login_timestamp';
  static const String _keyTermsAccepted = 'terms_accepted';
  static const String _keyPrivacyAccepted = 'privacy_accepted';

  // ============================================================================
  // User Data
  // ============================================================================

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: _keyUserId, value: userId);
      _logger.d('User ID saved securely');
    } catch (e) {
      _logger.e('Failed to save user ID: $e');
      rethrow;
    }
  }

  /// Get user ID
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _keyUserId);
    } catch (e) {
      _logger.e('Failed to read user ID: $e');
      return null;
    }
  }

  /// Save user name
  Future<void> saveUserName(String name) async {
    try {
      await _storage.write(key: _keyUserName, value: name);
      _logger.d('User name saved securely');
    } catch (e) {
      _logger.e('Failed to save user name: $e');
      rethrow;
    }
  }

  /// Get user name
  Future<String?> getUserName() async {
    try {
      return await _storage.read(key: _keyUserName);
    } catch (e) {
      _logger.e('Failed to read user name: $e');
      return null;
    }
  }

  /// Save user email
  Future<void> saveUserEmail(String email) async {
    try {
      await _storage.write(key: _keyUserEmail, value: email);
      _logger.d('User email saved securely');
    } catch (e) {
      _logger.e('Failed to save user email: $e');
      rethrow;
    }
  }

  /// Get user email
  Future<String?> getUserEmail() async {
    try {
      return await _storage.read(key: _keyUserEmail);
    } catch (e) {
      _logger.e('Failed to read user email: $e');
      return null;
    }
  }

  /// Save user image URL
  Future<void> saveUserImageUrl(String imageUrl) async {
    try {
      await _storage.write(key: _keyUserImageUrl, value: imageUrl);
      _logger.d('User image URL saved securely');
    } catch (e) {
      _logger.e('Failed to save user image URL: $e');
      rethrow;
    }
  }

  /// Get user image URL
  Future<String?> getUserImageUrl() async {
    try {
      return await _storage.read(key: _keyUserImageUrl);
    } catch (e) {
      _logger.e('Failed to read user image URL: $e');
      return null;
    }
  }

  // ============================================================================
  // Session Data
  // ============================================================================

  /// Save session token
  Future<void> saveSessionToken(String token) async {
    try {
      await _storage.write(key: _keySessionToken, value: token);
      _logger.d('Session token saved securely');
    } catch (e) {
      _logger.e('Failed to save session token: $e');
      rethrow;
    }
  }

  /// Get session token
  Future<String?> getSessionToken() async {
    try {
      return await _storage.read(key: _keySessionToken);
    } catch (e) {
      _logger.e('Failed to read session token: $e');
      return null;
    }
  }

  /// Save session ID
  Future<void> saveSessionId(String sessionId) async {
    try {
      await _storage.write(key: _keySessionId, value: sessionId);
      _logger.d('Session ID saved securely');
    } catch (e) {
      _logger.e('Failed to save session ID: $e');
      rethrow;
    }
  }

  /// Get session ID
  Future<String?> getSessionId() async {
    try {
      return await _storage.read(key: _keySessionId);
    } catch (e) {
      _logger.e('Failed to read session ID: $e');
      return null;
    }
  }

  /// Save last login timestamp
  Future<void> saveLastLoginTimestamp(DateTime timestamp) async {
    try {
      await _storage.write(
        key: _keyLastLogin,
        value: timestamp.toIso8601String(),
      );
      _logger.d('Last login timestamp saved securely');
    } catch (e) {
      _logger.e('Failed to save last login timestamp: $e');
      rethrow;
    }
  }

  /// Get last login timestamp
  Future<DateTime?> getLastLoginTimestamp() async {
    try {
      final timestamp = await _storage.read(key: _keyLastLogin);
      if (timestamp != null) {
        return DateTime.parse(timestamp);
      }
      return null;
    } catch (e) {
      _logger.e('Failed to read last login timestamp: $e');
      return null;
    }
  }

  // ============================================================================
  // Legal Acceptance
  // ============================================================================

  /// Save terms acceptance
  Future<void> saveTermsAccepted(bool accepted) async {
    try {
      await _storage.write(
        key: _keyTermsAccepted,
        value: accepted.toString(),
      );
      _logger.d('Terms acceptance saved securely');
    } catch (e) {
      _logger.e('Failed to save terms acceptance: $e');
      rethrow;
    }
  }

  /// Check if terms were accepted
  Future<bool> hasAcceptedTerms() async {
    try {
      final value = await _storage.read(key: _keyTermsAccepted);
      return value == 'true';
    } catch (e) {
      _logger.e('Failed to read terms acceptance: $e');
      return false;
    }
  }

  /// Save privacy policy acceptance
  Future<void> savePrivacyAccepted(bool accepted) async {
    try {
      await _storage.write(
        key: _keyPrivacyAccepted,
        value: accepted.toString(),
      );
      _logger.d('Privacy policy acceptance saved securely');
    } catch (e) {
      _logger.e('Failed to save privacy acceptance: $e');
      rethrow;
    }
  }

  /// Check if privacy policy was accepted
  Future<bool> hasAcceptedPrivacy() async {
    try {
      final value = await _storage.read(key: _keyPrivacyAccepted);
      return value == 'true';
    } catch (e) {
      _logger.e('Failed to read privacy acceptance: $e');
      return false;
    }
  }

  // ============================================================================
  // Utility Methods
  // ============================================================================

  /// Clear all stored data (logout)
  Future<void> clearAll() async {
    try {
      await _storage.deleteAll();
      _logger.d('All secure storage cleared');
    } catch (e) {
      _logger.e('Failed to clear secure storage: $e');
      rethrow;
    }
  }

  /// Clear only session data (keep user preferences)
  Future<void> clearSessionData() async {
    try {
      await _storage.delete(key: _keySessionToken);
      await _storage.delete(key: _keySessionId);
      await _storage.delete(key: _keyUserId);
      await _storage.delete(key: _keyUserName);
      await _storage.delete(key: _keyUserEmail);
      await _storage.delete(key: _keyUserImageUrl);
      _logger.d('Session data cleared');
    } catch (e) {
      _logger.e('Failed to clear session data: $e');
      rethrow;
    }
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    try {
      final userId = await getUserId();
      final sessionToken = await getSessionToken();
      return userId != null && sessionToken != null;
    } catch (e) {
      _logger.e('Failed to check login status: $e');
      return false;
    }
  }

  /// Save complete user session
  Future<void> saveUserSession({
    required String userId,
    required String userName,
    required String userEmail,
    String? userImageUrl,
    required String sessionToken,
    required String sessionId,
  }) async {
    try {
      await Future.wait([
        saveUserId(userId),
        saveUserName(userName),
        saveUserEmail(userEmail),
        if (userImageUrl != null) saveUserImageUrl(userImageUrl),
        saveSessionToken(sessionToken),
        saveSessionId(sessionId),
        saveLastLoginTimestamp(DateTime.now()),
      ]);
      _logger.d('Complete user session saved securely');
    } catch (e) {
      _logger.e('Failed to save user session: $e');
      rethrow;
    }
  }

  /// Get all user data as a map
  Future<Map<String, String?>> getUserData() async {
    try {
      return {
        'userId': await getUserId(),
        'userName': await getUserName(),
        'userEmail': await getUserEmail(),
        'userImageUrl': await getUserImageUrl(),
        'sessionToken': await getSessionToken(),
        'sessionId': await getSessionId(),
      };
    } catch (e) {
      _logger.e('Failed to get user data: $e');
      return {};
    }
  }

  /// Debug: List all stored keys (development only)
  Future<Map<String, String>> debugGetAllValues() async {
    try {
      return await _storage.readAll();
    } catch (e) {
      _logger.e('Failed to read all values: $e');
      return {};
    }
  }
}
