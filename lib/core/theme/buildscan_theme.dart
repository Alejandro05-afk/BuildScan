import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuildScanColors {
  static const tealDark = Color(0xFF0F3D3E);
  static const teal = Color(0xFF0B7A75);
  static const orange = Color(0xFFF28C28);
  static const background = Color(0xFFF2F2F2);
  static const textDark = Color(0xFF1F2933);
}

class BuildScanTheme {
  static ThemeData get lightTheme {
    final baseTextTheme = GoogleFonts.interTextTheme();
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: BuildScanColors.teal,
        primary: BuildScanColors.teal,
        secondary: BuildScanColors.orange,
      ),
      scaffoldBackgroundColor: BuildScanColors.background,
      
      // Tipografía Agradable
      textTheme: baseTextTheme.copyWith(
        titleLarge: baseTextTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        titleMedium: baseTextTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        titleSmall: baseTextTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      ),
      
      // Card Theme (Modern Minimal)
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 1,
        shadowColor: const Color.fromRGBO(0, 0, 0, 0.06),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFECECEC), width: 1),
        ),
      ),
      
      // AppBar Theme (Verde y menos invasivo)
      appBarTheme: const AppBarTheme(
        backgroundColor: BuildScanColors.teal,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        toolbarHeight: 48, // Header más pequeño
        foregroundColor: Colors.white,
        iconTheme: IconThemeData(color: Colors.white),
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700, // Títulos bold
          fontSize: 18, // Ligeramente más pequeño
        ),
      ),
    );
  }
}
