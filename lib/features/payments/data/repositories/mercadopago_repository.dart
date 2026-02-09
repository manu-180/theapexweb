// Archivo: lib/features/payments/data/repositories/mercadopago_repository.dart
import 'dart:convert';
import 'dart:io'; 
import 'package:flutter/foundation.dart';
import 'package:apex/core/providers/supabase_providers.dart';
import 'package:apex/features/services/domain/models/plan_model.dart';
import 'package:apex/main.dart'; 
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'mercadopago_repository.g.dart';

class MercadoPagoRepository {
  MercadoPagoRepository(this._supabase, this._supabaseUrl);

  final SupabaseClient? _supabase;
  final String _supabaseUrl;

  Future<String> createPreference({
    required ServicePlan plan,
    required String userEmail, 
    required String? userId, 
  }) async {
    if (_supabase == null) throw Exception('Servicio de pagos no disponible.');
    try {
      final session = _supabase!.auth.currentSession;
      final jwt = session?.accessToken;

      final response = await _supabase!.functions.invoke(
        'create_preference_manuel',
        headers: {
          'Content-Type': 'application/json',
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
      
      if (responseData is Map && responseData.containsKey('error')) {
         throw Exception(responseData['error']);
      }

      final String? checkoutUrl = responseData['init_point'];
      
      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        throw Exception('El servidor no devolvió el enlace de pago.');
      }

      return checkoutUrl;

    } on FunctionException catch (e) {
      // Error específico de Supabase Functions
      final msg = e.details?.toString() ?? e.reasonPhrase ?? 'Error en el servidor de pagos';
      throw Exception(msg); // Relanzamos como excepción limpia para la UI
    } on SocketException {
      throw Exception('No tienes conexión a internet.');
    } catch (e) {
      // Cualquier otro error (ej: timeout, parsing)
      debugPrint('Error en repositorio de pagos: $e');
      if (e.toString().contains('XMLHttpRequest')) {
         throw Exception('Error de red o CORS. Verifica tu conexión.');
      }
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