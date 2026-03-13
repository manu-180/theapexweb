// Archivo: lib/features/services/presentation/views/services_view.dart
import 'dart:async';
import 'package:apex/features/estimator/presentation/widgets/estimator_calculator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:apex/core/widgets/inspector_gadget.dart'; // <--- IMPORTACIÓN RAYOS X
import 'package:apex/features/services/data/repositories/plans_repository.dart';
import 'package:apex/features/services/domain/models/plan_model.dart';
import 'package:apex/features/services/presentation/widgets/plan_card.dart';
import 'package:apex/features/shared/widgets/footer.dart';

class ServicesView extends ConsumerStatefulWidget {
  final int initialIndex;

  const ServicesView({super.key, this.initialIndex = 0});

  @override
  ConsumerState<ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends ConsumerState<ServicesView> {
  late int _selectedIndex;
  final ValueNotifier<Offset> _mousePos = ValueNotifier(Offset.zero);
  Timer? _mouseThrottle;

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
  }

  void _onMouseMove(Offset position) {
    if (_mouseThrottle?.isActive ?? false) return;
    _mouseThrottle = Timer(const Duration(milliseconds: 32), () {
      _mousePos.value = position;
    });
  }

  @override
  void dispose() {
    _mouseThrottle?.cancel();
    _mousePos.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ServicesView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialIndex != oldWidget.initialIndex) {
      setState(() {
        _selectedIndex = widget.initialIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final plansRepo = ref.watch(plansRepositoryProvider);
    final currentPlans = _selectedIndex == 0
        ? plansRepo.webPlans
        : plansRepo.appPlans;
    final theme = Theme.of(context);

    return MouseRegion(
      onHover: (event) => _onMouseMove(event.position),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1200),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 48,
                  ),
                  child: Column(
                    children: [
                      // ── Header ───────────────────────────────────────────
                      Text(
                        'Mis Servicios',
                        style: theme.textTheme.displayMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Soluciones tecnológicas diseñadas para escalar tu negocio',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // ── Toggle ───────────────────────────────────────────
                      InspectorGadget(
                        name: "Renderizado Condicional",
                        techSpecs:
                            "UI Reactiva. Al cambiar el switch, solo redibujo la sección de tarjetas, manteniendo el resto de la memoria intacta para una transición suave y eficiente.",
                        icon: FontAwesomeIcons.toggleOff,
                        borderRadius: 50,
                        child: _PlatformToggle(
                          selectedIndex: _selectedIndex,
                          onChanged: (i) => setState(() => _selectedIndex = i),
                        ),
                      ),

                      const SizedBox(height: 48),

                      // ── Cards grid ───────────────────────────────────────
                      InspectorGadget(
                        name: "Arquitectura Limpia",
                        techSpecs:
                            "Datos desacoplados. Los planes vienen de un repositorio de datos puro, separados completamente del diseño visual.",
                        icon: FontAwesomeIcons.tags,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 320),
                          switchInCurve: Curves.easeOutCubic,
                          switchOutCurve: Curves.easeInCubic,
                          layoutBuilder: (currentChild, previousChildren) {
                            return Stack(
                              alignment: Alignment.topCenter,
                              children: [
                                ...previousChildren,
                                if (currentChild != null) currentChild,
                              ],
                            );
                          },
                          transitionBuilder: (child, animation) {
                            final opacity = CurvedAnimation(
                              parent: animation,
                              curve: Curves.easeInOut,
                            );
                            final scale = Tween<double>(begin: 0.995, end: 1.0)
                                .animate(
                                  CurvedAnimation(
                                    parent: animation,
                                    curve: Curves.easeOutCubic,
                                  ),
                                );
                            return FadeTransition(
                              opacity: opacity,
                              child: ScaleTransition(
                                scale: scale,
                                child: child,
                              ),
                            );
                          },
                          child: _PlansGrid(
                            key: ValueKey<int>(_selectedIndex),
                            plans: currentPlans,
                            mousePos: _mousePos,
                          ),
                        ),
                      ),

                      const SizedBox(height: 64),

                      // ── Trust card ───────────────────────────────────────
                      InspectorGadget(
                        name: "Cálculo de Luz Dinámica",
                        techSpecs:
                            "Interacción física. Calculo el ángulo y distancia de tu cursor relativo a la tarjeta para simular un reflejo de luz realista sobre la superficie.",
                        icon: FontAwesomeIcons.shieldHalved,
                        borderRadius: 24,
                        child: _TrustCard(
                          mousePos: _mousePos,
                          selectedIndex: _selectedIndex,
                          onIndexChanged: (i) =>
                              setState(() => _selectedIndex = i),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 64),

            // ── Calculadora (full width, maneja su propio ancho) ──────────
            InspectorGadget(
              name: "Motor Algorítmico",
              techSpecs:
                  "Matemática reactiva. Uso 'Sets' para evitar duplicados y recalculo el presupuesto total en tiempo real cada vez que tocas un ítem, sin latencia.",
              icon: FontAwesomeIcons.calculator,
              borderRadius: 24,
              child: const EstimatorCalculator(),
            ),

            const SizedBox(height: 64),
            const Footer(),
          ],
        ),
      ),
    );
  }
}

