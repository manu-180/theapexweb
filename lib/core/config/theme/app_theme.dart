// Archivo: lib/core/config/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/// Define los temas de la aplicación y su configuración visual.
enum AppTheme {
  neutral,
  flutter,
  supabase,
  riverpod,
  botlode,
  assistify,
  contactEngine;

  // 1. Getter para el Asset de imagen (Si el tema usa una imagen personalizada)
  String? get logoAsset {
    switch (this) {
      case AppTheme.botlode:
        return 'assets/icons/logo_botlode.png';
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
      case AppTheme.botlode:
        return null; // Usa logoAsset (logo_botlode.png)
      case AppTheme.contactEngine:
        return FontAwesomeIcons.crosshairs;
      default:
        return null;
    }
  }

  // Fondos neutros fijos — el color del tema nunca toca el fondo de página.
  static const _darkSurface = Color(0xFF111318);
  static const _lightSurface = Color(0xFFF4F6F8);

  // 3. Método para generar el ThemeData completo basado en el brillo (Claro/Oscuro)
  ThemeData getThemeData(Brightness brightness) {
    final colorSeed = switch (this) {
      AppTheme.neutral => Colors.blueGrey,
      AppTheme.flutter => const Color(0xFF0175C2),
      AppTheme.supabase => const Color(0xFF3ECF8E),
      AppTheme.riverpod => const Color(0xFF6E56F8),
      AppTheme.botlode => const Color(0xFFFFC000),
      AppTheme.assistify => const Color(0xFF00A8E8),
      AppTheme.contactEngine => const Color(0xFF6B7280),
    };

    final isDark = brightness == Brightness.dark;
    final surface = isDark ? _darkSurface : _lightSurface;

    // ColorScheme recibe la surface neutra: primary/secondary cambian con el tema,
    // pero el fondo permanece igual en todos los temas.
    final colorScheme = ColorScheme.fromSeed(
      seedColor: colorSeed,
      brightness: brightness,
      surface: surface,
    ).copyWith(
      surfaceContainerLowest: isDark ? const Color(0xFF0C0E12) : const Color(0xFFFFFFFF),
      surfaceContainerLow:    isDark ? const Color(0xFF161A20) : const Color(0xFFF0F2F5),
      surfaceContainer:       isDark ? const Color(0xFF1C2028) : const Color(0xFFE8ECF0),
      surfaceContainerHigh:   isDark ? const Color(0xFF222830) : const Color(0xFFDDE2E8),
      surfaceContainerHighest:isDark ? const Color(0xFF282E38) : const Color(0xFFD2D8E0),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: 'Oxanium',
      scaffoldBackgroundColor: surface,

      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        foregroundColor: colorScheme.onSurface,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: colorScheme.primary),
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
}
