// Archivo: lib/features/contact/presentation/views/contact_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prueba_de_riverpod/core/config/theme/extensions/app_bar_extension.dart';
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
      appBar: const CustomAppBarExtension(title: 'Contacto y Comunidad'),
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
          
          // Campos de formulario (Placeholder)
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
              // Lógica de envío de formulario por email (por implementar)
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Función de envío de formulario por email no implementada aún.')),
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

// --- Sección de Comentarios (Funcional) ---
class _CommentsSection extends ConsumerStatefulWidget {
  const _CommentsSection();

  @override
  ConsumerState<_CommentsSection> createState() => __CommentsSectionState();
}

class __CommentsSectionState extends ConsumerState<_CommentsSection> {
  final _commentController = TextEditingController();
  bool _isPosting = false;
  
  // Publicar Comentario
  void _postComment() async {
    final content = _commentController.text.trim();
    if (content.isEmpty) return;
    
    final user = ref.read(currentUserProvider);

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes iniciar sesión para publicar un comentario.')),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      await ref.read(commentsNotifierProvider.notifier).postComment(content);
      _commentController.clear();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', 'Error: '))),
      );
    } finally {
      setState(() => _isPosting = false);
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(commentsNotifierProvider);
    final user = ref.watch(currentUserProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Opiniones de la Comunidad (${commentsState.maybeWhen(data: (data) => data.length, orElse: () => 0)})',
            style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // --- Formulario de Publicación ---
          if (user != null) ...[
            TextField(
              controller: _commentController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Escribe tu opinión o pregunta aquí...',
                border: const OutlineInputBorder(),
                suffixIcon: _isPosting
                    ? const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _postComment,
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ] else ...[
            // Mensaje si no está logueado
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Icon(Icons.lock, color: theme.colorScheme.secondary),
                  const SizedBox(width: 10),
                  const Expanded(child: Text('Inicia sesión para dejar un comentario y unirte a la conversación.')),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
          
          // --- Lista de Comentarios ---
          commentsState.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error al cargar comentarios: $err')),
            data: (comments) {
              if (comments.isEmpty) {
                return const Center(child: Text('Sé el primero en dejar un comentario.'));
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: comments.map((comment) => CommentCard(comment: comment)).toList(),
              );
            },
          ),
        ],
      ),
    );
  }
}