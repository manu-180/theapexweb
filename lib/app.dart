// Archivo: lib/app.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // <--- 1. IMPORTAR ESTO
import 'package:apex/core/config/router/app_router.dart';
import 'package:apex/core/config/theme/app_theme_providers.dart';
import 'package:apex/core/config/theme/brightness_provider.dart';
import 'package:apex/core/widgets/offline_banner.dart';

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
      theme: themeConfig.lightTheme, 
      darkTheme: themeConfig.darkTheme, 

      // --- 2. CONFIGURACIÓN DE IDIOMA (CRUCIAL PARA DATEFORMAT) ---
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'AR'), // Español (Prioridad)
        Locale('en', 'US'), // Inglés (Fallback)
      ],
      // -----------------------------------------------------------

      // --- ESCUDO GLOBAL DE UI + MONITOR DE RED ---
      builder: (context, child) {
        // 1. Inyectamos el ErrorWidget custom (Tu escudo original)
        ErrorWidget.builder = (FlutterErrorDetails details) {
          return Material(
            color: Colors.black87,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0), // Reduje un poco el padding
                // BLINDAJE: Usamos FittedBox para que el error se encoja 
                // si ocurre dentro de un widget pequeño (como tu calendario)
                child: FittedBox( 
                  fit: BoxFit.scaleDown,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.bug_report_rounded, color: Colors.orangeAccent, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        "Algo salió mal visualmente",
                        style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        "No te preocupes, la app sigue funcionando. Intenta recargar.",
                        style: TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        };

        // 2. Envolvemos la app en el Monitor de Red
        return OfflineStatusBanner(
          child: child!,
        );
      },
    );
  }
}