// Archivo: lib/features/comments/presentation/widgets/comment_card.dart
import 'package:flutter/material.dart';
import 'package:prueba_de_riverpod/features/comments/presentation/providers/comments_provider.dart';
import 'package:intl/intl.dart';

class CommentCard extends StatelessWidget {
  final Comment comment;
  
  const CommentCard({
    super.key,
    required this.comment,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Formateador de tiempo relativo (ej: "hace 5 minutos")
    final timeAgo = DateFormat.yMd().add_Hm().format(comment.createdAt);

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 8.0),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar del Usuario
          CircleAvatar(
            radius: 24,
            backgroundImage: comment.avatarUrl != null 
                ? NetworkImage(comment.avatarUrl!) 
                : const AssetImage('assets/images/user_placeholder.png') as ImageProvider,
            backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
            child: comment.avatarUrl == null 
                ? Icon(Icons.person, color: theme.colorScheme.primary) 
                : null,
          ),
          const SizedBox(width: 16),
          
          // Contenido y Metadatos
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Nombre y Fecha
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      comment.userName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Contenido del Comentario
                Text(
                  comment.content,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}