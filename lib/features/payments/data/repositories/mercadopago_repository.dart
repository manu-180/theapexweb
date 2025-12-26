// Archivo: lib/features/payments/data/repositories/mercadopago_repository.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:prueba_de_riverpod/core/providers/supabase_providers.dart';
import 'package:prueba_de_riverpod/features/services/domain/models/plan_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:prueba_de_riverpod/main.dart'; 

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
    
    // CORRECCIÓN 1: En Supabase v2 es 'accessToken' (camelCase)
    final jwt = session?.accessToken;

    // Obtenemos la Anon Key desde los headers del cliente
    final anonKey = _supabase.headers['apikey'];

    try {
      if (kDebugMode) {
        print('Iniciando pago para $userEmail. Usuario ID: $userId');
      }
      
      final response = await _supabase.functions.invoke(
        'create-preference-manuel',
        headers: {
          'Content-Type': 'application/json',
          // Usamos la anonKey recuperada correctamente si no hay JWT
          'Authorization': jwt != null ? 'Bearer $jwt' : 'Bearer $anonKey', 
        },
        body: jsonEncode({
          'plan': {
            'id': plan.id,
            'name': plan.name,
            'price': plan.price,
            'description': plan.description,
          },
          'userEmail': userEmail,
          'userId': userId, 
        }),
      );

      final responseData = response.data;
      final String? checkoutUrl = responseData['checkoutUrl'];
      
      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        throw Exception('La Edge Function no devolvió una URL de checkout válida.');
      }

      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.inAppWebView,
        );
      } else {
        throw Exception('No se pudo abrir la URL de pago: $checkoutUrl');
      }

    // CORRECCIÓN 2: La excepción se llama 'FunctionException' (singular)
    } on FunctionException catch (e) {
      throw Exception('Error en el servicio de pago: NO SE QUE ERROR PONER $e');
    } catch (e) {
      throw Exception('Error desconocido al iniciar el pago: $e');
    }
  }
}

@riverpod
MercadoPagoRepository mercadoPagoRepository(MercadoPagoRepositoryRef ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final supabaseUrl = ref.watch(supabaseUrlProvider); 
  
  return MercadoPagoRepository(supabaseClient, supabaseUrl);
}