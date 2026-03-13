// Archivo: lib/features/comments/presentation/widgets/comment_input_area.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:apex/core/providers/network_status_provider.dart'; // <--- IMPORTACIÓN
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
        _showRatingError = false; 
      });
    }
    if (widget.replyingTo == null && oldWidget.replyingTo != null && _focusNode.hasFocus) {
      setState(() => _showRatingSelector = true);
    }
    if (widget.replyingTo != null && !_focusNode.hasFocus) {
      // Pequeño delay para asegurar que el UI se reconstruyó antes de pedir foco
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  void _submit() async {
    // 1. Verificación PROACTIVA de sesión
    final user = ref.read(currentUserProvider);

    if (user == null) {
      _focusNode.unfocus();
      showDialog(context: context, builder: (_) => const AuthRequiredModal());
      return;
    }

    final content = _controller.text.trim();
    if (content.isEmpty) return;

    if (widget.replyingTo == null && _rating == 0) {
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
      
      if (mounted) {
        setState(() {
          _rating = 0;
          _showRatingSelector = false;
          _showRatingError = false; 
        });
        _focusNode.unfocus();
      }

    } catch (e) {
      // 2. Manejo de errores ROBUSTO
      bool isAuthError = false;
      String errorMessage = 'Ocurrió un error inesperado';

      if (e is PostgrestException) {
        // Código 42501 = Permisos insuficientes (RLS)
        if (e.code == '42501') {
          isAuthError = true;
        } else {
          errorMessage = e.message;
        }
      } else if (e is AuthException) {
        isAuthError = true;
      }

      if (mounted) {
        if (isAuthError) {
          _focusNode.unfocus();
          showDialog(context: context, builder: (_) => const AuthRequiredModal());
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
        }
      }
    } finally {
      if (mounted) setState(() => _isPosting = false);
    }
  }

  bool _authListenerSetup = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final networkStatus = ref.watch(networkStatusNotifierProvider);
    final isOffline = networkStatus == NetworkStatus.offline;

    if (!_authListenerSetup) {
      _authListenerSetup = true;
      ref.listenManual(authStateStreamProvider, (previous, next) {
        if (next.value == null && _focusNode.hasFocus) {
          _focusNode.unfocus();
          if (mounted) {
            showDialog(context: context, builder: (_) => const AuthRequiredModal());
          }
        }
      });
    }

    return Opacity(
      // Reducimos opacidad visualmente si está offline para indicar estado desactivado
      opacity: isOffline ? 0.6 : 1.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                    onPressed: isOffline ? null : widget.onCancelReply,
                    tooltip: 'Cancelar',
                  )
                ],
              ),
            ),
    
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutBack,
            alignment: Alignment.bottomLeft,
            child: _showRatingSelector && widget.replyingTo == null && !isOffline
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
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
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(5, (index) {
                            final starIndex = index + 1;
                            return MouseRegion(
                              cursor: SystemMouseCursors.click,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _rating = starIndex;
                                    _showRatingError = false; 
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
                                        ? colorScheme.error.withOpacity(0.5) 
                                        : Colors.amber,
                                    size: 36,
                                  ),
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
    
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            // BLINDAJE: Si está offline, el input se deshabilita
            enabled: !isOffline,
            maxLines: 3,
            minLines: 1,
            onTap: () {
               if (isOffline) return;
               
               final user = ref.read(currentUserProvider);
               if (user == null) {
                 _focusNode.unfocus();
                 showDialog(context: context, builder: (_) => const AuthRequiredModal());
               }
            },
            decoration: InputDecoration(
              // BLINDAJE: Hint text informativo
              hintText: isOffline 
                  ? 'Sin conexión a internet...' 
                  : (widget.replyingTo != null ? 'Escribe una respuesta...' : 'Deja tu opinión...'),
              filled: true,
              fillColor: colorScheme.surfaceContainerLow,
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
              // Borde desactivado (offline)
              disabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide(color: colorScheme.onSurface.withOpacity(0.05)),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              suffixIcon: _isPosting
                  ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : IconButton(
                      // BLINDAJE: Botón desactivado si offline
                      onPressed: isOffline ? null : _submit,
                      icon: Icon(
                        isOffline ? Icons.wifi_off_rounded : Icons.send_rounded, 
                        color: isOffline
                            ? colorScheme.outline.withOpacity(0.5)
                            : (_rating > 0 || widget.replyingTo != null 
                                ? colorScheme.primary 
                                : (_showRatingError ? colorScheme.error : colorScheme.outline)),
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}