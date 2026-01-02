// Archivo: lib/features/contact/presentation/views/contact_view.dart
import 'package:apex/core/config/theme/app_theme_providers.dart';
import 'package:apex/core/providers/network_status_provider.dart';
import 'package:apex/core/widgets/inspector_gadget.dart'; 
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; 
import 'package:shimmer/shimmer.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:lottie/lottie.dart';
import 'package:apex/features/comments/presentation/providers/comments_provider.dart';
import 'package:apex/features/comments/presentation/widgets/comment_card.dart';
import 'package:apex/features/comments/presentation/widgets/comment_input_area.dart';
import 'package:apex/features/comments/presentation/widgets/rating_summary.dart';
import 'package:apex/features/shared/widgets/footer.dart';

class ContactView extends StatelessWidget {
  const ContactView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktop = constraints.maxWidth > 900;

          return SingleChildScrollView(
            child: Column(
              children: [
                if (isDesktop)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 60.0, horizontal: 60.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(flex: 4, child: _ContactForm()),
                        SizedBox(width: 60),
                        Expanded(flex: 7, child: _CommentsSection()),
                      ],
                    ),
                  )
                else
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 30.0, horizontal: 20.0),
                    child: Column(
                      children: [
                        _ContactForm(),
                        SizedBox(height: 60),
                        Divider(),
                        SizedBox(height: 40),
                        _CommentsSection(),
                      ],
                    ),
                  ),
                const Footer(),
              ],
            ),
          );
        },
      ),
    );
  }
}

// --- FORMULARIO CON RAYOS X ---
class _ContactForm extends ConsumerStatefulWidget {
  const _ContactForm();
  @override
  ConsumerState<_ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends ConsumerState<_ContactForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  
  late FocusNode _messageFocusNode; 
  bool _isLoading = false;
  bool _isMessageFocused = false; 
  bool _isHovered = false; 

