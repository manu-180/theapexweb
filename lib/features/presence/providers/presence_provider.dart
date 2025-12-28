// Archivo: lib/features/presence/providers/presence_provider.dart
import 'package:flutter/foundation.dart';
import 'package:apex/core/providers/supabase_providers.dart';
import 'package:apex/features/auth/presentation/providers/auth_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'presence_provider.g.dart';

// Modelo simple para saber quién está conectado
class ConnectedUser {
  final String id;
  final String? name; // Si es null, es anónimo
  final bool isMe;

  ConnectedUser({
    required this.id,
    this.name,
    required this.isMe,
  });
}

@riverpod
class PresenceNotifier extends _$PresenceNotifier {
  RealtimeChannel? _channel;

  @override
  List<ConnectedUser> build() {
    // 1. Obtenemos dependencias
    final supabase = ref.watch(supabaseClientProvider);
    final currentUser = ref.watch(currentUserProvider);

    // 2. Definimos mi identidad actual
    final myId = currentUser?.id ?? 'anon-${DateTime.now().millisecondsSinceEpoch}';
    final myName = currentUser?.userMetadata?['full_name']; // Nombre de Google

    // 3. Limpieza previa si cambia el usuario (login/logout)
    if (_channel != null) {
      _supabaseUnsubscribe();
    }

    // 4. Suscripción al canal de Presencia
    _subscribeToPresence(supabase, myId, myName);

    // Estado inicial vacío hasta que sincronice
    return [];
  }

  void _subscribeToPresence(SupabaseClient supabase, String myId, String? myName) {
    // Creamos un canal único para "usuarios online"
    _channel = supabase.channel('online_users');

    _channel!
        .onPresenceSync((payload) {
          // CORRECCIÓN: Aquí manejamos la LISTA directamente
          final presenceList = _channel!.presenceState();
          
          final List<ConnectedUser> users = [];
          
          // Iteramos la lista (sin usar .values)
          for (var presence in presenceList) {
             // Usamos 'dynamic' para evitar problemas de tipos internos de la librería
             final data = (presence as dynamic).payload as Map<String, dynamic>;
             
             final userId = data['user_id'] as String;
             final name = data['name'] as String?;
             
             users.add(ConnectedUser(
               id: userId,
               name: name,
               isMe: userId == myId,
             ));
          }
          
          state = users;
        })
        .subscribe((status, error) async {
          if (status == RealtimeSubscribeStatus.subscribed) {
            // Una vez conectados, enviamos NUESTRA data al canal
            await _channel!.track({
              'user_id': myId,
              'name': myName, 
              'online_at': DateTime.now().toIso8601String(),
            });
          }
        });
  }

  Future<void> _supabaseUnsubscribe() async {
    await _channel?.unsubscribe();
    _channel = null;
  }
}