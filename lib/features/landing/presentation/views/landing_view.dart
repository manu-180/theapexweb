// Archivo: lib/features/landing/presentation/views/landing_view.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prueba_de_riverpod/core/config/theme/app_theme.dart';
import 'package:prueba_de_riverpod/core/config/theme/app_theme_providers.dart';
import 'package:prueba_de_riverpod/features/landing/presentation/widgets/assistify_case_study_modal.dart';
import 'package:prueba_de_riverpod/features/landing/presentation/widgets/tech_card.dart';

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

    // Ajustamos la altura y ancho para mantener uniformidad
    const double cardHeight = 590; 
    const double cardWidth = 350;

    return MouseRegion(
      onHover: (event) {
        _mousePosNotifier.value = event.position;
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // --- SECCIÓN DE TÍTULOS ---
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
                const SizedBox(height: 80),

                // --- STACK TECNOLÓGICO (Cards de arriba) ---
                Wrap(
                  spacing: 24,     
                  runSpacing: 24, 
                  alignment: WrapAlignment.center,
                  children: [
                    // --- FLUTTER ---
                    Container(
                      constraints: const BoxConstraints(maxWidth: cardWidth),
                      height: cardHeight, 
                      child: _FlutterCard(_mousePosNotifier),
                    ),
                    
                    // --- SUPABASE ---
                    Container(
                      constraints: const BoxConstraints(maxWidth: cardWidth),
                      height: cardHeight, 
                      child: _SupabaseCard(_mousePosNotifier),
                    ),
                    
                    // --- RIVERPOD ---
                    Container(
                      constraints: const BoxConstraints(maxWidth: cardWidth),
                      height: cardHeight, 
                      child: _RiverpodCard(_mousePosNotifier),
                    ),
                  ],
                ),

                const SizedBox(height: 60),

                // --- PROYECTO DESTACADO (Card de abajo) ---
                FadeInUp(
                  delay: const Duration(milliseconds: 500),
                  child: Column(
                    children: [
                       Text(
                        'Desarrollo Integral: De la Idea al Lanzamiento',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aplicaciones móviles en tiendas y software de escritorio a medida.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 30),
                      
                      // AQUÍ ESTÁ EL CAMBIO: maxWidth pasó de 500 a 800
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 800), 
                        child: _AssistifyCard(_mousePosNotifier),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- WIDGETS PRIVADOS PARA LAS CARDS ---

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
      icon: const Icon(FontAwesomeIcons.flutter, size: 28, color: accentColor),
      accentColor: accentColor,
      bullets: const [
        'Aplicaciones Ultrarrápidas: Tiempos de carga mínimos que retienen clientes.', 
        'Experiencia Premium: Fluidez visual y animaciones profesionales.',
        'Time-to-Market: Tu producto listo para lanzar en tiempo récord.',
        'Gráficos de Alta Calidad: Renderizado nítido en cualquier dispositivo.', 
        'Diseño Adaptativo: Se ve increíble en celulares, tablets y web.',
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
      icon: const Icon(FontAwesomeIcons.bolt, size: 28, color: accentColor),
      accentColor: accentColor,
      bullets: const [
        'Seguridad Bancaria: Protección total de los datos de tus usuarios.',
        'Escalabilidad Automática: Crece de 1 a 1 millón de usuarios sin caídas.',
        'Tiempo Real: Actualizaciones instantáneas (stock, chats, alertas).',
        'Base de Datos Robusta: Tecnología SQL confiable y potente.',
        'Acceso Simplificado: Inicia sesión con Google o Apple en un clic.', 
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
      icon: const Icon(FontAwesomeIcons.water, size: 28, color: accentColor),
      accentColor: accentColor,
      bullets: const [
        'Arquitectura Sólida: Tu proyecto puede crecer años sin volverse un caos.',
        'Inversión Eficiente: Actualizar tu app en el futuro es más rápido y económico.',
        'Estabilidad Total: Minimiza errores y cierres inesperados de la app.',
        'Calidad Asegurada: Código preparado para detectar fallos antes de salir.', 
        'Datos 100% Confiables: Tus usuarios nunca verán información errónea o vieja.',
      ],
    );
  }
}

class _AssistifyCard extends ConsumerWidget {
  final ValueNotifier<Offset> mousePos;
  const _AssistifyCard(this.mousePos);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TechCard(
      mousePos: mousePos,
      theme: AppTheme.assistify,
      title: 'Assistify: App en Producción',
      
      // Animación suave del modal
      onTapOverride: () {
        ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.assistify);
        
        showGeneralDialog(
          context: context,
          barrierDismissible: true, 
          barrierLabel: 'Cerrar',
          barrierColor: Colors.black.withOpacity(0.6), 
          transitionDuration: const Duration(milliseconds: 500), 
          pageBuilder: (context, animation, secondaryAnimation) {
            return const AssistifyCaseStudyModal();
          },
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            final curvedValue = Curves.easeOutCubic.transform(animation.value);
            return Transform.scale(
              scale: 0.95 + (0.05 * curvedValue), 
              child: Opacity(
                opacity: curvedValue, 
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
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
      ),
      accentColor: const Color(0xFF00A8E8),
      bullets: const [
        'Notificaciones WhatsApp: El profesor recibe alertas de cambios sin necesidad de abrir la App.',
        'Adiós a la Agenda de Papel: Los alumnos cancelan y recuperan clases solos mediante Créditos.',
        'Listas de Espera Inteligentes: El sistema rellena huecos libres automáticamente.',
        'Panel de Administración: Gestión total de horarios, altas, bajas y asignación de créditos.',
        'Despliegue Real: Aplicación activa y descargable en Play Store y App Store.',
      ],
    );
  }
}