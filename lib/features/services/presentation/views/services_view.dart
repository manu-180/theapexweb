// Archivo: lib/features/services/presentation/views/services_view.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prueba_de_riverpod/features/services/data/repositories/plans_repository.dart';
import 'package:prueba_de_riverpod/features/services/presentation/widgets/plan_card.dart';
// Eliminamos la importación de responsive_builder ya que usaremos MediaQuery directo
// import 'package:responsive_builder/responsive_builder.dart'; 

class ServicesView extends ConsumerStatefulWidget {
  const ServicesView({super.key});

  @override
  ConsumerState<ServicesView> createState() => _ServicesViewState();
}

class _ServicesViewState extends ConsumerState<ServicesView> {
  final ValueNotifier<Offset> _mousePosNotifier = ValueNotifier(Offset.zero);

  @override
  void dispose() {
    _mousePosNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    final plansRepo = ref.watch(plansRepositoryProvider);
    final webPlans = plansRepo.webPlans;
    final videoPlans = plansRepo.videoPlans;

    // 1. Usamos MediaQuery para obtener el ancho de forma segura y estable
    final double screenWidth = MediaQuery.of(context).size.width;
    // 2. Definimos manualmente el breakpoint para evitar conflictos
    final bool isMobileOrTablet = screenWidth < 1100;

    return MouseRegion(
      onHover: (event) {
        _mousePosNotifier.value = event.position;
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1150),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FadeInDown(
                  child: Text(
                    'Planes de Desarrollo Web',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Soluciones a medida para potenciar tu marca y automatizar tu negocio.',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 20,
                      color: theme.colorScheme.onSurfaceVariant
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 60),

                // --- Layout Lógico Simplificado ---
                if (isMobileOrTablet) 
                  // MODO MÓVIL: Columna simple
                  Column(
                    children: [
                      PlanCard(plan: webPlans[0], mousePos: _mousePosNotifier),
                      const SizedBox(height: 32),
                      PlanCard(plan: webPlans[1], mousePos: _mousePosNotifier),
                      const SizedBox(height: 32),
                      PlanCard(plan: webPlans[2], mousePos: _mousePosNotifier),
                    ],
                  )
                else 
                  // MODO DESKTOP: Fila con altura intrínseca
                  IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: PlanCard(plan: webPlans[0], mousePos: _mousePosNotifier)),
                        const SizedBox(width: 32),
                        Expanded(child: PlanCard(plan: webPlans[1], mousePos: _mousePosNotifier)),
                        const SizedBox(width: 32),
                        Expanded(child: PlanCard(plan: webPlans[2], mousePos: _mousePosNotifier)),
                      ],
                    ),
                  ),

                const SizedBox(height: 100),

                FadeInDown(
                  child: Text(
                    'Contenido Viral con IA',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 16),
                FadeInDown(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Impulsa tus redes sociales con videos cortos optimizados para retener audiencia.',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 20,
                      color: theme.colorScheme.onSurfaceVariant
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 60),

                Wrap(
                  spacing: 32,
                  runSpacing: 32,
                  alignment: WrapAlignment.center,
                  children: videoPlans.map((plan) {
                    return ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 350),
                      child: SizedBox(
                        height: 480,
                        child: PlanCard(plan: plan, mousePos: _mousePosNotifier),
                      ),
                    );
                  }).toList(),
                ),
                
                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}