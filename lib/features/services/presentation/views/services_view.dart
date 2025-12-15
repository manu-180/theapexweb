// Archivo: lib/features/services/presentation/views/services_view.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prueba_de_riverpod/features/services/data/repositories/plans_repository.dart';
import 'package:prueba_de_riverpod/features/services/presentation/widgets/plan_card.dart'; // <--- RUTA CORREGIDA
import 'package:responsive_builder/responsive_builder.dart';

class ServicesView extends ConsumerWidget {
  const ServicesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    // 1. Obtenemos los planes desde el provider del repositorio
    final plansRepo = ref.watch(plansRepositoryProvider);
    final webPlans = plansRepo.webPlans;
    final videoPlans = plansRepo.videoPlans;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1600),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- Título Planes Web ---
              FadeInDown(
                child: Text(
                  'Planes de Desarrollo Web',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Soluciones a medida para tu presencia digital, desde sitios de presentación hasta E-Commerce avanzados.',
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 40),

              // --- Layout Responsivo para Planes Web (3 items) ---
              ResponsiveBuilder(
                builder: (context, sizingInfo) {
                  if (sizingInfo.isMobile) {
                    // Columna en móvil
                    return Column(
                      children: [
                        PlanCard(plan: webPlans[0]),
                        const SizedBox(height: 24),
                        PlanCard(plan: webPlans[1]),
                        const SizedBox(height: 24),
                        PlanCard(plan: webPlans[2]),
                      ],
                    );
                  }
                  
                  // Fila en desktop/tablet
                  return IntrinsicHeight( // Hace que las cards tengan la misma altura
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: PlanCard(plan: webPlans[0])),
                        const SizedBox(width: 24),
                        Expanded(child: PlanCard(plan: webPlans[1])),
                        const SizedBox(width: 24),
                        Expanded(child: PlanCard(plan: webPlans[2])),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 80),

              // --- Título Planes de Video IA ---
              FadeInDown(
                child: Text(
                  'Planes de Creación de Contenido',
                  style: theme.textTheme.displaySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              FadeInDown(
                delay: const Duration(milliseconds: 200),
                child: Text(
                  'Impulsa tus redes sociales con videos cortos generados por IA, listos para publicar.',
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              const SizedBox(height: 40),

              // --- Layout en 'Wrap' para Planes de Video (múltiples items) ---
              // Wrap ajusta automáticamente los hijos a la siguiente línea si no caben.
              Wrap(
                spacing: 24, // Espacio horizontal entre cards
                runSpacing: 24, // Espacio vertical entre filas
                alignment: WrapAlignment.center,
                children: videoPlans.map((plan) {
                  // Damos un ancho fijo a las cards de video para que el 'Wrap' funcione
                  return ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 380),
                    child: SizedBox(
                      height: 500, // Altura fija para alinear
                      child: PlanCard(plan: plan),
                    ),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 80),
              // TODO: Añadir el reproductor de video de Cloudflare
            ],
          ),
        ),
      ),
    );
  }
}