// ── Responsive grid de planes ─────────────────────────────────────────────────

class _PlansGrid extends StatelessWidget {
  const _PlansGrid({super.key, required this.plans, required this.mousePos});

  final List<ServicePlan> plans;
  final ValueNotifier<Offset> mousePos;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 860;

        if (isDesktop) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < plans.length; i++) ...[
                if (i > 0) const SizedBox(width: 18),
                Expanded(
                  child: RepaintBoundary(
                    child: PlanCard(plan: plans[i], mousePos: mousePos),
                  ),
                ),
              ],
            ],
          );
        }

        // Tablet / mobile: columna centrada con ancho máximo
        return Column(
          children: [
            for (int i = 0; i < plans.length; i++) ...[
              if (i > 0) const SizedBox(height: 18),
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: RepaintBoundary(
                    child: PlanCard(plan: plans[i], mousePos: mousePos),
                  ),
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _TrustCard extends StatelessWidget {
  final ValueNotifier<Offset> mousePos;
  final int selectedIndex;
  final ValueChanged<int> onIndexChanged;

  const _TrustCard({
    required this.mousePos,
    required this.selectedIndex,
    required this.onIndexChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brandColor = theme.colorScheme.primary;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 900),
      child: ValueListenableBuilder<Offset>(
        valueListenable: mousePos,
        builder: (context, mouseOffset, child) {
          Offset localLightPos = Offset.zero;
          final renderObject = context.findRenderObject();
          if (renderObject is RenderBox && renderObject.hasSize) {
            localLightPos = renderObject.globalToLocal(mouseOffset);
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: RadialGradient(
                center: Alignment(
                  (localLightPos.dx /
                              (renderObject is RenderBox
                                  ? renderObject.size.width
                                  : 1)) *
                          2 -
                      1,
                  (localLightPos.dy /
                              (renderObject is RenderBox
                                  ? renderObject.size.height
                                  : 1)) *
                          2 -
                      1,
                ),
                radius: 2.5,
                colors: [brandColor, Colors.transparent],
                stops: const [0.0, 1.0],
              ),
            ),
            padding: const EdgeInsets.all(2),
            child: Container(
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Mini toggle — fijo, no anima con el contenido
                    Align(
                      alignment: Alignment.centerRight,
                      child: _PlatformToggle(
                        selectedIndex: selectedIndex,
                        onChanged: onIndexChanged,
                        compact: true,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Contenido animado al cambiar web/app
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 280),
                      switchInCurve: Curves.easeOutCubic,
                      switchOutCurve: Curves.easeInCubic,
                      layoutBuilder: (currentChild, previousChildren) {
                        return Stack(
                          alignment: Alignment.topLeft,
                          children: [
                            ...previousChildren,
                            if (currentChild != null) currentChild,
                          ],
                        );
                      },
                      transitionBuilder: (child, animation) {
                        final opacity = CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeInOut,
                        );
                        final scale = Tween<double>(begin: 0.998, end: 1.0)
                            .animate(
                              CurvedAnimation(
                                parent: animation,
                                curve: Curves.easeOutCubic,
                              ),
                            );
                        return FadeTransition(
                          opacity: opacity,
                          child: ScaleTransition(scale: scale, child: child),
                        );
                      },
                      child: _TrustCardBody(
                        key: ValueKey(selectedIndex),
                        isApp: selectedIndex == 1,
                        theme: theme,
                        isMobile: MediaQuery.of(context).size.width < 800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Contenido animado de la TrustCard ─────────────────────────────────────────

class _TrustCardBody extends StatelessWidget {
  const _TrustCardBody({
    super.key,
    required this.isApp,
    required this.theme,
    required this.isMobile,
  });

  final bool isApp;
  final ThemeData theme;
  final bool isMobile;

  @override
  Widget build(BuildContext context) {
    final brandColor = theme.colorScheme.primary;

    final iconMain = isApp
        ? FontAwesomeIcons.rocket
        : FontAwesomeIcons.laptopCode;
    final title = isApp
        ? "¿Por qué confiar en mí?"
        : "Ingeniería aplicada a la Web";
    final subtitle = isApp
        ? "Experiencia comprobada"
        : "Potencia y Optimización Real";
    final bodyText = isApp
        ? "Desarrollar una aplicación real va más allá de escribir código. Con Assistify, gestioné el ciclo completo del software, garantizando el éxito de tu proyecto desde la arquitectura hasta el despliegue en tiendas."
        : "Mi experiencia construyendo aplicaciones móviles complejas eleva el estándar de mis webs. No uso plantillas genéricas ni constructores lentos. Desarrollo soluciones 100% a medida, ultrarrápidas y optimizadas con la misma tecnología robusta que usan las grandes aplicaciones.";

    final chips = isApp
        ? [
            _chip(FontAwesomeIcons.shieldHalved, "Autenticación Segura & DB"),
            _chip(FontAwesomeIcons.puzzlePiece, "Integración de APIs"),
            _chip(
              FontAwesomeIcons.appStoreIos,
              "Despliegue App Store & Play Store",
            ),
            _chip(FontAwesomeIcons.palette, "Diseño UI/UX Completo"),
            _chip(FontAwesomeIcons.bell, "Notificaciones Push"),
            _chip(FontAwesomeIcons.wifi, "Modo Offline & Sync"),
            _chip(FontAwesomeIcons.bolt, "Datos en Tiempo Real"),
            _chip(FontAwesomeIcons.creditCard, "Pasarelas de Pago"),
            _chip(FontAwesomeIcons.chartLine, "Analíticas de Usuario"),
          ]
        : [
            _chip(FontAwesomeIcons.ban, "Sin Plantillas (100% Custom)"),
            _chip(FontAwesomeIcons.gaugeHigh, "Velocidad Extrema"),
            _chip(FontAwesomeIcons.layerGroup, "Código Limpio y Escalable"),
            _chip(FontAwesomeIcons.microchip, "Tecnología de Punta"),
            _chip(FontAwesomeIcons.magnifyingGlass, "SEO Técnico Avanzado"),
            _chip(FontAwesomeIcons.mobileScreen, "Diseño 100% Responsivo"),
            _chip(FontAwesomeIcons.lock, "Seguridad SSL/TLS"),
            _chip(FontAwesomeIcons.wandMagicSparkles, "Animaciones Fluidas"),
            _chip(FontAwesomeIcons.server, "Configuración de Hosting"),
          ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Fila icono + título + subtítulo
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: brandColor.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: FaIcon(iconMain, color: brandColor, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: brandColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(bodyText, style: theme.textTheme.bodyLarge),
        const SizedBox(height: 32),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: isMobile ? WrapAlignment.start : WrapAlignment.center,
          children: chips,
        ),
      ],
    );
  }

  Widget _chip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.10),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FaIcon(
            icon,
            size: 14,
            color: theme.colorScheme.primary.withValues(alpha: 0.75),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Toggle plataforma (compartido: normal + compact) ──────────────────────────

class _PlatformToggle extends StatelessWidget {
  const _PlatformToggle({
    required this.selectedIndex,
    required this.onChanged,
    this.compact = false,
  });

  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(50),
        border: Border.all(color: cs.outline.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleTab(
            icon: FontAwesomeIcons.globe,
            label: compact ? 'Web' : 'Desarrollo Web',
            selected: selectedIndex == 0,
            onTap: () => onChanged(0),
            compact: compact,
          ),
          const SizedBox(width: 4),
          _ToggleTab(
            icon: FontAwesomeIcons.mobileScreenButton,
            label: compact ? 'App' : 'Aplicaciones Móviles',
            selected: selectedIndex == 1,
            onTap: () => onChanged(1),
            compact: compact,
          ),
        ],
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  const _ToggleTab({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    required this.compact,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 12 : 22,
            vertical: compact ? 8 : 12,
          ),
          decoration: BoxDecoration(
            color: selected ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(40),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: cs.primary.withValues(alpha: 0.28),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              FaIcon(
                icon,
                size: compact ? 11 : 13,
                color: selected ? cs.onPrimary : cs.onSurfaceVariant,
              ),
              SizedBox(width: compact ? 6 : 8),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                style: TextStyle(
                  fontFamily: Theme.of(
                    context,
                  ).textTheme.labelLarge?.fontFamily,
                  fontWeight: FontWeight.bold,
                  fontSize: compact ? 12 : 14,
                  color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                ),
                child: Text(label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
