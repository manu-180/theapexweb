// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'package:prueba_de_riverpod/core/config/theme/app_theme.dart';

/// Implementación real para WEB
void updateFavicon(AppTheme theme) {
  // Construimos el nombre. Asegúrate que tus archivos en web/favicons/
  // se llamen exactamente: favicon_neutral.png, favicon_flutter.png, etc.
  final iconFileName = 'favicon_${theme.name}.png';
  
  // TRUCO: Agregamos un timestamp para obligar al navegador a recargar la imagen
  // y evitar que use la versión vieja guardada en memoria caché.
  final version = DateTime.now().millisecondsSinceEpoch;
  final fullPath = 'favicons/$iconFileName?v=$version';

  final link = html.document.querySelector("link[rel*='icon']") as html.LinkElement?;

  if (link != null) {
    link.href = fullPath;
  } else {
    final newLink = html.LinkElement()
      ..rel = 'icon'
      ..href = fullPath;
    html.document.head?.append(newLink);
  }
}