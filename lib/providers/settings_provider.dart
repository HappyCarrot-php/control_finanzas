import 'package:flutter/foundation.dart';
import '../database/database_helper.dart';

class SettingsProvider extends ChangeNotifier {
  SettingsProvider() {
    _loadSettings();
  }

  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  bool _isInitialized = false;
  bool _isProcessing = false;
  bool _passwordProtectionEnabled = false;
  String? _storedPassword;

  bool get isInitialized => _isInitialized;
  bool get isProcessing => _isProcessing;
  bool get passwordProtectionEnabled => _passwordProtectionEnabled;
  String? get currentPassword => _storedPassword;

  Future<void> ensureInitialized() async {
    if (!_isInitialized) {
      await _loadSettings();
    }
  }

  Future<bool> verifyPassword(String value) async {
    await ensureInitialized();
    if (!_passwordProtectionEnabled) {
      return true;
    }
    return _storedPassword == value;
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await ensureInitialized();
    if (!_passwordProtectionEnabled) {
      return false;
    }
    if (_storedPassword != currentPassword) {
      return false;
    }

    await _setProcessing(true);
    try {
      await _dbHelper.updateStoredPassword(newPassword);
      _storedPassword = newPassword;
      notifyListeners();
      return true;
    } finally {
      await _setProcessing(false);
    }
  }

  Future<void> setPasswordProtection({
    required bool enabled,
    String? password,
  }) async {
    await ensureInitialized();
    if (enabled && (password == null || password.isEmpty)) {
      throw ArgumentError('La contraseña no puede estar vacía.');
    }

    await _setProcessing(true);
    try {
      await _dbHelper.updatePasswordProtection(
        enabled: enabled,
        password: enabled ? password : null,
      );
      _passwordProtectionEnabled = enabled;
      _storedPassword = enabled ? password : null;
      notifyListeners();
    } finally {
      await _setProcessing(false);
    }
  }

  Future<void> _loadSettings() async {
    final settings = await _dbHelper.getAppSettings();
    final enabledRaw = settings['passwordEnabled'];
    if (enabledRaw is int) {
      _passwordProtectionEnabled = enabledRaw == 1;
    } else if (enabledRaw is bool) {
      _passwordProtectionEnabled = enabledRaw;
    } else {
      _passwordProtectionEnabled = false;
    }
    final stored = settings['password'];
    _storedPassword = stored is String ? stored : null;

    _isInitialized = true;
    notifyListeners();
  }

  Future<void> _setProcessing(bool value) async {
    _isProcessing = value;
    notifyListeners();
  }
}
