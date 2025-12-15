// Archivo: lib/core/config/theme/extensions/app_bar_extension.dart
import 'package:flutter/material.dart';

// Esta clase es un StatelessWidget normal que se usa como AppBar
// Su nombre 'CustomAppBarExtension' es solo para la consistencia
// del nombre que usamos en la vista de contacto.
class CustomAppBarExtension extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBarExtension({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.onSurface,
        ),
      ),
      centerTitle: true,
      // Puedes añadir más acciones o el logo aquí si quieres
      actions: const [
        SizedBox(width: 20),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}