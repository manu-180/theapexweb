// Archivo: lib/features/auth/presentation/widgets/auth_modal.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:prueba_de_riverpod/features/auth/presentation/providers/auth_providers.dart';

class AuthRequiredModal extends ConsumerWidget {
  const AuthRequiredModal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Animación de Seguridad (Usamos la de Supabase que ya tienes)
            SizedBox(
              height: 120,
              child: Lottie.asset('assets/animations/supabase_lottie.json', repeat: false),
            ),
            const SizedBox(height: 24),
            
            Text(
              "Veracidad Garantizada",
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Para mantener la calidad y autenticidad de las reseñas en este portfolio, solicitamos un inicio de sesión rápido con Google.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            
            // Botón de Login
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(context); // Cerramos el modal
                  ref.read(authRepositoryProvider).signInWithGoogle(); // Ejecutamos login
                },
                icon: const Icon(Icons.g_mobiledata, size: 28),
                label: const Text("Autenticar con Google"),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
          ],
        ),
      ),
    );
  }
}