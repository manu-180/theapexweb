// Archivo: lib/features/presence/data/repositories/presence_repository.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:apex/core/providers/supabase_providers.dart';
import 'package:apex/features/presence/domain/models/connected_user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'presence_repository.g.dart';

class PresenceRepository {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;
  
  // Stream para emitir la lista actualizada de usuarios
  final _usersController = StreamController<List<ConnectedUser>>.broadcast();

  PresenceRepository(this._supabase);

  Stream<List<ConnectedUser>> get onlineUsers => _usersController.stream;

  void connectAndTrack({
    required String myId,
    required String? myName,
    required String? myPhotoUrl,
  }) {
    if (_channel != null) return; // Ya conectado

    // En Flutter Web, Realtime tiene problemas de autenticación con WebSocket
    // Simulamos presencia local sin conectar al servidor
    if (kIsWeb) {
      debugPrint('Presence: Web detected - usando modo simulado (sin Realtime)');
      _usersController.add([
        ConnectedUser(
          id: myId,
          name: myName ?? 'anon-${myId.substring(0, 8)}',
          photoUrl: myPhotoUrl,
          isMe: true,
        ),
      ]);
      return;
    }

    // Modo normal (Mobile/Desktop) - conectar a Realtime
    try {
      _channel = _supabase.channel('online_users');

      _channel!
          .onPresenceSync((payload) {
            final presenceStateList = _channel!.presenceState();
            final Map<String, ConnectedUser> uniqueUsers = {}; 
            
            for (var stateEntry in presenceStateList) {
               final presences = (stateEntry as dynamic).presences as List<dynamic>;
               
               for (var userPresence in presences) {
                 final data = (userPresence as dynamic).payload as Map<String, dynamic>;
                 
                 final userId = data['user_id'] as String;
                 final name = data['name'] as String?;
                 final photoUrl = data['photo_url'] as String?;
                 
                 // Evitamos duplicados visuales por ID
                 if (!uniqueUsers.containsKey(userId)) {
                   uniqueUsers[userId] = ConnectedUser(
                     id: userId,
                     name: name,
                     photoUrl: photoUrl,
                     isMe: userId == myId,
                   );
                 }
               }
            }
            
            _usersController.add(uniqueUsers.values.toList());
          })
          .subscribe((status, error) async {
            if (status == RealtimeSubscribeStatus.subscribed) {
              await _channel!.track({
                'user_id': myId,
                'name': myName,
                'photo_url': myPhotoUrl, 
                'online_at': DateTime.now().toIso8601String(),
              });
            } else if (error != null) {
              debugPrint('Presence: Error de suscripción - $error');
            }
          });
    } catch (e) {
      debugPrint('Presence: Error al conectar - $e');
      // Fallback: simulamos presencia local
      _usersController.add([
        ConnectedUser(
          id: myId,
          name: myName ?? 'anon-${myId.substring(0, 8)}',
          photoUrl: myPhotoUrl,
          isMe: true,
        ),
      ]);
    }
  }

  void disconnect() {
    _channel?.unsubscribe();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _usersController.close();
  }
}

@riverpod
PresenceRepository presenceRepository(PresenceRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final repo = PresenceRepository(supabase);
  ref.onDispose(() => repo.dispose());
  return repo;
}