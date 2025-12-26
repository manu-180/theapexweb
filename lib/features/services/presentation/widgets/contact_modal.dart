// Archivo: lib/features/services/presentation/widgets/contact_modal.dart
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:prueba_de_riverpod/features/services/domain/models/plan_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactModal extends StatefulWidget {
  final ServicePlan plan;

  const ContactModal({super.key, required this.plan});

  @override
  State<ContactModal> createState() => _ContactModalState();
}

class _ContactModalState extends State<ContactModal> {
  bool _isLoadingPayment = false;

  void _launchWhatsApp() async {
    final message = "Hola Manuel, estuve viendo tu portfolio. Me interesa el plan *${widget.plan.name}* para potenciar mi negocio. ¿Podemos coordinar una reunión?";
    final url = "https://wa.me/5491134272488?text=${Uri.encodeComponent(message)}";
    
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint("No se pudo abrir WhatsApp: $url");
    }
  }

  void _launchMercadoPago() async {
    setState(() => _isLoadingPayment = true);
    try {
      final response = await Supabase.instance.client.functions.invoke(
        'create_preference_manuel',
        body: {
          'title': widget.plan.name,
          'unit_price': widget.plan.price,
          'quantity': 1,
        },
      );

      final data = response.data;
      
      if (data != null && data['init_point'] != null) {
        final url = data['init_point'] as String;
        final uri = Uri.parse(url);
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
         if (data != null && data['error'] != null) {
          throw "Error de MP: ${data['error']}";
        }
        throw "La respuesta del servidor no contiene el link de pago.";
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar pago: $e'), 
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoadingPayment = false);
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                        const SizedBox(height: 4),
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
                    tooltip: 'Cerrar',
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // "IDEAL PARA"
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colorScheme.outline.withOpacity(0.1)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline, size: 16, color: colorScheme.onSurfaceVariant),
                        const SizedBox(width: 8),
                        Text(
                          "¿Es este plan para mí?",
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold, 
                            color: colorScheme.onSurfaceVariant
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.plan.idealFor,
                      style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Text(
                "Antes de contratar, quiero asegurarme de que este es el plan perfecto para vos. Estoy disponible para responder cualquier duda técnica o estratégica.",
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
              ),

              const SizedBox(height: 32),

              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 1. WhatsApp (Siempre disponible)
                  FilledButton.icon(
                    onPressed: _launchWhatsApp,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF25D366),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(FontAwesomeIcons.whatsapp, size: 22),
                    label: const Text("Contactar por WhatsApp"),
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // 2. Pagar (Solo si NO es Custom)
                  if (!widget.plan.isCustom)
                    OutlinedButton.icon(
                      onPressed: _isLoadingPayment ? null : _launchMercadoPago,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        side: BorderSide(color: colorScheme.primary.withOpacity(0.3)),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      icon: _isLoadingPayment 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
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