// Archivo: lib/core/config/theme/app_theme_providers.dart
import 'package:flutter/material.dart';
import 'package:apex/core/config/theme/app_theme.dart';
import 'package:apex/core/config/theme/app_theme_config.dart' as theme_config;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_theme_providers.g.dart';

// 1. Creamos un Provider simple para la instancia de SharedPreferences.
// Lanzamos un error por defecto porque SIEMPRE debe ser sobreescrito en main.dart
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) {
  throw UnimplementedError('SharedPreferences no inicializado en main.dart');
}

// 2. Modelo de Configuración del Tema (expone lo que viene de app_theme_config)
class AppThemeConfig {
  final AppTheme theme;
  final ThemeData lightTheme;
  final ThemeData darkTheme;
  final String themeName;

  // Helpers para acceder rápido a los assets desde la UI (desde enum)
  String? get logoAsset => theme.logoAsset;
  IconData? get logoIcon => theme.icon;

  const AppThemeConfig({
    required this.theme,
    required this.lightTheme,
    required this.darkTheme,
    required this.themeName,
  });
}

@Riverpod(keepAlive: true)
class DynamicTheme extends _$DynamicTheme {
  static const _themePrefsKey = 'selected_theme_key';

  @override
  AppThemeConfig build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedThemeName = prefs.getString(_themePrefsKey);

    AppTheme initialTheme = AppTheme.neutral;
    if (savedThemeName != null) {
      try {
        initialTheme = AppTheme.values.firstWhere(
          (e) => e.name == savedThemeName,
          orElse: () => AppTheme.neutral,
        );
      } catch (_) {
        initialTheme = AppTheme.neutral;
      }
    }

    return _getConfig(initialTheme);
  }

  void setTheme(AppTheme theme, {bool persist = true}) {
    debugPrint('[DynamicTheme] setTheme → ${theme.name} (persist: $persist)');
    if (persist) {
      ref.read(sharedPreferencesProvider).setString(_themePrefsKey, theme.name);
    }
    state = _getConfig(theme);
    final s = state.lightTheme.colorScheme.surface;
    debugPrint(
      '[DynamicTheme] surface light = #${s.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
    );
  }

  /// Usa appThemeConfigMap como única fuente de colores/tema (sin caché, hot reload refleja cambios).
  static AppThemeConfig _getConfig(AppTheme theme) {
    final config = theme_config.appThemeConfigMap[theme]!;
    return AppThemeConfig(
      theme: theme,
      lightTheme: config.lightTheme,
      darkTheme: config.darkTheme,
      themeName: config.themeName,
    );
  }
}

// 4. Providers de lectura fácil para la UI
@riverpod
AppThemeConfig currentAppThemeConfig(CurrentAppThemeConfigRef ref) {
  return ref.watch(dynamicThemeProvider);
}

@riverpod
ThemeData lightTheme(LightThemeRef ref) {
  return ref.watch(dynamicThemeProvider).lightTheme;
}

@riverpod
ThemeData darkTheme(DarkThemeRef ref) {
  return ref.watch(dynamicThemeProvider).darkTheme;
}
