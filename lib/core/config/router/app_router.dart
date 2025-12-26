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
              // AQUÍ ESTÁ EL CAMBIO:
              // Leemos el 'extra' que nos manda el footer. Si no hay nada, es 0 (Webs).
              final index = state.extra as int? ?? 0;
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