import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: const Interval(0.0, 0.5)),
    );

    _controller.forward();

    // Navegar al dashboard después de 2.5 segundos
    Future.delayed(const Duration(milliseconds: 2500), () async {
      if (!mounted) return;
      final settings = context.read<SettingsProvider>();
      await settings.ensureInitialized();
      if (!mounted) return;
      final nextRoute = settings.passwordProtectionEnabled ? '/password-lock' : '/dashboard';
      Navigator.of(context).pushReplacementNamed(nextRoute);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.backgroundDark,
              AppTheme.chromeBlack,
              AppTheme.backgroundCard,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Partículas brillantes de fondo
            Positioned(
              top: 100,
              left: 50,
              child: _buildGlowDot(12, AppTheme.accentBlue.withOpacity(0.4)),
            ),
            Positioned(
              top: 200,
              right: 80,
              child: _buildGlowDot(8, AppTheme.accentOrange.withOpacity(0.5)),
            ),
            Positioned(
              bottom: 150,
              left: 100,
              child: _buildGlowDot(10, AppTheme.silverBright.withOpacity(0.3)),
            ),
            Positioned(
              bottom: 250,
              right: 60,
              child: _buildGlowDot(15, AppTheme.accentBlue.withOpacity(0.3)),
            ),
            Positioned(
              top: 400,
              left: 30,
              child: _buildGlowDot(6, AppTheme.accentOrange.withOpacity(0.4)),
            ),
            
            // Contenido principal
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo con múltiples capas y efectos 3D
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Resplandor exterior
                              Container(
                                width: 200,
                                height: 200,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppTheme.accentBlue.withOpacity(0.4),
                                      blurRadius: 60,
                                      spreadRadius: 20,
                                    ),
                                  ],
                                ),
                              ),
                              // Anillo decorativo exterior
                              Container(
                                width: 180,
                                height: 180,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.silverBright.withOpacity(0.2),
                                      AppTheme.accentBlue.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                              ),
                              // Círculo principal con efecto metálico
                              Container(
                                width: 150,
                                height: 150,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppTheme.silverBright,
                                      AppTheme.silverMedium,
                                      AppTheme.silverDark,
                                      AppTheme.chromeMedium,
                                    ],
                                    stops: const [0.0, 0.3, 0.6, 1.0],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 25,
                                      offset: const Offset(0, 12),
                                    ),
                                    BoxShadow(
                                      color: AppTheme.silverBright.withOpacity(0.3),
                                      blurRadius: 15,
                                      offset: const Offset(-8, -8),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Símbolo de dólar con efecto 3D
                                    Transform.translate(
                                      offset: const Offset(3, 3),
                                      child: const Icon(
                                        Icons.attach_money_rounded,
                                        size: 90,
                                        color: Color(0xFF1A1A1A),
                                      ),
                                    ),
                                    // Símbolo de dólar principal con gradiente dorado
                                    ShaderMask(
                                      shaderCallback: (bounds) => LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          const Color(0xFFFFD700),
                                          const Color(0xFFFFA500),
                                          const Color(0xFFFF8C00),
                                        ],
                                      ).createShader(bounds),
                                      child: const Icon(
                                        Icons.attach_money_rounded,
                                        size: 90,
                                        color: Colors.white,
                                      ),
                                    ),
                                    // Brillo superior
                                    Positioned(
                                      top: 20,
                                      left: 30,
                                      child: Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          gradient: RadialGradient(
                                            colors: [
                                              Colors.white.withOpacity(0.6),
                                              Colors.white.withOpacity(0.0),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Detalles decorativos alrededor
                              Positioned(
                                top: 10,
                                right: 10,
                                child: _buildSparkle(8),
                              ),
                              Positioned(
                                bottom: 15,
                                left: 15,
                                child: _buildSparkle(6),
                              ),
                              Positioned(
                                top: 30,
                                left: 5,
                                child: _buildSparkle(5),
                              ),
                            ],
                          ),
                          const SizedBox(height: 50),
                          
                          // Nombre de la app con efecto metálico premium
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: ShaderMask(
                              shaderCallback: (bounds) => LinearGradient(
                                colors: [
                                  AppTheme.silverBright,
                                  Colors.white,
                                  AppTheme.silverLight,
                                  AppTheme.silverMedium,
                                  AppTheme.silverLight,
                                  Colors.white,
                                  AppTheme.silverBright,
                                ],
                                stops: const [0.0, 0.15, 0.3, 0.5, 0.7, 0.85, 1.0],
                              ).createShader(bounds),
                              child: const Text(
                              'Control Financiero',
                              style: TextStyle(
                                fontSize: 38,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                                letterSpacing: 2,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black45,
                                      offset: Offset(2, 2),
                                      blurRadius: 4,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Subtítulo elegante con borde luminoso
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.accentBlue.withOpacity(0.3),
                                  AppTheme.accentOrange.withOpacity(0.2),
                                ],
                              ),
                              border: Border.all(
                                color: AppTheme.silverMedium.withOpacity(0.5),
                                width: 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.accentBlue.withOpacity(0.3),
                                  blurRadius: 15,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.trending_up_rounded,
                                  color: AppTheme.accentOrange,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Tu Dinero Bajo Control',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: AppTheme.silverBright,
                                    letterSpacing: 1.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 80),
                          
                          // Indicador de carga con efecto metálico
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              SizedBox(
                                width: 55,
                                height: 55,
                                child: CircularProgressIndicator(
                                  strokeWidth: 4,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.silverBright,
                                  ),
                                  backgroundColor: AppTheme.silverDark.withOpacity(0.3),
                                ),
                              ),
                              Container(
                                width: 35,
                                height: 35,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: RadialGradient(
                                    colors: [
                                      AppTheme.accentBlue.withOpacity(0.6),
                                      AppTheme.accentBlue.withOpacity(0.0),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget helper para puntos brillantes
  Widget _buildGlowDot(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: color,
            blurRadius: size * 2,
            spreadRadius: size / 2,
          ),
        ],
      ),
    );
  }

  // Widget helper para destellos decorativos
  Widget _buildSparkle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.8),
            blurRadius: size * 3,
            spreadRadius: size,
          ),
        ],
      ),
    );
  }
}
