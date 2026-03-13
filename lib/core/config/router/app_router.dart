// Archivo: lib/core/config/router/app_router.dart
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

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  return GoRouter(
    initialLocation: '/',
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