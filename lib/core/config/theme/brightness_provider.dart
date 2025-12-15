// Archivo: lib/core/config/theme/brightness_provider.dart
import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'brightness_provider.g.dart';

// Clave para guardar la preferencia en SharedPreferences
const _kThemeModeKey = 'app_theme_mode';

@riverpod
class BrightnessMode extends _$BrightnessMode {
  late SharedPreferences _prefs;

  @override
  ThemeMode build() {
    // El estado inicial es 'dark' por defecto.
    // Luego, iniciamos la carga asíncrona de SharedPreferences.
    _initPrefs();
    return ThemeMode.dark;
  }

  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
    final modeString = _prefs.getString(_kThemeModeKey);
    
    // Una vez cargado, actualizamos el estado al valor guardado.
    switch (modeString) {
      case 'light':
        state = ThemeMode.light;
        break;
      case 'dark':
        state = ThemeMode.dark;
        break;
      default:
        // Si no hay nada guardado, mantenemos el default (dark).
        state = ThemeMode.dark;
    }
  }

  void setLightMode() {
    state = ThemeMode.light;
    _prefs.setString(_kThemeModeKey, 'light');
  }

  void setDarkMode() {
    state = ThemeMode.dark;
    _prefs.setString(_kThemeModeKey, 'dark');
  }

  void toggleMode() {
    if (state == ThemeMode.light) {
      setDarkMode();
    } else {
      setLightMode();
    }
  }
}