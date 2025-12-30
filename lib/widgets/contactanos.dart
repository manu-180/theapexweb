// Archivo: lib/widgets/contactanos.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necesario para el Clipboard
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:apex/core/config/app_constants.dart'; // Importamos la fuente de verdad

class Contactanos extends StatefulWidget {
  const Contactanos({super.key});

  @override
  State<Contactanos> createState() => _ContactanosState();
}

class _ContactanosState extends State<Contactanos> {
  bool _isHovering = false;

  Future<void> _launchWhatsApp() async {
    // CORRECCIÓN: Usamos la constante centralizada
    const phoneNumber = AppConstants.whatsappNumber;
    const message = 'Hola, necesito ayuda con Assistify.';
    
    final uri = Uri.parse(
        'https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');

    try {
      // Intentamos abrir en modo aplicación externa (mejor para móviles y desktop apps)
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'No se pudo abrir WhatsApp';
      }
    } catch (e) {
      // --- FALLBACK A PRUEBA DE BALAS ---
      // Si falla (ej: en web con bloqueador de popups), copiamos al portapapeles y avisamos.
      if (mounted) {
        Clipboard.setData(const ClipboardData(text: phoneNumber));
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.copy, color: Colors.white, size: 16),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No pudimos abrir WhatsApp. Número copiado al portapapeles.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
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
          
          // Ancho dinámico (Píldora vs Círculo)
          width: _isHovering ? 160 : 60, 
          height: 60,
          
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: colorScheme.primary,
            borderRadius: BorderRadius.circular(30),
            
            // Borde sutil que aparece en hover
            border: Border.all(
              color: Colors.white.withOpacity(_isHovering ? 0.3 : 0.0),
              width: 1.5,
            ),
            boxShadow: [
              if (_isHovering)
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                )
            ],
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