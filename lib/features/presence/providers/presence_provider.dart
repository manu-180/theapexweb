// Archivo: lib/features/presence/providers/presence_provider.dart
import 'package:flutter/foundation.dart';
import 'package:apex/core/providers/supabase_providers.dart';
import 'package:apex/features/auth/presentation/providers/auth_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'presence_provider.g.dart';

class ConnectedUser {
  final String id;
  final String? name;
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
    final supabase = ref.watch(supabaseClientProvider);
    final currentUser = ref.watch(currentUserProvider);

    final myId = currentUser?.id ?? 'anon-${DateTime.now().millisecondsSinceEpoch}';
    final myName = currentUser?.userMetadata?['full_name'];

    if (_channel != null) {
      _supabaseUnsubscribe();
    }

    _subscribeToPresence(supabase, myId, myName);

    return [];
  }

  void _subscribeToPresence(SupabaseClient supabase, String myId, String? myName) {
    debugPrint('🔌 Intentando conectar a Realtime...'); // LOG 1

    _channel = supabase.channel('online_users');

    _channel!
        .onPresenceSync((payload) {
          debugPrint('🔄 Sincronizando presencia...'); // LOG 2
          final presenceList = _channel!.presenceState();
          
          final List<ConnectedUser> users = [];
          
          for (var presence in presenceList) {
             final data = (presence as dynamic).payload as Map<String, dynamic>;
             final userId = data['user_id'] as String;
             final name = data['name'] as String?;
             
             users.add(ConnectedUser(
               id: userId,
               name: name,
               isMe: userId == myId,
             ));
          }
          
          debugPrint('✅ Usuarios conectados: ${users.length}'); // LOG 3
          state = users;
        })
        .subscribe((status, error) async {
          if (status == RealtimeSubscribeStatus.subscribed) {
            debugPrint('🟢 ¡Conectado al canal! Enviando mis datos...'); // LOG 4
            
            await _channel!.track({
              'user_id': myId,
              'name': myName, 
              'online_at': DateTime.now().toIso8601String(),
            });
          } else if (status == RealtimeSubscribeStatus.closed) {
             debugPrint('🔴 Conexión cerrada.');
          } else if (error != null) {
             debugPrint('❌ Error de suscripción: $error'); // LOG DE ERROR
          }
        });
  }

  Future<void> _supabaseUnsubscribe() async {
    await _channel?.unsubscribe();
    _channel = null;
  }
}