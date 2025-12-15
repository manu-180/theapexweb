// Archivo: lib/core/widgets/responsive_builder.dart
import 'package:flutter/material.dart';

enum ScreenType { mobile, desktop }

class ResponsiveBuilder extends StatelessWidget {
  final Widget Function(BuildContext context) mobile;
  final Widget Function(BuildContext context) desktop;
  final double breakpoint; // El punto donde cambia de móvil a escritorio

  const ResponsiveBuilder({
    super.key,
    required this.mobile,
    required this.desktop,
    this.breakpoint = 800, // Por defecto, cambia a escritorio a los 800px
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return mobile(context);
        } else {
          return desktop(context);
        }
      },
    );
  }
}