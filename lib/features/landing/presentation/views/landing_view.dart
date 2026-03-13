// Archivo: lib/features/landing/presentation/views/landing_view.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:apex/core/config/theme/app_theme.dart';
import 'package:apex/core/config/theme/app_theme_providers.dart';
import 'package:apex/core/widgets/inspector_gadget.dart'; // <--- IMPORTACIÓN RAYOS X
import 'package:apex/features/landing/presentation/widgets/project_drawer.dart';
import 'package:apex/features/landing/presentation/widgets/tech_card.dart';
import 'package:apex/features/shared/widgets/footer.dart';

class LandingView extends ConsumerStatefulWidget {
  const LandingView({super.key});

  @override
  ConsumerState<LandingView> createState() => _LandingViewState();
}

class _LandingViewState extends ConsumerState<LandingView> {
  final ValueNotifier<Offset> _mousePosNotifier = ValueNotifier(Offset.zero);
  Timer? _mouseThrottle;

  @override
  void dispose() {
    _mouseThrottle?.cancel();
    _mousePosNotifier.dispose();
    super.dispose();
  }

  void _onMouseMove(Offset position) {
    if (_mouseThrottle?.isActive ?? false) return;
    _mouseThrottle = Timer(const Duration(milliseconds: 32), () {
      _mousePosNotifier.value = position;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    const double cardHeight = 590;
    const double cardWidth = 350;

    return MouseRegion(
      onHover: (event) => _onMouseMove(event.position),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // --- SECCIÓN DE TÍTULOS CON RAYOS X ---
                      InspectorGadget(
                        name: "Hero Header Adaptativo",
                        techSpecs:
                            "Diseño fluido. Detecto el tamaño de tu pantalla para ajustar tipografías y márgenes matemáticamente, asegurando legibilidad perfecta en cualquier dispositivo.",
                        icon: Icons.title,
                        child: Column(
                          children: [
                            Text(
                              'Desarrollador Full-Stack & Mobile',
                              style: theme.textTheme.displaySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                                letterSpacing: -0.5,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Especializado en crear experiencias de usuario fluidas y eficientes\ncon Flutter, Supabase y Riverpod.',
                              style: theme.textTheme.headlineSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.3,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80),

                      // --- STACK TECNOLÓGICO (Cards de arriba) CON RAYOS X ---
                      InspectorGadget(
                        name: "Efecto 'Mouse Glow'",
                        techSpecs:
                            "Matemática visual. Rastreo la coordenada exacta de tu mouse/dedo para pintar un gradiente de luz dinámico en los bordes. Renderizado en tiempo real a 60 FPS.",
                        icon: FontAwesomeIcons.layerGroup,
                        child: Wrap(
                          spacing: 24,
                          runSpacing: 24,
                          alignment: WrapAlignment.center,
                          children: [
                            RepaintBoundary(
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: cardWidth,
                                ),
                                height: cardHeight,
                                child: _FlutterCard(_mousePosNotifier),
                              ),
                            ),
                            RepaintBoundary(
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: cardWidth,
                                ),
                                height: cardHeight,
                                child: _SupabaseCard(_mousePosNotifier),
                              ),
                            ),
                            RepaintBoundary(
                              child: Container(
                                constraints: const BoxConstraints(
                                  maxWidth: cardWidth,
                                ),
                                height: cardHeight,
                                child: _RiverpodCard(_mousePosNotifier),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 60),

                      // --- PROYECTO DESTACADO (Card de abajo) CON RAYOS X ---
                      Column(
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
                            'Productos digitales listos para atraer clientes y convertir conversaciones en ventas.',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 30),

                          InspectorGadget(
                            name: "Inyección de Tema Aislado",
                            techSpecs:
                                "Arquitectura avanzada. Al abrir este modal, inyecto un 'ThemeData' nuevo solo para esta sección, sin afectar los colores globales del resto de la app.",
                            icon: FontAwesomeIcons.mobileScreen,
                            child: Wrap(
                              spacing: 24,
                              runSpacing: 24,
                              alignment: WrapAlignment.center,
                              children: [
                                RepaintBoundary(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 800,
                                    ),
                                    child: _ContactEngineCard(
                                      _mousePosNotifier,
                                    ),
                                  ),
                                ),
                                RepaintBoundary(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 800,
                                    ),
                                    child: _BotLodeCard(_mousePosNotifier),
                                  ),
                                ),
                                RepaintBoundary(
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(
                                      maxWidth: 800,
                                    ),
                                    child: _AssistifyCard(_mousePosNotifier),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // --- FOOTER ---
            const Footer(),
          ],
        ),
      ),
    );
  }
}

// --- WIDGETS PRIVADOS PARA LAS CARDS (Sin cambios lógicos, solo visuales) ---

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

const _botlodeGold = Color(0xFFFFC000);

class _BotLodeCard extends ConsumerWidget {
  final ValueNotifier<Offset> mousePos;
  const _BotLodeCard(this.mousePos);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TechCard(
      mousePos: mousePos,
      theme: AppTheme.botlode,
      title: 'BotLode: Ecosistema de Bots IA',
      onTapOverride: () {
        showProjectDrawer(context, content: const BotLodeDrawerContent());
        Future.delayed(const Duration(milliseconds: 150), () {
          ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.botlode);
        });
      },
      icon: Image.asset(
        'assets/icons/logo_botlode.png',
        height: 28,
        width: 28,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        isAntiAlias: true,
        errorBuilder: (context, error, stackTrace) =>
            const Icon(FontAwesomeIcons.robot, size: 28, color: _botlodeGold),
      ),
      accentColor: _botlodeGold,
      bullets: const [
        'Fábrica de bots: crea muchos de tus bots sin código, listos para trabajar 24/7.',
        'Bot con 6 modos: Feliz, Enojado, Técnico, Confundido, Neutro y Vendedor.',
        'Historial y datos: recopilación en modo vendedor, todo visible en el Command Center.',
        'Alertas por email y agendado de reuniones desde el historial en un calendario.',
        'Producto listo para comercializar: genera ingresos con IA sin inversión inicial.',
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

      onTapOverride: () {
        showProjectDrawer(context, content: const AssistifyDrawerContent());
        Future.delayed(const Duration(milliseconds: 150), () {
          ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.assistify);
        });
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

class _ContactEngineCard extends ConsumerWidget {
  final ValueNotifier<Offset> mousePos;
  const _ContactEngineCard(this.mousePos);

  static const _contactEngineGray = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TechCard(
      mousePos: mousePos,
      theme: AppTheme.contactEngine,
      title: 'Contact Engine',
      onTapOverride: () {
        showProjectDrawer(context, content: const ContactEngineDrawerContent());
        Future.delayed(const Duration(milliseconds: 150), () {
          ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.contactEngine);
        });
      },
      icon: const Icon(
        FontAwesomeIcons.crosshairs,
        size: 28,
        color: _contactEngineGray,
      ),
      accentColor: _contactEngineGray,
      bullets: const [
        'Hace búsquedas en Google (por rubro y ciudad) y extrae los contactos por vos.',
        'Encuentra clientes potenciales de forma automática todos los días.',
        'Activa email + WhatsApp para convertir más conversaciones en oportunidades.',
        'Organiza el seguimiento comercial sin perder tiempo en tareas repetitivas.',
        'Muestra resultados claros con panel de control en tiempo real.',
      ],
    );
  }
}
