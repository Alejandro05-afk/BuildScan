import 'package:flutter/material.dart';
 
class BuildScanColors {
  static const tealDark = Color(0xFF0F3D3E);
  static const teal = Color(0xFF0B7A75);
  static const orange = Color(0xFFF28C28);
  static const background = Color(0xFFF2F2F2);
  static const textDark = Color(0xFF1F2933);
}
 
class BuildScanTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: BuildScanColors.teal,
        primary: BuildScanColors.teal,
        secondary: BuildScanColors.orange,
      ),
      scaffoldBackgroundColor: BuildScanColors.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: BuildScanColors.tealDark,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
    );
  }
}
