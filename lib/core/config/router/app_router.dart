// Archivo: lib/core/config/router/app_router.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:apex/core/widgets/main_layout.dart';
import 'package:apex/features/about_me/presentation/views/about_me_view.dart';
import 'package:apex/features/contact/presentation/views/contact_view.dart';
import 'package:apex/features/landing/presentation/views/landing_view.dart';
import 'package:apex/features/services/presentation/views/services_view.dart';

part 'app_router.g.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Rutas válidas de la app (para respetar la URL al cargar en web).
const _validPaths = ['/', '/services', '/about', '/contact'];

/// Ruta capturada al arranque (antes de cualquier MaterialApp) para no perder el hash.
String? _capturedInitialPath;

/// Llamar desde main() al inicio para guardar #/about etc. antes de que el hash se pierda.
void captureInitialPathFromPlatform() {
  if (!kIsWeb) return;
  final fragment = Uri.base.fragment;
  if (fragment.isEmpty) return;
  final path = fragment.startsWith('/') ? fragment : '/$fragment';
  if (_validPaths.contains(path)) {
    _capturedInitialPath = path;
    if (kDebugMode) debugPrint('[Router] captureInitialPathFromPlatform() → "$path"');
  }
}

String _initialLocation() {
  if (!kIsWeb) return '/';
  // Preferir la ruta capturada al arranque (el hash puede limpiarse tras el loading).
  if (_capturedInitialPath != null) {
    if (kDebugMode) debugPrint('[Router] _initialLocation() → "$_capturedInitialPath" (captured at startup)');
    return _capturedInitialPath!;
  }
  final fragment = Uri.base.fragment;
  if (kDebugMode) {
    debugPrint('[Router] Uri.base: ${Uri.base}');
    debugPrint('[Router] fragment: "$fragment" (isEmpty: ${fragment.isEmpty})');
  }
  if (fragment.isEmpty) return '/';
  final path = fragment.startsWith('/') ? fragment : '/$fragment';
  final use = _validPaths.contains(path) ? path : '/';
  if (kDebugMode) debugPrint('[Router] _initialLocation() → "$use"');
  return use;
}

String? _redirectFromHash(BuildContext context, GoRouterState state) {
  if (!kIsWeb) return null;
  final fragment = Uri.base.fragment;
  if (fragment.isEmpty) return null;
  final path = fragment.startsWith('/') ? fragment : '/$fragment';
  if (!_validPaths.contains(path)) return null;
  if (state.matchedLocation == path) return null;
  if (kDebugMode) debugPrint('[Router] redirect: "${state.matchedLocation}" → "$path" (hash)');
  return path;
}

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  final initial = _initialLocation();
  if (kDebugMode) debugPrint('[Router] goRouter build, initialLocation: "$initial"');
  return GoRouter(
    initialLocation: initial,
    redirect: _redirectFromHash,
    navigatorKey: _rootNavigatorKey,
    errorBuilder: (context, state) {
      return MainLayout(
        child: _NotFoundPage(attemptedPath: state.uri.toString()),
      );
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) {
          return MainLayout(child: child);
        },
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const LandingView(),
          ),
          GoRoute(
            path: '/services',
            name: 'services',
            builder: (context, state) {
              if (state.extra is int) {
                return ServicesView(initialIndex: state.extra as int);
              }

              final viewParam = state.uri.queryParameters['view'];
              int index = 0;

              if (viewParam == 'apps' || viewParam == 'mobile') {
                index = 1;
              }

              return ServicesView(initialIndex: index);
            },
          ),
          GoRoute(
            path: '/about',
            name: 'about',
            builder: (context, state) => const AboutMeView(),
          ),
          GoRoute(
            path: '/contact',
            name: 'contact',
            builder: (context, state) => const ContactView(),
          ),
        ],
      ),
    ],
  );
}

class _NotFoundPage extends StatelessWidget {
  final String attemptedPath;
  const _NotFoundPage({required this.attemptedPath});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.explore_off_rounded,
                size: 80,
                color: colorScheme.primary.withOpacity(0.5),
              ),
              const SizedBox(height: 24),
              Text(
                '404',
                style: theme.textTheme.displayLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                  fontFamily: 'Oxanium',
                  letterSpacing: 4,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Página no encontrada',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'La ruta "$attemptedPath" no existe.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              Wrap(
                spacing: 16,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: [
                  FilledButton.icon(
                    onPressed: () => context.goNamed('home'),
                    icon: const Icon(Icons.home_rounded),
                    label: const Text('Volver al inicio'),
                  ),
                  OutlinedButton.icon(
                    onPressed: () => context.goNamed('contact'),
                    icon: const Icon(Icons.mail_rounded),
                    label: const Text('Contactar'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}