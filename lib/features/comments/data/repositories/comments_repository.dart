// Archivo: lib/features/comments/data/repositories/comments_repository.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:apex/core/providers/supabase_providers.dart';
import 'package:apex/features/comments/domain/models/comment_model.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

part 'comments_repository.g.dart';

// Tu ID de administrador para anclar tus comentarios
const String _kOwnerUuid = '37dad3e9-531c-4657-8db6-ddebbdcfa878';

class CommentsRepository {
  final SupabaseClient? _supabase;
  final StreamController<void> _dataChangeController = StreamController.broadcast();
  final List<RealtimeChannel> _subscriptions = [];

  CommentsRepository(this._supabase) {
    _initRealtime();
  }

  Stream<void> get onDataChanged => _dataChangeController.stream;

  void _initRealtime() {
    if (_supabase == null) return;
    if (kIsWeb) {
      debugPrint('Comments: Web detected - Realtime deshabilitado (sin suscripciones)');
      return;
    }
    try {
      final subComments = _supabase!.channel('public:comments').onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'comments',
        callback: (_) => _dataChangeController.add(null),
      ).subscribe();

      // Escuchamos cambios en 'comment_likes'
      final subLikes = _supabase!.channel('public:comment_likes').onPostgresChanges(
        event: PostgresChangeEvent.all,
        schema: 'public',
        table: 'comment_likes',
        callback: (_) => _dataChangeController.add(null),
      ).subscribe();

      _subscriptions.addAll([subComments, subLikes]);
    } catch (e) {
      debugPrint('Comments: Error al inicializar Realtime - $e');
    }
  }

  void dispose() {
    for (var sub in _subscriptions) {
      sub.unsubscribe();
    }
    _dataChangeController.close();
  }

  Future<List<Comment>> fetchComments() async {
    if (_supabase == null) return [];
    try {
      final rootsResponse = await _supabase!
          .from('comments_with_metadata') 
          .select()
          .filter('parent_id', 'is', null) // <--- CORRECCIÓN ROBUSTA: Usamos .filter explícito
          .order('created_at', ascending: false)
          .limit(50);

      final roots = (rootsResponse as List).map((json) => Comment.fromJson(json)).toList();

      if (roots.isEmpty) return []; 

      // 2. Fetch RESPUESTAS (Hijos) correspondientes a estos padres
      final rootIds = roots.map((c) => c.id).toList();

      final repliesResponse = await _supabase!
          .from('comments_with_metadata')
          .select()
          .filter('parent_id', 'in', rootIds) // <--- CORRECCIÓN ROBUSTA: Usamos .filter explícito
          .order('created_at', ascending: true); 

      final replies = (repliesResponse as List).map((json) => Comment.fromJson(json)).toList();

      // 3. Reconstrucción del Árbol (Mapping)
      final Map<int, List<Comment>> childrenMap = {};
      for (var r in replies) {
        childrenMap.putIfAbsent(r.parentId!, () => []).add(r);
      }

      // 4. Asignación y Lógica de Admin (Pinning)
      final processedParents = roots.map((p) {
        return p.copyWith(replies: childrenMap[p.id] ?? []);
      }).toList();

      // Buscamos si existe un comentario tuyo (Admin) para anclarlo
      final adminIndex = processedParents.indexWhere((c) => c.userId == _kOwnerUuid);
      
      if (adminIndex > 0) {
        final adminComment = processedParents.removeAt(adminIndex);
        processedParents.insert(0, adminComment);
      }

      return processedParents;
      
    } catch (e) {
      // Log de error para depuración
      print("Error crítico fetching comments: $e");
      return []; // Retornamos lista vacía para no romper la UI
    }
  }

  Future<void> postComment({
    required String userId,
    required String content,
    int? parentId,
    int? rating,
  }) async {
    if (_supabase == null) return;
    await _supabase!.from('comments').insert({
      'user_id': userId,
      'content': content,
      'parent_id': parentId, 
      'rating': rating,
    });
  }

  Future<void> toggleLike(String userId, int commentId) async {
    if (_supabase == null) return;
    final maybeLike = await _supabase!
        .from('comment_likes')
        .select()
        .eq('user_id', userId)
        .eq('comment_id', commentId)
        .maybeSingle();

    if (maybeLike != null) {
      await _supabase!.from('comment_likes').delete().eq('user_id', userId).eq('comment_id', commentId);
    } else {
      await _supabase!.from('comment_likes').insert({'user_id': userId, 'comment_id': commentId});
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