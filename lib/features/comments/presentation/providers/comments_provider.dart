// Archivo: lib/features/comments/presentation/providers/comments_provider.dart
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:apex/features/auth/presentation/providers/auth_providers.dart';
import 'package:apex/features/comments/domain/models/comment_model.dart';
import 'package:apex/features/comments/data/repositories/comments_repository.dart';

export 'package:apex/features/comments/domain/models/comment_model.dart';

part 'comments_provider.g.dart';

// Mismo UUID que en el repo para mantener consistencia
const String _kOwnerUuid = '37dad3e9-531c-4657-8db6-ddebbdcfa878';

@riverpod
class CommentsNotifier extends _$CommentsNotifier {
  
  @override
  Future<List<Comment>> build() async {
    final repository = ref.watch(commentsRepositoryProvider);
    
    final sub = repository.onDataChanged.listen((_) {
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

    // --- ACTUALIZACIÓN OPTIMISTA INTELIGENTE ---
    final tempId = -DateTime.now().millisecondsSinceEpoch; 
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
      // LOGICA DE INSERCIÓN ROOT
      final List<Comment> newList = List.from(currentList);
      final bool isAdminPinned = newList.isNotEmpty && newList.first.userId == _kOwnerUuid;
      final bool amIAdmin = user.id == _kOwnerUuid;

      if (amIAdmin) {
        // Si TÚ comentas, vas arriba de todo (incluso arriba de tu comentario anterior pinned si quisieras, 
        // o simplemente al tope).
        newList.insert(0, newComment);
      } else if (isAdminPinned) {
        // Si hay un admin pinned, el nuevo comentario va SEGUNDO (index 1)
        newList.insert(1, newComment);
      } else {
        // Si no hay admin, va PRIMERO
        newList.insert(0, newComment);
      }
      
      state = AsyncData(newList);
    } else {
      // LOGICA DE RESPUESTA (Sin cambios, se agrega al final de las respuestas)
      final updatedList = currentList.map((c) {
        if (c.id == parentId) {
          return c.copyWith(replies: [...c.replies, newComment]);
        }
        return c;
      }).toList();
      state = AsyncData(updatedList);
    }
    // -------------------------------------------

    try {
      await repository.postComment(
        userId: user.id,
        content: content,
        parentId: parentId,
        rating: rating,
      );
    } catch (e) {
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

    List<Comment> updateList(List<Comment> list) {
      return list.map((c) {
        if (c.id == commentId) {
          final newStatus = !c.isLikedByMe;
          return c.copyWith(
            isLikedByMe: newStatus,
            likesCount: newStatus ? c.likesCount + 1 : c.likesCount - 1,
          );
        }
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

    try {
       await repository.toggleLike(user.id, commentId);
    } catch (e) {
      state = previousState; 
      rethrow;
    }
  }
}