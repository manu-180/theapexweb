// Archivo: lib/features/estimator/presentation/widgets/estimator_calculator.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:apex/core/config/app_constants.dart';
import 'package:apex/features/estimator/data/repositories/estimator_repository.dart';
import 'package:apex/features/estimator/domain/models/estimator_item_model.dart';
import 'package:apex/features/estimator/presentation/providers/estimator_provider.dart';

class EstimatorCalculator extends ConsumerWidget {
  const EstimatorCalculator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final state = ref.watch(estimatorNotifierProvider);
    final notifier = ref.read(estimatorNotifierProvider.notifier);
    final repo = ref.watch(estimatorRepositoryProvider);
    final items = repo.getItems(state.selectedType);

    return Container(
      constraints: const BoxConstraints(maxWidth: 800),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- HEADER & SELECTOR ---
          Padding(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              children: [
                Text(
                  "Arma tu Proyecto a Medida",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w900, 
                    color: colorScheme.primary,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  "Selecciona los módulos que necesitas. Precios optimizados para emprendedores.",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                
                // SEGMENTED CONTROL
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _SegmentButton(
                        label: "Sitio Web",
                        icon: FontAwesomeIcons.globe,
                        isSelected: state.selectedType == ServiceType.web,
                        onTap: () => notifier.setType(ServiceType.web),
                      ),
                      const SizedBox(width: 4),
                      _SegmentButton(
                        label: "Aplicación Móvil",
                        icon: FontAwesomeIcons.mobileScreen,
                        isSelected: state.selectedType == ServiceType.app,
                        onTap: () => notifier.setType(ServiceType.app),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // --- LISTA DE ITEMS ---
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), 
              padding: const EdgeInsets.all(24),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = state.selectedItemIds.contains(item.id);
                
                return FadeInUp(
                  delay: Duration(milliseconds: index * 50), 
                  child: _EstimatorItemCard(
                    item: item,
                    isSelected: isSelected,
                    onToggle: () => notifier.toggleItem(item),
                  ),
                );
              },
            ),
          ),

          // --- RESUMEN FINAL ---
          _EstimatorSummaryBar(state: state, allItems: items),
        ],
      ),
    );
  }
}

// ==========================================
// WIDGETS PRIVADOS
// ==========================================

class _SegmentButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SegmentButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Expanded(
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? colorScheme.surface : Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              boxShadow: isSelected 
                ? [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)] 
                : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon, 
                  size: 16, 
                  color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant
                ),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isSelected ? colorScheme.primary : colorScheme.onSurfaceVariant,
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

class _EstimatorItemCard extends StatelessWidget {
  final EstimatorItem item;
  final bool isSelected;
  final VoidCallback onToggle;

  const _EstimatorItemCard({
    required this.item,
    required this.isSelected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currency = NumberFormat.currency(locale: 'es_AR', symbol: '\$', decimalDigits: 0);
    
    final hasDiscount = item.originalPrice != null && item.originalPrice! > item.price;

    return MouseRegion(
      cursor: item.isCore ? SystemMouseCursors.basic : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: item.isCore ? null : onToggle,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected 
                ? colorScheme.primary.withOpacity(0.08) 
                : colorScheme.surfaceContainerLow.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected 
                  ? colorScheme.primary 
                  : Colors.transparent,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              // CHECKBOX
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? colorScheme.primary : Colors.transparent,
                  border: Border.all(
                    color: isSelected ? colorScheme.primary : colorScheme.outline.withOpacity(0.4),
                    width: 2,
                  ),
                ),
                child: isSelected 
                    ? Icon(Icons.check, size: 14, color: colorScheme.onPrimary)
                    : null,
              ),
              const SizedBox(width: 16),
              
              // TEXTOS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            item.label,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        if (item.isCore) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "BASE",
                              style: TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: colorScheme.primary),
                            ),
                          ),
                        ]
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.description,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // PRECIO (CON DESCUENTO)
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (hasDiscount)
                    Text(
                      currency.format(item.originalPrice),
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        decorationColor: colorScheme.onSurface.withOpacity(0.4),
                        color: colorScheme.onSurface.withOpacity(0.4),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  Text(
                    currency.format(item.price),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      // COLOR DINÁMICO DEL TEMA SI TIENE DESCUENTO
                      color: hasDiscount ? colorScheme.primary : colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EstimatorSummaryBar extends StatelessWidget {
  final EstimatorState state;
  final List<EstimatorItem> allItems;

  const _EstimatorSummaryBar({required this.state, required this.allItems});

  Future<void> _launchWhatsApp(BuildContext context) async {
    final selectedLabels = allItems
        .where((item) => state.selectedItemIds.contains(item.id))
        .map((item) => "✅ ${item.label}")
        .join("\n");

    final typeLabel = state.selectedType == ServiceType.web ? "WEB" : "APP";
    final currency = NumberFormat.currency(locale: 'es_AR', symbol: '\$', decimalDigits: 0);
    final totalStr = currency.format(state.totalEstimate);

    final message = 
      "Hola Manuel! 👋\n\n"
      "Armé mi proyecto *$typeLabel* a medida en tu web:\n\n"
      "$selectedLabels\n\n"
      "💰 *Estimado: $totalStr*\n\n"
      "¿Cuándo podemos tener una reunión?";

    final uri = Uri.parse("https://wa.me/${AppConstants.whatsappNumber}?text=${Uri.encodeComponent(message)}");

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'Error WhatsApp';
      }
    } catch (e) {
      if (context.mounted) {
        Clipboard.setData(ClipboardData(text: AppConstants.whatsappNumber));
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('Error al abrir WhatsApp. Número copiado.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currency = NumberFormat.currency(locale: 'es_AR', symbol: '\$', decimalDigits: 0);
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // FILA SUPERIOR: Precios y Botón
          Flex(
            direction: isMobile ? Axis.vertical : Axis.horizontal,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: isMobile ? CrossAxisAlignment.stretch : CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start,
                children: [
                  Text(
                    "INVERSIÓN ESTIMADA",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                  TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0, end: state.totalEstimate),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutQuart,
                    builder: (context, value, child) {
                      return Text(
                        currency.format(value),
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: colorScheme.primary,
                        ),
                      );
                    },
                  ),
                ],
              ),
              
              if (isMobile) const SizedBox(height: 20),

              FilledButton.icon(
                onPressed: () => _launchWhatsApp(context),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 18),
                  elevation: 4,
                  shadowColor: const Color(0xFF25D366).withOpacity(0.4),
                ),
                icon: const Icon(FontAwesomeIcons.whatsapp, size: 20),
                label: const Text(
                  "Validar Idea",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // FILA INFERIOR: Aviso de Garantía (NUEVO)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: colorScheme.primary.withOpacity(0.2)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_user_outlined, size: 16, color: colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  "Incluye 3 meses de soporte técnico y mantenimiento gratuito.",
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          Text(
            "* Los valores son aproximados. Requiere evaluación técnica final.",
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withOpacity(0.5),
              fontStyle: FontStyle.italic,
              fontSize: 11,
            ),
          )
        ],
      ),
    );
  }
}