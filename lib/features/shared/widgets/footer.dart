// Archivo: lib/features/shared/widgets/footer.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  void _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.platformDefault)) {
      // Manejar error silenciosamente
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      // Usamos el color primario con muy baja opacidad para teñir el footer
      color: colorScheme.primary.withOpacity(0.05),
      padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Manuel Navarro',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
              // El nombre toma el color principal
              color: colorScheme.primary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Desarrollo Web Full-Stack y Consultoría',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SocialIcon(
                icon: FontAwesomeIcons.github,
                onTap: () => _launchUrl('https://github.com/manunv97'),
                color: colorScheme.primary, // Iconos del color del tema
              ),
              _SocialIcon(
                icon: FontAwesomeIcons.linkedin,
                onTap: () => _launchUrl('https://linkedin.com/in/manuelnavarrodev'),
                color: colorScheme.primary,
              ),
              _SocialIcon(
                icon: FontAwesomeIcons.xTwitter,
                onTap: () => _launchUrl('https://twitter.com/manunv97'),
                color: colorScheme.primary,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Divider(color: colorScheme.primary.withOpacity(0.1)), // Divisor teñido
          const SizedBox(height: 10),
          Text(
            '© 2025 Manuel Navarro. Todos los derechos reservados.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }
}

class _SocialIcon extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final Color color;

  const _SocialIcon({
    required this.icon,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(icon, size: 22),
      color: color,
      // Efecto hover sutil
      hoverColor: color.withOpacity(0.1),
      onPressed: onTap,
    );
  }
}