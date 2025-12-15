// Archivo: lib/core/widgets/main_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:prueba_de_riverpod/core/config/theme/app_theme.dart';
import 'package:prueba_de_riverpod/core/config/theme/app_theme_providers.dart';
import 'package:prueba_de_riverpod/core/config/theme/brightness_provider.dart';
import 'package:prueba_de_riverpod/features/auth/presentation/providers/auth_providers.dart';
// IMPORTANTE: Asegúrate de que esta ruta apunte a donde guardaste el widget Contactanos
import 'package:prueba_de_riverpod/widgets/contactanos.dart'; 

class MainLayout extends ConsumerWidget {
  const MainLayout({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final brightness = ref.watch(brightnessModeProvider);
    final isDark = brightness == ThemeMode.dark;
    final themeConfig = ref.watch(currentAppThemeConfigProvider);
    final authState = ref.watch(authStateStreamProvider);

    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 4,
            width: double.infinity,
            color: theme.colorScheme.primary, 
          ),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                title: GestureDetector(
                  onTap: () => context.goNamed('home'),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // --- LÓGICA INTELIGENTE DE LOGO ---
                      
                      // CASO 1: Es una IMAGEN (ej. Assistify)
                      if (themeConfig.logoAsset != null) ...[
                        Image.asset(
                          themeConfig.logoAsset!,
                          height: 32,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high, 
                          isAntiAlias: true,
                        ),
                        const SizedBox(width: 12),
                      ]
                      // CASO 2: Es un ICONO (ej. Flutter, Supabase)
                      else if (themeConfig.logoIcon != null) ...[
                        Icon(
                          themeConfig.logoIcon!,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                      ],
                      // ----------------------------------
                      
                      Text(
                        'Manuel Navarro',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: themeConfig.themeName == 'Neutral' 
                              ? theme.colorScheme.onSurface 
                              : theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                actions: [
                  if (MediaQuery.of(context).size.width > 700) ...[
                    TextButton(onPressed: () => context.goNamed('home'), child: const Text('Home')),
                    TextButton(onPressed: () => context.goNamed('services'), child: const Text('Servicios')),
                    TextButton(onPressed: () => context.goNamed('about'), child: const Text('Sobre Mí')),
                    TextButton(onPressed: () => context.goNamed('contact'), child: const Text('Contacto')),
                    const SizedBox(width: 16),
                  ],

                  IconButton(
                    onPressed: () => ref.read(brightnessModeProvider.notifier).toggleMode(),
                    icon: Icon(isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
                    color: theme.colorScheme.primary,
                  ),
                  IconButton(
                    tooltip: 'Resetear Tema',
                    onPressed: () => ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.neutral),
                    icon: const Icon(Icons.refresh_rounded),
                  ),
                  
                  const SizedBox(width: 8),

                  authState.when(
                    loading: () => const SizedBox(width: 40, child: Center(child: CircularProgressIndicator(strokeWidth: 2))),
                    error: (_, __) => const Icon(Icons.error, color: Colors.red),
                    data: (user) {
                      if (user == null) {
                        return FilledButton.icon(
                          onPressed: () => ref.read(authRepositoryProvider).signInWithGoogle(),
                          icon: const Icon(FontAwesomeIcons.google, size: 14),
                          label: const Text('Login'),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0), 
                            visualDensity: VisualDensity.compact,
                          ),
                        );
                      } else {
                        return PopupMenuButton<String>(
                          onSelected: (v) { if(v == 'logout') ref.read(authRepositoryProvider).signOut(); },
                          itemBuilder: (context) => [
                            const PopupMenuItem(value: 'logout', child: Text('Cerrar Sesión')),
                          ],
                          child: CircleAvatar(
                            radius: 16,
                            backgroundImage: user.userMetadata?['avatar_url'] != null 
                              ? NetworkImage(user.userMetadata!['avatar_url']) 
                              : null,
                            child: user.userMetadata?['avatar_url'] == null ? const Icon(Icons.person, size: 16) : null,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(width: 16),
                ],
              ),
              
              // --- CAMBIO AQUÍ: Usamos el nuevo widget dinámico ---
              floatingActionButton: const Contactanos(),
              
              body: child, 
            ),
          ),
        ],
      ),
    );
  }
}