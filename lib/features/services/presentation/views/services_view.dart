// Archivo: lib/features/services/presentation/views/services_view.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prueba_de_riverpod/features/services/data/repositories/plans_repository.dart';
import 'package:prueba_de_riverpod/features/services/presentation/widgets/plan_card.dart';
import 'package:prueba_de_riverpod/features/shared/widgets/footer.dart'; // Importante
import 'package:responsive_builder/responsive_builder.dart';

class ServicesView extends ConsumerStatefulWidget {
  final int initialIndex;
  
  const ServicesView({
    super.key,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends ConsumerState<ServicesView> {
  late int _selectedIndex;
  final ValueNotifier<Offset> _mousePos = ValueNotifier(Offset.zero);

  @override
  void initState() {
    super.initState();
    _selectedIndex = widget.initialIndex;
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
    final currentPlans = _selectedIndex == 0 ? plansRepo.webPlans : plansRepo.appPlans;
    final theme = Theme.of(context);

    return MouseRegion(
      onHover: (event) {
        _mousePos.value = event.position;
      },
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 48),
              child: Column(
                children: [
                  FadeInDown(
                    child: Text(
                      'Mis Servicios',
                      style: theme.textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FadeInDown(
                    delay: const Duration(milliseconds: 200),
                    child: Text(
                      'Soluciones tecnológicas diseñadas para escalar tu negocio',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // --- TOGGLE SWITCH ---
                  FadeIn(
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(50),
                        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildToggleItem("Desarrollo Web", 0),
                          const SizedBox(width: 4),
                          _buildToggleItem("Aplicaciones Móviles", 1),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 48),

                  // --- LISTA DE PLANES ---
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 500),
                    child: ScreenTypeLayout.builder(
                      key: ValueKey<int>(_selectedIndex), 
                      mobile: (context) => ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: currentPlans.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 32),
                        itemBuilder: (context, index) => Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(
                              maxWidth: 350,
                              maxHeight: 560,
                            ),
                            child: PlanCard(
                              plan: currentPlans[index],
                              mousePos: _mousePos,
                            ),
                          ),
                        ),
                      ),
                      desktop: (context) => Wrap(
                        spacing: 24,
                        runSpacing: 24,
                        alignment: WrapAlignment.center,
                        children: currentPlans.map((plan) => SizedBox(
                          width: 350,
                          height: 500, 
                          child: PlanCard(
                            plan: plan,
                            mousePos: _mousePos,
                          ),
                        )).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 60),
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: _TrustCard(
                      mousePos: _mousePos,
                      selectedIndex: _selectedIndex,
                    ),
                  ),
                ],
              ),
            ),
            
            // --- EL FOOTER VA AQUÍ (Al final de la columna principal) ---
            const SizedBox(height: 60),
            const Footer(),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleItem(String text, int index) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => setState(() => _selectedIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(40),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}

class _TrustCard extends StatelessWidget {
  final ValueNotifier<Offset> mousePos;
  final int selectedIndex;

  const _TrustCard({
    required this.mousePos,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isApp = selectedIndex == 1;
    final brandColor = theme.colorScheme.primary; 
    
    final iconMain = isApp ? FontAwesomeIcons.rocket : FontAwesomeIcons.laptopCode;
    final title = isApp ? "¿Por qué confiar en mí?" : "Ingeniería aplicada a la Web";
    final subtitle = isApp ? "Experiencia comprobada" : "Potencia y Optimización Real";
    
    final bodyText = isApp 
        ? "Desarrollar una aplicación real va más allá de escribir código. Con Assistify, gestioné el ciclo completo del software, garantizando el éxito de tu proyecto desde la arquitectura hasta el despliegue en tiendas."
        : "Mi experiencia construyendo aplicaciones móviles complejas eleva el estándar de mis webs. No uso plantillas genéricas ni constructores lentos. Desarrollo soluciones 100% a medida, ultrarrápidas y optimizadas con la misma tecnología robusta que usan las grandes aplicaciones.";

    final chips = isApp 
        ? [
            _buildChip(theme, FontAwesomeIcons.shieldHalved, "Autenticación Segura & DB"),
            _buildChip(theme, FontAwesomeIcons.puzzlePiece, "Integración de APIs"),
            _buildChip(theme, FontAwesomeIcons.appStoreIos, "Despliegue App Store & Play Store"),
            _buildChip(theme, FontAwesomeIcons.palette, "Diseño UI/UX Completo"),
            _buildChip(theme, FontAwesomeIcons.bell, "Notificaciones Push"),
            _buildChip(theme, FontAwesomeIcons.wifi, "Modo Offline & Sync"),
            _buildChip(theme, FontAwesomeIcons.bolt, "Datos en Tiempo Real"),
            _buildChip(theme, FontAwesomeIcons.creditCard, "Pasarelas de Pago"),
            _buildChip(theme, FontAwesomeIcons.chartLine, "Analíticas de Usuario"),
          ]
        : [
            _buildChip(theme, FontAwesomeIcons.ban, "Sin Plantillas (100% Custom)"),
            _buildChip(theme, FontAwesomeIcons.gaugeHigh, "Velocidad Extrema"),
            _buildChip(theme, FontAwesomeIcons.layerGroup, "Código Limpio y Escalable"),
            _buildChip(theme, FontAwesomeIcons.microchip, "Tecnología de Punta"),
            _buildChip(theme, FontAwesomeIcons.magnifyingGlass, "SEO Técnico Avanzado"),
            _buildChip(theme, FontAwesomeIcons.mobileScreen, "Diseño 100% Responsivo"),
            _buildChip(theme, FontAwesomeIcons.lock, "Seguridad SSL/TLS"),
            _buildChip(theme, FontAwesomeIcons.wandMagicSparkles, "Animaciones Fluidas"),
            _buildChip(theme, FontAwesomeIcons.server, "Configuración de Hosting"),
          ];

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
                  (localLightPos.dx / (renderObject is RenderBox ? renderObject.size.width : 1)) * 2 - 1,
                  (localLightPos.dy / (renderObject is RenderBox ? renderObject.size.height : 1)) * 2 - 1,
                ),
                radius: 2.5, 
                colors: [brandColor, Colors.transparent],
                stops: const [0.0, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: brandColor.withOpacity(0.1),
                  blurRadius: 30,
                  offset: const Offset(0, 10),
                ),
              ],
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
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: brandColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(iconMain, color: brandColor),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                title,
                                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                subtitle, 
                                style: theme.textTheme.bodyMedium?.copyWith(color: brandColor),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      bodyText,
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: chips,
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

  Widget _buildChip(ThemeData theme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurface),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              label, 
              style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600)
            ),
          ),
        ],
      ),
    );
  }
}