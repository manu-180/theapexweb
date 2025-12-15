// Archivo: lib/core/config/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:prueba_de_riverpod/core/widgets/main_layout.dart';
import 'package:prueba_de_riverpod/features/about_me/presentation/views/about_me_view.dart';
import 'package:prueba_de_riverpod/features/contact/presentation/views/contact_view.dart';
import 'package:prueba_de_riverpod/features/landing/presentation/views/landing_view.dart';
import 'package:prueba_de_riverpod/features/services/presentation/views/services_view.dart';

part 'app_router.g.dart';

// Creamos un GlobalKey para el ShellRoute
final _rootNavigatorKey = GlobalKey<NavigatorState>();

@riverpod
GoRouter goRouter(GoRouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    navigatorKey: _rootNavigatorKey,
    routes: [
      // --- ShellRoute para el Layout Principal ---
      // 
      // Este ShellRoute envuelve todas las rutas hijas con el MainLayout.
      ShellRoute(
        // El 'builder' del ShellRoute renderiza el MainLayout
        builder: (context, state, child) {
          // 'child' es la vista que coincide con la ruta (ej. LandingView)
          return MainLayout(child: child); 
        },
        // --- Rutas Hijas (las páginas de tu app) ---
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            builder: (context, state) => const LandingView(),
          ),
          GoRoute(
            path: '/services',
            name: 'services',
            builder: (context, state) => const ServicesView(),
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