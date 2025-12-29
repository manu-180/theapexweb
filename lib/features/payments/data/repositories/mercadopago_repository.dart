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
      final response = await _supabase.functions.invoke(
        'create_preference_manuel',
        headers: {
          'Content-Type': 'application/json',
          // Si hay JWT lo mandamos, si no, Supabase usará la anonKey por defecto del cliente
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

      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('No se pudo abrir la pasarela de pagos.');
      }

    } on FunctionException catch (e) {
      final msg = e.details?.toString() ?? e.reasonPhrase ?? 'Error en la función';
      debugPrint('Error de Edge Function: $msg');
      throw Exception('Error al conectar con el servidor de pagos.');
    } catch (e) {
      debugPrint('Error en checkout: $e');
      throw Exception('No se pudo iniciar el pago.');
    }
  }}

@riverpod
MercadoPagoRepository mercadoPagoRepository(MercadoPagoRepositoryRef ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final supabaseUrl = ref.watch(supabaseUrlProvider); 
  
  return MercadoPagoRepository(supabaseClient, supabaseUrl);
}