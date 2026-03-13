// Archivo: lib/core/config/theme/app_theme_config.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:apex/core/config/theme/app_theme.dart';

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
const _botlodeColor = Color(0xFFFFC000);
const _assistifyColor = Color(0xFF00A8E8);
const _contactEngineColor = Color(0xFF6B7280);
const _neutralColor = Color(0xFF64748B);

// Fondos neutros fijos — el color del tema NUNCA toca el fondo
const _darkSurface = Color(0xFF111318); // Gris-azul muy oscuro, neutro premium
const _lightSurface = Color(0xFFF4F6F8); // Gris frío muy suave

ThemeData _createTheme({
  required Color seedColor,
  required Brightness brightness,
  required String fontFamily,
}) {
  final isDark = brightness == Brightness.dark;
  final surface = isDark ? _darkSurface : _lightSurface;

  // El ColorScheme hereda primaries/secondaries del seed pero
  // recibe una surface neutra para que el fondo no se tiña.
  final colorScheme = ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: brightness,
    surface: surface,
  ).copyWith(
    // Garantizamos que el scaffold y las superficies contenedoras
    // sean variantes neutras del mismo tono base, sin tinte.
    surfaceContainerLowest: isDark
        ? const Color(0xFF0C0E12)
        : const Color(0xFFFFFFFF),
    surfaceContainerLow: isDark
        ? const Color(0xFF161A20)
        : const Color(0xFFF0F2F5),
    surfaceContainer: isDark
        ? const Color(0xFF1C2028)
        : const Color(0xFFE8ECF0),
    surfaceContainerHigh: isDark
        ? const Color(0xFF222830)
        : const Color(0xFFDDE2E8),
    surfaceContainerHighest: isDark
        ? const Color(0xFF282E38)
        : const Color(0xFFD2D8E0),
  );

  return ThemeData(
    useMaterial3: true,
    fontFamily: fontFamily,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: surface,

    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      surfaceTintColor: Colors.transparent, // Sin tinte en AppBar
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
    lightTheme: _createTheme(
      seedColor: _neutralColor,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
    ),
    darkTheme: _createTheme(
      seedColor: _neutralColor,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
    ),
  ),

  // --- FLUTTER ---
  AppTheme.flutter: AppThemeConfig(
    themeName: 'Flutter',
    logoIcon: FontAwesomeIcons.flutter,
    lottieAsset: 'assets/animations/flutter_lottie.json',
    lightTheme: _createTheme(
      seedColor: _flutterColor,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
    ),
    darkTheme: _createTheme(
      seedColor: _flutterColor,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
    ),
  ),

  // --- SUPABASE ---
  AppTheme.supabase: AppThemeConfig(
    themeName: 'Supabase',
    logoIcon: FontAwesomeIcons.bolt,
    lottieAsset: 'assets/animations/supabase_lottie.json',
    lightTheme: _createTheme(
      seedColor: _supabaseColor,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
    ),
    darkTheme: _createTheme(
      seedColor: _supabaseColor,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
    ),
  ),

  // --- RIVERPOD ---
  AppTheme.riverpod: AppThemeConfig(
    themeName: 'Riverpod',
    logoIcon: FontAwesomeIcons.water,
    lottieAsset: 'assets/animations/riverpod_lottie.json',
    lightTheme: _createTheme(
      seedColor: _riverpodColor,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
    ),
    darkTheme: _createTheme(
      seedColor: _riverpodColor,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
    ),
  ),

  // --- BOTLODE ---
  AppTheme.botlode: AppThemeConfig(
    themeName: 'BotLode',
    logoAsset: 'assets/icons/logo_botlode.png',
    lightTheme: _createTheme(
      seedColor: _botlodeColor,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
    ),
    darkTheme: _createTheme(
      seedColor: _botlodeColor,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
    ),
  ),

  // --- ASSISTIFY ---
  AppTheme.assistify: AppThemeConfig(
    themeName: 'Assistify',
    logoAsset: 'assets/icons/logo_assistify.png',
    lottieAsset: 'assets/animations/assistify_lottie.json',
    lightTheme: _createTheme(
      seedColor: _assistifyColor,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
    ),
    darkTheme: _createTheme(
      seedColor: _assistifyColor,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
    ),
  ),

  // --- CONTACT ENGINE ---
  AppTheme.contactEngine: AppThemeConfig(
    themeName: 'Contact Engine',
    logoIcon: FontAwesomeIcons.crosshairs,
    lightTheme: _createTheme(
      seedColor: _contactEngineColor,
      brightness: Brightness.light,
      fontFamily: _fontFamily,
    ),
    darkTheme: _createTheme(
      seedColor: _contactEngineColor,
      brightness: Brightness.dark,
      fontFamily: _fontFamily,
    ),
  ),
};
