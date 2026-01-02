// Archivo: lib/features/comments/presentation/providers/comments_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:apex/features/auth/presentation/providers/auth_providers.dart';
import 'package:apex/features/comments/domain/models/comment_model.dart';
import 'package:apex/features/comments/data/repositories/comments_repository.dart';
// Exportamos el modelo para que los archivos viejos no se rompan si importaban solo este archivo
export 'package:apex/features/comments/domain/models/comment_model.dart';

part 'comments_provider.g.dart';

@riverpod
class CommentsNotifier extends _$CommentsNotifier {
  
  @override
  Future<List<Comment>> build() async {
    final repository = ref.watch(commentsRepositoryProvider);
    
    // Escucha pasiva de cambios en tiempo real desde el repositorio
    // Usamos 'listen' en lugar de watch para evitar reconstrucciones innecesarias del repositorio
    final sub = repository.onDataChanged.listen((_) {
      // Cuando el repositorio avisa que hubo cambios, invalidamos este provider
      // para que vuelva a ejecutar build() y traiga la data fresca.
      ref.invalidateSelf();
    });
    
    ref.onDispose(() => sub.cancel());

    return repository.fetchComments();
  }

  Future<void> postComment(String content, {int? parentId, int? rating}) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      throw const AuthException('Tu sesión ha expirado. Por favor, inicia sesión nuevamente.');
    }
    
    final repository = ref.read(commentsRepositoryProvider);
    final previousState = state;
    final currentList = state.valueOrNull ?? [];

    // --- ACTUALIZACIÓN OPTIMISTA ---
    final tempId = -DateTime.now().millisecondsSinceEpoch; // ID temporal negativo
    final newComment = Comment(
      id: tempId,
      content: content,
      userName: user.userMetadata?['full_name'] ?? 'Yo',
      userId: user.id,
      avatarUrl: user.userMetadata?['avatar_url'],
      createdAt: DateTime.now(),
      likesCount: 0,
      isLikedByMe: false,
      parentId: parentId,
      rating: rating,
      replies: [],
    );

    if (parentId == null) {
      state = AsyncData([newComment, ...currentList]);
    } else {
      final updatedList = currentList.map((c) {
        if (c.id == parentId) {
          return c.copyWith(replies: [...c.replies, newComment]);
        }
        return c;
      }).toList();
      state = AsyncData(updatedList);
    }
    // -------------------------------

    try {
      await repository.postComment(
        userId: user.id,
        content: content,
        parentId: parentId,
        rating: rating,
      );
      // No necesitamos hacer nada si tiene éxito, el Realtime disparará la actualización real
    } catch (e) {
      // Si falla, revertimos al estado anterior
      state = previousState; 
      rethrow;
    }
  }

  Future<void> toggleLike(int commentId) async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
       throw const AuthException('Debes iniciar sesión para dar like.');
    }

    final repository = ref.read(commentsRepositoryProvider);
    final previousState = state;
    final currentList = state.valueOrNull ?? [];

    // --- ACTUALIZACIÓN OPTIMISTA ---
    List<Comment> updateList(List<Comment> list) {
      return list.map((c) {
        if (c.id == commentId) {
          final newStatus = !c.isLikedByMe;
          return c.copyWith(
            isLikedByMe: newStatus,
            likesCount: newStatus ? c.likesCount + 1 : c.likesCount - 1,
          );
        }
        // Buscamos también en las respuestas
        if (c.replies.any((r) => r.id == commentId)) {
          final newReplies = c.replies.map((r) {
             if (r.id == commentId) {
               final newStatus = !r.isLikedByMe;
               return r.copyWith(
                 isLikedByMe: newStatus,
                 likesCount: newStatus ? r.likesCount + 1 : r.likesCount - 1,
               );
             }
             return r;
          }).toList();
          return c.copyWith(replies: newReplies);
        }
        return c;
      }).toList();
    }
    state = AsyncData(updateList(currentList));
    // -------------------------------

    try {
       await repository.toggleLike(user.id, commentId);
    } catch (e) {
      state = previousState; 
      rethrow;
    }
  }
}