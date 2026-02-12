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
    with TickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  late final AnimationController _shimmerController;

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

    _shimmerController = AnimationController(
      duration: const Duration(milliseconds: 2400),
      vsync: this,
    )..repeat();

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
    _shimmerController.dispose();
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
              Color(0xFF060D19),
              Color(0xFF0A1628),
              Color(0xFF0D1117),
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
                AppTheme.accentBlue.withValues(alpha: 0.08),
              ),
            ),
            Positioned(
              bottom: -160,
              left: -60,
              child: _buildBackdropCircle(
                260,
                AppTheme.accentBlue.withValues(alpha: 0.05),
              ),
            ),
            Positioned(
              top: 120,
              left: -40,
              child: _buildBackdropCircle(
                180,
                AppTheme.chromeMedium.withValues(alpha: 0.04),
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
                    colors: [Colors.transparent, Color(0xFF060D19)],
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
              child: AnimatedBuilder(
                animation: _opacityAnimation,
                builder: (context, child) => Opacity(
                  opacity: _opacityAnimation.value,
                  child: child,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accentBlue.withValues(alpha: 0.1),
                        border: Border.all(
                          color: AppTheme.accentBlue.withValues(alpha: 0.2),
                        ),
                      ),
                      child: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppTheme.accentBlue,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Sesión protegida · Datos cifrados localmente',
                        style: TextStyle(
                          color: AppTheme.chromeMedium.withValues(alpha: 0.6),
                          fontSize: 12,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                  ],
                ),
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
                  vertical: 40,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF141C2B),
                      Color(0xFF0F1520),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.accentBlue.withValues(alpha: 0.15),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 40,
                      offset: const Offset(0, 20),
                    ),
                    BoxShadow(
                      color: AppTheme.accentBlue.withValues(alpha: 0.08),
                      blurRadius: 30,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ScaleTransition(
                      scale: _pulseAnimation,
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF3B82F6),
                              Color(0xFF1D4ED8),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 28,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.savings_rounded,
                          size: 42,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Text(
                      'Control Finanzas',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tu dinero bajo control',
                      style: TextStyle(
                        color: AppTheme.accentBlue.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        color: AppTheme.accentBlue.withValues(alpha: 0.08),
                        border: Border.all(
                          color: AppTheme.accentBlue.withValues(alpha: 0.12),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shield_outlined,
                            size: 16,
                            color: AppTheme.accentBlue.withValues(alpha: 0.7),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              'Cargando datos y preferencias...',
                              style: TextStyle(
                                color: AppTheme.chromeLight.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 12,
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
          'Sincronizando datos',
          style: TextStyle(
            color: AppTheme.chromeLight.withValues(alpha: 0.6),
            fontSize: 13,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 14),
        SizedBox(
          width: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              minHeight: 3,
              value: clamped,
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF3B82F6),
              ),
              backgroundColor: AppTheme.chromeDark.withValues(alpha: 0.2),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$percentage%',
          style: TextStyle(
            color: AppTheme.chromeMedium.withValues(alpha: 0.5),
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.4,
          ),
        ),
      ],
    );
  }
}
