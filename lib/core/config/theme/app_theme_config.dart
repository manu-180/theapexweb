// Archivo: lib/core/config/theme/app_theme_config.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prueba_de_riverpod/core/config/theme/app_theme.dart';

// --- 1. Modelo de Configuración Híbrido ---
class AppThemeConfig {
  final String themeName;
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final IconData? logoIcon;   
  final String? logoAsset;    
  final String? lottieAsset;

  const AppThemeConfig({
    required this.themeName,
    required this.lightTheme,
    required this.darkTheme,
    this.logoIcon,
    this.logoAsset,
    this.lottieAsset,
  });
}

// --- 2. Colores de Marca ---
const _flutterColor = Color(0xFF0175C2);
const _supabaseColor = Color(0xFF3ECF8E);
const _riverpodColor = Color(0xFF6E56F8);
const _assistifyColor = Color(0xFF00A8E8);
const _neutralColor = Color(0xFF64748B);

ThemeData _createTheme({
  required Color seedColor,
  required Brightness brightness,
  required String fontFamily,
}) {
  // CAMBIO AQUÍ: Intensidad aumentada para que el cambio sea evidente
  final Color surfaceColor = brightness == Brightness.dark 
      // Modo Oscuro: Negro con 8% de color (Antes 5%) - Se nota más el matiz
      ? Color.alphaBlend(seedColor.withOpacity(0.08), const Color(0xFF0A0A0A)) 
      // Modo Claro: Blanco con 10% de color (Antes 3%) - AHORA SÍ SE VA A NOTAR
      : Color.alphaBlend(seedColor.withOpacity(0.08), Colors.white);

  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
    surface: surfaceColor, 
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: surfaceColor, // Fondo general teñido
    
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor, 
      surfaceTintColor: seedColor,
      elevation: 0,
      centerTitle: false,
      iconTheme: IconThemeData(color: colorScheme.primary),
      titleTextStyle: TextStyle(
        fontFamily: fontFamily,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: colorScheme.onSurface,
      ),
    ),
    
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),
  );
}

const String _fontFamily = 'Oxanium';

// --- 3. Mapa de Configuraciones ---
final Map<AppTheme, AppThemeConfig> appThemeConfigMap = {
  
  // --- NEUTRAL ---
  AppTheme.neutral: AppThemeConfig(
    themeName: 'Neutral',
    lightTheme: _createTheme(seedColor: _neutralColor, brightness: Brightness.light, fontFamily: _fontFamily),
    darkTheme: _createTheme(seedColor: _neutralColor, brightness: Brightness.dark, fontFamily: _fontFamily),
  ),

  // --- FLUTTER ---
  AppTheme.flutter: AppThemeConfig(
    themeName: 'Flutter',
    logoIcon: FontAwesomeIcons.flutter, 
    lottieAsset: 'assets/animations/flutter_lottie.json',
    lightTheme: _createTheme(seedColor: _flutterColor, brightness: Brightness.light, fontFamily: _fontFamily),
    darkTheme: _createTheme(seedColor: _flutterColor, brightness: Brightness.dark, fontFamily: _fontFamily),
  ),

  // --- SUPABASE ---
  AppTheme.supabase: AppThemeConfig(
    themeName: 'Supabase',
    logoIcon: FontAwesomeIcons.bolt,
    lottieAsset: 'assets/animations/supabase_lottie.json',
    lightTheme: _createTheme(seedColor: _supabaseColor, brightness: Brightness.light, fontFamily: _fontFamily),
    darkTheme: _createTheme(seedColor: _supabaseColor, brightness: Brightness.dark, fontFamily: _fontFamily),
  ),

  // --- RIVERPOD ---
  AppTheme.riverpod: AppThemeConfig(
    themeName: 'Riverpod',
    logoIcon: FontAwesomeIcons.water,
    lottieAsset: 'assets/animations/riverpod_lottie.json',
    lightTheme: _createTheme(seedColor: _riverpodColor, brightness: Brightness.light, fontFamily: _fontFamily),
    darkTheme: _createTheme(seedColor: _riverpodColor, brightness: Brightness.dark, fontFamily: _fontFamily),
  ),

  // --- ASSISTIFY ---
  AppTheme.assistify: AppThemeConfig(
    themeName: 'Assistify',
    logoAsset: 'assets/icons/logo_assistify.png', 
    lottieAsset: 'assets/animations/assistify_lottie.json',
    lightTheme: _createTheme(seedColor: _assistifyColor, brightness: Brightness.light, fontFamily: _fontFamily),
    darkTheme: _createTheme(seedColor: _assistifyColor, brightness: Brightness.dark, fontFamily: _fontFamily),
  ),
};