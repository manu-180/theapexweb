// Archivo: lib/features/services/presentation/widgets/contact_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:apex/core/config/app_constants.dart';
import 'package:apex/features/auth/presentation/providers/auth_providers.dart';
import 'package:apex/features/payments/data/repositories/mercadopago_repository.dart';
import 'package:apex/features/services/domain/models/plan_model.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactModal extends ConsumerStatefulWidget {
  final ServicePlan plan;

  const ContactModal({super.key, required this.plan});

  @override
  ConsumerState<ContactModal> createState() => _ContactModalState();
}

class _ContactModalState extends ConsumerState<ContactModal> {
  bool _isLoadingPayment = false;
  // Si la apertura automática falla, guardamos la URL aquí para mostrar el botón manual
  String? _manualUrl; 
  String? _errorMessage;

  void _launchWhatsApp() async {
    final phone = AppConstants.whatsappNumber;
    final message = "Hola Manuel, estuve viendo tu portfolio. Me interesa el plan *${widget.plan.name}* para potenciar mi negocio. ¿Podemos coordinar una reunión?";
    final url = "https://wa.me/$phone?text=${Uri.encodeComponent(message)}";
    
    try {
      if (!await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication)) {
        throw 'No se pudo abrir WhatsApp';
      }
    } catch (e) {
      // Fallback: Copiar al portapapeles si falla el deep link
      if (mounted) {
        Clipboard.setData(ClipboardData(text: phone));
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('No se pudo abrir WhatsApp. Número copiado al portapapeles.')),
        );
      }
    }
  }

  Future<void> _processPayment() async {
    final user = ref.read(currentUserProvider);
    
    setState(() {
      _isLoadingPayment = true;
      _errorMessage = null;
      _manualUrl = null; // Reseteamos
    });
    
    try {
      // 1. Obtenemos URL (Puede tardar por red)
      final url = await ref.read(mercadoPagoRepositoryProvider).createPreference(
        plan: widget.plan,
        userEmail: user?.email ?? 'cliente_anonimo@theapexweb.com',
        userId: user?.id,
      );

      // 2. Intentamos abrir automáticamente
      final uri = Uri.parse(url);
      bool launched = false;
      try {
         launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      } catch (_) {
         launched = false;
      }

      // 3. Si falla (bloqueo de popup), activamos modo manual
      if (!launched) {
        setState(() => _manualUrl = url);
      }

    } catch (e) {
      final msg = e.toString().replaceAll('Exception:', '').trim();
      setState(() => _errorMessage = msg);
    } finally {
      if (mounted) setState(() => _isLoadingPayment = false);
    }
  }

  // Widget auxiliar para abrir la URL manualmente
  Future<void> _launchManualUrl() async {
    if (_manualUrl != null) {
      final uri = Uri.parse(_manualUrl!);
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      backgroundColor: colorScheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 500),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(FontAwesomeIcons.handshake, color: colorScheme.primary, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Hablemos de tu Proyecto",
                          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          widget.plan.name,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // INFO BOX
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  widget.plan.idealFor,
                  style: theme.textTheme.bodyMedium,
                ),
              ),

              const SizedBox(height: 24),

              // --- ZONA DE ACCIÓN Y ERRORES ---
              
              // 1. Mensaje de Error de Red (Si hubo)
              if (_errorMessage != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: colorScheme.errorContainer.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: colorScheme.error, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!, 
                          style: TextStyle(color: colorScheme.onErrorContainer, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),

              // 2. Botón Manual (Fallback si el automático falla)
              if (_manualUrl != null) ...[
                 Container(
                   margin: const EdgeInsets.only(bottom: 16),
                   padding: const EdgeInsets.all(16),
                   decoration: BoxDecoration(
                     border: Border.all(color: Colors.amber),
                     borderRadius: BorderRadius.circular(12),
                     color: Colors.amber.withOpacity(0.1),
                   ),
                   child: Column(
                     children: [
                       const Text(
                         "El navegador bloqueó la ventana de pago automática.",
                         textAlign: TextAlign.center,
                         style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                       ),
                       const SizedBox(height: 8),
                       FilledButton.icon(
                         onPressed: _launchManualUrl,
                         style: FilledButton.styleFrom(
                           backgroundColor: Colors.amber[800],
                           foregroundColor: Colors.white,
                         ),
                         icon: const Icon(Icons.open_in_new), 
                         label: const Text("Abrir MercadoPago Manualmente"),
                       ),
                     ],
                   ),
                 )
              ],

              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  FilledButton.icon(
                    onPressed: _launchWhatsApp,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(FontAwesomeIcons.whatsapp, size: 22),
                    label: const Text("Contactar por WhatsApp"),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  if (!widget.plan.isCustom)
                    // Si ya tenemos URL manual, deshabilitamos este botón para no confundir
                    // O permitimos reintentar si hubo error.
                    OutlinedButton.icon(
                      onPressed: (_isLoadingPayment || _manualUrl != null) ? null : _processPayment,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isLoadingPayment 
                        ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: colorScheme.primary))
                        : Icon(Icons.credit_card, size: 20, color: colorScheme.primary),
                      label: Text(
                        _isLoadingPayment ? "Generando link..." : "Pagar ahora (${widget.plan.price ~/ 1000}k)",
                        style: TextStyle(color: colorScheme.primary),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, size: 12, color: colorScheme.onSurface.withOpacity(0.5)),
                    const SizedBox(width: 4),
                    Text(
                      "Pagos seguros procesados por MercadoPago",
                      style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.onSurface.withOpacity(0.5)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}