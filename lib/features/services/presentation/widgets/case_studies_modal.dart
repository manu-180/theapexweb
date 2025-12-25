// Archivo: lib/features/services/presentation/widgets/case_studies_modal.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prueba_de_riverpod/features/services/domain/models/case_study_model.dart';
import 'package:url_launcher/url_launcher.dart';

class CaseStudiesModal extends StatelessWidget {
  final List<CaseStudy> caseStudies;
  final String planName;

  const CaseStudiesModal({
    super.key,
    required this.caseStudies,
    required this.planName,
  });

  Future<void> _launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Error launching URL: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      // Altura dinámica pero limitada para que no tape toda la pantalla en desktop
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.8,
        maxWidth: 600, // En escritorio se verá centrado y no estirado
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // --- Handle (Barrita gris para arrastrar) ---
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: theme.colorScheme.onSurface.withOpacity(0.1),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 24),

          // --- Título ---
          Text(
            'Casos de Éxito',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Proyectos reales desarrollados con el plan "$planName"',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 32),

          // --- Lista de Tarjetas ---
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: caseStudies.length,
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemBuilder: (context, index) {
                final project = caseStudies[index];
                
                return InkWell(
                  onTap: () => _launchURL(project.url),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 80,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      // Degradado sutil basado en el color de la marca
                      gradient: LinearGradient(
                        colors: [
                          project.brandColor.withOpacity(0.15),
                          project.brandColor.withOpacity(0.05),
                        ],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      border: Border.all(
                        color: project.brandColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    child: Row(
                      children: [
                        // --- Logo del Proyecto ---
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: Colors.white, // Fondo blanco para que el logo resalte
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ],
                          ),
                          padding: const EdgeInsets.all(8), // Padding interno para el logo
                          child: Image.asset(
                            project.logoAsset,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.broken_image, 
                              color: theme.colorScheme.onSurface,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // --- Nombre y URL ---
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                project.name,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.link, size: 12, color: project.brandColor),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      project.url.replaceFirst('https://', ''),
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // --- Icono de Flecha ---
                        Icon(
                          FontAwesomeIcons.chevronRight, 
                          size: 16, 
                          color: project.brandColor.withOpacity(0.8),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}