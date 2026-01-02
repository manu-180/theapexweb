// Archivo: lib/features/presence/presentation/widgets/presence_badge.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shimmer/shimmer.dart';
import 'package:apex/core/providers/network_status_provider.dart'; 
import 'package:apex/features/presence/providers/presence_provider.dart';

class PresenceBadge extends ConsumerWidget {
  const PresenceBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final users = ref.watch(presenceNotifierProvider);
    final networkStatus = ref.watch(networkStatusNotifierProvider);

    // --- LÓGICA DE ESTADOS ---
    final isOffline = networkStatus == NetworkStatus.offline;
    final isConnecting = !isOffline && users.isEmpty;
    final isOnline = !isOffline && users.isNotEmpty;

    // Configuración visual según estado
    Widget statusIconOrAnim;
    Color statusColor;
    String statusText;

    if (isOffline) {
      statusColor = colorScheme.error;
      statusText = "Offline";
      statusIconOrAnim = Icon(Icons.wifi_off_rounded, size: 14, color: statusColor);
    } else if (isConnecting) {
      statusColor = Colors.orangeAccent;
      statusText = "Conectando...";
      statusIconOrAnim = SizedBox(
        width: 10, height: 10, 
        child: CircularProgressIndicator(strokeWidth: 2, color: statusColor)
      );
    } else {
      statusColor = const Color(0xFF00E676); // Verde
      statusText = "${users.length} Online";
      // BLINDAJE: SizedBox estricto para evitar rebotes de layout
      statusIconOrAnim = SizedBox(
        width: 10, height: 10,
        child: Pulse(
          infinite: true,
          duration: const Duration(seconds: 2),
          child: Center(
            child: Container(
              width: 8, height: 8,
              decoration: BoxDecoration(
                color: statusColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(color: statusColor.withOpacity(0.6), blurRadius: 6, spreadRadius: 1)
                ]
              ),
            ),
          ),
        ),
      );
    }

    // --- DEFINICIÓN DEL CONTENIDO INTERNO ---
    final innerContent = Container(
      height: 34, // Altura fija para evitar overflow
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          statusIconOrAnim,
          const SizedBox(width: 8),
          Text(
            statusText,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: isOffline ? statusColor : colorScheme.onSurface,
              height: 1.0,
            ),
          ),
          if (isOnline) ...[
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: colorScheme.onSurfaceVariant),
          ]
        ],
      ),
    );

    // --- CONSTRUCCIÓN DEL CONTENEDOR PRINCIPAL (PÍLDORA) ---
    // Usamos Material para manejar el color, la forma y CORTAR (Clip) el efecto de hover.
    final badgeDecoration = Material(
      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      borderRadius: BorderRadius.circular(20),
      clipBehavior: Clip.antiAlias, // <--- ESTO ES LA CLAVE: Corta el hover cuadrado
      child: isOnline
          ? _buildMenuButton(context, ref, innerContent, users, colorScheme)
          : innerContent, // Si no es online, solo mostramos el contenido sin botón
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      // Envolvemos en un contenedor transparente para el margen externo
      child: badgeDecoration,
    );
  }

  Widget _buildMenuButton(
    BuildContext context, 
    WidgetRef ref, 
    Widget child, 
    List<ConnectedUser> users, 
    ColorScheme colorScheme
  ) {
    final me = users.firstWhere((u) => u.isMe, orElse: () => ConnectedUser(id: '?', isMe: true, name: 'Yo'));
    final others = users.where((u) => !u.isMe).toList();
    final realUsers = others.where((u) => u.name != null && !u.name!.startsWith('anon-')).toList();
    final anonymousCount = others.length - realUsers.length;

    return PopupMenuButton(
      tooltip: 'Comunidad',
      offset: const Offset(0, 45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 4,
      shadowColor: Colors.black26,
      padding: EdgeInsets.zero, // Quitamos padding para que el hover llene la píldora
      
      // BLINDAJE: Tipo explícito para evitar error de compilación
      itemBuilder: (context) => <PopupMenuEntry<dynamic>>[
        PopupMenuItem(
          enabled: false,
          child: _UserRow(user: me, isMe: true),
        ),
        const PopupMenuDivider(),
        
        if (realUsers.isNotEmpty) ...[
           PopupMenuItem(
            enabled: false,
            height: 30,
            child: Text("Comunidad", style: TextStyle(fontSize: 10, color: colorScheme.primary, fontWeight: FontWeight.bold)),
          ),
          ...realUsers.map((u) => PopupMenuItem(
            enabled: false, 
            height: 40,
            child: _UserRow(user: u, isMe: false),
          )),
        ],

        if (anonymousCount > 0) ...[
          if (realUsers.isNotEmpty) const PopupMenuDivider(),
          PopupMenuItem(
            enabled: false,
            height: 40,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: colorScheme.surfaceContainerHighest,
                  child: Icon(FontAwesomeIcons.userSecret, size: 12, color: colorScheme.onSurfaceVariant),
                ),
                const SizedBox(width: 12),
                Text(
                  "$anonymousCount Visitante${anonymousCount > 1 ? 's' : ''}",
                  style: TextStyle(fontStyle: FontStyle.italic, color: colorScheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
        ]
      ],
      child: child,
    );
  }
}

// --- WIDGETS AUXILIARES ---

class _UserRow extends StatelessWidget {
  final ConnectedUser user;
  final bool isMe;

  const _UserRow({required this.user, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = user.name ?? 'Anónimo';
    final isAnon = name.startsWith('anon-') || user.name == null;

    return Row(
      children: [
        _SmartAvatar(url: user.photoUrl, name: name, isMe: isMe),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isMe ? "$name (Tú)" : name,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              if (isMe && isAnon)
                Text(
                  "Inicia sesión para tu foto",
                  style: theme.textTheme.labelSmall?.copyWith(fontSize: 9, color: theme.colorScheme.primary),
                  overflow: TextOverflow.ellipsis,
                ),
            ],
          ),
        ),
        if (isMe) 
          Icon(Icons.check_circle, size: 14, color: theme.colorScheme.primary)
      ],
    );
  }
}

class _SmartAvatar extends StatelessWidget {
  final String? url;
  final String name;
  final bool isMe;

  const _SmartAvatar({required this.url, required this.name, required this.isMe});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasUrl = url != null && url!.isNotEmpty;

    if (hasUrl) {
      return Container(
        width: 32, height: 32,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isMe ? Border.all(color: colorScheme.primary, width: 1.5) : null,
        ),
        child: ClipOval(
          child: Image.network(
            url!,
            fit: BoxFit.cover,
            errorBuilder: (_,__,___) => _FallbackAvatar(name: name),
            loadingBuilder: (ctx, child, progress) {
              if (progress == null) return child;
              return Shimmer.fromColors(
                baseColor: colorScheme.surfaceContainerHighest,
                highlightColor: colorScheme.surface,
                child: Container(color: Colors.white),
              );
            },
          ),
        ),
      );
    }
    return _FallbackAvatar(name: name, isMe: isMe);
  }
}

class _FallbackAvatar extends StatelessWidget {
  final String name;
  final bool isMe;
  const _FallbackAvatar({required this.name, this.isMe = false});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    
    return Container(
      width: 32, height: 32,
      decoration: BoxDecoration(
        color: isMe ? theme.colorScheme.primaryContainer : theme.colorScheme.surfaceContainerHighest,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          initial,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isMe ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurfaceVariant,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}