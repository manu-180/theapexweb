// Archivo: lib/core/config/theme/app_theme_providers.dart
import 'package:flutter/material.dart';
import 'package:prueba_de_riverpod/core/config/theme/app_theme.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'app_theme_providers.g.dart';

// 1. Creamos un Provider simple para la instancia de SharedPreferences.
// Lanzamos un error por defecto porque lo vamos a sobreescribir en el main.dart
@Riverpod(keepAlive: true)
SharedPreferences sharedPreferences(SharedPreferencesRef ref) {
  throw UnimplementedError('SharedPreferences no inicializado');
}

// 2. Modelo de Configuración del Tema
class AppThemeConfig {
  final AppTheme theme;
  final ThemeData lightTheme;
  final ThemeData darkTheme;

  // Helpers para acceder rápido a los assets desde la UI
  String? get logoAsset => theme.logoAsset;
  IconData? get logoIcon => theme.icon;
  String get themeName => theme.name; // Para guardar en prefs

  AppThemeConfig({
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
    // A. Obtenemos la instancia de SharedPreferences (sincrónicamente gracias al override)
    final prefs = ref.watch(sharedPreferencesProvider);
    
    // B. Leemos el String guardado (si no existe, devuelve null)
    final savedThemeName = prefs.getString(_themePrefsKey);

    // C. Buscamos qué tema coincide con ese nombre
    AppTheme initialTheme = AppTheme.neutral; // Default
    
    if (savedThemeName != null) {
      try {
        // Buscamos en el enum el que tenga el mismo nombre
        initialTheme = AppTheme.values.firstWhere(
          (e) => e.name == savedThemeName, 
          orElse: () => AppTheme.neutral
        );
      } catch (_) {
        // Si hay error de lectura, volvemos al neutral
        initialTheme = AppTheme.neutral;
      }
    }

    // D. Retornamos la configuración inicial lista
    return _createConfig(initialTheme);
  }

  void setTheme(AppTheme theme) {
    // 1. Guardamos en el almacenamiento del dispositivo
    ref.read(sharedPreferencesProvider).setString(_themePrefsKey, theme.name);
    
    // 2. Actualizamos el estado de la app
    state = _createConfig(theme);
  }

  void setHoverTheme(AppTheme theme) {
    // Solo cambia visualmente, NO guarda en preferencias (es temporal por hover)
    state = _createConfig(theme);
  }

  void clearHoverTheme() {
    // Vuelve al tema que estaba guardado en preferencias
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

// 4. Provider de lectura fácil para la UI (solo devuelve la config actual)
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