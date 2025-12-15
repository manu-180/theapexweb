// Archivo: lib/core/config/theme/app_theme_providers.dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:prueba_de_riverpod/core/config/theme/app_theme.dart';
import 'package:prueba_de_riverpod/core/config/theme/app_theme_config.dart';

part 'app_theme_providers.g.dart';

// Este Provider controla el tema dinámico de la Landing Page
@riverpod
class DynamicTheme extends _$DynamicTheme {
  // Variable privada para recordar el tema "Fijo" (el último clickeado)
  AppTheme _fixedTheme = AppTheme.neutral;

  @override
  AppThemeConfig build() {
    // Estado inicial: Neutral
    _fixedTheme = AppTheme.neutral;
    return appThemeConfigMap[AppTheme.neutral]!;
  }

  // ACCIÓN 1: CLICK (Fijar tema)
  // Cuando el usuario hace clic, actualizamos la variable _fixedTheme
  void setTheme(AppTheme theme) {
    _fixedTheme = theme; 
    state = appThemeConfigMap[theme]!;
  }

  // ACCIÓN 2: HOVER (Previsualizar tema)
  // Cuando pasa el mouse, cambiamos el estado visual PERO NO la variable _fixedTheme
  void setHoverTheme(AppTheme theme) {
    state = appThemeConfigMap[theme]!;
  }

  // ACCIÓN 3: SALIR DEL HOVER (Restaurar)
  // Cuando saca el mouse, volvemos al que estaba guardado en _fixedTheme
  void clearHoverTheme() {
    state = appThemeConfigMap[_fixedTheme]!;
  }
}

// Provider auxiliar para exponer la configuración actual
@riverpod
AppThemeConfig currentAppThemeConfig(CurrentAppThemeConfigRef ref) {
  return ref.watch(dynamicThemeProvider);
}