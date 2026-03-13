import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

/// Capa visual para suavizar el cambio de tema con un reveal radial.
/// Es sutil a propósito: aporta sensación premium sin ruido visual.
class ThemeRevealOverlay extends StatefulWidget {
  const ThemeRevealOverlay({
    required this.child,
    required this.revealColor,
    super.key,
  });

  final Widget child;
  final Color revealColor;

  @override
  State<ThemeRevealOverlay> createState() => _ThemeRevealOverlayState();
}

class _ThemeRevealOverlayState extends State<ThemeRevealOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  Color _previousColor = Colors.transparent;
  Color _currentColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _currentColor = widget.revealColor;
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void didUpdateWidget(covariant ThemeRevealOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.revealColor != widget.revealColor) {
      _previousColor = oldWidget.revealColor;
      _currentColor = widget.revealColor;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final progress = Curves.easeOutCubic.transform(_controller.value);
        final isAnimating = _controller.isAnimating || _controller.value > 0;

        return Stack(
          fit: StackFit.expand,
          children: [
            widget.child,
            if (isAnimating)
              IgnorePointer(
                child: CustomPaint(
                  painter: _ThemeRevealPainter(
                    progress: progress,
                    fromColor: _previousColor,
                    toColor: _currentColor,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ThemeRevealPainter extends CustomPainter {
  const _ThemeRevealPainter({
    required this.progress,
    required this.fromColor,
    required this.toColor,
  });

  final double progress;
  final Color fromColor;
  final Color toColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;

    final center = Offset(size.width * 0.12, 72);
    final maxRadius = math.sqrt(
      size.width * size.width + size.height * size.height,
    );
    final radius = lerpDouble(0, maxRadius, progress) ?? maxRadius;

    final revealPaint = Paint()
      ..color =
          Color.lerp(
            fromColor.withValues(alpha: 0.00),
            toColor.withValues(alpha: 0.14),
            progress,
          ) ??
          toColor.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, radius, revealPaint);

    // Halo de borde ultra sutil para reforzar la sensación de expansión.
    final ringPaint = Paint()
      ..color = toColor.withValues(
        alpha: (0.16 * (1 - progress)).clamp(0, 0.16),
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, radius, ringPaint);
  }

  @override
  bool shouldRepaint(covariant _ThemeRevealPainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.fromColor != fromColor ||
        oldDelegate.toColor != toColor;
  }
}