  @override
  void initState() {
    super.initState();
    _messageFocusNode = FocusNode();
    _messageFocusNode.addListener(() {
      if (mounted) setState(() => _isMessageFocused = _messageFocusNode.hasFocus);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose(); 
    super.dispose();
  }

  void _showSuccessAnimation() {
    final themeConfig = ref.read(currentAppThemeConfigProvider);
    final themeName = themeConfig.themeName.toLowerCase();

    String lottieAsset = 'assets/animations/envia_apex.json'; 
    if (themeName.contains('supabase')) lottieAsset = 'assets/animations/envia_supabase.json';
    else if (themeName.contains('flutter')) lottieAsset = 'assets/animations/envia_flutter.json';
    else if (themeName.contains('riverpod')) lottieAsset = 'assets/animations/envia_riverpod.json';
    else if (themeName.contains('assistify')) lottieAsset = 'assets/animations/envia_assistify.json';

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.8),
      builder: (context) {
        Future.delayed(const Duration(milliseconds: 3500), () {
          if (context.mounted) Navigator.of(context).pop();
        });

        return Center(
          child: Container(
            width: 300, 
            height: 350,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: Lottie.asset(
                    lottieAsset,
                    fit: BoxFit.contain,
                    repeat: false,
                    animate: true,
                  ),
                ),
                const SizedBox(height: 20),
                const Material(
                  color: Colors.transparent,
                  child: Text(
                    "¡Mensaje Enviado!",
                    style: TextStyle(
                      color: Colors.white, 
                      fontSize: 22, 
                      fontWeight: FontWeight.bold, 
                      fontFamily: 'Oxanium'
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    
    try {
      await Supabase.instance.client.functions.invoke(
        'send-contact-email',
        body: { 
          'name': _nameController.text.trim(), 
          'email': _emailController.text.trim(), 
          'message': _messageController.text.trim() 
        },
      );
      
      if (mounted) {
        _nameController.clear(); 
        _emailController.clear(); 
        _messageController.clear();
        FocusScope.of(context).unfocus(); 
        _showSuccessAnimation();
      }
    } catch (e) {
      if (mounted) {
        final errStr = e.toString().toLowerCase();
        final isNetworkError = errStr.contains('socket') || 
                               errStr.contains('network') || 
                               errStr.contains('xmlhttprequest') || 
                               errStr.contains('connection');
                               
        final userMessage = isNetworkError 
            ? 'Sin conexión a internet. Verifica tu red.' 
            : 'No pudimos enviar el mensaje. Inténtalo de nuevo.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(isNetworkError ? Icons.wifi_off_rounded : Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text(userMessage, style: const TextStyle(fontWeight: FontWeight.bold))),
              ],
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            margin: const EdgeInsets.all(16),
          )
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final networkStatus = ref.watch(networkStatusNotifierProvider);
    final isOffline = networkStatus == NetworkStatus.offline;

    return InspectorGadget(
      name: "Formulario Serverless",
      techSpecs: "Validación Reactiva (Riverpod) • Trigger de Edge Function (Deno) • SMTP Relay",
      icon: FontAwesomeIcons.envelopeOpenText,
      child: Container(
        padding: const EdgeInsets.all(32), 
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerLow, 
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min, 
          children: [
            Text(
              '¡Hablemos de tu proyecto!', 
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold, 
                color: colorScheme.primary,
                fontFamily: 'Oxanium',
                letterSpacing: -0.5,
              )
            ),
            const SizedBox(height: 8),
            Text(
              'Completa el formulario y te responderé a la brevedad.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            
            Form(
              key: _formKey,
              child: Opacity(
                opacity: isOffline ? 0.6 : 1.0, 
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, 
                  children: [
                    _buildTextField(
                      controller: _nameController, 
                      label: 'Tu Nombre', 
                      icon: Icons.person_outline, 
                      theme: theme, 
                      validator: (v) => v?.isEmpty == true ? 'Requerido' : null, 
                      isLastField: false,
                      enabled: !isOffline,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _emailController, 
                      label: 'Tu Email', 
                      icon: Icons.email_outlined, 
                      keyboardType: TextInputType.emailAddress, 
                      theme: theme, 
                      validator: (v) => !v!.contains('@') ? 'Email inválido' : null, 
                      isLastField: false,
                      enabled: !isOffline,
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: _messageController, 
                      label: 'Mensaje', 
                      icon: Icons.chat_bubble_outline, 
                      theme: theme, 
                      validator: (v) => v == null || v.isEmpty ? 'Escribe un mensaje' : null, 
                      isLastField: true, 
                      focusNode: _messageFocusNode,
                      minLines: (_isMessageFocused || _messageController.text.isNotEmpty) ? 5 : 1, 
                      maxLines: 5, 
                      enabled: !isOffline,
                    ),
                    const SizedBox(height: 40),
      
                    MouseRegion(
                      cursor: (isOffline || _isLoading) ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
                      onEnter: (_) => setState(() => _isHovered = true),
                      onExit: (_) => setState(() => _isHovered = false),
                      child: GestureDetector(
                        onTap: (isOffline || _isLoading) ? null : _sendMessage,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeInOut,
                          width: double.infinity, 
                          height: 54,
                          transform: Matrix4.identity()
                            ..translate(0.0, (_isHovered && !isOffline && !_isLoading) ? -2.0 : 0.0),
                          decoration: BoxDecoration(
                            color: isOffline 
                                ? colorScheme.surfaceContainerHighest 
                                : (_isLoading ? colorScheme.primary.withOpacity(0.8) : colorScheme.primary),
                            borderRadius: BorderRadius.circular(16), 
                            boxShadow: [
                              if (!isOffline && ! _isLoading)
                                BoxShadow(
                                  color: colorScheme.primary.withOpacity(_isHovered ? 0.4 : 0.1),
                                  blurRadius: _isHovered ? 20 : 10,
                                  offset: const Offset(0, 8),
                                )
                            ],
                          ),
                          child: Center(
                            child: _isLoading 
                              ? Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.onPrimary)),
                                    const SizedBox(width: 12),
                                    Text("Enviando...", style: TextStyle(color: colorScheme.onPrimary, fontWeight: FontWeight.bold, fontFamily: 'Oxanium')),
                                  ],
                                )
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      isOffline ? Icons.wifi_off_rounded : Icons.send_rounded, 
                                      size: 20, 
                                      color: isOffline ? colorScheme.onSurfaceVariant : colorScheme.onPrimary
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      isOffline ? "Sin Conexión" : "Enviar Mensaje", 
                                      style: TextStyle(
                                        color: isOffline ? colorScheme.onSurfaceVariant : colorScheme.onPrimary, 
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 16, 
                                        fontFamily: 'Oxanium'
                                      )
                                    ),
                                  ],
                                ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller, 
    required String label, 
    required IconData icon, 
    required ThemeData theme, 
    int minLines = 1, 
    int maxLines = 1, 
    TextInputType? keyboardType, 
    String? Function(String?)? validator, 
    required bool isLastField, 
    FocusNode? focusNode,
    bool enabled = true,
  }) {
    final primaryColor = theme.colorScheme.primary;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
        enabled: enabled,
        minLines: minLines,
        maxLines: maxLines,
        keyboardType: keyboardType,
        validator: validator,
        textInputAction: isLastField ? TextInputAction.send : TextInputAction.next,
        onFieldSubmitted: isLastField ? (_) => _sendMessage() : null,
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(color: theme.colorScheme.onSurface, fontFamily: 'Oxanium'),
        decoration: InputDecoration(
          labelText: label,
          alignLabelWithHint: true,
          labelStyle: TextStyle(color: theme.colorScheme.onSurface.withOpacity(0.6), fontFamily: 'Oxanium'),
          prefixIcon: Padding(
            padding: const EdgeInsets.only(top: 14.0, bottom: 14.0, left: 12, right: 8), 
            child: Icon(icon, color: primaryColor.withOpacity(0.7), size: 22),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.1))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 1.5)),
          disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.onSurface.withOpacity(0.05))),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          errorStyle: TextStyle(color: theme.colorScheme.error, fontSize: 12),
        ),
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
  void _onReply(Comment comment) { setState(() => _replyingTo = comment); }
  void _onCancelReply() { setState(() => _replyingTo = null); }

  @override
  Widget build(BuildContext context) {
    final commentsState = ref.watch(commentsNotifierProvider);
    final theme = Theme.of(context);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Opiniones de clientes', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        
        // --- AQUÍ APLICAMOS EL INSPECTOR ---
        // Envolvemos el Resumen de Calificaciones. Es un bloque compacto y visible.
        InspectorGadget(
          name: "Motor de Opiniones Realtime",
          techSpecs: "Sincronización WebSocket (Supabase) • CRUD en Tiempo Real • RLS Security",
          icon: FontAwesomeIcons.comments,
          // preferBelow: false por defecto (sale arriba, que es lo que queremos)
          child: commentsState.when(
            data: (comments) => RatingSummary(comments: comments),
            loading: () => const RatingSummarySkeleton(), 
            error: (_, __) => const SizedBox.shrink()
          ),
        ),
        // -----------------------------------

        const SizedBox(height: 30),
        CommentInputArea(replyingTo: _replyingTo, onCancelReply: _onCancelReply),
        const SizedBox(height: 30),
        Divider(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        const SizedBox(height: 20),
        commentsState.when(
          loading: () => const _SkeletonList(), 
          error: (err, stack) => Center(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer.withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.error.withOpacity(0.3)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.cloud_off_rounded, color: theme.colorScheme.error, size: 40),
                  const SizedBox(height: 12),
                  Text(
                    "No pudimos cargar los comentarios",
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Por favor, verifica tu conexión e inténtalo de nuevo.",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => ref.invalidate(commentsNotifierProvider),
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text("Reintentar"),
                    style: FilledButton.styleFrom(
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                    ),
                  ),
                ],
              ),
            ),
          ),
          data: (comments) {
            if (comments.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0), 
                  child: Text(
                    'Sé el primero en dejar una reseña.', 
                    style: TextStyle(color: theme.colorScheme.onSurfaceVariant)
                  )
                )
              );
            }
            return Column(children: comments.map((comment) => CommentCard(comment: comment, onReply: _onReply)).toList());
          },
        ),
      ],
    );
  }
}

