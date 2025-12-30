// Archivo: lib/features/presence/presentation/widgets/presence_badge.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/core/providers/network_status_provider.dart'; // <--- IMPORTACIÓN
import 'package:apex/features/presence/providers/presence_provider.dart';

class PresenceBadge extends ConsumerWidget {
  const PresenceBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final users = ref.watch(presenceNotifierProvider);
    
    // Escuchamos la red también aquí para dar feedback visual inmediato
    final networkStatus = ref.watch(networkStatusNotifierProvider);

    // --- CONFIGURACIÓN DE TAMAÑOS ---
    const double kAvatarRadius = 16.0; 
    const double kIconSize = 20.0;     
    // --------------------------------

    // 1. ESTADO "SIN CONEXIÓN" (Prioridad Máxima)
    if (networkStatus == NetworkStatus.offline) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              "Offline",
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ),
      );
    }

    // 2. ESTADO "CONECTANDO" (Hay internet pero lista vacía)
    if (users.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 8, height: 8,
              decoration: const BoxDecoration(color: Colors.orangeAccent, shape: BoxShape.circle),
            ),
            const SizedBox(width: 8),
            Text(
              "Conectando...",
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
      );
    }

    final totalCount = users.length;
    
    // Identificamos quién soy yo
    final me = users.firstWhere(
      (u) => u.isMe, 
      orElse: () => ConnectedUser(id: 'unknown', isMe: true, name: 'Yo')
    );

    // --- LÓGICA DE AGRUPAMIENTO ---
    final others = users.where((u) => !u.isMe).toList();
    final namedUsers = others.where((u) => u.name != null).toList();
    final anonymousCount = others.where((u) => u.name == null).length;
    // ------------------------------
    
    String labelText = totalCount == 1 ? "1 online (Tú)" : "$totalCount online";

    return PopupMenuButton(
      tooltip: 'Ver quién está conectado',
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      itemBuilder: (context) => <PopupMenuEntry<dynamic>>[
          
          // A. MI USUARIO (Siempre visible arriba)
          PopupMenuItem(
            enabled: false,
            height: 48, 
            child: Row(
              children: [
                _UserAvatar(user: me, radius: kAvatarRadius, iconSize: kIconSize),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    me.name != null ? "${me.name} (Tú)" : "Tú (Visitante Anónimo)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface, 
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          if (others.isNotEmpty) const PopupMenuDivider(height: 1),
          
          // B. OTROS USUARIOS CON NOMBRE
          ...namedUsers.map((u) {
            return PopupMenuItem(
              enabled: false,
              height: 48,
              child: Row(
                children: [
                  _UserAvatar(user: u, radius: kAvatarRadius, iconSize: kIconSize),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      u.name!,
                      style: TextStyle(color: theme.colorScheme.onSurface),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }),

          // C. LOGICA DE ANÓNIMOS
          if (anonymousCount == 1)
             PopupMenuItem(
              enabled: false,
              height: 48,
              child: Row(
                children: [
                   CircleAvatar(
                    radius: kAvatarRadius,
                    backgroundColor: theme.colorScheme.onSurface.withOpacity(0.08),
                    child: Icon(Icons.person_outline, size: kIconSize, color: theme.colorScheme.onSurface.withOpacity(0.7)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Visitante Anónimo",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

          if (anonymousCount > 1)
            PopupMenuItem(
              enabled: false,
              height: 48,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: kAvatarRadius,
                    backgroundColor: theme.colorScheme.onSurface.withOpacity(0.05),
                    child: Icon(Icons.group_outlined, size: kIconSize, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    "Visitantes Anónimos x $anonymousCount",
                    style: TextStyle(
                      fontStyle: FontStyle.italic,
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),

          // D. MENSAJE FINAL
          if (totalCount > 1)
             PopupMenuItem(
              enabled: false,
              height: 36,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4.0),
                  child: Text(
                    "¡Gracias por visitar!",
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 11,
                      color: theme.colorScheme.onSurface.withOpacity(0.5),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ),
            ),
      ],
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Pulse(
              infinite: true,
              duration: const Duration(seconds: 2),
              child: Container(
                width: 8, height: 8,
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
                color: theme.colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- HELPER: Avatar Unificado ---
class _UserAvatar extends StatelessWidget {
  final ConnectedUser user;
  final double radius;
  final double iconSize;

  const _UserAvatar({
    required this.user, 
    required this.radius,
    required this.iconSize,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    if (user.photoUrl != null && user.photoUrl!.isNotEmpty) {
      return CircleAvatar(
        radius: radius, 
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        backgroundImage: NetworkImage(user.photoUrl!),
        onBackgroundImageError: (_, __) {}, 
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: theme.colorScheme.onSurface.withOpacity(0.08),
      child: Icon(
        user.name != null ? Icons.person : Icons.person_outline,
        size: iconSize, 
        color: theme.colorScheme.onSurface.withOpacity(0.7),
      ),
    );
  }
}