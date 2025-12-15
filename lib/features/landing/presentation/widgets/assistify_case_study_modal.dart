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
                  Image.asset(
                    'assets/icons/logo_assistify.png',
                    height: 48,
                    filterQuality: FilterQuality.medium,
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
                    _SectionTitle('El Problema', Icons.warning_amber_rounded, colorScheme),
                    const SizedBox(height: 8),
                    // --- TEXTO REESCRITO ---
                    Text(
                      'Cuando un alumno cancela, el profesor pierde tiempo valioso revisando manualmente toda su agenda para encontrar huecos libres, ofrecerlos y esperar respuestas (que a menudo son negativas), reiniciando un ciclo interminable de mensajes.',
                      style: textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 24),

                    _SectionTitle('La Solución', Icons.lightbulb_outline, colorScheme),
                    const SizedBox(height: 12),
                    
                    _FeatureItem(
                      'Adiós a la "Agenda de Papel"',
                      'Control total desde el celular. Creación de horarios, gestión de alumnos y visualización completa del mes de un vistazo.',
                    ),
                    _FeatureItem(
                      'Sistema Justo de Créditos',
                      'Si un alumno cancela a tiempo, recibe un "Crédito" para reagendarse él mismo buscando su propio hueco en la app. El profesor se olvida de coordinar recuperatorios.',
                    ),
                    _FeatureItem(
                      'Lista de Espera Inteligente',
                      'Si se libera un lugar, la app avisa y ocupa el hueco automáticamente con alumnos en espera. Cero horas muertas.',
                    ),
                    _FeatureItem(
                      'Notificaciones Automáticas',
                      'Integración con WhatsApp para avisar cambios o inscripciones al instante. Ni el profesor ni el alumno necesitan entrar a la app para estar al tanto de todo.',
                    ),
                     _FeatureItem(
                      'Diseño Intuitivo',
                      'Interfaz pensada para que cualquier profesor, independientemente de su nivel tecnológico, pueda usarla desde el primer día.',
                    ),

                    const SizedBox(height: 24),
                    _SectionTitle('Resultados', Icons.trending_up, colorScheme),
                    const SizedBox(height: 8),
                    Text(
                      'Una herramienta que ahorra horas de gestión administrativa al mes y elimina la fricción con los alumnos al momento de recuperar clases. Disponible hoy mismo en las tiendas.',
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
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: themeColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.check_rounded, size: 16, color: themeColor),
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