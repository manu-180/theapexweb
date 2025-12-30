// Archivo: lib/features/payments/data/repositories/mercadopago_repository.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:apex/core/providers/supabase_providers.dart';
import 'package:apex/features/services/domain/models/plan_model.dart';
import 'package:apex/main.dart'; 
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

part 'mercadopago_repository.g.dart';

class MercadoPagoRepository {
  MercadoPagoRepository(this._supabase, this._supabaseUrl);

  final SupabaseClient _supabase;
  final String _supabaseUrl;
  
  /// Llama a la Edge Function para crear la preferencia de pago en Mercado Pago.
  Future<void> createPreferenceAndLaunchCheckout({
    required ServicePlan plan,
    required String userEmail, 
    required String? userId, 
  }) async {
    
    final session = _supabase.auth.currentSession;
    final jwt = session?.accessToken;

    try {
      // 1. Llamada a la Edge Function
      final response = await _supabase.functions.invoke(
        'create_preference_manuel',
        headers: {
          'Content-Type': 'application/json',
          // Enviamos el JWT explícitamente para asegurar contextos autenticados
          if (jwt != null) 'Authorization': 'Bearer $jwt',
        },
        body: jsonEncode({
          'title': plan.name,
          'unit_price': plan.price,
          'quantity': 1,
          'metadata': {
            'user_email': userEmail,
            'user_id': userId,
          }
        }),
      );

      final responseData = response.data;
      
      // Validación robusta de respuesta
      if (responseData is Map && responseData.containsKey('error')) {
         throw Exception(responseData['error']);
      }

      final String? checkoutUrl = responseData['init_point'];
      
      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        throw Exception('El servidor no devolvió el enlace de pago.');
      }

      final uri = Uri.parse(checkoutUrl);

      // 2. Lanzamiento Optimizado (Sin canLaunchUrl redundante)
      // Intentamos abrir directamente. En web, esto reduce la latencia 
      // y minimiza la chance de bloqueo por el navegador.
      try {
        await launchUrl(
          uri, 
          // externalApplication es lo correcto para salir de la PWA/SPA hacia MP
          mode: LaunchMode.externalApplication,
        );
      } catch (e) {
        debugPrint('Error lanzando URL: $e');
        // Si falla externalApplication (raro), intentamos fallback a platformDefault
        await launchUrl(uri, mode: LaunchMode.platformDefault);
      }

    } on FunctionException catch (e) {
      // Errores específicos de Supabase Functions
      final msg = e.details?.toString() ?? e.reasonPhrase ?? 'Error en la función de pagos';
      debugPrint('Error de Edge Function: $msg');
      throw Exception('Error de conexión con pagos: $msg');
    } catch (e) {
      // Errores generales
      debugPrint('Error general en checkout: $e');
      rethrow; 
    }
  }
}

@riverpod
MercadoPagoRepository mercadoPagoRepository(MercadoPagoRepositoryRef ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final supabaseUrl = ref.watch(supabaseUrlProvider); 
  
  return MercadoPagoRepository(supabaseClient, supabaseUrl);
}