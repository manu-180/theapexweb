// Archivo: lib/features/contact/data/repositories/whatsapp_repository.dart
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'whatsapp_repository.g.dart';

class WhatsappRepository {
  final http.Client _httpClient;
  // Cache simple para no cargar .env mil veces
  bool _envLoaded = false;

  WhatsappRepository(this._httpClient);

  Future<void> _ensureEnvLoaded() async {
    if (_envLoaded) return;
    try {
      if (!dotenv.isInitialized) await dotenv.load(fileName: ".env");
    } catch (_) {} // Silencioso si ya estaba cargado
    _envLoaded = true;
  }

  /// Método genérico para Twilio
  Future<String?> sendTemplateMessage(
    String contentSid,
    String toNumber,
    List<String> parameters,
  ) async {
    await _ensureEnvLoaded();

    final apiKeySid = dotenv.env['API_KEY_SID'] ?? '';
    final apiKeySecret = dotenv.env['API_KEY_SECRET'] ?? '';
    final accountSid = dotenv.env['ACCOUNT_SID'] ?? '';

    if (apiKeySid.isEmpty || apiKeySecret.isEmpty || accountSid.isEmpty) {
      throw Exception("Faltan credenciales de Twilio en el archivo .env");
    }

    final uri = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/$accountSid/Messages.json');
    
    // IMPORTANTE: Asegúrate de que este número sea el sender autorizado en tu consola Twilio
    const fromWhatsappNumber = 'whatsapp:+5491125303794'; 

    final contentVariables = jsonEncode({
      "1": parameters.isNotEmpty ? parameters[0] : "",
      "2": parameters.length > 1 ? parameters[1] : "",
      "3": parameters.length > 2 ? parameters[2] : "",
      "4": parameters.length > 3 ? parameters[3] : "",
      "5": parameters.length > 4 ? parameters[4] : "",
    });

    final body = <String, String>{
      'From': fromWhatsappNumber,
      'To': 'whatsapp:$toNumber', // Twilio requiere prefijo whatsapp:
      'ContentSid': contentSid,
      'ContentVariables': contentVariables,
    };

    try {
      final response = await _httpClient.post(
        uri,
        headers: {
          'Authorization':
              'Basic ${base64Encode(utf8.encode('$apiKeySid:$apiKeySecret'))}',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return decoded['sid'] as String?;
      } else {
        throw Exception(
            'Twilio Error (${response.statusCode}): ${response.body}');
      }
    } catch (e) {
      // Logueamos pero no crasheamos la app si falla el aviso
      print("Error enviando WhatsApp: $e");
      rethrow;
    }
  }

  /// Método específico de negocio para APEX
  Future<void> sendBookingConfirmation({
    required String phone,
    required DateTime date,
    required int hour,
  }) async {
    await _ensureEnvLoaded();
    
    // Asumimos que guardaste el ID de tu plantilla en el .env
    // Si no, pon el string directo aquí: 'HXxxxxxxxx...'
    final templateSid = dotenv.env['WHATSAPP_TEMPLATE_SID']; 
    
    if (templateSid == null) {
      print("Warning: WHATSAPP_TEMPLATE_SID no definido en .env");
      return;
    }

    // Formateo amigable: "Viernes 10 de Octubre", "15:00 hs"
    final dateStr = DateFormat('EEEE d \'de\' MMMM', 'es').format(date);
    final timeStr = "$hour:00 hs";

    // Enviamos los parámetros a la plantilla {{1}} y {{2}}
    await sendTemplateMessage(
      templateSid, 
      phone, 
      [dateStr, timeStr], 
    );
  }
}

@riverpod
WhatsappRepository whatsappRepository(WhatsappRepositoryRef ref) {
  return WhatsappRepository(http.Client());
}