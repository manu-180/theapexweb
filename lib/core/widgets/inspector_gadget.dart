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
  final bool preferBelow; // Para controlar si el cartel sale arriba o abajo

  const InspectorGadget({
    super.key,
    required this.child,
    required this.name,
    required this.techSpecs,
    this.icon = FontAwesomeIcons.code,
    this.preferBelow = false, 
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isInspectorOn = ref.watch(inspectorModeProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // 1. Si el modo inspector está APAGADO, devolvemos el widget limpio.
    if (!isInspectorOn) return child;

    // --- CONFIGURACIÓN DE COLORES ---
    final bgColor = isDark 
        ? const Color(0xFF0F172A).withOpacity(0.95) 
        : Colors.white.withOpacity(0.98); 
        
    final accentColor = isDark 
        ? const Color(0xFF38BDF8)  // Cyan claro
        : const Color(0xFF0284C7); // Azul técnico

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final iconContentColor = isDark ? Colors.black : Colors.white;

    // 2. USAMOS TOOLTIP: El cartel solo aparece al pasar el mouse (Hover)
    return Tooltip(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: accentColor, width: 1.5), 
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(isDark ? 0.2 : 0.1), 
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(12),
      textStyle: TextStyle(color: textColor, fontFamily: 'monospace', fontSize: 12),
      richMessage: TextSpan(
        children: [
          TextSpan(
            text: "$name\n", 
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: accentColor)
          ),
          TextSpan(text: techSpecs),
        ],
      ),
      preferBelow: preferBelow, // Respetamos si pediste que salga abajo
      verticalOffset: 20, 
      waitDuration: const Duration(milliseconds: 100), // Aparece rápido
      
      // EL WIDGET VISIBLE (Borde + Contenido)
      child: Stack(
        children: [
          // A. BORDE VISUAL (Siempre visible si Inspector está ON)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12), 
                border: Border.all(
                  color: accentColor.withOpacity(0.5), 
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
                color: accentColor.withOpacity(0.05), // Tinte suave
              ),
            ),
          ),
          
          // B. EL CONTENIDO ORIGINAL
          child, 
          
          // C. EL ICONO BADGE (Esquina superior derecha)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8), 
                  topRight: Radius.circular(10) // Ajuste para coincidir con el borde
                ),
              ),
              child: Icon(icon, size: 12, color: iconContentColor),
            ),
          ),
        ],
      ),
    );
  }
}