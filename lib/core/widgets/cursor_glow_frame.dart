import 'package:flutter/material.dart';

/// Borde luminoso que sigue la posicion global del cursor.
/// Se usa para unificar el estilo de cards grandes en toda la app.
class CursorGlowFrame extends StatefulWidget {
  const CursorGlowFrame({
    super.key,
    required this.mousePos,
    required this.child,
    this.borderRadius = 24,
    this.glowThickness = 2.2,
    this.intensity = 1.0,
    this.innerColor,
    this.lightModeShadow = const [],
    this.enableHoverLift = false,
    this.hoverScale = 1.01,
  });

  final ValueNotifier<Offset> mousePos;
  final Widget child;
  final double borderRadius;
  final double glowThickness;
  final double intensity;
  final Color? innerColor;
  final List<BoxShadow> lightModeShadow;
  final bool enableHoverLift;
  final double hoverScale;

  @override
  State<CursorGlowFrame> createState() => _CursorGlowFrameState();
}

class _CursorGlowFrameState extends State<CursorGlowFrame> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final glowColor = cs.primary;
    final strong = (0.95 * widget.intensity).clamp(0.0, 1.0);
    final medium = (0.38 * widget.intensity).clamp(0.0, 1.0);

    return MouseRegion(
      onEnter: widget.enableHoverLift
          ? (_) => setState(() => _isHovered = true)
          : null,
      onExit: widget.enableHoverLift
          ? (_) => setState(() => _isHovered = false)
          : null,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        scale: widget.enableHoverLift && _isHovered ? widget.hoverScale : 1.0,
        child: ValueListenableBuilder<Offset>(
          valueListenable: widget.mousePos,
          builder: (context, mouseOffset, _) {
            Offset local = Offset.zero;
            final renderObject = context.findRenderObject();
            if (renderObject is RenderBox && renderObject.hasSize) {
              local = renderObject.globalToLocal(mouseOffset);
            }
            final width = renderObject is RenderBox
                ? renderObject.size.width
                : 1.0;
            final height = renderObject is RenderBox
                ? renderObject.size.height
                : 1.0;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 110),
              curve: Curves.easeOut,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(widget.borderRadius),
                gradient: RadialGradient(
                  center: Alignment(
                    (local.dx / width) * 2 - 1,
                    (local.dy / height) * 2 - 1,
                  ),
                  radius: 1.38,
                  colors: [
                    glowColor.withValues(alpha: strong),
                    glowColor.withValues(alpha: medium),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.40, 1.0],
                ),
                boxShadow: const [],
              ),
              padding: EdgeInsets.all(widget.glowThickness),
              child: Container(
                decoration: BoxDecoration(
                  color: widget.innerColor ?? cs.surface,
                  borderRadius: BorderRadius.circular(
                    widget.borderRadius - widget.glowThickness,
                  ),
                ),
                child: widget.child,
              ),
            );
          },
        ),
      ),
    );
  }
}
