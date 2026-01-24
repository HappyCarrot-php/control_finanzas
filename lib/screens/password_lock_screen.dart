import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class PasswordLockScreen extends StatefulWidget {
  const PasswordLockScreen({super.key});

  @override
  State<PasswordLockScreen> createState() => _PasswordLockScreenState();
}

class _PasswordLockScreenState extends State<PasswordLockScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final FocusNode _passwordFocusNode = FocusNode();
  final LocalAuthentication _localAuth = LocalAuthentication();

  bool _hidePassword = true;
  bool _isVerifying = false;
  bool _isAuthenticating = false;
  bool _canUseBiometrics = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _redirectIfDisabled());
    _checkBiometricAvailability();
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  Future<void> _redirectIfDisabled() async {
    final settings = context.read<SettingsProvider>();
    await settings.ensureInitialized();
    if (!mounted) return;
    if (!settings.passwordProtectionEnabled) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    }
  }

  Future<void> _checkBiometricAvailability() async {
    if (!Platform.isAndroid) {
      return;
    }

    try {
      final isSupported = await _localAuth.isDeviceSupported();
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!mounted) {
        return;
      }

      if (!isSupported || !canCheck) {
        setState(() {
          _canUseBiometrics = false;
        });
        return;
      }

      final methods = await _localAuth.getAvailableBiometrics();
      if (!mounted) {
        return;
      }

      final supportsFingerprint = methods.contains(BiometricType.fingerprint) ||
          methods.contains(BiometricType.strong) ||
          methods.contains(BiometricType.weak);

      setState(() {
        _canUseBiometrics = supportsFingerprint;
      });
    } on PlatformException catch (e) {
      debugPrint('Biometric availability error: ${e.message}');
    } catch (e) {
      debugPrint('Unexpected biometric error: $e');
    }
  }

  Future<void> _handleSubmit() async {
    final settings = context.read<SettingsProvider>();
    setState(() {
      _isVerifying = true;
      _errorMessage = null;
    });

    final password = _passwordController.text.trim();
    final isValid = await settings.verifyPassword(password);

    if (!mounted) {
      return;
    }

    if (isValid && settings.passwordProtectionEnabled) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      setState(() {
        _isVerifying = false;
        _errorMessage = 'Contraseña incorrecta';
      });
      _passwordFocusNode.requestFocus();
    }
  }

  Future<void> _authenticateWithBiometrics() async {
    if (!_canUseBiometrics || _isAuthenticating) {
      return;
    }

    setState(() {
      _isAuthenticating = true;
      _errorMessage = null;
    });

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: 'Coloca tu huella para continuar',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (!mounted) {
        return;
      }

      if (authenticated) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        setState(() {
          _isAuthenticating = false;
          _errorMessage = 'No se reconoció la huella. Intenta de nuevo o usa tu contraseña.';
        });
      }
    } on PlatformException catch (e) {
      if (!mounted) {
        return;
      }

      String message = 'No se pudo usar la huella en este momento.';
      if (e.code == auth_error.notEnrolled) {
        message = 'Configura una huella en tu dispositivo para usar esta opción.';
      } else if (e.code == auth_error.lockedOut || e.code == auth_error.permanentlyLockedOut) {
        message = 'Huella temporalmente bloqueada. Usa tu contraseña.';
      }

      setState(() {
        _isAuthenticating = false;
        _errorMessage = message;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() {
        _isAuthenticating = false;
        _errorMessage = 'Error inesperado. Usa tu contraseña.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundDark,
              AppTheme.chromeBlack.withOpacity(0.95),
              AppTheme.backgroundCard,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 360),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: AppTheme.chromeContainer(borderRadius: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: AppTheme.shinyCard(
                          color: AppTheme.accentBlue,
                          borderRadius: 20,
                        ),
                        child: const Icon(
                          Icons.lock_outline,
                          color: Colors.white,
                          size: 36,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Protección Activada',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.chromeLight,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Ingresa tu contraseña para continuar',
                        style: TextStyle(
                          color: AppTheme.chromeMedium.withOpacity(0.8),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                      TextField(
                        controller: _passwordController,
                        focusNode: _passwordFocusNode,
                        obscureText: _hidePassword,
                        enableSuggestions: false,
                        autocorrect: false,
                        onSubmitted: (_) => _handleSubmit(),
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          suffixIcon: IconButton(
                            onPressed: () => setState(() {
                              _hidePassword = !_hidePassword;
                            }),
                            icon: Icon(
                              _hidePassword
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                          errorText: _errorMessage,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _isVerifying ? null : _handleSubmit,
                          icon: _isVerifying
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(strokeWidth: 2.2),
                                )
                              : const Icon(Icons.arrow_forward_rounded),
                          label: Text(_isVerifying ? 'Verificando...' : 'Desbloquear'),
                        ),
                      ),
                      if (_canUseBiometrics) ...[
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(child: Divider(color: AppTheme.chromeMedium.withValues(alpha: 0.25))),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                'o',
                                style: TextStyle(color: AppTheme.chromeMedium.withValues(alpha: 0.7)),
                              ),
                            ),
                            Expanded(child: Divider(color: AppTheme.chromeMedium.withValues(alpha: 0.25))),
                          ],
                        ),
                        const SizedBox(height: 16),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: _isAuthenticating ? null : _authenticateWithBiometrics,
                            icon: _isAuthenticating
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2.2),
                                  )
                                : const Icon(Icons.fingerprint_rounded),
                            label: Text(
                              _isAuthenticating ? 'Autenticando...' : 'Usar huella',
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
