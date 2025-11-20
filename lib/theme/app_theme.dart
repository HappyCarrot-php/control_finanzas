import 'package:flutter/material.dart';

class AppTheme {
  // Colores plateados brillantes con efecto metálico
  static const Color silverBright = Color(0xFFF5F5F5);
  static const Color silverLight = Color(0xFFE8E8E8);
  static const Color silverMedium = Color(0xFFC0C0C0);
  static const Color silverDark = Color(0xFF9E9E9E);
  static const Color silverDeep = Color(0xFF6E6E6E);
  
  // Tonos oscuros metálicos con tinte plateado
  static const Color chromeLight = Color(0xFFE8EAED);
  static const Color chromeMedium = Color(0xFFBDC3C7);
  static const Color chromeDark = Color(0xFF7F8C8D);
  static const Color chromeDeep = Color(0xFF34495E);
  static const Color chromeBlack = Color(0xFF2C3E50);
  
  // Colores de acento mejorados con tintes metálicos
  static const Color accentBlue = Color(0xFF5DADE2);
  static const Color accentGreen = Color(0xFF52D273);
  static const Color accentOrange = Color(0xFFFFB142);
  static const Color accentRed = Color(0xFFFF7979);
  static const Color accentPurple = Color(0xFFA569BD);
  static const Color accentGold = Color(0xFFFFD700);
  
  // Colores para el background con efecto metálico plateado
  static const Color backgroundDark = Color(0xFF1C1E26);
  static const Color backgroundCard = Color(0xFF2A2D3A);
  static const Color backgroundCardLight = Color(0xFF353847);
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      
      colorScheme: const ColorScheme.dark(
        primary: chromeLight,
        secondary: accentBlue,
        surface: backgroundCard,
        surfaceContainerHighest: backgroundCardLight,
        onPrimary: chromeBlack,
        onSecondary: Colors.white,
        onSurface: chromeLight,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: chromeLight,
          fontSize: 22,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        iconTheme: IconThemeData(color: chromeLight),
      ),
      
      cardTheme: CardThemeData(
        color: backgroundCard,
        elevation: 8,
        shadowColor: Colors.black45,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: chromeMedium.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBlue,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentBlue,
        foregroundColor: Colors.white,
        elevation: 8,
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundCardLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: chromeMedium.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: chromeMedium.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: accentBlue, width: 2),
        ),
        labelStyle: const TextStyle(color: chromeMedium),
        hintStyle: TextStyle(color: chromeMedium.withOpacity(0.6)),
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.bold,
          color: chromeLight,
          letterSpacing: -1,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: chromeLight,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: chromeLight,
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: chromeLight,
        ),
        titleLarge: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: chromeLight,
        ),
        titleMedium: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: chromeLight,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: chromeMedium,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: chromeMedium,
        ),
      ),
      
      iconTheme: const IconThemeData(
        color: chromeMedium,
        size: 24,
      ),
      
      dividerTheme: DividerThemeData(
        color: chromeMedium.withOpacity(0.2),
        thickness: 1,
        space: 1,
      ),
    );
  }
  
  // Decoración para contenedores con efecto cromado plateado
  static BoxDecoration chromeContainer({
    Color? color,
    double borderRadius = 16,
    bool withGradient = true,
  }) {
    return BoxDecoration(
      color: color ?? backgroundCard,
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: withGradient ? LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (color ?? backgroundCard).withOpacity(0.95),
          (color ?? backgroundCard),
          (color ?? backgroundCard).withOpacity(0.85),
        ],
        stops: const [0.0, 0.5, 1.0],
      ) : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.4),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: silverLight.withOpacity(0.08),
          blurRadius: 10,
          offset: const Offset(-3, -3),
        ),
        BoxShadow(
          color: silverBright.withOpacity(0.05),
          blurRadius: 6,
          offset: const Offset(2, 2),
        ),
      ],
      border: Border.all(
        color: silverMedium.withOpacity(0.15),
        width: 1.5,
      ),
    );
  }
  
  // Decoración para tarjetas con efecto metálico plateado brillante
  static BoxDecoration shinyCard({
    required Color color,
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.85),
          color,
          color.withOpacity(0.7),
          color.withOpacity(0.9),
        ],
        stops: const [0.0, 0.4, 0.7, 1.0],
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.5),
          blurRadius: 20,
          offset: const Offset(0, 8),
        ),
        BoxShadow(
          color: silverBright.withOpacity(0.15),
          blurRadius: 12,
          offset: const Offset(-4, -4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 8,
          offset: const Offset(3, 3),
        ),
      ],
      border: Border.all(
        color: silverLight.withOpacity(0.2),
        width: 1,
      ),
    );
  }
  
  // Nuevo: Decoración para efecto de acero inoxidable pulido
  static BoxDecoration steelCard({
    double borderRadius = 16,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF3A3F51),
          Color(0xFF2D3142),
          Color(0xFF3A3F51),
          Color(0xFF464B5D),
        ],
        stops: [0.0, 0.3, 0.6, 1.0],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
        BoxShadow(
          color: silverLight.withOpacity(0.1),
          blurRadius: 15,
          offset: const Offset(-5, -5),
        ),
      ],
      border: Border.all(
        color: silverMedium.withOpacity(0.2),
        width: 2,
      ),
    );
  }
}
