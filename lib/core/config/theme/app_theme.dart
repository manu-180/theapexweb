// Archivo: lib/core/config/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Define los temas de la aplicación y su configuración visual.
enum AppTheme {
  neutral,
  flutter,
  supabase,
  riverpod,
  assistify;

  // 1. Getter para el Asset de imagen (Si el tema usa una imagen personalizada)
  String? get logoAsset {
    switch (this) {
      case AppTheme.assistify:
        return 'assets/icons/logo_assistify.png'; // Asegúrate que este path sea correcto
      default:
        return null;
    }
  }

  // 2. Getter para el Icono vectorial (Si el tema usa un icono de FontAwesome)
  IconData? get icon {
    switch (this) {
      case AppTheme.flutter:
        return FontAwesomeIcons.flutter;
      case AppTheme.supabase:
        return FontAwesomeIcons.bolt;
      case AppTheme.riverpod:
        return FontAwesomeIcons.water;
      default:
        return null;
    }
  }

  // 3. Método para generar el ThemeData completo basado en el brillo (Claro/Oscuro)
  ThemeData getThemeData(Brightness brightness) {
    // Definimos el color base (Seed Color) para cada tema
    final colorSeed = switch (this) {
      AppTheme.neutral => Colors.blueGrey, // Un tono neutro profesional
      AppTheme.flutter => const Color(0xFF0175C2),
      AppTheme.supabase => const Color(0xFF3ECF8E),
      AppTheme.riverpod => const Color(0xFF6E56F8),
      AppTheme.assistify => const Color(0xFF00A8E8),
    };

    // Generamos el esquema de colores Material 3
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colorSeed,
      brightness: brightness,
    );

    // Retornamos el tema configurado
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      // Usamos la fuente Oxanium que definiste en tu pubspec.yaml
      fontFamily: 'Oxanium', 
      
      // Ajustes opcionales para que se vea más moderno
      appBarTheme: AppBarTheme(
        backgroundColor: colorScheme.surface,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
      ),
      scaffoldBackgroundColor: colorScheme.surface,
    );
  }
}