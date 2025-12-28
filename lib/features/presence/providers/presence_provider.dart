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
  final String? photoUrl;
  final bool isMe;

  ConnectedUser({
    required this.id,
    this.name,
    this.photoUrl,
    required this.isMe,
  });
  
  @override
  String toString() => 'User(name: $name, photo: $photoUrl)';
}

@riverpod
class PresenceNotifier extends _$PresenceNotifier {
  RealtimeChannel? _channel;

  @override
  List<ConnectedUser> build() {
    final supabase = ref.watch(supabaseClientProvider);
    final currentUser = ref.watch(currentUserProvider);

    final myId = currentUser?.id ?? 'anon-${DateTime.now().millisecondsSinceEpoch}';
    
    // --- DIAGNÓSTICO DE LA FOTO ---
    final metadata = currentUser?.userMetadata;
    
    if (currentUser != null) {
      debugPrint('\n🤠 --- DIAGNÓSTICO DE METADATA ---');
      debugPrint('📦 Metadata Completa: $metadata');
      // Intentamos adivinar dónde está la foto
      debugPrint('🔍 avatar_url: ${metadata?['avatar_url']}');
      debugPrint('🔍 picture: ${metadata?['picture']}');
      debugPrint('🔍 full_name: ${metadata?['full_name']}');
      debugPrint('🤠 --------------------------------\n');
    }
    // -----------------------------

    // Intentamos recuperar la foto de varios lugares comunes
    final myName = metadata?['full_name'];
    final myPhotoUrl = metadata?['avatar_url'] ?? metadata?['picture'] ?? metadata?['image'];

    if (_channel != null) {
      _supabaseUnsubscribe();
    }

    _subscribeToPresence(supabase, myId, myName, myPhotoUrl);

    return [];
  }

  void _subscribeToPresence(SupabaseClient supabase, String myId, String? myName, String? myPhotoUrl) {
    _channel = supabase.channel('online_users');

    _channel!
        .onPresenceSync((payload) {
          final presenceStateList = _channel!.presenceState();
          final List<ConnectedUser> users = [];
          
          for (var state in presenceStateList) {
             final presences = (state as dynamic).presences as List<dynamic>;
             
             for (var userPresence in presences) {
               final data = (userPresence as dynamic).payload as Map<String, dynamic>;
               
               final userId = data['user_id'] as String;
               final name = data['name'] as String?;
               final photoUrl = data['photo_url'] as String?;
               
               users.add(ConnectedUser(
                 id: userId,
                 name: name,
                 photoUrl: photoUrl,
                 isMe: userId == myId,
               ));
             }
          }
          state = users;
        })
        .subscribe((status, error) async {
          if (status == RealtimeSubscribeStatus.subscribed) {
            await _channel!.track({
              'user_id': myId,
              'name': myName,
              'photo_url': myPhotoUrl, 
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