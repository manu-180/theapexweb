// Archivo: lib/core/config/theme/brightness_provider.dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:apex/core/config/theme/app_theme_providers.dart';

part 'brightness_provider.g.dart';

// Clave para guardar la preferencia en SharedPreferences
const _kThemeModeKey = 'app_theme_mode';

@riverpod
class BrightnessMode extends _$BrightnessMode {
  
  @override
  ThemeMode build() {
    // CORRECCIÓN CRÍTICA:
    // Accedemos a la instancia de SharedPreferences de forma SÍNCRONA.
    // Esto es posible gracias al override en main.dart.
    // Eliminamos el parpadeo (flicker) inicial: la app nace con el tema correcto.
    final prefs = ref.watch(sharedPreferencesProvider);
    final modeString = prefs.getString(_kThemeModeKey);

    // Retornamos el valor directo. Sin 'await', sin 'late', sin riesgo de null.
    if (modeString == 'light') {
      return ThemeMode.light;
    }
    
    // Por defecto dark si no hay nada guardado
    return ThemeMode.dark;
  }

  void toggleMode() {
    // Leemos el provider sin escuchar cambios (read) para ejecutar la acción
    final prefs = ref.read(sharedPreferencesProvider);
    
    if (state == ThemeMode.light) {
      state = ThemeMode.dark;
      prefs.setString(_kThemeModeKey, 'dark');
    } else {
      state = ThemeMode.light;
      prefs.setString(_kThemeModeKey, 'light');
    }
  }
}