// Script para mantener activo el proyecto Supabase (evitar pausa por inactividad).
// Ejecutar cada ~2 días (Programador de tareas en Windows, cron en Linux/Mac).
//
// Uso:
//   cd APEX
//   dart run tool/keepalive_supabase.dart
//
// Opcional: insertar una cita de prueba en el calendario (--insert).
//   dart run tool/keepalive_supabase.dart --insert
//
// Variables: lee .env en la raíz de APEX o SUPABASE_URL y SUPABASE_ANON_KEY en el entorno.
//
// Programar cada 2 días en Windows:
//   1. Abrir "Programador de tareas" → Crear tarea básica.
//   2. Desencadenador: Diario, repetir cada 2 días.
//   3. Acción: Iniciar un programa.
//   4. Programa: dart (o ruta completa a dart.exe).
//   5. Argumentos: run tool/keepalive_supabase.dart
//   6. "Iniciar en": ruta de la carpeta APEX (ej. C:\...\contact-engine\APEX).

import 'dart:io';
import 'package:http/http.dart' as http;

const _keepaliveEmail = 'keepalive@apex.local';

Map<String, String> _loadEnv() {
  final file = File('.env');
  if (!file.existsSync()) return {};
  final lines = file.readAsStringSync().split('\n');
  final map = <String, String>{};
  for (final line in lines) {
    final trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) continue;
    final idx = trimmed.indexOf('=');
    if (idx <= 0) continue;
    final key = trimmed.substring(0, idx).trim();
    String value = trimmed.substring(idx + 1).trim();
    if (value.length >= 2 &&
        ((value.startsWith('"') && value.endsWith('"')) ||
            (value.startsWith("'") && value.endsWith("'")))) {
      value = value.substring(1, value.length - 1);
    }
    map[key] = value;
  }
  return map;
}

Future<void> main(List<String> args) async {
  final env = _loadEnv();
  final url = env['SUPABASE_URL'] ?? Platform.environment['SUPABASE_URL'];
  final key = env['SUPABASE_ANON_KEY'] ?? Platform.environment['SUPABASE_ANON_KEY'];

  if (url == null || url.isEmpty || key == null || key.isEmpty) {
    print('Error: necesitas SUPABASE_URL y SUPABASE_ANON_KEY en .env o en el entorno.');
    exit(1);
  }

  final baseUrl = url.endsWith('/') ? url : '$url/';
  final doInsert = args.contains('--insert');

  try {
    // 1. Ping: GET a la API cuenta como actividad y evita la pausa
    final getUri = Uri.parse('${baseUrl}rest/v1/appointments?select=id&limit=1');
    final getResponse = await http.get(
      getUri,
      headers: {
        'apikey': key,
        'Authorization': 'Bearer $key',
        'Content-Type': 'application/json',
      },
    );

    if (getResponse.statusCode >= 200 && getResponse.statusCode < 300) {
      print('OK: Supabase activo (ping ${getResponse.statusCode})');
    } else {
      print('Ping devolvió ${getResponse.statusCode}: ${getResponse.body}');
      exit(1);
    }

    // 2. Opcional: insertar una cita de “keepalive” en el calendario
    if (doInsert) {
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final dateStr = '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';
      final postUri = Uri.parse('${baseUrl}rest/v1/appointments');
      final body = '''
{
  "date_slot": "$dateStr",
  "hour_slot": 9,
  "contact_info": "$_keepaliveEmail",
  "contact_type": "email",
  "client_name": "Keepalive (script)"
}
''';
      final postResponse = await http.post(
        postUri,
        headers: {
          'apikey': key,
          'Authorization': 'Bearer $key',
          'Content-Type': 'application/json',
          'Prefer': 'return=minimal',
        },
        body: body,
      );

      if (postResponse.statusCode >= 200 && postResponse.statusCode < 300) {
        print('OK: Cita keepalive creada para $dateStr a las 9:00.');
      } else if (postResponse.statusCode == 409 || postResponse.body.contains('23505')) {
        print('OK: Ya existe una cita a esa hora (keepalive previo).');
      } else {
        print('Insert devolvió ${postResponse.statusCode}: ${postResponse.body}');
      }
    }
  } catch (e, st) {
    print('Error: $e');
    print(st);
    exit(1);
  }
}
