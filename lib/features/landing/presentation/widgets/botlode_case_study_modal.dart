// Archivo: lib/features/landing/presentation/widgets/botlode_case_study_modal.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class BotlodeCaseStudyModal extends StatelessWidget {
  const BotlodeCaseStudyModal({super.key});

  static const _botlodeGold = Color(0xFFFFC000);
  static const _urlBotlode = 'https://botlode.com';
  static const _urlBotrive = 'https://botrive.com';

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('No se pudo abrir: $url. Error: $e');
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
                color: _botlodeGold.withOpacity(0.12),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/icons/logo_botlode.png',
                      height: 48,
                      width: 48,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      isAntiAlias: true,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 48,
                          width: 48,
                          decoration: BoxDecoration(
                            color: _botlodeGold.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(FontAwesomeIcons.robot, color: _botlodeGold, size: 26),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BotLode: Ecosistema de Bots IA',
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        Text(
                          'Fábrica • Player • History • 24/7',
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
                    _SectionTitle('Los 3 Pilares', Icons.hub_rounded, colorScheme),
                    const SizedBox(height: 12),
                    _PillarRow(
                      icon: Icons.factory_outlined,
                      label: 'La Fábrica',
                      desc: 'Crea bots ilimitados con un clic. Sin código.',
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    _PillarRow(
                      icon: FontAwesomeIcons.robot,
                      label: 'Cat Bot Player',
                      desc: '6 modos, IA conversacional, modo vendedor.',
                      color: colorScheme.primary,
                      useFaIcon: true,
                    ),
                    const SizedBox(height: 8),
                    _PillarRow(
                      icon: Icons.analytics_outlined,
                      label: 'Command Center History',
                      desc: 'Leads, alertas por email, calendario de reuniones.',
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 24),

                    _SectionTitle('BotLode Factory', Icons.factory_rounded, colorScheme),
                    const SizedBox(height: 8),
                    Text(
                      'Plataforma para que cualquiera pueda crear y comercializar sus propios bots con IA. Cada bot es un empleado virtual listo para trabajar 24/7 en cualquier sitio web. Creación instantánea, personalización total y cero código. Producto listo para vender, sin inversión inicial.',
                      style: textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 24),

                    _SectionTitle('Cat Bot', FontAwesomeIcons.robot, colorScheme),
                    const SizedBox(height: 12),
                    const _FeatureItem(
                      '6 modos',
                      'Feliz, Enojado, Técnico, Confundido, Neutro y Vendedor. El bot adapta su personalidad y respuestas según el contexto.',
                    ),
                    const _FeatureItem(
                      'Modo vendedor',
                      'Recopila datos de interés (emails, teléfonos, necesidades) y los muestra en el historial para seguimiento.',
                    ),
                    const _FeatureItem(
                      'Experiencia inmersiva',
                      'Seguimiento de mouse, detección de WiFi e IA conversacional. Un bot que parece vivo y conecta con tus clientes.',
                    ),
                    const SizedBox(height: 24),

                    _SectionTitle('BotLode History', Icons.analytics_rounded, colorScheme),
                    const SizedBox(height: 12),
                    const _FeatureItem(
                      'Dashboard en tiempo real',
                      'Cada conversación, cada lead. Análisis de intenciones y lead scoring neuronal (0-100).',
                    ),
                    const _FeatureItem(
                      'Alertas por email',
                      'Cuando un lead es caliente recibes un email profesional con datos detectados y preview de la conversación.',
                    ),
                    const _FeatureItem(
                      'Calendario de reuniones',
                      'Desde el historial se agendan reuniones directamente en un calendario configurado por bot.',
                    ),
                    const SizedBox(height: 24),

                    _SectionTitle('Comercialización', Icons.storefront_rounded, colorScheme),
                    const SizedBox(height: 8),
                    Text(
                      'Empleados virtuales que venden, atienden y generan leads 24/7. Producto listo para comercializar: sin inversión en desarrollo, escalable con IA. Ideal para negocios que quieren automatizar atención al cliente, captar leads y agendar reuniones sin tocar código.',
                      style: textTheme.bodyMedium?.copyWith(height: 1.5),
                    ),
                    const SizedBox(height: 20),
                    const _FeatureItem(
                      'Listo para vender',
                      'Genera ingresos con IA. El cliente obtiene su fábrica de bots y empieza a monetizar desde el día uno.',
                    ),
                    const SizedBox(height: 28),

                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 16,
                      runSpacing: 12,
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _launchUrl(_urlBotlode),
                          icon: const Icon(FontAwesomeIcons.externalLinkAlt, size: 16),
                          label: const Text('Visitar botlode.com'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(color: colorScheme.primary),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => _launchUrl(_urlBotrive),
                          icon: const Icon(FontAwesomeIcons.externalLinkAlt, size: 16),
                          label: const Text('Visitar botrive.com'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: colorScheme.primary,
                            side: BorderSide(color: colorScheme.primary),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
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

class _PillarRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String desc;
  final Color color;
  final bool useFaIcon;

  const _PillarRow({
    required this.icon,
    required this.label,
    required this.desc,
    required this.color,
    this.useFaIcon = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: useFaIcon
              ? FaIcon(icon, size: 20, color: color)
              : Icon(icon, size: 20, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      height: 1.3,
                    ),
              ),
            ],
          ),
        ),
      ],
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
