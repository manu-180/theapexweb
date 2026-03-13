// Archivo: lib/core/config/theme/app_theme_providers.dart
import 'package:flutter/material.dart';
import 'package:apex/core/config/theme/app_theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_theme_providers.g.dart';

// 1. Creamos un Provider simple para la instancia de SharedPreferences.
// Lanzamos un error por defecto porque SIEMPRE debe ser sobreescrito en main.dart
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) {
  throw UnimplementedError('SharedPreferences no inicializado en main.dart');
}

// 2. Modelo de Configuración del Tema
class AppThemeConfig {
  final AppTheme theme;
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  // Helpers para acceder rápido a los assets desde la UI
  String? get logoAsset => theme.logoAsset;
  IconData? get logoIcon => theme.icon;
  String get themeName => theme.name;

  const AppThemeConfig({
    required this.theme,
    required this.lightTheme,
    required this.darkTheme,
  });
}

@Riverpod(keepAlive: true)
class DynamicTheme extends _$DynamicTheme {
  static const _themePrefsKey = 'selected_theme_key';
  static final Map<AppTheme, AppThemeConfig> _configCache = {};

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

    return _getOrCreateConfig(initialTheme);
  }

  void setTheme(AppTheme theme, {bool persist = true}) {
    debugPrint('[DynamicTheme] setTheme → ${theme.name} (persist: $persist)');
    if (persist) {
      ref.read(sharedPreferencesProvider).setString(_themePrefsKey, theme.name);
    }
    state = _getOrCreateConfig(theme);
    final s = state.lightTheme.colorScheme.surface;
    debugPrint(
      '[DynamicTheme] surface light = #${s.toARGB32().toRadixString(16).padLeft(8, '0').toUpperCase()}',
    );
  }

  static AppThemeConfig _getOrCreateConfig(AppTheme theme) {
    // No cacheamos indefinidamente para que hot-reload refleje cambios en getThemeData.
    return _configCache.putIfAbsent(theme, () {
      debugPrint('[DynamicTheme] creando config para ${theme.name}');
      return AppThemeConfig(
        theme: theme,
        lightTheme: theme.getThemeData(Brightness.light),
        darkTheme: theme.getThemeData(Brightness.dark),
      );
    });
  }

  /// Limpia el cache (útil en desarrollo para reflejar cambios en getThemeData).
  static void clearCache() => _configCache.clear();
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
