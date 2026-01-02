// Archivo: lib/core/widgets/inspector_gadget.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:apex/core/providers/inspector_provider.dart';

class InspectorGadget extends ConsumerWidget {
  final Widget child;
  final String name;      
  final String techSpecs; 
  final IconData icon;
  // Ya no necesitamos preferBelow porque ahora es una etiqueta fija

  const InspectorGadget({
    super.key,
    required this.child,
    required this.name,
    required this.techSpecs,
    this.icon = FontAwesomeIcons.code,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInspectorOn = ref.watch(inspectorModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 1. Si está apagado, devolvemos el hijo limpio
    if (!isInspectorOn) return child;

    // --- PALETA DE COLORES ADAPTATIVA ---
    final accentColor = isDark 
        ? const Color(0xFF38BDF8)  // Cyan claro
        : const Color(0xFF0284C7); // Azul técnico

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final bgColor = isDark 
        ? const Color(0xFF0F172A).withOpacity(0.90) 
        : Colors.white.withOpacity(0.95);

    return Stack(
      children: [
        // A. EL WIDGET ORIGINAL
        // Lo envolvemos en un Container con borde para marcar el área
        Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: accentColor.withOpacity(0.5), 
              width: 1.5,
            ),
            color: accentColor.withOpacity(0.05), // Tinte suave fondo
            borderRadius: BorderRadius.circular(12),
          ),
          child: child,
        ),
        
        // B. LA ETIQUETA TÉCNICA (HUD)
        // Usamos Positioned para pegarlo abajo del widget.
        // Usamos IgnorePointer para que si la etiqueta tapa un botón, 
        // ¡todavía puedas hacer clic en el botón a través del texto!
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: IgnorePointer( 
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: bgColor,
                border: Border(
                  top: BorderSide(color: accentColor, width: 1.5), // Línea separadora
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(10), // Ajuste -2px del borde padre
                  bottomRight: Radius.circular(10),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Título con Icono
                  Row(
                    children: [
                      Icon(icon, size: 10, color: accentColor),
                      const SizedBox(width: 6),
                      Text(
                        name.toUpperCase(), 
                        style: TextStyle(
                          fontWeight: FontWeight.w900, 
                          fontSize: 10, 
                          color: accentColor,
                          letterSpacing: 1.0,
                        )
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  // Specs
                  Text(
                    techSpecs,
                    style: TextStyle(
                      color: textColor, 
                      fontFamily: 'monospace', 
                      fontSize: 10,
                      height: 1.2
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),

        // C. INDICADOR DE ESQUINA (Opcional, decorativo)
        Positioned(
          top: 0,
          right: 0,
          child: Container(
            width: 10, 
            height: 10,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: accentColor, width: 2),
                right: BorderSide(color: accentColor, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}