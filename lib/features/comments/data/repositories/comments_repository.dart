// Archivo: lib/features/comments/data/repositories/comments_repository.dart
import 'dart:async';
import 'package:apex/core/providers/supabase_providers.dart';
import 'package:apex/features/comments/domain/models/comment_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'comments_repository.g.dart';

// Tu ID de administrador para anclar tus comentarios
const String _kOwnerUuid = '37dad3e9-531c-4657-8db6-ddebbdcfa878';

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
    // 1. Fetch crudo ordenado por FECHA (más reciente primero)
    final response = await _supabase
        .from('comments_with_metadata') 
        .select()
        .order('created_at', ascending: false) // <--- CAMBIO: Orden cronológico inverso
        .limit(50);

    final flatList = (response as List).map((json) => Comment.fromJson(json)).toList();

    // 2. Reconstrucción del Árbol
    final List<Comment> parents = [];
    final Map<int, List<Comment>> childrenMap = {};

    for (var c in flatList) {
      if (c.parentId == null) {
        parents.add(c);
      } else {
        childrenMap.putIfAbsent(c.parentId!, () => []).add(c);
      }
    }

    // 3. Procesamiento final (Asignar hijos y Ordenar Admin)
    final processedParents = parents.map((p) {
      final replies = childrenMap[p.id] ?? [];
      // Las respuestas se suelen leer cronológicamente (antiguas arriba)
      replies.sort((a, b) => a.createdAt.compareTo(b.createdAt)); 
      return p.copyWith(replies: replies);
    }).toList();

    // 4. LÓGICA DE ANCLAJE (PINNED COMMENT)
    // Buscamos si existe un comentario tuyo (Admin)
    final adminIndex = processedParents.indexWhere((c) => c.userId == _kOwnerUuid);
    
    if (adminIndex > 0) {
      // Si existe y no está primero, lo sacamos y lo ponemos al inicio
      final adminComment = processedParents.removeAt(adminIndex);
      processedParents.insert(0, adminComment);
    }

    return processedParents;
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
    final maybeLike = await _supabase
        .from('comment_likes')
        .select()
        .eq('user_id', userId)
        .eq('comment_id', commentId)
        .maybeSingle();

    if (maybeLike != null) {
      await _supabase.from('comment_likes').delete().eq('user_id', userId).eq('comment_id', commentId);
    } else {
      await _supabase.from('comment_likes').insert({'user_id': userId, 'comment_id': commentId});
    }
  }
}

@riverpod
CommentsRepository commentsRepository(CommentsRepositoryRef ref) {
  final supabase = ref.watch(supabaseClientProvider);
  final repo = CommentsRepository(supabase);
  
  ref.onDispose(() => repo.dispose());
  
  return repo;
}