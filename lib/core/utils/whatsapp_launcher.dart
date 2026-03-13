import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:apex/core/config/app_constants.dart';

abstract final class WhatsAppLauncher {
  static Future<bool> open({
    required BuildContext context,
    required String message,
    String? phone,
  }) async {
    final number = phone ?? AppConstants.whatsappNumber;
    final uri = Uri.parse(
      'https://wa.me/$number?text=${Uri.encodeComponent(message)}',
    );

    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return true;
      }
      throw 'No se pudo abrir WhatsApp';
    } catch (e) {
      debugPrint('[WhatsAppLauncher] Error: $e');
      if (context.mounted) {
        Clipboard.setData(ClipboardData(text: number));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.copy, color: Colors.white, size: 16),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'No pudimos abrir WhatsApp. Número copiado al portapapeles.',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
      return false;
    }
  }
}
