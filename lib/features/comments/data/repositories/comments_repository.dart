// Archivo: lib/features/comments/data/repositories/comments_repository.dart
import 'dart:async';
import 'package:apex/core/providers/supabase_providers.dart';
import 'package:apex/features/comments/domain/models/comment_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'comments_repository.g.dart';

class CommentsRepository {
  final SupabaseClient _supabase;
  final StreamController<void> _dataChangeController = StreamController.broadcast();
  final List<RealtimeChannel> _subscriptions = [];

  CommentsRepository(this._supabase) {
    _initRealtime();
  }

  // Exponemos un stream simple para notificar cambios externos
  Stream<void> get onDataChanged => _dataChangeController.stream;

  void _initRealtime() {
    // Escuchamos cambios en 'comments'
    final subComments = _supabase.channel('public:comments').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'comments',
      callback: (_) => _dataChangeController.add(null),
    ).subscribe();

    // Escuchamos cambios en 'comment_likes'
    final subLikes = _supabase.channel('public:comment_likes').onPostgresChanges(
      event: PostgresChangeEvent.all,
      schema: 'public',
      table: 'comment_likes',
      callback: (_) => _dataChangeController.add(null),
    ).subscribe();

    _subscriptions.addAll([subComments, subLikes]);
  }

  void dispose() {
    for (var sub in _subscriptions) {
      sub.unsubscribe();
    }
    _dataChangeController.close();
  }

  Future<List<Comment>> fetchComments() async {
    // 1. Fetch crudo con límite de seguridad
    final response = await _supabase
        .from('comments_with_metadata') 
        .select()
        .order('likes_count', ascending: false)
        .order('created_at', ascending: false)
        .limit(50);

    final flatList = (response as List).map((json) => Comment.fromJson(json)).toList();

    // 2. Reconstrucción del Árbol (Lógica de Transformación)
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
  }

  Future<void> postComment({
    required String userId,
    required String content,
    int? parentId,
    int? rating,
  }) async {
    await _supabase.from('comments').insert({
      'user_id': userId,
      'content': content,
      'parent_id': parentId, 
      'rating': rating,
    });
  }

  Future<void> toggleLike(String userId, int commentId) async {
    // Verificamos si ya existe el like
    final maybeLike = await _supabase
        .from('comment_likes')
        .select()
        .eq('user_id', userId)
        .eq('comment_id', commentId)
        .maybeSingle();

    if (maybeLike != null) {
      // Si existe, lo borramos
      await _supabase.from('comment_likes').delete().eq('user_id', userId).eq('comment_id', commentId);
    } else {
      // Si no existe, lo creamos
      await _supabase.from('comment_likes').insert({'user_id': userId, 'comment_id': commentId});
    }
  }
}

@riverpod
CommentsRepository commentsRepository(CommentsRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final repo = CommentsRepository(supabase);
  
  // Limpieza automática al destruir el provider
  ref.onDispose(() => repo.dispose());
  
  return repo;
}