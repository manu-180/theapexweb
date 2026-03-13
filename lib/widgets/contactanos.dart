// Archivo: lib/widgets/contactanos.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:apex/core/utils/whatsapp_launcher.dart';

class Contactanos extends StatefulWidget {
  const Contactanos({super.key});

  @override
  State<Contactanos> createState() => _ContactanosState();
}

class _ContactanosState extends State<Contactanos> {
  bool _isHovering = false;

  Future<void> _launchWhatsApp() async {
    await WhatsAppLauncher.open(
      context: context,
      message: 'Hola, estoy buscando un desarrollador para llevar a cabo un proyecto digital y me gustaría saber más sobre tus servicios.',
    );
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