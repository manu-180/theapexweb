// Archivo: lib/features/presence/providers/presence_provider.dart
import 'package:apex/core/config/theme/app_theme_providers.dart'; // Para SharedPreferences
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
  static const _kAnonIdKey = 'device_anon_id';

  @override
  List<ConnectedUser> build() {
    final supabase = ref.watch(supabaseClientProvider);
    final currentUser = ref.watch(currentUserProvider);
    final prefs = ref.watch(sharedPreferencesProvider); // Acceso a disco
    
    // 1. Definimos la identidad de forma PERSISTENTE
    String myId;
    if (currentUser != null) {
      myId = currentUser.id;
    } else {
      // Si es anónimo, intentamos recuperar su ID de sesión anterior
      String? storedAnonId = prefs.getString(_kAnonIdKey);
      if (storedAnonId == null) {
        // Primera vez: Generamos y guardamos
        storedAnonId = 'anon-${DateTime.now().millisecondsSinceEpoch}';
        prefs.setString(_kAnonIdKey, storedAnonId);
      }
      myId = storedAnonId;
    }

    final metadata = currentUser?.userMetadata;
    final myName = metadata?['full_name'];
    // Buscamos avatar en varios campos comunes de OAuth
    final myPhotoUrl = metadata?['avatar_url'] ?? metadata?['picture'] ?? metadata?['image'];

    // 2. Limpieza automática al destruir el provider
    ref.onDispose(() {
      _channel?.unsubscribe();
    });

    // 3. Iniciamos la suscripción
    _subscribeToPresence(supabase, myId, myName, myPhotoUrl);

    // Estado inicial vacío mientras conecta
    return [];
  }

  void _subscribeToPresence(SupabaseClient supabase, String myId, String? myName, String? myPhotoUrl) {
    if (_channel != null) return;

    _channel = supabase.channel('online_users');

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
          
          state = uniqueUsers.values.toList();
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
}