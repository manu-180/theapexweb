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
    final anonKey = _supabase.headers['apikey'];

    try {
      if (kDebugMode) {
        print('Iniciando pago para $userEmail. Usuario ID: $userId');
      }
      
      final response = await _supabase.functions.invoke(
        'create_preference_manuel', // Nombre correcto (guion bajo)
        headers: {
          'Content-Type': 'application/json',
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
      
      // Verificación robusta de errores lógicos
      if (responseData is Map && responseData.containsKey('error')) {
         throw Exception(responseData['error']);
      }

      final String? checkoutUrl = responseData['checkoutUrl'];
      
      if (checkoutUrl == null || checkoutUrl.isEmpty) {
        throw Exception('El servidor no devolvió el enlace de pago.');
      }

      final uri = Uri.parse(checkoutUrl);
      if (await canLaunchUrl(uri)) {
        await launchUrl(
          uri,
          mode: LaunchMode.externalApplication, 
        );
      } else {
        throw Exception('No se pudo abrir la pasarela de pagos.');
      }

    } on FunctionException catch (e) {
      // CORRECCIÓN AQUÍ: Usamos details o reasonPhrase, ya que .message no existe
      final msg = e.details?.toString() ?? e.reasonPhrase ?? 'Error desconocido en Edge Function';
      debugPrint('Error de Edge Function: $msg');
      throw Exception('Error al conectar con el servidor de pagos. Intenta nuevamente.');
      
    } catch (e) {
      debugPrint('Error en checkout: $e');
      throw Exception('No se pudo iniciar el pago. Verifica tu conexión.');
    }
  }
}

@riverpod
MercadoPagoRepository mercadoPagoRepository(MercadoPagoRepositoryRef ref) {
  final supabaseClient = ref.watch(supabaseClientProvider);
  final supabaseUrl = ref.watch(supabaseUrlProvider); 
  
  return MercadoPagoRepository(supabaseClient, supabaseUrl);
}