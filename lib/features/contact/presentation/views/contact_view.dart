// Archivo: lib/features/contact/presentation/views/contact_view.dart
import 'package:apex/core/config/theme/app_theme_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// --- FORMULARIO CORREGIDO CON CONSUMERSTATE PARA ACCEDER A REF ---
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
    // 1. Obtenemos el tema actual para elegir el Lottie correcto
    final themeConfig = ref.read(currentAppThemeConfigProvider);
    final themeName = themeConfig.themeName.toLowerCase();

    // 2. Mapeamos al archivo local correspondiente
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
        // El diálogo se cierra tras 3.5 segundos para dar tiempo a ver el frame final
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
                    repeat: false, // Evita que reinicie la animación
                    animate: true,
                    // Esta es la clave: al terminar, se queda en el último frame
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.redAccent)
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary; 
    final onPrimary = theme.colorScheme.onPrimary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '¡Hablemos de tu proyecto!', 
          style: theme.textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold, 
            color: primaryColor,
            fontFamily: 'Oxanium',
          )
        ),
        const SizedBox(height: 40),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, 
            children: [
              _buildTextField(controller: _nameController, label: 'Tu Nombre', icon: Icons.person_outline, theme: theme, validator: (v) => v?.isEmpty == true ? 'Requerido' : null, isLastField: false),
              const SizedBox(height: 20),
              _buildTextField(controller: _emailController, label: 'Tu Email', icon: Icons.email_outlined, keyboardType: TextInputType.emailAddress, theme: theme, validator: (v) => !v!.contains('@') ? 'Email inválido' : null, isLastField: false),
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
              ),
              const SizedBox(height: 40),

              // --- BOTÓN PROFESIONAL CON MANITO Y ELEVACIÓN FIJA ---
              MouseRegion(
                cursor: SystemMouseCursors.click, // Activa la manito
                onEnter: (_) => setState(() => _isHovered = true),
                onExit: (_) => setState(() => _isHovered = false),
                child: GestureDetector(
                  onTap: _isLoading ? null : _sendMessage,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    width: _isLoading ? 260 : 220,
                    height: 54,
                    // Elevación sin que el texto se mueva relativo al botón
                    transform: Matrix4.identity()
                      ..translate(0.0, _isHovered && !_isLoading ? -5.0 : 0.0),
                    decoration: BoxDecoration(
                      color: _isLoading ? primaryColor.withOpacity(0.8) : primaryColor,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: primaryColor.withOpacity(_isHovered && !_isLoading ? 0.4 : 0.1),
                          blurRadius: _isHovered && !_isLoading ? 25 : 10,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: Center(
                      child: _isLoading 
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: onPrimary)),
                              const SizedBox(width: 12),
                              Text("Enviando mensaje...", style: TextStyle(color: onPrimary, fontWeight: FontWeight.bold, fontFamily: 'Oxanium')),
                            ],
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                margin: EdgeInsets.only(left: _isHovered ? 8 : 0),
                                child: Icon(Icons.send_rounded, size: 20, color: onPrimary),
                              ),
                              const SizedBox(width: 10),
                              Text("Enviar Mensaje", style: TextStyle(color: onPrimary, fontWeight: FontWeight.bold, fontSize: 16, fontFamily: 'Oxanium')),
                            ],
                          ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
    FocusNode? focusNode
  }) {
    final primaryColor = theme.colorScheme.primary;

    return AnimatedSize(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
      alignment: Alignment.topCenter,
      child: TextFormField(
        controller: controller,
        focusNode: focusNode,
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
            padding: const EdgeInsets.only(top: 16.0), // Fijo arriba para que no se mueva
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: primaryColor.withOpacity(0.7), size: 20),
              ],
            ),
          ),
          prefixIconConstraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          filled: true,
          fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.2))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: primaryColor, width: 1.5)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
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
        commentsState.when(
          data: (comments) => RatingSummary(comments: comments),
          loading: () => const RatingSummarySkeleton(), 
          error: (_, __) => const SizedBox.shrink()
        ),
        const SizedBox(height: 30),
        CommentInputArea(replyingTo: _replyingTo, onCancelReply: _onCancelReply),
        const SizedBox(height: 30),
        Divider(color: theme.colorScheme.outlineVariant.withOpacity(0.5)),
        const SizedBox(height: 20),
        commentsState.when(
          loading: () => const _SkeletonList(), 
          error: (err, stack) => Center(child: Text('Error: $err')),
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
  const _SkeletonList({super.key});
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Theme.of(context).colorScheme.surfaceContainerHighest.withOpacity(0.5),
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

class RatingSummarySkeleton extends StatelessWidget {
  const RatingSummarySkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final basePulseColor = Colors.white.withOpacity(0.05);

    return Shimmer.fromColors(
      baseColor: Colors.white.withOpacity(0.05),
      highlightColor: Colors.white.withOpacity(0.1),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: const Color(0xFF111827).withOpacity(0.5), 
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 70, height: 45, decoration: BoxDecoration(color: basePulseColor, borderRadius: BorderRadius.circular(8))),
                const SizedBox(height: 12),
                Container(width: 90, height: 16, decoration: BoxDecoration(color: basePulseColor, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 8),
                Container(width: 60, height: 12, decoration: BoxDecoration(color: basePulseColor, borderRadius: BorderRadius.circular(4))),
              ],
            ),
            const SizedBox(width: 40),
            Expanded(
              child: Column(
                children: List.generate(5, (index) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6.0),
                  child: Row(
                    children: [
                      Container(width: 15, height: 12, decoration: BoxDecoration(color: basePulseColor, borderRadius: BorderRadius.circular(2))),
                      const SizedBox(width: 8),
                      Expanded(child: Container(height: 8, decoration: BoxDecoration(color: basePulseColor, borderRadius: BorderRadius.circular(4)))),
                      const SizedBox(width: 8),
                      Container(width: 15, height: 12, decoration: BoxDecoration(color: basePulseColor, borderRadius: BorderRadius.circular(2))),
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