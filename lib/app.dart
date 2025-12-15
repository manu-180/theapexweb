// Archivo: lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prueba_de_riverpod/core/config/router/app_router.dart';
import 'package:prueba_de_riverpod/core/config/theme/app_theme_providers.dart';
import 'package:prueba_de_riverpod/core/config/theme/brightness_provider.dart';

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 1. Escucha el router
    final goRouter = ref.watch(goRouterProvider);

    // 2. Escucha el provider de modo (light/dark)
    final themeMode = ref.watch(brightnessModeProvider);

    // 3. Escucha el provider de configuración del tema (colores, assets)
    final themeConfig = ref.watch(currentAppThemeConfigProvider);

    return MaterialApp.router(
      title: 'Manuel Navarro - Full-Stack Developer',
      debugShowCheckedModeBanner: false,
      
      // Conectamos el router
      routerConfig: goRouter,

      // Conectamos los providers del tema
      themeMode: themeMode,
      theme: themeConfig.lightTheme, // Tema claro dinámico
      darkTheme: themeConfig.darkTheme, // Tema oscuro dinámico
    );
  }
}