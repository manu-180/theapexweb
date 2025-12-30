import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/core/providers/network_status_provider.dart';

class OfflineStatusBanner extends ConsumerWidget {
  final Widget child;

  const OfflineStatusBanner({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkStatusNotifierProvider);
    final isOffline = networkStatus == NetworkStatus.offline;
    final theme = Theme.of(context);
    
    // Altura segura para el banner (evita notch/status bar si se pone arriba)
    final topPadding = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // 1. La aplicación normal
        child,

        // 2. El Banner de "Sin Conexión"
        if (isOffline)
          Positioned(
            bottom: 0, // Lo ponemos abajo para no tapar la navegación principal
            left: 0,
            right: 0,
            child: FadeInUp(
              duration: const Duration(milliseconds: 300),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    border: Border(
                      top: BorderSide(color: theme.colorScheme.error, width: 2),
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off_rounded, color: theme.colorScheme.error, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          "Estás desconectado. Revisa tu internet.",
                          style: TextStyle(
                            color: theme.colorScheme.onErrorContainer,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}