// Archivo: lib/features/presence/data/repositories/presence_repository.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:apex/core/providers/supabase_providers.dart';
import 'package:apex/features/presence/domain/models/connected_user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'presence_repository.g.dart';

/// Contrato del repositorio de presencia (permite implementación no-op cuando no hay Supabase).
abstract class PresenceRepository {
  Stream<List<ConnectedUser>> get onlineUsers;
  void connectAndTrack({
    required String myId,
    required String? myName,
    required String? myPhotoUrl,
  });
  void disconnect();
  void dispose();
}

class _SupabasePresenceRepository extends PresenceRepository {
  final SupabaseClient _supabase;
  RealtimeChannel? _channel;
  final _usersController = StreamController<List<ConnectedUser>>.broadcast();

  _SupabasePresenceRepository(this._supabase);

  @override
  Stream<List<ConnectedUser>> get onlineUsers => _usersController.stream;

  @override
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

  @override
  void disconnect() {
    _channel?.unsubscribe();
    _channel = null;
  }

  @override
  void dispose() {
    disconnect();
    _usersController.close();
  }
}

/// Repositorio sin operaciones cuando Supabase no está inicializado (p. ej. web sin credenciales).
/// Evita que el AppBar de presencia lance y muestre "Algo salió mal visualmente".
class _NoOpPresenceRepository extends PresenceRepository {
  final _usersController = StreamController<List<ConnectedUser>>.broadcast();

  @override
  Stream<List<ConnectedUser>> get onlineUsers => _usersController.stream;

  @override
  void connectAndTrack({
    required String myId,
    required String? myName,
    required String? myPhotoUrl,
  }) {
    // Sin Supabase mostramos al menos "tú" como online para que no se quede en "Conectando..."
    _usersController.add([
      ConnectedUser(
        id: myId,
        name: myName ?? 'anon-${myId.length > 12 ? myId.substring(0, 12) : myId}',
        photoUrl: myPhotoUrl,
        isMe: true,
      ),
    ]);
  }

  @override
  void disconnect() {}

  @override
  void dispose() {
    _usersController.close();
  }
}

@riverpod
PresenceRepository presenceRepository(PresenceRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  if (supabase == null) {
    final repo = _NoOpPresenceRepository();
    ref.onDispose(() => repo.dispose());
    return repo;
  }
  final repo = _SupabasePresenceRepository(supabase);
  ref.onDispose(() => repo.dispose());
  return repo;
}