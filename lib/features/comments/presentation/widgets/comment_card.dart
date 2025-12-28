// Archivo: lib/features/comments/presentation/widgets/comment_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prueba_de_riverpod/features/auth/presentation/providers/auth_providers.dart';
import 'package:prueba_de_riverpod/features/comments/presentation/providers/comments_provider.dart';

// --- CONFIGURACIÓN ---
// Reemplaza esto con tu User UID de Supabase (Authentication -> Users)
// para que tu tarjeta tenga el estilo de "Admin/Autor".
const String OWNER_UUID = '37dad3e9-531c-4657-8db6-ddebbdcfa878'; 

class CommentCard extends ConsumerWidget {
  final Comment comment;
  final Function(Comment) onReply; // Callback para cuando pulsan "Responder"
  
  const CommentCard({
    super.key,
    required this.comment,
    required this.onReply,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    // Detectamos si este comentario es del dueño del sitio
    final bool isAdmin = comment.userId == OWNER_UUID; 
    
    // Estilos dinámicos para el Admin
    final cardColor = isAdmin 
        ? colorScheme.primary.withOpacity(0.05) 
        : Colors.transparent;
        
    final borderColor = isAdmin 
        ? colorScheme.primary.withOpacity(0.3) 
        : Colors.transparent;

    return Column(
      children: [
        // --- TARJETA PRINCIPAL ---
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: cardColor,
            border: Border.all(color: borderColor),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. AVATAR
              _buildAvatar(comment.avatarUrl, isAdmin, colorScheme),
              const SizedBox(width: 12),
              
              // 2. CONTENIDO
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header: Nombre + Tiempo + (Admin Badge)
                    Row(
                      children: [
                        Text(
                          comment.userName,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: isAdmin ? colorScheme.primary : colorScheme.onSurface,
                          ),
                        ),
                        if (isAdmin) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              "Admin",
                              style: TextStyle(
                                fontSize: 10, 
                                fontWeight: FontWeight.bold, 
                                color: colorScheme.onPrimary
                              ),
                            ),
                          )
                        ],
                        const Spacer(),
                        Text(
                          _timeAgo(comment.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    
                    // Texto del Comentario
                    Text(
                      comment.content,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Footer: Acciones (Like / Reply)
                    Row(
                      children: [
                        // Botón LIKE
                        _LikeButton(comment: comment),
                        
                        const SizedBox(width: 16),
                        
                        // Botón REPLY
                        InkWell(
                          onTap: () => onReply(comment),
                          borderRadius: BorderRadius.circular(4),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                            child: Text(
                              "Responder",
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // --- RECURSIVIDAD: HILOS DE RESPUESTAS ---
        // Si hay respuestas, las mostramos indentadas (margen a la izquierda)
        if (comment.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 44.0), // Indentación
            child: Column(
              children: comment.replies.map((reply) => CommentCard(
                comment: reply,
                onReply: onReply, // Pasamos el mismo callback hacia abajo
              )).toList(),
            ),
          ),
      ],
    );
  }

  Widget _buildAvatar(String? url, bool isAdmin, ColorScheme colors) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: isAdmin ? Border.all(color: colors.primary, width: 2) : null,
      ),
      child: CircleAvatar(
        radius: 18,
        backgroundImage: url != null ? NetworkImage(url) : null,
        backgroundColor: colors.surfaceContainerHighest,
        child: url == null 
          ? Icon(Icons.person, size: 18, color: colors.onSurfaceVariant) 
          : null,
      ),
    );
  }

  // Helper simple para fechas relativas
  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 365) return "${(diff.inDays / 365).floor()}a";
    if (diff.inDays > 30) return "${(diff.inDays / 30).floor()}mes";
    if (diff.inDays > 0) return "${diff.inDays}d";
    if (diff.inHours > 0) return "${diff.inHours}h";
    if (diff.inMinutes > 0) return "${diff.inMinutes}m";
    return "ahora";
  }
}

// Widget interno optimizado para el botón de Like
class _LikeButton extends ConsumerWidget {
  final Comment comment;
  const _LikeButton({required this.comment});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLiked = comment.isLikedByMe;

    return InkWell(
      onTap: () async {
        try {
          // Llamada optimista al provider
          await ref.read(commentsNotifierProvider.notifier).toggleLike(comment.id);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Inicia sesión para dar Like")),
          );
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
              size: 14,
              color: isLiked ? Colors.redAccent : colorScheme.onSurfaceVariant,
            ),
            if (comment.likesCount > 0) ...[
              const SizedBox(width: 6),
              Text(
                "${comment.likesCount}",
                style: theme.textTheme.labelSmall?.copyWith(
                  color: isLiked ? Colors.redAccent : colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}