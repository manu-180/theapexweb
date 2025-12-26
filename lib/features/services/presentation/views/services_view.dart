// Archivo: lib/features/services/presentation/views/services_view.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prueba_de_riverpod/features/services/data/repositories/plans_repository.dart';
import 'package:prueba_de_riverpod/features/services/presentation/widgets/plan_card.dart';
import 'package:responsive_builder/responsive_builder.dart';

class ServicesView extends ConsumerStatefulWidget {
  const ServicesView({super.key});

  @override
  ConsumerState<ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends ConsumerState<ServicesView> {
  // 0 = Web, 1 = Apps
  int _selectedIndex = 0; 
  final ValueNotifier<Offset> _mousePos = ValueNotifier(Offset.zero);

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
                  separatorBuilder: (_, __) => const SizedBox(height: 24),
                  itemBuilder: (context, index) => PlanCard(
                    plan: currentPlans[index],
                    mousePos: _mousePos,
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

            // --- TARJETA DE EXPERIENCIA (ASSISTIFY) ---
            if (_selectedIndex == 1) ...[
              const SizedBox(height: 60),
              FadeInUp(
                delay: const Duration(milliseconds: 400),
                child: _TrustCard(mousePos: _mousePos),
              ),
            ],
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

// --- WIDGET DE EXPERIENCIA (ASSISTIFY) ---
class _TrustCard extends StatelessWidget {
  final ValueNotifier<Offset> mousePos;

  const _TrustCard({required this.mousePos});

  // Función para mostrar el modal con animación
  void _showAssistifyModal(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 250),
      // AQUÍ: Reemplaza 'const AssistifyModal()' por tu propio widget de modal
      pageBuilder: (context, _, __) => const AssistifyModal(), 
      transitionBuilder: (context, anim, __, child) {
        // Animación de escala y opacidad (Pop-up suave)
        return Transform.scale(
          scale: Curves.easeOutBack.transform(anim.value),
          child: Opacity(
            opacity: anim.value,
            child: child,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const brandColor = Color(0xFF00A8E8); 

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 800),
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
              child: Material( // Necesario para el InkWell
                color: Colors.transparent,
                child: InkWell(
                  onTap: () => _showAssistifyModal(context), // Llama a la función de animación
                  borderRadius: BorderRadius.circular(22),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      children: [
                        // Header
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: brandColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(FontAwesomeIcons.rocket, color: brandColor),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "¿Por qué confiar en mí?",
                                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    "Experiencia comprobada", 
                                    style: theme.textTheme.bodyMedium?.copyWith(color: brandColor),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        
                        // Cuerpo del texto
                        Text(
                          "Desarrollar una aplicación real va más allá de escribir código. Con Assistify, gestioné el ciclo completo del software, lo que me permite garantizar el éxito de tu proyecto:",
                          style: theme.textTheme.bodyLarge,
                        ),
                        const SizedBox(height: 24),

                        // Chips
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _buildChip(theme, FontAwesomeIcons.shieldHalved, "Autenticación Segura & DB"),
                            _buildChip(theme, FontAwesomeIcons.puzzlePiece, "Integración de cualquier API"),
                            _buildChip(theme, FontAwesomeIcons.appStoreIos, "Despliegue en AppStore & PlayStore"),
                            _buildChip(theme, FontAwesomeIcons.palette, "Diseño UI/UX Completo"),
                          ],
                        ),
                      ],
                    ),
                  ),
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

// --- MODAL DE EJEMPLO (Reemplázalo por el tuyo) ---
class AssistifyModal extends StatelessWidget {
  const AssistifyModal({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        padding: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 400),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Caso de Éxito: Assistify", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text("Aquí iría el detalle completo de tu caso de éxito, con imágenes, estadísticas y testimonios."),
            const SizedBox(height: 24),
            FilledButton(onPressed: () => Navigator.pop(context), child: const Text("Cerrar"))
          ],
        ),
      ),
    );
  }
}