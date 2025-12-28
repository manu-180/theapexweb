// Archivo: lib/features/comments/presentation/providers/comments_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:prueba_de_riverpod/core/providers/supabase_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prueba_de_riverpod/features/auth/presentation/providers/auth_providers.dart';

part 'comments_provider.g.dart';

/// Modelo optimizado para trabajar con la vista SQL 'comments_with_metadata'.
/// Incluye soporte para likes, respuestas anidadas y estado del usuario actual.
class Comment {
  final int id;
  final String content;
  final String userName;
  final String? avatarUrl;
  final DateTime createdAt;
  final int likesCount;
  final bool isLikedByMe;
  final int? parentId;
  final String userId; 
  final List<Comment> replies; // Lista de respuestas (hijos)

  Comment({
    required this.id,
    required this.content,
    required this.userName,
    this.avatarUrl,
    required this.createdAt,
    required this.likesCount,
    required this.isLikedByMe,
    this.parentId,
    required this.userId,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      // La vista SQL ya nos devuelve el nombre del perfil o un fallback
      userName: json['user_name'] ?? 'Usuario Anónimo',
      avatarUrl: json['avatar_url'],
      likesCount: json['likes_count'] ?? 0,
      isLikedByMe: json['is_liked_by_me'] ?? false,
      parentId: json['parent_id'],
      userId: json['user_id'],
    );
  }
  
  // Método copyWith para facilitar actualizaciones optimistas o anidación
  Comment copyWith({List<Comment>? replies}) {
    return Comment(
      id: id,
      content: content,
      userName: userName,
      avatarUrl: avatarUrl,
      createdAt: createdAt,
      likesCount: likesCount,
      isLikedByMe: isLikedByMe,
      parentId: parentId,
      userId: userId,
      replies: replies ?? this.replies,
    );
  }
}

/// Provider encargado de la lógica de negocio de los comentarios.
/// Maneja la carga inicial, suscripciones en tiempo real y acciones (post/like).
@riverpod
class CommentsNotifier extends _$CommentsNotifier {
  late final SupabaseClient _supabase;
  // Guardamos las suscripciones de Realtime para poder limpiarlas correctamente
  final List<RealtimeChannel> _subscriptions = [];

  @override
  Future<List<Comment>> build() async {
    _supabase = ref.watch(supabaseClientProvider);
    
    // 1. Limpieza de seguridad: Cancelamos suscripciones anteriores si hubo un hot-reload
    for (var sub in _subscriptions) { await sub.unsubscribe(); }
    _subscriptions.clear();

    // 2. Iniciamos la escucha de cambios en la DB (Realtime)
    _startRealtimeSubscription();

    // 3. Cargamos los datos iniciales
    return _fetchComments();
  }

  /// Configura los canales de Realtime de Supabase
  void _startRealtimeSubscription() {
    // Canal para cambios en la tabla de comentarios (inserts, deletes)
    final subComments = _supabase.channel('public:comments').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'comments',
      callback: (payload) {
        // Al detectar cualquier cambio, invalidamos el provider para refescar la lista
        // Esto fuerza una nueva llamada a _fetchComments() automáticamente
        ref.invalidateSelf(); 
      },
    ).subscribe();

    // Canal para cambios en los likes (inserts, deletes)
    final subLikes = _supabase.channel('public:comment_likes').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'comment_likes',
      callback: (payload) {
        // Refrescamos para actualizar contadores y estados de "liked"
        ref.invalidateSelf();
      },
    ).subscribe();

    _subscriptions.addAll([subComments, subLikes]);
  }

  /// Recupera los comentarios desde la VISTA SQL y los estructura en árbol (Padre -> Hijos)
  Future<List<Comment>> _fetchComments() async {
    try {
      // IMPORTANTE: Consultamos la VISTA 'comments_with_metadata', NO la tabla cruda.
      final response = await _supabase
          .from('comments_with_metadata') 
          .select()
          .order('created_at', ascending: false); // Traemos los más recientes primero

      // Convertimos la respuesta cruda a objetos Comment
      final flatList = (response as List).map((json) => Comment.fromJson(json)).toList();

      // ALGORITMO DE AGRUPACIÓN (Nivel 1 de profundidad)
      final List<Comment> parents = [];
      final Map<int, List<Comment>> childrenMap = {};

      for (var c in flatList) {
        if (c.parentId == null) {
          // Es un comentario raíz
          parents.add(c);
        } else {
          // Es una respuesta, lo guardamos en el mapa usando el ID del padre como clave
          childrenMap.putIfAbsent(c.parentId!, () => []).add(c);
        }
      }

      // Asignamos las listas de hijos a cada padre
      return parents.map((p) {
        final replies = childrenMap[p.id] ?? [];
        // Ordenamos las respuestas cronológicamente (más viejas arriba, estilo hilo de conversación)
        replies.sort((a, b) => a.createdAt.compareTo(b.createdAt)); 
        return p.copyWith(replies: replies);
      }).toList();

    } catch (e) {
      debugPrint("Error fetching comments: $e");
      // En caso de error, devolvemos lista vacía para no romper la UI, pero logueamos el fallo
      return []; 
    }
  }

  /// Publica un nuevo comentario o una respuesta
  Future<void> postComment(String content, {int? parentId}) async {
    final user = ref.read(currentUserProvider);
    if (user == null) throw Exception('Debes iniciar sesión para comentar.');

    try {
      await _supabase.from('comments').insert({
        'user_id': user.id,
        'content': content,
        'parent_id': parentId, // Si es null, es comentario raíz; si tiene ID, es respuesta
      });
      // No necesitamos actualizar el estado manualmente, el Realtime disparará la recarga.
    } catch (e) {
      throw Exception('Error al publicar comentario: ${e.toString()}');
    }
  }

  /// Alterna el estado de "Me gusta" (Like/Dislike)
  Future<void> toggleLike(int commentId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) throw Exception('Debes iniciar sesión para dar like.');

    try {
       // 1. Verificamos si el like ya existe en la DB
       final maybeLike = await _supabase
           .from('comment_likes')
           .select()
           .eq('user_id', user.id)
           .eq('comment_id', commentId)
           .maybeSingle();

       if (maybeLike != null) {
         // 2. Si existe, lo borramos (Dislike)
         await _supabase
             .from('comment_likes')
             .delete()
             .eq('user_id', user.id)
             .eq('comment_id', commentId);
       } else {
         // 3. Si no existe, lo insertamos (Like)
         await _supabase
             .from('comment_likes')
             .insert({
               'user_id': user.id,
               'comment_id': commentId,
             });
       }
    } catch (e) {
      debugPrint('Error toggling like: $e');
      throw Exception('Error al procesar el like.');
    }
  }
}