class _SkeletonList extends StatelessWidget {
  const _SkeletonList();
  
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Shimmer.fromColors(
      baseColor: colorScheme.onSurface.withOpacity(0.05),
      highlightColor: colorScheme.onSurface.withOpacity(0.1),
      child: Column(
        children: List.generate(3, (index) => Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white10),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(radius: 20, backgroundColor: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(width: 120, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                        Container(width: 30, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (i) => const Padding(
                        padding: EdgeInsets.only(right: 4.0),
                        child: Icon(Icons.star, size: 12, color: Colors.white),
                      )),
                    ),
                    const SizedBox(height: 12),
                    Container(width: double.infinity, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                    const SizedBox(height: 6),
                    Container(width: MediaQuery.of(context).size.width * 0.4, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  ],
                ),
              ),
            ],
          ),
        )),
      ),
    );
  }
}

class RatingSummarySkeleton extends StatelessWidget {
  const RatingSummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Shimmer.fromColors(
      baseColor: colorScheme.onSurface.withOpacity(0.05),
      highlightColor: colorScheme.onSurface.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Column(
                children: [
                  Container(width: 60, height: 40, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8))),
                  const SizedBox(height: 12),
                  Container(width: 80, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                  const SizedBox(height: 8),
                  Container(width: 50, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                ],
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              flex: 3,
              child: Column(
                children: List.generate(5, (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(width: 10, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 8),
                      Expanded(child: Container(height: 6, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)))),
                      const SizedBox(width: 8),
                      Container(width: 15, height: 10, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(2))),
                    ],
                  ),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}