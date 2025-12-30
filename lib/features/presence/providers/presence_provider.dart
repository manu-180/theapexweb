// Archivo: lib/features/presence/providers/presence_provider.dart
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
    
    // 1. Definimos la identidad del usuario actual
    // Si no hay usuario logueado, generamos un ID temporal único para esta sesión
    final myId = currentUser?.id ?? 'anon-${DateTime.now().millisecondsSinceEpoch}';
    final metadata = currentUser?.userMetadata;
    final myName = metadata?['full_name'];
    // Buscamos avatar en varios campos comunes de OAuth
    final myPhotoUrl = metadata?['avatar_url'] ?? metadata?['picture'] ?? metadata?['image'];

    // 2. Limpieza automática al destruir el provider (Navegación/Refresco/Logout)
    // Esto es VITAL: Cierra el socket cuando este provider ya no se usa.
    ref.onDispose(() {
      _channel?.unsubscribe();
    });

    // 3. Iniciamos la suscripción
    _subscribeToPresence(supabase, myId, myName, myPhotoUrl);

    // Estado inicial vacío mientras conecta
    return [];
  }

  void _subscribeToPresence(SupabaseClient supabase, String myId, String? myName, String? myPhotoUrl) {
    // Seguridad: Evitamos duplicar canales si ya existe uno activo
    if (_channel != null) return;

    _channel = supabase.channel('online_users');

    _channel!
        .onPresenceSync((payload) {
          // A. Obtenemos el estado crudo de Supabase
          final presenceStateList = _channel!.presenceState();
          final Map<String, ConnectedUser> uniqueUsers = {}; 
          
          // B. Procesamos y aplanamos la lista (eliminando duplicados por ID)
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
          
          // C. Actualización segura del estado (Inmutabilidad)
          state = uniqueUsers.values.toList();
        })
        .subscribe((status, error) async {
          if (status == RealtimeSubscribeStatus.subscribed) {
            // D. Una vez conectados, enviamos nuestra señal ("track") para que otros nos vean
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