// Archivo: lib/features/comments/presentation/widgets/comment_card.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prueba_de_riverpod/features/auth/presentation/providers/auth_providers.dart';
import 'package:prueba_de_riverpod/features/auth/presentation/widgets/auth_modal.dart';
import 'package:prueba_de_riverpod/features/comments/presentation/providers/comments_provider.dart';

// RECUERDA: Reemplaza esto con tu User UID real de Supabase
const String OWNER_UUID = 'TU_UUID_DE_SUPABASE_AQUI'; 

class CommentCard extends ConsumerStatefulWidget {
  final Comment comment;
  final Function(Comment) onReply;
  
  const CommentCard({
    super.key,
    required this.comment,
    required this.onReply,
  });

  @override
  ConsumerState<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends ConsumerState<CommentCard> {
  bool _showReplies = false;

  void _toggleReplies() {
    if (widget.comment.replies.isNotEmpty) {
      setState(() => _showReplies = !_showReplies);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final comment = widget.comment;
    
    final bool isAdmin = comment.userId == OWNER_UUID; 
    
    final cardColor = isAdmin 
        ? colorScheme.primary.withOpacity(0.08) 
        : colorScheme.surfaceContainerLow;      
        
    final borderColor = isAdmin 
        ? colorScheme.primary.withOpacity(0.4) 
        : colorScheme.outline.withOpacity(0.15); 

    return Column(
      children: [
        GestureDetector(
          onTap: _toggleReplies, 
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: cardColor, 
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(16), 
              boxShadow: isAdmin ? [ 
                BoxShadow(
                  color: colorScheme.primary.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ] : null,
            ),
            padding: const EdgeInsets.all(16), 
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(comment.avatarUrl, isAdmin, colorScheme),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        children: [
                          Text(
                            comment.userName,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isAdmin ? colorScheme.primary : colorScheme.onSurface,
                            ),
                          ),
                          // Estrellas
                          if (comment.rating != null) ...[
                            const SizedBox(width: 8),
                            Row(
                              children: List.generate(comment.rating!, (index) => 
                                const Icon(Icons.star_rounded, size: 14, color: Colors.amber)
                              ),
                            )
                          ],
                          
                          if (isAdmin) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: colorScheme.primary.withOpacity(0.5)),
                              ),
                              child: Text(
                                "Admin",
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: colorScheme.primary),
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
                      const SizedBox(height: 8),
                      // Contenido
                      Text(
                        comment.content,
                        style: theme.textTheme.bodyMedium?.copyWith(height: 1.5, fontSize: 15),
                      ),
                      const SizedBox(height: 12),
                      
                      // Acciones
                      Row(
                        children: [
                          _LikeButton(comment: comment),
                          
                          if (comment.parentId == null) ...[
                            const SizedBox(width: 20),
                            InkWell(
                              onTap: () => widget.onReply(comment), 
                              borderRadius: BorderRadius.circular(4),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                child: Row(
                                  children: [
                                    Icon(Icons.reply_rounded, size: 14, color: colorScheme.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Text(
                                      "Responder",
                                      style: theme.textTheme.labelSmall?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                          
                          if (comment.replies.isNotEmpty && !_showReplies) ...[
                             const Spacer(),
                             Container(
                               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                               decoration: BoxDecoration(
                                 color: colorScheme.surfaceContainerHighest,
                                 borderRadius: BorderRadius.circular(10),
                               ),
                               child: Text(
                                 "${comment.replies.length} respuestas",
                                 style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                               ),
                             ),
                          ]
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // Acordeón de Respuestas
        if (_showReplies && comment.replies.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(left: 40.0), 
            child: Column(
              children: comment.replies.map((reply) => CommentCard(
                comment: reply,
                onReply: widget.onReply, 
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
        boxShadow: isAdmin ? [BoxShadow(color: colors.primary.withOpacity(0.2), blurRadius: 8)] : null,
      ),
      child: CircleAvatar(
        radius: 20, 
        backgroundImage: url != null ? NetworkImage(url) : null,
        backgroundColor: colors.surfaceContainerHighest,
        child: url == null 
          ? Icon(Icons.person, size: 20, color: colors.onSurfaceVariant) 
          : null,
      ),
    );
  }

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
        final user = ref.read(currentUserProvider);
        if (user == null) {
           showDialog(context: context, builder: (_) => const AuthRequiredModal());
           return;
        }

        try {
          await ref.read(commentsNotifierProvider.notifier).toggleLike(comment.id);
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        }
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isLiked ? Colors.red.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, anim) => ScaleTransition(scale: anim, child: child),
              child: Icon(
                isLiked ? FontAwesomeIcons.solidHeart : FontAwesomeIcons.heart,
                key: ValueKey(isLiked),
                size: 14,
                color: isLiked ? Colors.redAccent : colorScheme.onSurfaceVariant,
              ),
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