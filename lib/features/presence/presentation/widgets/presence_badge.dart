// Archivo: lib/features/presence/presentation/widgets/presence_badge.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/core/config/theme/app_theme_providers.dart';
import 'package:apex/features/presence/providers/presence_provider.dart';

class PresenceBadge extends ConsumerWidget {
  const PresenceBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final users = ref.watch(presenceNotifierProvider);

    // Si no hay nadie (o solo yo y falló la conexión), mostramos algo discreto
    if (users.isEmpty) return const SizedBox.shrink();

    final totalCount = users.length;
    
    // Filtramos para saber quién soy yo
    final me = users.firstWhere((u) => u.isMe, orElse: () => ConnectedUser(id: '', isMe: true));
    
    // Texto del Badge
    String labelText;
    if (totalCount == 1) {
      labelText = "1 online (Tú)";
    } else {
      labelText = "$totalCount online";
    }

    return PopupMenuButton(
      tooltip: 'Ver quién está conectado',
      offset: const Offset(0, 50),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) {
        return [
          // 1. HEADER: TÚ
          PopupMenuItem(
            enabled: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "🟢 En línea ahora",
                  style: TextStyle(
                    color: Colors.green, 
                    fontWeight: FontWeight.bold, 
                    fontSize: 12
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.person, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        me.name != null 
                            ? "${me.name} (Tú)" 
                            : "Tú (Visitante Anónimo)",
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
                const Divider(),
              ],
            ),
          ),
          
          // 2. LISTA DE OTROS
          ...users.where((u) => !u.isMe).map((u) {
            return PopupMenuItem(
              enabled: false,
              height: 40,
              child: Row(
                children: [
                  // Icono diferente si es anónimo o logueado
                  Icon(
                    u.name != null ? Icons.face : Icons.person_outline, 
                    size: 16, 
                    color: Colors.grey
                  ),
                  const SizedBox(width: 8),
                  Text(
                    u.name ?? "Visitante Anónimo",
                    style: TextStyle(
                      color: Colors.grey[800],
                      fontStyle: u.name == null ? FontStyle.italic : FontStyle.normal
                    ),
                  ),
                ],
              ),
            );
          }),

          // 3. MENSAJE FINAL (Solo si hay más gente)
          if (totalCount > 1)
             const PopupMenuItem(
              enabled: false,
              child: Padding(
                padding: EdgeInsets.only(top: 8.0),
                child: Text(
                  "¡Gracias por visitar!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ),
            ),
        ];
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // PUNTO VERDE PULSANTE (Efecto "Live")
            Pulse(
              infinite: true,
              duration: const Duration(seconds: 2),
              child: Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Colors.greenAccent,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.green, blurRadius: 4, spreadRadius: 1)
                  ]
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              labelText,
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                // Color dinámico según tema para que se vea bien siempre
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}