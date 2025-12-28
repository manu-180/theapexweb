// Archivo: lib/features/contact/presentation/views/contact_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:prueba_de_riverpod/core/widgets/responsive_builder.dart';
import 'package:prueba_de_riverpod/features/comments/presentation/providers/comments_provider.dart';
import 'package:prueba_de_riverpod/features/comments/presentation/widgets/comment_card.dart';
import 'package:prueba_de_riverpod/features/comments/presentation/widgets/comment_input_area.dart'; // <--- NUEVO
import 'package:prueba_de_riverpod/features/comments/presentation/widgets/rating_summary.dart';   // <--- NUEVO
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
                    SizedBox(width: 60),
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
            'Si tienes una consulta directa, usa este formulario. Contesto en menos de 24 horas.',
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
  Comment? _replyingTo;

  void _onReply(Comment comment) {
    setState(() => _replyingTo = comment);
  }

  void _onCancelReply() {
    setState(() => _replyingTo = null);
  }

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(commentsNotifierProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Título
          Text(
            'Opiniones de clientes',
            style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          // 1. RESUMEN TIPO MERCADO LIBRE
          commentsState.when(
            data: (comments) => RatingSummary(comments: comments),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
          
          const SizedBox(height: 30),

          // 2. INPUT AREA (Estrellas + Texto)
          CommentInputArea(
            replyingTo: _replyingTo,
            onCancelReply: _onCancelReply,
          ),
          
          const SizedBox(height: 30),
          Divider(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
          const SizedBox(height: 20),

          // 3. LISTA DE COMENTARIOS
          commentsState.when(
            loading: () => const _SkeletonList(),
            error: (err, stack) => Center(child: Text('Error: $err')),
            data: (comments) {
              if (comments.isEmpty) {
                return const Center(child: Text('Sé el primero en dejar una reseña.'));
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