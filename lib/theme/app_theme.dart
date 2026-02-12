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
  
  // Colores background premium
  static const Color backgroundDark = Color(0xFF0D1117);
  static const Color backgroundCard = Color(0xFF161B22);
  static const Color backgroundCardLight = Color(0xFF21262D);
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: backgroundDark,
      
      colorScheme: const ColorScheme.dark(
        primary: accentBlue,
        secondary: accentBlue,
        surface: backgroundCard,
        surfaceContainerHighest: backgroundCardLight,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: chromeLight,
      ),
      
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: chromeLight,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.3,
        ),
        iconTheme: IconThemeData(color: chromeLight),
      ),

      tabBarTheme: const TabBarThemeData(
        labelColor: Colors.white,
        unselectedLabelColor: chromeMedium,
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorColor: accentBlue,
      ),

      drawerTheme: const DrawerThemeData(
        backgroundColor: backgroundDark,
        scrimColor: Colors.black54,
      ),

      listTileTheme: const ListTileThemeData(
        iconColor: chromeLight,
        textColor: chromeLight,
      ),

      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentBlue;
          }
          return chromeMedium;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return accentBlue.withOpacity(0.35);
          }
          return chromeMedium.withOpacity(0.2);
        }),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: backgroundCard,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        titleTextStyle: const TextStyle(
          color: chromeLight,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        contentTextStyle: const TextStyle(
          color: chromeMedium,
          fontSize: 14,
          height: 1.5,
        ),
      ),

      snackBarTheme: SnackBarThemeData(
        backgroundColor: backgroundCardLight,
        contentTextStyle: const TextStyle(
          color: chromeLight,
          fontSize: 14,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      
      cardTheme: CardThemeData(
        color: backgroundCard,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: silverMedium.withOpacity(0.08),
            width: 1,
          ),
        ),
      ),
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: chromeLight,
          side: BorderSide(color: chromeMedium.withOpacity(0.3)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: accentBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: backgroundCardLight.withOpacity(0.6),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: chromeMedium.withOpacity(0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: chromeMedium.withOpacity(0.15)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentBlue, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: accentRed, width: 1),
        ),
        labelStyle: const TextStyle(color: chromeMedium),
        hintStyle: TextStyle(color: chromeMedium.withOpacity(0.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w800,
          color: chromeLight,
          letterSpacing: -1.5,
        ),
        displayMedium: TextStyle(
          fontSize: 36,
          fontWeight: FontWeight.w700,
          color: chromeLight,
          letterSpacing: -0.5,
        ),
        displaySmall: TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.w700,
          color: chromeLight,
        ),
        headlineMedium: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: chromeLight,
          letterSpacing: -0.3,
        ),
        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: chromeLight,
        ),
        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: chromeLight,
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: chromeMedium,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: chromeMedium,
          height: 1.5,
        ),
      ),
      
      iconTheme: const IconThemeData(
        color: chromeMedium,
        size: 24,
      ),
      
      dividerTheme: DividerThemeData(
        color: chromeMedium.withOpacity(0.1),
        thickness: 1,
        space: 1,
      ),

      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: backgroundCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),

      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: accentBlue,
      ),
    );
  }
  
  // Decoración moderna para contenedores con efecto glass
  static BoxDecoration chromeContainer({
    Color? color,
    double borderRadius = 18,
    bool withGradient = true,
  }) {
    return BoxDecoration(
      color: color ?? backgroundCard,
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: withGradient ? LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          (color ?? backgroundCard),
          (color ?? backgroundCardLight).withOpacity(0.7),
        ],
      ) : null,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      border: Border.all(
        color: silverMedium.withOpacity(0.08),
        width: 1,
      ),
    );
  }
  
  // Decoración premium para tarjetas de color
  static BoxDecoration shinyCard({
    required Color color,
    double borderRadius = 18,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          color.withOpacity(0.9),
          color,
          color.withOpacity(0.8),
        ],
        stops: const [0.0, 0.5, 1.0],
      ),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    );
  }
  
  // Decoración de acero
  static BoxDecoration steelCard({
    double borderRadius = 18,
  }) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(borderRadius),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFF1E2330),
          Color(0xFF161B22),
          Color(0xFF1E2330),
        ],
        stops: [0.0, 0.5, 1.0],
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.3),
          blurRadius: 16,
          offset: const Offset(0, 6),
        ),
      ],
      border: Border.all(
        color: silverMedium.withOpacity(0.1),
        width: 1,
      ),
    );
  }

  // Gradiente primario reutilizable
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentBlue, Color(0xFF3A7BD5)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
