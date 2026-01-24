import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.06).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;
      final settings = context.read<SettingsProvider>();
      await settings.ensureInitialized();
      if (!mounted) return;
      final nextRoute = settings.passwordProtectionEnabled
          ? '/password-lock'
          : '/dashboard';
      Navigator.of(context).pushReplacementNamed(nextRoute);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B1D3C),
              Color(0xFF15294C),
              AppTheme.backgroundDark,
            ],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -140,
              right: -80,
              child: _buildBackdropCircle(
                280,
                AppTheme.accentBlue.withValues(alpha: 0.18),
              ),
            ),
            Positioned(
              bottom: -160,
              left: -60,
              child: _buildBackdropCircle(
                260,
                AppTheme.accentOrange.withValues(alpha: 0.12),
              ),
            ),
            Positioned(
              top: 120,
              left: -40,
              child: _buildBackdropCircle(
                180,
                AppTheme.chromeMedium.withValues(alpha: 0.08),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 220,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0xFF10131C)],
                  ),
                ),
              ),
            ),
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  final progress = _controller.value.clamp(0.0, 1.0);
                  return _buildAnimatedContent(progress);
                },
              ),
            ),
            Positioned(
              bottom: 48,
              left: 32,
              right: 32,
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.chromeMedium.withValues(alpha: 0.25),
                      ),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.backgroundCardLight,
                          AppTheme.backgroundCard,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.verified_user_outlined,
                      color: AppTheme.chromeLight,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Sesión protegida. Personalizando indicadores para tu portafolio.',
                      style: TextStyle(
                        color: AppTheme.chromeMedium.withValues(alpha: 0.85),
                        fontSize: 13,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedContent(double progress) {
    return Opacity(
      opacity: _opacityAnimation.value,
      child: Transform.translate(
        offset: Offset(0, (1 - _scaleAnimation.value) * 24),
        child: Transform.scale(
          scale: _scaleAnimation.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 320,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 36,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundCard.withValues(alpha: 0.95),
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: AppTheme.accentBlue.withValues(alpha: 0.25),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 32,
                      offset: const Offset(0, 28),
                    ),
                    BoxShadow(
                      color: AppTheme.accentBlue.withValues(alpha: 0.18),
                      blurRadius: 18,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppTheme.accentBlue,
                                AppTheme.accentOrange,
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.accentBlue.withValues(
                                  alpha: 0.45,
                                ),
                                blurRadius: 24,
                                spreadRadius: 2,
                                offset: const Offset(0, 14),
                              ),
                            ],
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.white.withValues(alpha: 0.9),
                                  Colors.white.withValues(alpha: 0.6),
                                ],
                              ),
                            ),
                            child: const Icon(
                              Icons.savings_rounded,
                              size: 48,
                              color: AppTheme.chromeBlack,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Control Finanzas',
                      style: TextStyle(
                        color: AppTheme.chromeLight,
                        fontSize: 28,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppTheme.accentBlue.withValues(alpha: 0.4),
                        ),
                        color: AppTheme.backgroundCardLight.withValues(
                          alpha: 0.45,
                        ),
                      ),
                      child: Text(
                        'Tu dinero bajo control',
                        style: TextStyle(
                          color: AppTheme.chromeLight.withValues(alpha: 0.92),
                          fontSize: 14,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(18),
                        color: AppTheme.backgroundCardLight.withValues(
                          alpha: 0.6,
                        ),
                        border: Border.all(
                          color: AppTheme.chromeMedium.withValues(alpha: 0.15),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            size: 18,
                            color: AppTheme.accentBlue,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Inicializando tablero principal y preferencias de seguridad',
                              style: TextStyle(
                                color: AppTheme.chromeLight.withValues(
                                  alpha: 0.9,
                                ),
                                fontSize: 13,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 42),
              _buildProgressSection(progress),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackdropCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0.0)]),
      ),
    );
  }

  Widget _buildProgressSection(double progress) {
    final clamped = progress.clamp(0.0, 1.0);
    final percentage = (clamped * 100).round();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Sincronizando datos financieros',
          style: TextStyle(
            color: AppTheme.chromeLight.withValues(alpha: 0.85),
            fontSize: 14,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: 240,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: AppTheme.backgroundCardLight.withValues(alpha: 0.45),
              border: Border.all(
                color: AppTheme.accentBlue.withValues(alpha: 0.25),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                minHeight: 6,
                value: clamped,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppTheme.accentBlue,
                ),
                backgroundColor: AppTheme.chromeDark.withValues(alpha: 0.35),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          '$percentage% listo',
          style: TextStyle(
            color: AppTheme.chromeMedium.withValues(alpha: 0.85),
            fontSize: 13,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}
