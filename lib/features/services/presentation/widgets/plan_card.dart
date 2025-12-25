// Archivo: lib/features/services/presentation/widgets/plan_card.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prueba_de_riverpod/features/auth/presentation/providers/auth_providers.dart';
import 'package:prueba_de_riverpod/features/payments/data/repositories/mercadopago_repository.dart';
import 'package:prueba_de_riverpod/features/services/domain/models/plan_model.dart';
import 'package:prueba_de_riverpod/features/services/presentation/widgets/case_studies_modal.dart'; // <--- IMPORTAR
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PlanCard extends ConsumerStatefulWidget {
  const PlanCard({
    super.key,
    required this.plan,
    required this.mousePos,
  });

  final ServicePlan plan;
  final ValueNotifier<Offset> mousePos;

  @override
  ConsumerState<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends ConsumerState<PlanCard> {
  bool _isHovering = false;
  bool _isLoading = false;

  void _onHover(bool isHovering) {
    setState(() {
      _isHovering = isHovering;
    });
  }

  // --- NUEVA FUNCIÓN: Abrir Modal de Casos de Éxito ---
  void _showCaseStudies() {
    if (widget.plan.caseStudies == null || widget.plan.caseStudies!.isEmpty) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Permite que el modal crezca según contenido
      backgroundColor: Colors.transparent, // Fondo transparente para ver bordes redondeados
      builder: (context) => CaseStudiesModal(
        caseStudies: widget.plan.caseStudies!,
        planName: widget.plan.name,
      ),
    );
  }

  void _onBuyPressed(BuildContext context) async {
    final user = ref.read(currentUserProvider);
    String? userEmail;
    String? userId;

    if (user == null || user.email == null) {
      final guestEmail = await _showGuestEmailDialog(context);
      if (guestEmail == null) return; 
      userEmail = guestEmail;
      userId = null; 
    } else {
      userEmail = user.email!;
      userId = user.id;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(mercadoPagoRepositoryProvider).createPreferenceAndLaunchCheckout(
        plan: widget.plan,
        userEmail: userEmail,
        userId: userId, 
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Redirigiendo a Mercado Pago para $userEmail...')),
        );
      }
      
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst('Exception: ', '')),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<String?> _showGuestEmailDialog(BuildContext context) {
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    return showDialog<String?>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirma tu Email'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Necesitamos tu correo para enviarte el servicio o la factura.'),
              const SizedBox(height: 15),
              TextFormField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Correo Electrónico',
                  prefixIcon: Icon(Icons.email_outlined),
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'El email es obligatorio.';
                  }
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Introduce un email válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    icon: const Icon(FontAwesomeIcons.google, size: 16),
                    label: const Text('O Iniciar Sesión'),
                    onPressed: () {
                      Navigator.of(context).pop(); 
                      ref.read(authRepositoryProvider).signInWithGoogle();
                    },
                  ),
                ],
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(null), 
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(emailController.text.trim()); 
              }
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final primaryColor = colorScheme.primary;

    final currencyFormatter = NumberFormat.currency(
      locale: 'es_AR',
      symbol: '\$',
      decimalDigits: 0,
    );

    final hasDiscount = widget.plan.originalPrice != null && 
                        widget.plan.originalPrice! > widget.plan.price;

    // Chequeamos si tiene casos de éxito para activar el cursor clickeable
    final hasCases = widget.plan.caseStudies != null && widget.plan.caseStudies!.isNotEmpty;

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      // Si tiene casos, mostramos manito de click. Si no, cursor básico.
      cursor: hasCases ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: ValueListenableBuilder<Offset>(
        valueListenable: widget.mousePos,
        builder: (context, mouseOffset, child) {
          Offset localLightPos = Offset.zero;
          
          final renderObject = context.findRenderObject();
          if (renderObject is RenderBox && renderObject.hasSize) {
            localLightPos = renderObject.globalToLocal(mouseOffset);
          }

          final borderGradient = RadialGradient(
            center: Alignment(
              (localLightPos.dx / (renderObject is RenderBox ? renderObject.size.width : 1)) * 2 - 1,
              (localLightPos.dy / (renderObject is RenderBox ? renderObject.size.height : 1)) * 2 - 1,
            ),
            radius: 1.5,
            colors: [
              primaryColor,
              Colors.transparent,
            ],
            stops: const [0.0, 1.0],
          );

          final surfaceColor = colorScheme.surface;
          final hoverColor = Color.alphaBlend(
            primaryColor.withOpacity(0.15),
            surfaceColor,
          );

          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            transform: _isHovering ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: borderGradient,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(_isHovering ? 0.2 : 0.05),
                  blurRadius: _isHovering ? 20 : 10,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(2.5),
            child: Container(
              decoration: BoxDecoration(
                color: _isHovering ? hoverColor : surfaceColor,
                borderRadius: BorderRadius.circular(13.5),
              ),
              child: Material( // Material transparente para efectos InkWell
                color: Colors.transparent,
                child: InkWell(
                  // Solo activamos el onTap si hay casos de éxito
                  onTap: hasCases ? _showCaseStudies : null,
                  borderRadius: BorderRadius.circular(13.5),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- Nombre del Plan ---
                        FadeIn(
                          child: Text(
                            widget.plan.name,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: primaryColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        if (widget.plan.type == PlanType.video)
                          FadeIn(
                            child: Text(
                              widget.plan.description,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                        const SizedBox(height: 16),

                        // --- PRECIO ---
                        FadeIn(
                          delay: const Duration(milliseconds: 100),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                            decoration: BoxDecoration(
                              color: primaryColor.withOpacity(0.08), 
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: primaryColor.withOpacity(0.2), 
                                width: 1,
                              ),
                            ),
                            child: Column(
                              children: [
                                if (hasDiscount)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 4.0),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          currencyFormatter.format(widget.plan.originalPrice),
                                          style: TextStyle(
                                            decoration: TextDecoration.lineThrough,
                                            decorationColor: theme.colorScheme.onSurface.withOpacity(0.5),
                                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: primaryColor.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                            border: Border.all(color: primaryColor.withOpacity(0.5)),
                                          ),
                                          child: Text(
                                            '-${widget.plan.discountPercentage}%',
                                            style: TextStyle(
                                              color: primaryColor,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                Text(
                                  currencyFormatter.format(widget.plan.price),
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                    fontSize: 32,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // --- Indicador de "Ver Casos de Éxito" (Opcional, ayuda a la UX) ---
                        if (hasCases) ...[
                          const SizedBox(height: 12),
                          Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceContainerHighest,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.visibility, size: 12, color: theme.colorScheme.primary),
                                  const SizedBox(width: 6),
                                  Text(
                                    "Ver Ejemplos Reales",
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),

                        // --- Features ---
                        ...widget.plan.features.map((text) => FadeInUp(
                              delay: Duration(milliseconds: widget.plan.features.indexOf(text) * 100 + 300),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.check, size: 18, color: primaryColor),
                                    const SizedBox(width: 10),
                                    Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
                                  ],
                                ),
                              ),
                            )),
                        
                        const Spacer(),
                        const SizedBox(height: 24),

                        // --- Botón Contratar ---
                        FadeInUp(
                          delay: const Duration(milliseconds: 800),
                          child: FilledButton(
                            // IMPORTANTE: Este onPressed anula el InkWell del padre. 
                            // Así el botón funciona para comprar y el resto de la tarjeta para ver casos.
                            onPressed: _isLoading ? null : () => _onBuyPressed(context),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              textStyle: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            child: _isLoading
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      color: colorScheme.onPrimary,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : const Text('Contratar Ahora'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}