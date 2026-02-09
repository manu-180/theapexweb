import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Envuelve la app sin mostrar barra/snackbar de offline en Flutter.
/// El aviso de "Sin conexión" se muestra desde web/index.html (cartel del overlay)
/// controlado por el script que escucha los eventos online/offline del navegador.
/// Si usás botlode_player u otro embed desde index.html, ese cartel sigue funcionando.
class OfflineStatusBanner extends ConsumerWidget {
  final Widget child;

  const OfflineStatusBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return child;
  }
}