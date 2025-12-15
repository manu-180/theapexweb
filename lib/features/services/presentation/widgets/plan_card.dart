// Archivo: lib/features/services/presentation/widgets/plan_card.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:prueba_de_riverpod/features/auth/presentation/providers/auth_providers.dart';
import 'package:prueba_de_riverpod/features/payments/data/repositories/mercadopago_repository.dart';
import 'package:prueba_de_riverpod/features/services/domain/models/plan_model.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart'; // Asegúrate de tener esta importación

class PlanCard extends ConsumerStatefulWidget {
  const PlanCard({
    super.key,
    required this.plan,
  });

  final ServicePlan plan;

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

  // --- Lógica de Compra Central ---
  void _onBuyPressed(BuildContext context) async {
    final user = ref.read(currentUserProvider);

    // 1. Determinar el email y el ID de usuario (si existe)
    String? userEmail;
    String? userId;

    if (user == null || user.email == null) {
      // Caso 1: Usuario NO logueado (Guest Checkout)
      final guestEmail = await _showGuestEmailDialog(context);
      if (guestEmail == null) return; // Cancelado por el usuario
      userEmail = guestEmail;
      userId = null; // ID nulo para compra de invitado
    } else {
      // Caso 2: Usuario logueado
      userEmail = user.email!;
      userId = user.id;
    }

    setState(() => _isLoading = true);

    try {
      // 2. Llamar al repositorio con el email y el ID (que puede ser nulo)
      await ref.read(mercadoPagoRepositoryProvider).createPreferenceAndLaunchCheckout(
        plan: widget.plan,
        userEmail: userEmail,
        userId: userId, // Puede ser null
      );
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Redirigiendo a Mercado Pago para ${userEmail}...')),
        );
      }
      
    } catch (e) {
      // 3. Manejo de errores
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
  
  // --- Diálogo para Capturar Email del Invitado ---
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
                  // Validación básica de email
                  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Introduce un email válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 15),
              // Opción de Login
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    icon: const Icon(FontAwesomeIcons.google, size: 16),
                    label: const Text('O Iniciar Sesión'),
                    onPressed: () {
                      Navigator.of(context).pop(); // Cierra el diálogo de email
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
            onPressed: () => Navigator.of(context).pop(null), // Devuelve null si cancela
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(emailController.text.trim()); // Devuelve el email
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
    final borderColor = colorScheme.primary.withOpacity(0.5);

    final currencyFormatter = NumberFormat.currency(
      locale: 'es_AR',
      symbol: '\$',
      decimalDigits: 0,
    );

    // [resto del build method (animaciones, diseño, etc.)]
    final transform = _isHovering ? (Matrix4.identity()..scale(1.03)) : Matrix4.identity();
    final elevation = _isHovering ? 16.0 : 4.0;
    final shadowColor = _isHovering ? borderColor : Colors.black.withOpacity(0.1);

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      cursor: SystemMouseCursors.click,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        transform: transform,
        child: Card(
          elevation: elevation,
          shadowColor: shadowColor,
          surfaceTintColor: colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: _isHovering ? borderColor : Colors.transparent,
              width: 1.5,
            ),
          ),
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
                      color: colorScheme.primary,
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // --- Descripción Corta (para planes de video) ---
                if (widget.plan.type == PlanType.video)
                  FadeIn(
                    child: Text(
                      widget.plan.description,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium,
                    ),
                  ),
                const SizedBox(height: 16),

                // --- Precio ---
                FadeIn(
                  delay: const Duration(milliseconds: 100),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      currencyFormatter.format(widget.plan.price),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // --- Lista de Features ---
                ...widget.plan.features.map((text) => FadeInUp(
                      delay: Duration(milliseconds: widget.plan.features.indexOf(text) * 100 + 300),
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.check, size: 18, color: colorScheme.primary),
                            const SizedBox(width: 10),
                            Expanded(child: Text(text, style: theme.textTheme.bodyLarge)),
                          ],
                        ),
                      ),
                    )),
                
                const Spacer(),
                const SizedBox(height: 24),

                // --- Botón de Comprar Dinámico ---
                FadeInUp(
                  delay: const Duration(milliseconds: 800),
                  child: FilledButton(
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
    );
  }
}