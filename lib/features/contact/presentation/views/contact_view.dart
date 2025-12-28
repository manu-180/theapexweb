// Archivo: lib/features/contact/presentation/views/contact_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:prueba_de_riverpod/core/widgets/responsive_builder.dart';
import 'package:prueba_de_riverpod/features/auth/presentation/providers/auth_providers.dart';
import 'package:prueba_de_riverpod/features/auth/presentation/widgets/auth_modal.dart';
import 'package:prueba_de_riverpod/features/comments/presentation/providers/comments_provider.dart';
import 'package:prueba_de_riverpod/features/comments/presentation/widgets/comment_card.dart';
import 'package:prueba_de_riverpod/features/shared/widgets/footer.dart';

class ContactView extends StatelessWidget {
  const ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            ResponsiveBuilder(
              desktop: (context) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _ContactForm()),
                    SizedBox(width: 80),
                    Expanded(child: _CommentsSection()),
                  ],
                ),
              ),
              mobile: (context) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Column(
                  children: [
                    _ContactForm(),
                    SizedBox(height: 40),
                    _CommentsSection(),
                  ],
                ),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }
}

class _ContactForm extends StatelessWidget {
  const _ContactForm();
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hablemos de tu proyecto!',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
          ),
          const SizedBox(height: 10),
          Text(
            'Si tienes una consulta directa o un requerimiento específico, usa este formulario. Contesto en menos de 24 horas.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 30),
          const TextField(decoration: InputDecoration(labelText: 'Tu Nombre', border: OutlineInputBorder())),
          const SizedBox(height: 15),
          const TextField(decoration: InputDecoration(labelText: 'Tu Email', border: OutlineInputBorder())),
          const SizedBox(height: 15),
          const TextField(maxLines: 5, decoration: InputDecoration(labelText: 'Mensaje', border: OutlineInputBorder())),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Formulario de email no implementado aún.')));
            },
            icon: const Icon(Icons.send),
            label: const Text('Enviar Mensaje'),
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15)),
          ),
        ],
      ),
    );
  }
}

class _CommentsSection extends ConsumerStatefulWidget {
  const _CommentsSection();
  @override
  ConsumerState<_CommentsSection> createState() => __CommentsSectionState();
}

class __CommentsSectionState extends ConsumerState<_CommentsSection> {
  final _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  bool _isPosting = false;
  Comment? _replyingTo;
  int _selectedRating = 5; 

  void _onReply(Comment comment) {
    _checkAuthOrExecute(() {
      setState(() => _replyingTo = comment);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        FocusScope.of(context).requestFocus(_focusNode);
      });
    });
  }

  void _checkAuthOrExecute(VoidCallback action) {
    final user = ref.read(currentUserProvider);
    if (user != null) {
      action();
    } else {
      showDialog(context: context, builder: (_) => const AuthRequiredModal());
    }
  }

  void _cancelReply() {
    setState(() => _replyingTo = null);
  }

  void _postComment() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      showDialog(context: context, builder: (_) => const AuthRequiredModal());
      return;
    }

    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    
    setState(() => _isPosting = true);

    try {
      final ratingToSend = _replyingTo == null ? _selectedRating : null;

      await ref.read(commentsNotifierProvider.notifier).postComment(
        content,
        parentId: _replyingTo?.id,
        rating: ratingToSend, 
      );
      
      _commentController.clear();
      _cancelReply();
      if (mounted) setState(() => _selectedRating = 5);
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(commentsNotifierProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // --- CÁLCULO DE PROMEDIO ---
    double averageRating = 0;
    int totalRatings = 0;
    int totalCommentsCount = 0;

    commentsState.whenData((comments) {
      totalCommentsCount = comments.length + comments.fold(0, (sum, c) => sum + c.replies.length);
      final ratedComments = comments.where((c) => c.rating != null).toList();
      if (ratedComments.isNotEmpty) {
        final sum = ratedComments.fold(0, (prev, c) => prev + c.rating!);
        averageRating = sum / ratedComments.length;
        totalRatings = ratedComments.length;
      }
    });

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header con Promedio
          Row(
            children: [
              Text(
                'Reseñas',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 12),
              if (totalRatings > 0) ...[
                Text(
                  averageRating.toStringAsFixed(1),
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold, color: Colors.amber),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.star, color: Colors.amber, size: 24),
                const SizedBox(width: 8),
                Text(
                  '($totalRatings)',
                  style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
              ] else 
                 Text(
                  '($totalCommentsCount)',
                  style: theme.textTheme.titleMedium?.copyWith(color: colorScheme.onSurfaceVariant),
                ),
            ],
          ),
          const SizedBox(height: 20),

          // Selector de Estrellas
          if (_replyingTo == null) 
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                children: [
                  Text("Tu valoración:", style: theme.textTheme.labelLarge),
                  const SizedBox(width: 10),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(5, (index) {
                      final starIndex = index + 1;
                      return GestureDetector(
                        onTap: () => _checkAuthOrExecute(() => setState(() => _selectedRating = starIndex)),
                        child: Icon(
                          starIndex <= _selectedRating ? Icons.star_rounded : Icons.star_outline_rounded,
                          color: Colors.amber,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),

          if (_replyingTo != null)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: colorScheme.secondaryContainer.withOpacity(0.5),
                borderRadius: BorderRadius.circular(8),
                border: Border(left: BorderSide(color: colorScheme.primary, width: 3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.reply, size: 16, color: colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: [
                          const TextSpan(text: 'Respondiendo a '),
                          TextSpan(
                            text: _replyingTo!.userName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed: _cancelReply,
                    tooltip: 'Cancelar respuesta',
                  )
                ],
              ),
            ),

          // Input de Texto con Modal de Auth
          GestureDetector(
            onTap: () {
               if (!_focusNode.hasFocus) {
                 _checkAuthOrExecute(() => _focusNode.requestFocus());
               }
            },
            child: TextField(
              controller: _commentController,
              focusNode: _focusNode,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: _replyingTo != null 
                    ? 'Escribe tu respuesta...' 
                    : 'Cuéntanos tu experiencia...',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colorScheme.surface,
                suffixIcon: _isPosting
                    ? const Padding(padding: EdgeInsets.all(12.0), child: CircularProgressIndicator(strokeWidth: 2))
                    : IconButton(
                        icon: const Icon(Icons.send),
                        color: colorScheme.primary,
                        onPressed: _postComment,
                      ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          
          commentsState.when(
            loading: () => const _SkeletonList(),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (comments) {
              if (comments.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      Icon(Icons.rate_review_outlined, size: 40, color: colorScheme.outline),
                      const SizedBox(height: 10),
                      const Text('Sé el primero en dejar una reseña.'),
                    ],
                  ),
                );
              }
              return Column(
                children: comments.map((comment) => CommentCard(
                  comment: comment, 
                  onReply: _onReply, 
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest,
      highlightColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: List.generate(3, (index) => Container(
          margin: const EdgeInsets.only(bottom: 20),
          height: 100,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        )),
      ),
    );
  }
}