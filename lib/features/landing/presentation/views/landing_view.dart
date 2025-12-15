// Archivo: lib/features/landing/presentation/views/landing_view.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// Eliminé la importación de lottie ya que no se usa
import 'package:prueba_de_riverpod/core/config/theme/app_theme.dart';
import 'package:prueba_de_riverpod/core/config/theme/app_theme_providers.dart';
import 'package:prueba_de_riverpod/features/landing/presentation/widgets/assistify_case_study_modal.dart';
import 'package:prueba_de_riverpod/features/landing/presentation/widgets/tech_card.dart';
import 'package:responsive_builder/responsive_builder.dart';

class LandingView extends ConsumerStatefulWidget {
  const LandingView({super.key});

  @override
  ConsumerState<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends ConsumerState<LandingView> {
  final ValueNotifier<Offset> _mousePosNotifier = ValueNotifier(Offset.zero);

  @override
  void dispose() {
    _mousePosNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // Ya no necesitamos 'themeConfig' para el Lottie, pero lo dejamos por si usas algo más
    // final themeConfig = ref.watch(currentAppThemeConfigProvider); 

    return MouseRegion(
      onHover: (event) {
        _mousePosNotifier.value = event.position;
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24), // Aumenté padding superior
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1600),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- SECCIÓN DE TÍTULOS (Sin Lottie) ---
                FadeInDown(
                  duration: const Duration(milliseconds: 800),
                  child: Text(
                    'Desarrollador Full-Stack & Mobile',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 24),
                FadeInUp(
                  delay: const Duration(milliseconds: 300),
                  child: Text(
                    'Especializado en crear experiencias de usuario fluidas y eficientes\ncon Flutter, Supabase y Riverpod.',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 80), // Más aire antes de las cards

                // --- Sección de Cards ---
                ResponsiveBuilder(
                  builder: (context, sizingInfo) {
                    final bool isMobile = sizingInfo.isMobile || sizingInfo.isTablet;
                    
                    if (isMobile) {
                      return Column(
                        children: [
                          _FlutterCard(_mousePosNotifier),
                          const SizedBox(height: 24),
                          _SupabaseCard(_mousePosNotifier),
                          const SizedBox(height: 24),
                          _RiverpodCard(_mousePosNotifier),
                          const SizedBox(height: 24),
                          _AssistifyCard(_mousePosNotifier),
                        ],
                      );
                    }

                    // Layout Desktop
                    return Column(
                      children: [
                        IntrinsicHeight( // Asegura que todas tengan la misma altura visual si el contenido varía
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(child: _FlutterCard(_mousePosNotifier)),
                              const SizedBox(width: 24),
                              Expanded(child: _SupabaseCard(_mousePosNotifier)),
                              const SizedBox(width: 24),
                              Expanded(child: _RiverpodCard(_mousePosNotifier)),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        // Fila inferior para Assistify (centrado)
                        Row(
                          children: [
                            const Spacer(flex: 1), // Espacio vacío a la izquierda
                            Expanded(flex: 2, child: _AssistifyCard(_mousePosNotifier)), // Ocupa el centro
                            const Spacer(flex: 1), // Espacio vacío a la derecha
                          ],
                        )
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Widgets privados para las Cards ---

class _FlutterCard extends StatelessWidget {
  final ValueNotifier<Offset> mousePos;
  const _FlutterCard(this.mousePos);

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF0175C2);
    return TechCard(
      mousePos: mousePos,
      theme: AppTheme.flutter,
      title: 'Flutter',
      // AHORA PASAMOS UN WIDGET ICON COMPLETO
      icon: const Icon(FontAwesomeIcons.flutter, size: 28, color: accentColor),
      accentColor: accentColor,
      bullets: const [
        'Ahorro inteligente: Desarrollo simultáneo para iOS, Android y Web con un solo código.',
        'Experiencia Premium: Fluidez nativa (60fps) que enamora a tus usuarios.',
        'Time-to-Market: Tu producto en el mercado en tiempo récord.',
      ],
    );
  }
}

class _SupabaseCard extends StatelessWidget {
  final ValueNotifier<Offset> mousePos;
  const _SupabaseCard(this.mousePos);

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF3ECF8E);
    return TechCard(
      mousePos: mousePos,
      theme: AppTheme.supabase,
      title: 'Supabase',
      // AHORA PASAMOS UN WIDGET ICON COMPLETO
      icon: const Icon(FontAwesomeIcons.bolt, size: 28, color: accentColor),
      accentColor: accentColor,
      bullets: const [
        'Seguridad Grado Bancario: Protección total de datos y usuarios.',
        'Escalabilidad Automática: Soporta desde tu primer cliente hasta millones sin caerse.',
        'Tiempo Real: Actualizaciones instantáneas (stock, chats, notificaciones).',
      ],
    );
  }
}

class _RiverpodCard extends StatelessWidget {
  final ValueNotifier<Offset> mousePos;
  const _RiverpodCard(this.mousePos);

  @override
  Widget build(BuildContext context) {
    const accentColor = Color(0xFF6E56F8);
    return TechCard(
      mousePos: mousePos,
      theme: AppTheme.riverpod,
      title: 'Riverpod',
      // AHORA PASAMOS UN WIDGET ICON COMPLETO
      icon: const Icon(FontAwesomeIcons.water, size: 28, color: accentColor),
      accentColor: accentColor,
      bullets: const [
        'Inversión a Largo Plazo: Arquitectura limpia que permite que tu proyecto crezca años sin volverse un caos.',
        'Mantenimiento Económico: Agregar nuevas funciones en el futuro cuesta menos horas de desarrollo.',
        'Estabilidad "A prueba de balas": Minimiza errores y cierres inesperados de la app.',
      ],
    );
  }
}

// En lib/features/landing/presentation/views/landing_view.dart

class _AssistifyCard extends ConsumerWidget {
  final ValueNotifier<Offset> mousePos;
  const _AssistifyCard(this.mousePos);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TechCard(
      mousePos: mousePos,
      theme: AppTheme.assistify,
      title: 'Mi Proyecto: Assistify',
      
      onTapOverride: () {
        // 1. Cambiar el tema visual
        ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.assistify);
        
        // 2. Abrir Modal con Animación Fluida (showGeneralDialog)
        showGeneralDialog(
          context: context,
          barrierDismissible: true, // Permite cerrar clicando afuera
          barrierLabel: 'Cerrar',
          barrierColor: Colors.black.withOpacity(0.6), // Fondo oscurecido
          transitionDuration: const Duration(milliseconds: 500), // Duración más lenta para suavidad
          pageBuilder: (context, animation, secondaryAnimation) {
            return const AssistifyCaseStudyModal();
          },
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            // Usamos una curva "Cubic" que empieza rápido y frena suavemente al final
            final curvedValue = Curves.easeOutCubic.transform(animation.value);
            
            return Transform.scale(
              scale: 0.95 + (0.05 * curvedValue), // Efecto sutil: crece del 95% al 100%
              child: Opacity(
                opacity: curvedValue, // Aparece progresivamente (Fade In)
                child: child,
              ),
            );
          },
        );
      },

      icon: Image.asset(
        'assets/icons/logo_assistify.png',
        height: 28,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        isAntiAlias: true,
      ),
      accentColor: const Color(0xFF00A8E8),
      bullets: const [
        'Adiós a coordinar por WhatsApp: Gestión automática de horarios y alumnos en un solo lugar.',
        'Sistema de Créditos: Si un alumno cancela, recupera su clase automáticamente sin que tengas que intervenir.',
        'Listas de Espera Inteligentes: La app rellena los huecos libres avisando a los interesados por ti.',
      ],
    );
  }
}