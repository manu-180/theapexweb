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

// 3. Notifier que maneja el tema y la persistencia
@Riverpod(keepAlive: true)
class DynamicTheme extends _$DynamicTheme {
  
  static const _themePrefsKey = 'selected_theme_key';

  @override
  AppThemeConfig build() {
    // LECTURA SÍNCRONA: Gracias al override en main.dart, esto es instantáneo.
    // Evita pantallas blancas o parpadeos al iniciar.
    final prefs = ref.watch(sharedPreferencesProvider);
    final savedThemeName = prefs.getString(_themePrefsKey);

    AppTheme initialTheme = AppTheme.neutral; // Default seguro
    
    if (savedThemeName != null) {
      // Lógica blindada: Si el nombre guardado no existe (ej. cambio de versión),
      // fallback a Neutral sin crashear.
      try {
        initialTheme = AppTheme.values.firstWhere(
          (e) => e.name == savedThemeName, 
          orElse: () => AppTheme.neutral
        );
      } catch (_) {
        initialTheme = AppTheme.neutral;
      }
    }

    return _createConfig(initialTheme);
  }

  void setTheme(AppTheme theme) {
    // 1. Guardamos en disco (fire and forget)
    ref.read(sharedPreferencesProvider).setString(_themePrefsKey, theme.name);
    // 2. Actualizamos UI inmediatamente
    state = _createConfig(theme);
  }

  void setHoverTheme(AppTheme theme) {
    // Cambio temporal visual, NO toca persistencia
    state = _createConfig(theme);
  }

  void clearHoverTheme() {
    // Restauramos lo que realmente está guardado en disco
    final prefs = ref.read(sharedPreferencesProvider);
    final savedName = prefs.getString(_themePrefsKey);
    
    AppTheme savedTheme = AppTheme.neutral;
    if (savedName != null) {
      savedTheme = AppTheme.values.firstWhere(
        (e) => e.name == savedName, 
        orElse: () => AppTheme.neutral
      );
    }
    state = _createConfig(savedTheme);
  }

  // Helper privado para crear el objeto de configuración
  AppThemeConfig _createConfig(AppTheme theme) {
    return AppThemeConfig(
      theme: theme,
      lightTheme: theme.getThemeData(Brightness.light),
      darkTheme: theme.getThemeData(Brightness.dark),
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