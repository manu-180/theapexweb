// Archivo: lib/features/comments/presentation/providers/comments_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:prueba_de_riverpod/core/providers/supabase_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prueba_de_riverpod/features/auth/presentation/providers/auth_providers.dart';

part 'comments_provider.g.dart';

/// Modelo optimizado para trabajar con la vista SQL 'comments_with_metadata'.
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
  final List<Comment> replies;

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
      userName: json['user_name'] ?? 'Usuario Anónimo',
      avatarUrl: json['avatar_url'],
      likesCount: json['likes_count'] ?? 0,
      isLikedByMe: json['is_liked_by_me'] ?? false,
      parentId: json['parent_id'],
      userId: json['user_id'],
    );
  }
  
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

@riverpod
class CommentsNotifier extends _$CommentsNotifier {
  // CORRECCIÓN AQUÍ: Quitamos 'final' para permitir re-asignación en el hot-reload/invalidate
  late SupabaseClient _supabase;
  
  final List<RealtimeChannel> _subscriptions = [];

  @override
  Future<List<Comment>> build() async {
    _supabase = ref.watch(supabaseClientProvider);
    
    // Cancelamos suscripciones anteriores para evitar duplicados al refrescar
    for (var sub in _subscriptions) { await sub.unsubscribe(); }
    _subscriptions.clear();

    _startRealtimeSubscription();

    return _fetchComments();
  }

  void _startRealtimeSubscription() {
    final subComments = _supabase.channel('public:comments').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'comments',
      callback: (payload) {
        ref.invalidateSelf(); 
      },
    ).subscribe();

    final subLikes = _supabase.channel('public:comment_likes').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'comment_likes',
      callback: (payload) {
        ref.invalidateSelf();
      },
    ).subscribe();

    _subscriptions.addAll([subComments, subLikes]);
  }

  Future<List<Comment>> _fetchComments() async {
    try {
      final response = await _supabase
          .from('comments_with_metadata') 
          .select()
          .order('created_at', ascending: false);

      final flatList = (response as List).map((json) => Comment.fromJson(json)).toList();

      final List<Comment> parents = [];
      final Map<int, List<Comment>> childrenMap = {};

      for (var c in flatList) {
        if (c.parentId == null) {
          parents.add(c);
        } else {
          childrenMap.putIfAbsent(c.parentId!, () => []).add(c);
        }
      }

      return parents.map((p) {
        final replies = childrenMap[p.id] ?? [];
        replies.sort((a, b) => a.createdAt.compareTo(b.createdAt)); 
        return p.copyWith(replies: replies);
      }).toList();

    } catch (e) {
      debugPrint("Error fetching comments: $e");
      return []; 
    }
  }

  Future<void> postComment(String content, {int? parentId}) async {
    final user = ref.read(currentUserProvider);
    if (user == null) throw Exception('Debes iniciar sesión para comentar.');

    try {
      await _supabase.from('comments').insert({
        'user_id': user.id,
        'content': content,
        'parent_id': parentId, 
      });
    } catch (e) {
      throw Exception('Error al publicar comentario: ${e.toString()}');
    }
  }

  Future<void> toggleLike(int commentId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) throw Exception('Debes iniciar sesión para dar like.');

    try {
       final maybeLike = await _supabase
           .from('comment_likes')
           .select()
           .eq('user_id', user.id)
           .eq('comment_id', commentId)
           .maybeSingle();

       if (maybeLike != null) {
         await _supabase
             .from('comment_likes')
             .delete()
             .eq('user_id', user.id)
             .eq('comment_id', commentId);
       } else {
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