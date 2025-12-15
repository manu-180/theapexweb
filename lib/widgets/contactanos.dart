// Archivo: lib/widgets/contactanos.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Contactanos extends StatefulWidget {
  const Contactanos({super.key});

  @override
  State<Contactanos> createState() => _ContactanosState();
}

class _ContactanosState extends State<Contactanos> {
  bool _isHovering = false;

  Future<void> _launchWhatsApp() async {
    const phoneNumber = '5491134272488';
    const message = 'Hola, necesito ayuda con Assistify.';
    
    final uri = Uri.parse(
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'No se pudo abrir WhatsApp';
      }
    } catch (e) {
      debugPrint('Error al abrir WhatsApp: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: _launchWhatsApp,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutExpo,
          
          // SIN TRANSFORM (Eliminada la elevación/levitación)
          
          // Ancho dinámico (Píldora vs Círculo)
          width: _isHovering ? 160 : 60, 
          height: 60,
          
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(30),
            
            // Borde sutil que aparece en hover para resaltar sin usar sombras
            border: Border.all(
              color: Colors.white.withOpacity(_isHovering ? 0.3 : 0.0),
              width: 1.5,
            ),
            
            // SIN SOMBRAS (Diseño Flat puro)
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                FontAwesomeIcons.whatsapp,
                color: colorScheme.onPrimary,
                size: 28,
              ),
              
              // Texto desplegable
              AnimatedSize(
                duration: const Duration(milliseconds: 400),
                curve: Curves.easeOutExpo,
                child: SizedBox(
                  width: _isHovering ? null : 0, 
                  child: Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      "¡Escribime!",
                      overflow: TextOverflow.clip,
                      maxLines: 1,
                      softWrap: false,
                      style: textTheme.labelLarge?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}