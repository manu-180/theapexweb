// Archivo: lib/features/presence/domain/models/connected_user_model.dart
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