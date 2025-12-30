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

// Creamos un GlobalKey para el ShellRoute para evitar que se reconstruya innecesariamente
final _rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
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
              // MEJORA: Sistema híbrido de persistencia de estado
              
              // 1. Prioridad: Navegación interna (state.extra)
              // Si venimos del footer con un objeto explícito, lo usamos.
              if (state.extra is int) {
                return ServicesView(initialIndex: state.extra as int);
              }

              // 2. Fallback: Query Parameters (URL)
              // Permite refrescar la página o compartir links específicos: /services?view=apps
              final viewParam = state.uri.queryParameters['view'];
              int index = 0; // Por defecto: Web
              
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