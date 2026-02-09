// Archivo: lib/features/services/presentation/widgets/plan_card.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/features/services/domain/models/plan_model.dart';
import 'package:apex/features/services/presentation/widgets/case_studies_modal.dart';
import 'package:apex/features/services/presentation/widgets/contact_modal.dart';

class PlanCard extends ConsumerStatefulWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.mousePos,
  });

  final ServicePlan plan;
  final ValueNotifier<Offset> mousePos;

  @override
  ConsumerState<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends ConsumerState<PlanCard> {
  bool _isHovering = false;

  void _onHover(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
    });
  }

  void _showCaseStudies() {
    if (widget.plan.caseStudies == null || widget.plan.caseStudies!.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CaseStudiesModal(
        caseStudies: widget.plan.caseStudies!,
        planName: widget.plan.name,
      ),
    );
  }

  void _onBuyPressed(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, _, __) => ContactModal(plan: widget.plan),
      transitionBuilder: (context, anim, __, child) {
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
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    final hasCases = widget.plan.caseStudies != null && widget.plan.caseStudies!.isNotEmpty;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      cursor: hasCases ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: ValueListenableBuilder<Offset>(
        valueListenable: widget.mousePos,
        builder: (context, mouseOffset, child) {
          Offset localLightPos = Offset.zero;
          
          final renderObject = context.findRenderObject();
          if (renderObject is RenderBox && renderObject.hasSize) {
            localLightPos = renderObject.globalToLocal(mouseOffset);
          }

          final borderGradient = RadialGradient(
            center: Alignment(
              (localLightPos.dx / (renderObject is RenderBox ? renderObject.size.width : 1)) * 2 - 1,
              (localLightPos.dy / (renderObject is RenderBox ? renderObject.size.height : 1)) * 2 - 1,
            ),
            radius: 1.5,
            colors: [
              primaryColor,
              Colors.transparent,
            ],
            stops: const [0.0, 1.0],
          );

          final surfaceColor = colorScheme.surface;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            transform: _isHovering ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: borderGradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_isHovering ? 0.2 : 0.05),
                  blurRadius: _isHovering ? 20 : 10,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: BoxDecoration(
                color: surfaceColor,
                borderRadius: BorderRadius.circular(13.5),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: hasCases ? _showCaseStudies : null,
                  borderRadius: BorderRadius.circular(13.5),
                  child: Padding(
                    // Reduje el padding general de 24 a 20 para hacerla más compacta
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        
                        // --- ZONA SCROLLABLE ---
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Nombre
                                FadeIn(
                                  child: Text(
                                    widget.plan.name,
                                    textAlign: TextAlign.center,
                                    style: theme.textTheme.headlineMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                      fontSize: 22, // Reduje un poco la fuente
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 6), // Reduje espacio

                                // Descripción
                                if (widget.plan.description.isNotEmpty)
                                  FadeIn(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                      child: Text(
                                        widget.plan.description,
                                        textAlign: TextAlign.center,
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: theme.colorScheme.onSurfaceVariant,
                                          fontSize: 13, // Fuente un poco más chica para ahorrar espacio
                                        ),
                                      ),
                                    ),
                                  ),
                                const SizedBox(height: 16),

                                // Casos de Éxito
                                if (hasCases) ...[
                                  const SizedBox(height: 10),
                                  Center(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: theme.colorScheme.surfaceContainerHighest,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.visibility, size: 12, color: theme.colorScheme.primary),
                                          const SizedBox(width: 6),
                                          Text(
                                            "Ver Ejemplos Reales",
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: theme.colorScheme.primary,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 16), // Reduje espacio

                                // Features
                                ...widget.plan.features.map((text) => FadeInUp(
                                  delay: const Duration(milliseconds: 100),
                                  child: Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0), // Reduje padding entre items
                                    child: Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Icon(Icons.check, size: 16, color: primaryColor), // Icono más chico
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            text, 
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              height: 1.2,
                                              fontSize: 13, // Texto un poco más compacto
                                            )
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                )),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // --- BOTÓN FIJO ---
                        FadeInUp(
                          delay: const Duration(milliseconds: 300),
                          child: FilledButton(
                            onPressed: () => _onBuyPressed(context),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16), // Botón un poco menos alto
                              textStyle: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            child: Text(widget.plan.isCustom ? 'Agendar Reunión' : 'Contratar Ahora'),
                          ),
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
}