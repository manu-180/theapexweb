import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';

class ContactEngineCaseStudyModal extends StatelessWidget {
  const ContactEngineCaseStudyModal({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final accent = colorScheme.primary;
    final textTheme = theme.textTheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 760),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    accent.withOpacity(0.20),
                    accent.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(22),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: accent.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: accent.withOpacity(0.28)),
                    ),
                    child: Icon(
                      FontAwesomeIcons.crosshairs,
                      color: accent,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Contact Engine',
                          style: textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Encuentra clientes y convierte conversaciones en ventas, de forma automática.',
                          style: textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                  ),
                ],
              ),
            ),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(
                      'Objetivos de Negocio',
                      Icons.flag_rounded,
                      colorScheme,
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: const [
                        _ObjectiveChip(
                          label: 'Encontrar clientes todos los dias',
                        ),
                        _ObjectiveChip(label: 'Ahorrar tiempo operativo'),
                        _ObjectiveChip(label: 'Aumentar respuesta comercial'),
                        _ObjectiveChip(
                          label: 'Escalar sin contratar mas equipo',
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle(
                      'Como impacta en tu negocio',
                      Icons.bolt_rounded,
                      colorScheme,
                    ),
                    const SizedBox(height: 12),
                    const _FeatureItem(
                      'Prospeccion 24/7',
                      'Detecta negocios, prepara el contacto y activa el alcance incluso mientras tu equipo esta fuera de horario.',
                    ),
                    const _FeatureItem(
                      'Atencion en el canal correcto',
                      'Combina email y WhatsApp para que cada oportunidad reciba seguimiento por el canal con mayor respuesta.',
                    ),
                    const _FeatureItem(
                      'Operacion bajo control',
                      'Dashboard con estados, volumen de envios y conversaciones en un solo lugar para tomar decisiones rapidas.',
                    ),
                    const _FeatureItem(
                      'Modelo escalable para vender',
                      'Arquitectura multi-tenant lista para usarlo en tu marca o comercializarlo como servicio para terceros.',
                    ),
                    const SizedBox(height: 24),
                    _SectionTitle(
                      'Motor modular',
                      Icons.hub_rounded,
                      colorScheme,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest.withOpacity(
                          0.3,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: colorScheme.outline.withOpacity(0.18),
                        ),
                      ),
                      child: Column(
                        children: const [
                          _FlowRow(
                            icon: FontAwesomeIcons.magnifyingGlassLocation,
                            title: 'Finder',
                            description:
                                'Descubre contactos y oportunidades por nicho y ciudad.',
                          ),
                          SizedBox(height: 10),
                          _FlowRow(
                            icon: FontAwesomeIcons.envelopeOpenText,
                            title: 'Hunter',
                            description:
                                'Prepara datos y ejecuta outreach por email con seguimiento.',
                          ),
                          SizedBox(height: 10),
                          _FlowRow(
                            icon: FontAwesomeIcons.paperPlane,
                            title: 'Sender',
                            description:
                                'Gestiona cola de WhatsApp para sostener conversaciones activas.',
                          ),
                          SizedBox(height: 10),
                          _FlowRow(
                            icon: FontAwesomeIcons.chartLine,
                            title: 'Panel',
                            description:
                                'Visualiza, ajusta y optimiza todo el embudo comercial.',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: accent.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: accent.withOpacity(0.24),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.trending_up_rounded,
                            color: accent,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Contact Engine esta diseñado para transformar el alcance comercial en una maquina de oportunidades: mas conversaciones, mas reuniones y mas cierres.',
                              style: textTheme.bodyMedium?.copyWith(
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    Divider(color: colorScheme.outline.withOpacity(0.2)),
                    const SizedBox(height: 14),
                    FadeInUp(
                      child: Column(
                        children: [
                          Text(
                            'Quieres este nivel de captacion en tu negocio?',
                            style: textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          FilledButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              if (context.mounted) {
                                GoRouter.of(context).goNamed('contact');
                              }
                            },
                            icon: const Icon(
                              Icons.calendar_month_rounded,
                              size: 18,
                            ),
                            label: const Text('Agendar consulta gratis'),
                            style: FilledButton.styleFrom(
                              backgroundColor: accent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
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
          Icon(icon, color: colorScheme.secondary, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

class _ObjectiveChip extends StatelessWidget {
  final String label;
  const _ObjectiveChip({required this.label});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: theme.colorScheme.primary.withOpacity(0.22)),
      ),
      child: Text(
        label,
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(
              Icons.check_circle_rounded,
              size: 18,
              color: themeColor,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(height: 1.4),
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

class _FlowRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _FlowRow({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 15, color: theme.colorScheme.primary),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.35),
              children: [
                TextSpan(
                  text: '$title: ',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
                TextSpan(
                  text: description,
                  style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
