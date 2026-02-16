// Archivo: lib/features/auth/presentation/widgets/auth_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:apex/core/config/theme/app_theme.dart'; // Importa tu Enum
import 'package:apex/core/config/theme/app_theme_providers.dart'; // Importa el provider
import 'package:apex/features/auth/presentation/providers/auth_providers.dart';

class AuthRequiredModal extends ConsumerStatefulWidget {
  const AuthRequiredModal({super.key});

  @override
  ConsumerState<AuthRequiredModal> createState() => _AuthRequiredModalState();
}

class _AuthRequiredModalState extends ConsumerState<AuthRequiredModal> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // MENTORÍA: Ahora seleccionamos por el ENUM del tema. 
  // Esto es 100% robusto porque no depende de cómo Flutter altere los colores.
  String _getAnimationAsset(AppTheme currentTheme) {
    switch (currentTheme) {
      case AppTheme.flutter:
        return 'assets/animations/password_flutter.json';
      case AppTheme.supabase:
        return 'assets/animations/password_supabase.json';
      case AppTheme.riverpod:
        return 'assets/animations/password_riverpod.json';
      case AppTheme.assistify:
        return 'assets/animations/password_assistify.json';
      case AppTheme.neutral:
      default:
        return 'assets/animations/password_neutral.json';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // 1. Escuchamos la configuración actual del tema desde Riverpod
    final appConfig = ref.watch(currentAppThemeConfigProvider);
    
    // 2. Obtenemos el path basado en el Enum (appConfig.theme)
    final animationPath = _getAnimationAsset(appConfig.theme);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      backgroundColor: colorScheme.surface,
      elevation: 0,
      insetPadding: const EdgeInsets.all(20),
      
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // --- ANIMACIÓN LOTTIE SELECCIONADA ---
              SizedBox(
                height: 220, 
                width: double.infinity,
                child: Lottie.asset(
                  animationPath, 
                  controller: _controller,
                  onLoaded: (composition) {
                    _controller
                      ..duration = composition.duration * 0.7 
                      ..repeat(); 
                  },
                  fit: BoxFit.contain,
                ),
              ),
              
              // --- CONTENIDO ---
              Padding(
                padding: const EdgeInsets.fromLTRB(32, 0, 32, 32), 
                child: Column(
                  children: [
                    Text(
                      "Veracidad Garantizada",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: colorScheme.onSurface,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "Para mantener la calidad de las reseñas, solicitamos un inicio de sesión rápido. Así confirmamos que eres una persona real.",
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        height: 1.6,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 32), 
                    
                    // --- BOTONES ---
                    Row(
                      children: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                            foregroundColor: colorScheme.onSurfaceVariant,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: const Text(
                            "Cancelar",
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () async {
                              Navigator.pop(context);
                              final started = await ref.read(authRepositoryProvider).signInWithGoogle();
                              if (!started && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Login con Google no está configurado. Ejecutá la app con credenciales de Supabase (ver README).',
                                    ),
                                    duration: Duration(seconds: 5),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(Icons.g_mobiledata_rounded, size: 26),
                            label: const Text(
                              "Autenticar",
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                            ),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              elevation: 0,
                              backgroundColor: colorScheme.primary,
                              foregroundColor: colorScheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}