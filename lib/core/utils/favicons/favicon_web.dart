// Archivo: lib/core/utils/favicons/favicon_web.dart
import 'dart:convert';
import 'dart:js_interop'; // Necesario para .toJS y JSAny
import 'package:web/web.dart' as web;
import 'package:apex/core/config/theme/app_theme.dart';

/// Implementación "Tierra Quemada" basada en el informe técnico.
void updateFavicon(AppTheme theme) {
  final timestamp = DateTime.now().millisecondsSinceEpoch;
  // Ajusta la ruta si es necesario. Como están en 'web/favicons/', la ruta relativa es:
  final iconFileName = 'favicons/favicon_${theme.name}.png';
  final iconUrlWithCacheBust = '$iconFileName?v=$timestamp';

  // 1. MANIPULACIÓN DE ETIQUETAS LINK (ICONOS)
  _updateLinkTag('icon', iconUrlWithCacheBust);
  _updateLinkTag('shortcut icon', iconUrlWithCacheBust);
  _updateLinkTag('apple-touch-icon', iconUrlWithCacheBust);

  // 2. INYECCIÓN DE MANIFIESTO DINÁMICO (BLOB)
  _injectDynamicManifest(iconUrlWithCacheBust, theme);
}

/// Elimina la etiqueta vieja y crea una nueva para forzar el repintado.
void _updateLinkTag(String rel, String href) {
  final head = web.document.head;
  if (head == null) return;

  // A. Buscar y destruir etiquetas existentes
  final selector = "link[rel='$rel']";
  final existingLinks = web.document.querySelectorAll(selector);
  
  // CORRECCIÓN AQUÍ: Iteramos y casteamos a Element para poder usar .remove()
  for (var i = 0; i < existingLinks.length; i++) {
    final node = existingLinks.item(i);
    // Verificamos si es un Elemento antes de borrarlo
    if (node is web.Element) {
      node.remove();
    }
  }

  // B. Crear nueva etiqueta fresca
  final newLink = web.HTMLLinkElement()
    ..rel = rel
    ..type = 'image/png'
    ..href = href;

  // C. Inyectar
  head.append(newLink);
}

/// Genera un manifiesto en memoria y lo inyecta como URL Blob.
void _injectDynamicManifest(String iconUrl, AppTheme theme) {
  final head = web.document.head;
  if (head == null) return;

  // A. Definir el JSON del manifiesto dinámico
  final Map<String, dynamic> manifestJson = {
    "name": "Manuel Navarro - ${theme.name.toUpperCase()}",
    "short_name": "Portfolio",
    "start_url": ".",
    "display": "standalone",
    "background_color": "#ffffff",
    "theme_color": _getThemeColorHex(theme),
    "icons": [
      {
        "src": iconUrl,
        "sizes": "192x192",
        "type": "image/png"
      },
      {
        "src": iconUrl,
        "sizes": "512x512",
        "type": "image/png"
      }
    ]
  };

  // B. Convertir a Blob
  final jsonString = jsonEncode(manifestJson);
  
  // CORRECCIÓN: Conversión explícita para JSAny
  final blob = web.Blob(
    [jsonString.toJS].toJS, 
    web.BlobPropertyBag(type: 'application/json'),
  );

  // C. Crear URL volátil
  final manifestUrl = web.URL.createObjectURL(blob);

  // D. Reemplazar la etiqueta del manifiesto
  final selector = "link[rel='manifest']";
  final existingManifest = web.document.querySelector(selector);
  
  // querySelector devuelve Element?, así que aquí remove() funciona directo
  existingManifest?.remove();

  final newManifestLink = web.HTMLLinkElement()
    ..rel = 'manifest'
    ..href = manifestUrl;

  head.append(newManifestLink);
}

String _getThemeColorHex(AppTheme theme) {
  switch (theme) {
    case AppTheme.flutter: return "#0175C2";
    case AppTheme.supabase: return "#3ECF8E";
    case AppTheme.riverpod: return "#6E56F8";
    case AppTheme.assistify: return "#00A8E8";
    default: return "#64748B"; // Neutral
  }
}