// Archivo: lib/features/comments/presentation/providers/comments_provider.dart

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:prueba_de_riverpod/core/providers/supabase_providers.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:prueba_de_riverpod/features/auth/presentation/providers/auth_providers.dart'; 

part 'comments_provider.g.dart';

/// Modelo simple para la respuesta de Comentarios.
class Comment {
  final int id;
  final String content;
  final String userName;
  final String? avatarUrl;
  final DateTime createdAt;

   Comment({
    required this.id,
    required this.content,
    required this.userName,
    this.avatarUrl,
    required this.createdAt,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final profile = json['profiles'];
    return Comment(
      id: json['id'],
      content: json['content'],
      createdAt: DateTime.parse(json['created_at']),
      // Manejo seguro si profile es null
      userName: profile != null ? (profile['full_name'] ?? profile['username'] ?? 'Usuario Web') : 'Usuario Desconocido',
      avatarUrl: profile?['avatar_url'],
    );
  }
}

/// Provider que gestiona la lógica de la sección de comentarios.
@riverpod
class CommentsNotifier extends _$CommentsNotifier {
  late final SupabaseClient _supabase;
  StreamSubscription<List<Map<String, dynamic>>>? _commentsSubscription;

  @override
  Future<List<Comment>> build() async {
    _commentsSubscription?.cancel(); 
    _supabase = ref.watch(supabaseClientProvider);
    
    _startRealtimeSubscription();
    
    return _fetchComments();
  }
  
  void _startRealtimeSubscription() {
    _commentsSubscription?.cancel();
    _commentsSubscription = _supabase.from('comments').stream(
      primaryKey: ['id']
    ).listen((data) async {
      // Usamos AsyncValue.guard para capturar errores dentro del stream
      state = await AsyncValue.guard(() async => _fetchComments());
    });
  }

  Future<List<Comment>> _fetchComments() async {
    final response = await _supabase
        .from('comments')
        .select('*, profiles (full_name, avatar_url, username)') 
        .order('created_at', ascending: false)
        .limit(20); 

    // Supabase v2 devuelve List<Map<String, dynamic>> directamente
    return response.map((json) => Comment.fromJson(json)).toList();
  }


  Future<void> postComment(String content) async {
    final user = ref.read(currentUserProvider);
    
    if (user == null || user.id == null) {
      throw Exception('Debes iniciar sesión para publicar un comentario.');
    }

    try {
      await _supabase.from('comments').insert({
        'user_id': user.id,
        'content': content,
        'is_approved': true, 
      });
      
    } on PostgrestException catch (e) { 
      throw Exception('Error al publicar comentario: ${e.message}');
    } catch (e) {
      if (kDebugMode) print(e);
      throw Exception('Error desconocido al publicar.');
    }
  }
}