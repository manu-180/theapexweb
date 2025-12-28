// Archivo: lib/features/comments/presentation/widgets/comment_input_area.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prueba_de_riverpod/features/auth/presentation/providers/auth_providers.dart';
import 'package:prueba_de_riverpod/features/auth/presentation/widgets/auth_modal.dart';
import 'package:prueba_de_riverpod/features/comments/presentation/providers/comments_provider.dart';

class CommentInputArea extends ConsumerStatefulWidget {
  final Comment? replyingTo;
  final VoidCallback onCancelReply;

  const CommentInputArea({
    super.key,
    this.replyingTo,
    required this.onCancelReply,
  });

  @override
  ConsumerState<CommentInputArea> createState() => _CommentInputAreaState();
}

class _CommentInputAreaState extends ConsumerState<CommentInputArea> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  int _rating = 0; // 0 significa sin calificar aún
  bool _isPosting = false;
  bool _showRatingSelector = false; // Controla la animación

  @override
  void initState() {
    super.initState();
    // Detectar foco para mostrar selector
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && widget.replyingTo == null) {
        setState(() => _showRatingSelector = true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant CommentInputArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambia a modo respuesta, ocultamos rating
    if (widget.replyingTo != null && _showRatingSelector) {
      setState(() => _showRatingSelector = false);
    }
    // Si volvemos a modo normal y tenemos foco, mostramos rating
    if (widget.replyingTo == null && oldWidget.replyingTo != null && _focusNode.hasFocus) {
      setState(() => _showRatingSelector = true);
    }
    
    // Auto-foco si estamos respondiendo
    if (widget.replyingTo != null && !_focusNode.hasFocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _focusNode.requestFocus();
      });
    }
  }

  void _submit() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      _focusNode.unfocus();
      showDialog(context: context, builder: (_) => const AuthRequiredModal());
      return;
    }

    final content = _controller.text.trim();
    if (content.isEmpty) return;

    // Validación: Si es reseña nueva, exigir estrellas (opcional, pero recomendado)
    if (widget.replyingTo == null && _rating == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecciona una puntuación tocando las estrellas.')),
      );
      return;
    }

    setState(() => _isPosting = true);

    try {
      await ref.read(commentsNotifierProvider.notifier).postComment(
        content,
        parentId: widget.replyingTo?.id,
        rating: widget.replyingTo == null ? _rating : null,
      );
      
      _controller.clear();
      if (widget.replyingTo != null) widget.onCancelReply();
      
      // Reset rating
      setState(() {
        _rating = 0;
        _showRatingSelector = false;
      });
      _focusNode.unfocus();

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // --- HEADER DE RESPUESTA ---
        if (widget.replyingTo != null)
          Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: colorScheme.secondaryContainer.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border(left: BorderSide(color: colorScheme.secondary, width: 3)),
            ),
            child: Row(
              children: [
                Icon(Icons.reply, size: 16, color: colorScheme.secondary),
                const SizedBox(width: 8),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: theme.textTheme.bodyMedium,
                      children: [
                        const TextSpan(text: 'Respondiendo a '),
                        TextSpan(
                          text: widget.replyingTo!.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, size: 18),
                  onPressed: widget.onCancelReply,
                  tooltip: 'Cancelar',
                )
              ],
            ),
          ),

        // --- SELECTOR DE ESTRELLAS (ANIMADO) ---
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          alignment: Alignment.bottomLeft,
          child: _showRatingSelector && widget.replyingTo == null
              ? Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "¿Cómo calificarías tu experiencia?",
                        style: theme.textTheme.labelLarge?.copyWith(
                          color: colorScheme.primary, 
                          fontWeight: FontWeight.bold
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          final starIndex = index + 1;
                          return GestureDetector(
                            onTap: () => setState(() => _rating = starIndex),
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: AnimatedScale(
                                scale: _rating == starIndex ? 1.2 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  starIndex <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                  color: Colors.amber,
                                  size: 36,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
        ),

        // --- CAMPO DE TEXTO ---
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          maxLines: 3,
          minLines: 1,
          onTap: () {
             final user = ref.read(currentUserProvider);
             if (user == null) {
               _focusNode.unfocus();
               showDialog(context: context, builder: (_) => const AuthRequiredModal());
             }
          },
          decoration: InputDecoration(
            hintText: widget.replyingTo != null 
                ? 'Escribe una respuesta...' 
                : 'Deja tu opinión...',
            filled: true,
            fillColor: colorScheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: _isPosting
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: Icon(Icons.send_rounded, color: _rating > 0 || widget.replyingTo != null ? colorScheme.primary : colorScheme.outline),
                    onPressed: _submit,
                  ),
          ),
        ),
      ],
    );
  }
}