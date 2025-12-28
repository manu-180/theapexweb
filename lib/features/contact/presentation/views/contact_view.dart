// Archivo: lib/features/contact/presentation/views/contact_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart'; // Asegúrate de tener esta dependencia
import 'package:prueba_de_riverpod/core/widgets/responsive_builder.dart';
import 'package:prueba_de_riverpod/features/auth/presentation/providers/auth_providers.dart';
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

// --- Formulario de Contacto (Placeholder) ---
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
          
          const TextField(
            decoration: InputDecoration(labelText: 'Tu Nombre', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 15),
          const TextField(
            decoration: InputDecoration(labelText: 'Tu Email', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 15),
          const TextField(
            maxLines: 5,
            decoration: InputDecoration(labelText: 'Mensaje', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Formulario de email no implementado aún.')),
              );
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

// --- Sección de Comentarios (Funcional y Mejorada) ---
class _CommentsSection extends ConsumerStatefulWidget {
  const _CommentsSection();

  @override
  ConsumerState<_CommentsSection> createState() => __CommentsSectionState();
}

class __CommentsSectionState extends ConsumerState<_CommentsSection> {
  final _commentController = TextEditingController();
  final FocusNode _focusNode = FocusNode(); // Para enfocar al responder
  
  bool _isPosting = false;
  Comment? _replyingTo; // ¿A quién estamos respondiendo? (null = comentario nuevo)

  // Acción al pulsar "Responder" en una tarjeta
  void _onReply(Comment comment) {
    setState(() {
      _replyingTo = comment;
    });
    // Llevamos el foco al campo de texto
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
  }

  void _cancelReply() {
    setState(() {
      _replyingTo = null;
    });
  }

  void _postComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    
    final user = ref.read(currentUserProvider);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para comentar.')),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      // Enviamos el parentId si estamos respondiendo
      await ref.read(commentsNotifierProvider.notifier).postComment(
        content,
        parentId: _replyingTo?.id,
      );
      
      _commentController.clear();
      _cancelReply(); // Reseteamos el estado de respuesta
      
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
      );
    } finally {
      setState(() => _isPosting = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(commentsNotifierProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Calculamos cantidad total (opcional, podrías hacer un getter en el notifier)
    final totalComments = commentsState.maybeWhen(
      data: (list) => list.length + list.fold(0, (sum, c) => sum + c.replies.length),
      orElse: () => 0
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título
          Row(
            children: [
              Text(
                'Comunidad',
                style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$totalComments',
                  style: TextStyle(
                    fontWeight: FontWeight.bold, 
                    color: colorScheme.onPrimaryContainer
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // --- INPUT AREA ---
          if (user != null) ...[
            // Indicador de "Respondiendo a..."
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

            // Campo de Texto
            TextField(
              controller: _commentController,
              focusNode: _focusNode,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: _replyingTo != null 
                    ? 'Escribe tu respuesta...' 
                    : 'Deja tu opinión o pregunta...',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: colorScheme.surface,
                suffixIcon: _isPosting
                    ? const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send),
                        color: colorScheme.primary,
                        onPressed: _postComment,
                      ),
              ),
            ),
            const SizedBox(height: 30),
          ] else ...[
            // Banner de Login
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock_outline, color: colorScheme.secondary),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Únete a la conversación',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Inicia sesión para comentar, dar likes y responder.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.tonal(
                    onPressed: () => ref.read(authRepositoryProvider).signInWithGoogle(),
                    child: const Text('Entrar con Google'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
          ],
          
          // --- LISTA DE COMENTARIOS ---
          commentsState.when(
            loading: () => const _SkeletonList(), // Skeleton Loading Profesional
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (comments) {
              if (comments.isEmpty) {
                return Center(
                  child: Column(
                    children: [
                      Icon(Icons.chat_bubble_outline, size: 40, color: colorScheme.outline),
                      const SizedBox(height: 10),
                      const Text('Sé la primera persona en comentar.'),
                    ],
                  ),
                );
              }
              return Column(
                children: comments.map((comment) => CommentCard(
                  comment: comment, 
                  onReply: _onReply, // Pasamos el callback de respuesta
                )).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}

// --- SKELETON LOADING (Shimmer) ---
class _SkeletonList extends StatelessWidget {
  const _SkeletonList();

  @override
  Widget build(BuildContext context) {
    final baseColor = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlightColor = Theme.of(context).colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Column(
        children: List.generate(3, (index) => Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(radius: 18),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 120, height: 14, color: Colors.white),
                    const SizedBox(height: 8),
                    Container(width: double.infinity, height: 12, color: Colors.white),
                    const SizedBox(height: 6),
                    Container(width: 200, height: 12, color: Colors.white),
                  ],
                ),
              )
            ],
          ),
        )),
      ),
    );
  }
}