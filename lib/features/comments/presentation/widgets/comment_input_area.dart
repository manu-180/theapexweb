// Archivo: lib/features/comments/presentation/widgets/comment_input_area.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/features/auth/presentation/providers/auth_providers.dart';
import 'package:apex/features/auth/presentation/widgets/auth_modal.dart';
import 'package:apex/features/comments/presentation/providers/comments_provider.dart';

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
  
  int _rating = 0; 
  bool _isPosting = false;
  bool _showRatingSelector = false;
  
  // NUEVO: Estado para controlar el mensaje de error inline
  bool _showRatingError = false; 

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && widget.replyingTo == null) {
        setState(() => _showRatingSelector = true);
      }
    });
  }

  @override
  void didUpdateWidget(covariant CommentInputArea oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.replyingTo != null && _showRatingSelector) {
      setState(() {
        _showRatingSelector = false;
        _showRatingError = false; // Limpiamos error si cambia a respuesta
      });
    }
    if (widget.replyingTo == null && oldWidget.replyingTo != null && _focusNode.hasFocus) {
      setState(() => _showRatingSelector = true);
    }
    
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

    // VALIDACIÓN VISUAL (Sin SnackBar)
    if (widget.replyingTo == null && _rating == 0) {
      // Activamos el estado de error para mostrar la alerta visual
      setState(() => _showRatingError = true);
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
      
      setState(() {
        _rating = 0;
        _showRatingSelector = false;
        _showRatingError = false; // Reset error
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
                      // Título + Mensaje de Error (Row)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            "¿Cómo calificarías tu experiencia?",
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: colorScheme.primary, 
                              fontWeight: FontWeight.bold
                            ),
                          ),
                          
                          // --- MENSAJE DE ERROR ELEGANTE ---
                          // Usamos AnimatedOpacity para que aparezca suavemente
                          AnimatedOpacity(
                            opacity: _showRatingError ? 1.0 : 0.0,
                            duration: const Duration(milliseconds: 300),
                            child: _showRatingError 
                              ? Container(
                                  margin: const EdgeInsets.only(left: 12),
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: colorScheme.errorContainer,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.priority_high_rounded, size: 12, color: colorScheme.error),
                                      const SizedBox(width: 4),
                                      Text(
                                        "Requerido",
                                        style: TextStyle(
                                          fontSize: 10, 
                                          fontWeight: FontWeight.bold,
                                          color: colorScheme.error
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 8),
                      
                      // Las Estrellas
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(5, (index) {
                          final starIndex = index + 1;
                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _rating = starIndex;
                                _showRatingError = false; // Ocultar error al tocar
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: AnimatedScale(
                                scale: _rating == starIndex ? 1.2 : 1.0,
                                duration: const Duration(milliseconds: 200),
                                child: Icon(
                                  starIndex <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                                  color: _showRatingError 
                                      ? colorScheme.error.withOpacity(0.5) // Feedback visual en las estrellas también
                                      : Colors.amber,
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
            // Si hay error, pintamos el borde suavemente de rojo
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: _showRatingError 
                  ? BorderSide(color: colorScheme.error.withOpacity(0.5)) 
                  : BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: _showRatingError 
                  ? BorderSide(color: colorScheme.error) 
                  : BorderSide(color: colorScheme.primary.withOpacity(0.5)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: _isPosting
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : IconButton(
                    icon: Icon(
                      Icons.send_rounded, 
                      // El color del ícono cambia si hay error o si está listo
                      color: _rating > 0 || widget.replyingTo != null 
                          ? colorScheme.primary 
                          : (_showRatingError ? colorScheme.error : colorScheme.outline)
                    ),
                    onPressed: _submit,
                  ),
          ),
        ),
      ],
    );
  }
}