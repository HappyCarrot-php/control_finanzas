import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Ajustes de Seguridad'),
        backgroundColor: Colors.transparent,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundDark,
              AppTheme.backgroundCard,
              AppTheme.backgroundDark.withValues(alpha: 0.95),
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              if (!settings.isInitialized && !settings.isProcessing) {
                return const Center(child: CircularProgressIndicator());
              }

              return Stack(
                children: [
                  ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      _buildIntroBanner(),
                      const SizedBox(height: 24),
                      _buildSecurityCard(context, settings),
                      const SizedBox(height: 24),
                      _buildTipsCard(),
                    ],
                  ),
                  if (settings.isProcessing)
                    Container(
                      color: Colors.black45,
                      alignment: Alignment.center,
                      child: const CircularProgressIndicator(),
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildIntroBanner() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.chromeMedium.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Tu acceso, tu control',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppTheme.chromeLight,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'Activa el bloqueo mediante contraseña para proteger tus finanzas. Puedes cambiarla o desactivarla cuando lo necesites desde aquí.',
            style: TextStyle(
              color: AppTheme.chromeMedium,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityCard(BuildContext context, SettingsProvider settings) {
    final protectionEnabled = settings.passwordProtectionEnabled;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.chromeMedium.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: (protectionEnabled ? AppTheme.accentGreen : AppTheme.accentBlue).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  protectionEnabled ? Icons.verified_user : Icons.lock_open,
                  color: protectionEnabled ? AppTheme.accentGreen : AppTheme.accentBlue,
                  size: 26,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      protectionEnabled ? 'Protección por contraseña activa' : 'Protección por contraseña desactivada',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.chromeLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      protectionEnabled
                          ? 'Se solicitará la contraseña al iniciar la aplicación.'
                          : 'Puedes activar el bloqueo para requerir autorización al abrir la app.',
                      style: const TextStyle(
                        color: AppTheme.chromeMedium,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SwitchListTile.adaptive(
            value: protectionEnabled,
            onChanged: settings.isProcessing ? null : (value) => _handleToggle(context, settings, value),
            title: const Text(
              'Bloqueo con contraseña',
              style: TextStyle(
                color: AppTheme.chromeLight,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: Text(
              protectionEnabled
                  ? 'Requerirá contraseña o huella al abrir la app.'
                  : 'La app abrirá sin pedir contraseña.',
              style: const TextStyle(color: AppTheme.chromeMedium),
            ),
            activeColor: AppTheme.accentGreen,
            inactiveThumbColor: AppTheme.chromeMedium,
          ),
          const SizedBox(height: 12),
          AnimatedOpacity(
            opacity: protectionEnabled ? 1 : 0.4,
            duration: const Duration(milliseconds: 300),
            child: ElevatedButton.icon(
              onPressed: protectionEnabled && !settings.isProcessing
                  ? () => _handleChangePassword(context, settings)
                  : null,
              icon: const Icon(Icons.password_rounded),
              label: const Text('Cambiar contraseña'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleToggle(
    BuildContext context,
    SettingsProvider settings,
    bool value,
  ) async {
    if (value) {
      final newPassword = await _promptForNewPassword(context);
      if (!mounted || newPassword == null) {
        return;
      }
      try {
        await settings.setPasswordProtection(enabled: true, password: newPassword);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Bloqueo activado correctamente.')),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo activar el bloqueo: $e')),
        );
      }
    } else {
      final confirmed = await _confirmDisable(context);
      if (!mounted || confirmed != true) {
        return;
      }
      await settings.setPasswordProtection(enabled: false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Bloqueo desactivado.')),
      );
    }
  }

  Future<void> _handleChangePassword(
    BuildContext context,
    SettingsProvider settings,
  ) async {
    final result = await _promptForPasswordChange(context);
    if (!mounted || result == null) {
      return;
    }

    final current = result['current']!;
    final updated = result['updated']!;
    final success = await settings.changePassword(
      currentPassword: current,
      newPassword: updated,
    );

    if (!mounted) {
      return;
    }

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Contraseña actualizada.')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La contraseña actual no coincide.')),
      );
    }
  }

  Future<String?> _promptForNewPassword(BuildContext context) async {
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    bool obscure = true;
    bool obscureConfirm = true;
    String? error;

    return showDialog<String?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.backgroundCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Define una contraseña'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: newController,
                    obscureText: obscure,
                    decoration: InputDecoration(
                      labelText: 'Contraseña',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() {
                          obscure = !obscure;
                        }),
                        icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmController,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirmar contraseña',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() {
                          obscureConfirm = !obscureConfirm;
                        }),
                        icon: Icon(obscureConfirm ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      error!,
                      style: const TextStyle(color: AppTheme.accentRed),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(null),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final newPassword = newController.text.trim();
                    final confirmed = confirmController.text.trim();
                    if (newPassword.isEmpty) {
                      setState(() {
                        error = 'La contraseña no puede estar vacía.';
                      });
                      return;
                    }
                    if (newPassword.length < 4) {
                      setState(() {
                        error = 'Usa al menos 4 caracteres.';
                      });
                      return;
                    }
                    if (newPassword != confirmed) {
                      setState(() {
                        error = 'Las contraseñas no coinciden.';
                      });
                      return;
                    }
                    Navigator.of(dialogContext).pop(newPassword);
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<Map<String, String>?> _promptForPasswordChange(BuildContext context) async {
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();

    bool obscureCurrent = true;
    bool obscureNew = true;
    bool obscureConfirm = true;
    String? error;

    return showDialog<Map<String, String>?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: AppTheme.backgroundCard,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Text('Cambiar contraseña'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: currentController,
                    obscureText: obscureCurrent,
                    decoration: InputDecoration(
                      labelText: 'Contraseña actual',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() {
                          obscureCurrent = !obscureCurrent;
                        }),
                        icon: Icon(obscureCurrent ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: newController,
                    obscureText: obscureNew,
                    decoration: InputDecoration(
                      labelText: 'Nueva contraseña',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() {
                          obscureNew = !obscureNew;
                        }),
                        icon: Icon(obscureNew ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmController,
                    obscureText: obscureConfirm,
                    decoration: InputDecoration(
                      labelText: 'Confirmar nueva contraseña',
                      suffixIcon: IconButton(
                        onPressed: () => setState(() {
                          obscureConfirm = !obscureConfirm;
                        }),
                        icon: Icon(obscureConfirm ? Icons.visibility : Icons.visibility_off),
                      ),
                    ),
                  ),
                  if (error != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      error!,
                      style: const TextStyle(color: AppTheme.accentRed),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(null),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final current = currentController.text.trim();
                    final updated = newController.text.trim();
                    final confirmed = confirmController.text.trim();

                    if (current.isEmpty || updated.isEmpty || confirmed.isEmpty) {
                      setState(() {
                        error = 'Completa todos los campos.';
                      });
                      return;
                    }
                    if (updated.length < 4) {
                      setState(() {
                        error = 'Usa al menos 4 caracteres.';
                      });
                      return;
                    }
                    if (updated != confirmed) {
                      setState(() {
                        error = 'La nueva contraseña no coincide.';
                      });
                      return;
                    }

                    Navigator.of(dialogContext).pop({
                      'current': current,
                      'updated': updated,
                    });
                  },
                  child: const Text('Actualizar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<bool?> _confirmDisable(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppTheme.backgroundCard,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('Desactivar bloqueo'),
          content: const Text('¿Seguro que deseas abrir la app sin contraseña?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Desactivar'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTipsCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.backgroundCard,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppTheme.chromeMedium.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Recomendaciones rápidas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.chromeLight,
            ),
          ),
          SizedBox(height: 12),
          Text('- Usa combinaciones fáciles de recordar para ti, pero difíciles de adivinar.'),
          SizedBox(height: 6),
          Text('- Actualiza tu contraseña periódicamente y evita compartirla.'),
          SizedBox(height: 6),
          Text('- Si olvidas la contraseña, desactívala desde este mismo apartado.'),
        ],
      ),
    );
  }
}
