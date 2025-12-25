// Archivo: lib/features/landing/presentation/widgets/assistify_case_study_modal.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AssistifyCaseStudyModal extends StatelessWidget {
  const AssistifyCaseStudyModal({super.key});

  Future<void> _launchStore(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('No se pudo abrir el enlace de la tienda: $url. Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // --- HEADER ---
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  // --- IMAGEN OPTIMIZADA ---
                  Image.asset(
                    'assets/icons/logo_assistify.png',
                    height: 48,
                    width: 48,
                    fit: BoxFit.contain,
                    // TRUCO PRO 1: High usa interpolación bicúbica (más suave y nítida)
                    filterQuality: FilterQuality.high, 
                    // TRUCO PRO 2: Suaviza los bordes serrados
                    isAntiAlias: true, 
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Assistify: Gestión para Profesores',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Aplicación en Producción • iOS & Android',
                          style: textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),

            // --- BODY SCROLLEABLE ---
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle('El Dolor (Problema)', Icons.warning_amber_rounded, colorScheme),
                    const SizedBox(height: 8),
                    Text(
                      'Coordinar cambios de horario por WhatsApp es un trabajo no remunerado que consume horas. Además, cuando un alumno cancela sobre la hora, ese "hueco" suele quedar vacío, lo que significa dinero perdido irreuperable para el profesor.',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    _SectionTitle('La Solución', Icons.lightbulb_outline, colorScheme),
                    const SizedBox(height: 12),
                    
                    // --- FEATURES MEJORADOS ---
                    const _FeatureItem(
                      'Autogestión Total',
                      'El alumno cancela y busca su propio horario de recuperación desde la App. Elimina el 100% de la carga operativa manual.',
                    ),
                    const _FeatureItem(
                      'Ingresos Blindados',
                      'El sistema de Créditos y Listas de Espera rellena automáticamente los huecos libres. Tu agenda (y tu bolsillo) siempre llenos.',
                    ),
                    const _FeatureItem(
                      'Cero Fricción (WhatsApp)',
                      'Si hay un cambio, Assistify te avisa por WhatsApp automáticamente. No necesitas entrar a la App para estar informado.',
                    ),
                     const _FeatureItem(
                      'Control Operativo Total',
                      'Crea clases, ajusta cupos en tiempo real y administra el padrón de alumnos con total libertad. Tu academia bajo control.',
                    ),

                    const SizedBox(height: 24),
                    _SectionTitle('Resultados', Icons.trending_up, colorScheme),
                    const SizedBox(height: 8),
                    Text(
                      'Una herramienta que elimina el 90% de la carga administrativa y mejora la relación con los alumnos al ofrecerles flexibilidad inmediata. Disponible hoy mismo.',
                      style: textTheme.bodyMedium,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    const Center(child: Text("Disponible para descargar en:", style: TextStyle(fontWeight: FontWeight.bold))),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      alignment: WrapAlignment.center,
                      children: [
                        _StoreButton(
                          icon: FontAwesomeIcons.googlePlay,
                          label: 'Google Play',
                          color: const Color(0xFF01875F), 
                          onTap: () => _launchStore('https://play.google.com/store/apps/details?id=com.manuelnavarro.tallerdeceramica'),
                        ),
                        _StoreButton(
                          icon: FontAwesomeIcons.appStoreIos,
                          label: 'App Store',
                          color: const Color(0xFF0D96F6), 
                          onTap: () => _launchStore('https://apps.apple.com/app/assistify/id6745438721'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StoreButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _StoreButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
      ),
      icon: Icon(icon, size: 22, color: color), 
      label: Text(
        label,
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final IconData icon;
  final ColorScheme colorScheme;

  const _SectionTitle(this.title, this.icon, this.colorScheme);

  @override
  Widget build(BuildContext context) {
    return FadeInLeft(
      duration: const Duration(milliseconds: 500),
      child: Row(
        children: [
          Icon(icon, color: colorScheme.secondary, size: 24),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  final String title;
  final String description;

  const _FeatureItem(this.title, this.description);

  @override
  Widget build(BuildContext context) {
    final themeColor = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2.0), 
            child: Icon(Icons.check, size: 20, color: themeColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.4),
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: description),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}