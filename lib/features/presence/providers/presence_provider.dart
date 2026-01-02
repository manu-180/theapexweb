// Archivo: lib/features/presence/providers/presence_provider.dart
import 'package:apex/core/config/theme/app_theme_providers.dart';
import 'package:apex/core/providers/network_status_provider.dart';
import 'package:apex/features/auth/presentation/providers/auth_providers.dart';
import 'package:apex/features/presence/data/repositories/presence_repository.dart';
import 'package:apex/features/presence/domain/models/connected_user_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Export para mantener compatibilidad con las vistas
export 'package:apex/features/presence/domain/models/connected_user_model.dart';

part 'presence_provider.g.dart';

@riverpod
class PresenceNotifier extends _$PresenceNotifier {
  static const _kAnonIdKey = 'device_anon_id';

  @override
  List<ConnectedUser> build() {
    final repository = ref.watch(presenceRepositoryProvider);
    final networkStatus = ref.watch(networkStatusNotifierProvider);
    final currentUser = ref.watch(currentUserProvider);
    final prefs = ref.watch(sharedPreferencesProvider);

    // 1. Escuchamos el stream del repositorio para actualizar el estado AUTOMÁTICAMENTE
    final subscription = repository.onlineUsers.listen((users) {
      state = users; // Esto actualiza el estado cuando llega data nueva
    });
    ref.onDispose(() => subscription.cancel());

    // 2. Lógica de Identidad
    String myId;
    String? myName;
    String? myPhotoUrl;

    if (currentUser != null) {
      myId = currentUser.id;
      myName = currentUser.userMetadata?['full_name'];
      myPhotoUrl = currentUser.userMetadata?['avatar_url'] 
          ?? currentUser.userMetadata?['picture'] 
          ?? currentUser.userMetadata?['image'];
    } else {
      String? storedAnonId = prefs.getString(_kAnonIdKey);
      if (storedAnonId == null) {
        storedAnonId = 'anon-${DateTime.now().millisecondsSinceEpoch}';
        prefs.setString(_kAnonIdKey, storedAnonId);
      }
      myId = storedAnonId;
      myName = null;
      myPhotoUrl = null;
    }

    // 3. Orquestación
    if (networkStatus == NetworkStatus.offline) {
      repository.disconnect();
      return []; 
    } else {
      // Ordenamos conectar
      repository.connectAndTrack(
        myId: myId,
        myName: myName,
        myPhotoUrl: myPhotoUrl,
      );
      
      // CORRECCIÓN CRÍTICA AQUÍ:
      // Devolvemos una lista vacía inicial.
      // NO devolvemos 'state' porque aún no se ha inicializado.
      // La data real llegará a través del 'subscription' de arriba.
      return []; 
    }
  }
}