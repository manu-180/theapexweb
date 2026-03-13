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
  final bool preferBelow; 
  final double borderRadius; 

  const InspectorGadget({
    super.key,
    required this.child,
    required this.name,
    required this.techSpecs,
    this.icon = FontAwesomeIcons.code,
    this.preferBelow = false, 
    this.borderRadius = 12.0, 
  });

  static const _inspectorEnabled = bool.fromEnvironment(
    'ENABLE_INSPECTOR',
    defaultValue: false,
  );

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!_inspectorEnabled) return child;

    final isInspectorOn = ref.watch(inspectorModeProvider);
    if (!isInspectorOn) return child;

    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // 2. Detección de Plataforma (Mobile vs Desktop)
    // Usamos el breakpoint estándar de 800px que tienes en ResponsiveBuilder
    final isMobile = MediaQuery.of(context).size.width < 800;

    // --- CONFIGURACIÓN DE COLORES (Compartida) ---
    final bgColor = isDark 
        ? const Color(0xFF0F172A).withOpacity(0.95) 
        : Colors.white.withOpacity(0.98); 
        
    final accentColor = isDark 
        ? const Color(0xFF38BDF8)  
        : const Color(0xFF0284C7); 

    final textColor = isDark ? Colors.white : const Color(0xFF0F172A);
    final iconContentColor = isDark ? Colors.black : Colors.white;

    // --- COMPONENTE VISUAL 1: EL CONTENEDOR DECORADO (Borde + Icono) ---
    final gadgetVisuals = Stack(
      children: [
        // A. Borde Visual
        Positioned.fill(
          child: IgnorePointer( 
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(borderRadius),
                border: Border.all(
                  color: accentColor.withOpacity(0.5), 
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
                color: accentColor.withOpacity(0.05),
              ),
            ),
          ),
        ),
        
        // B. Contenido Original
        child, 
        
        // C. Badge Identificador
        Positioned(
          top: 0,
          right: 0,
          child: IgnorePointer(
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: const Radius.circular(8), 
                  topRight: Radius.circular(borderRadius), 
                ),
              ),
              child: Icon(icon, size: 12, color: iconContentColor),
            ),
          ),
        ),
      ],
    );

    // --- LÓGICA MÓVIL: Mostrar descripción explícita e inmediata ---
    if (isMobile) {
      final infoBox = Container(
        margin: EdgeInsets.only(
          top: preferBelow ? 8 : 0,
          bottom: preferBelow ? 0 : 8,
        ),
        padding: const EdgeInsets.all(12),
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
        child: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: "$name\n", 
                style: TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: accentColor, fontFamily: 'monospace')
              ),
              TextSpan(
                text: techSpecs,
                style: TextStyle(color: textColor, fontFamily: 'monospace', fontSize: 12),
              ),
            ],
          ),
        ),
      );

      // En móvil, inyectamos la info en el layout verticalmente
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: preferBelow 
            ? [gadgetVisuals, infoBox] 
            : [infoBox, gadgetVisuals],
      );
    }

    // --- LÓGICA DESKTOP: Tooltip Hover (Comportamiento original) ---
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
      preferBelow: preferBelow,
      verticalOffset: 20, 
      waitDuration: const Duration(milliseconds: 100),
      
      child: gadgetVisuals,
    );
  }
}