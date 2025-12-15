// Archivo: lib/features/landing/presentation/widgets/tech_card.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:prueba_de_riverpod/core/config/theme/app_theme.dart';
import 'package:prueba_de_riverpod/core/config/theme/app_theme_providers.dart';

class TechCard extends ConsumerStatefulWidget {
  const TechCard({
    super.key,
    required this.theme,
    required this.title,
    // CAMBIO 1: Ahora aceptamos un Widget genérico, no solo un IconData
    required this.icon, 
    required this.bullets,
    required this.accentColor,
    required this.mousePos,
    this.onTapOverride,
  });

  final AppTheme theme;
  final String title;
  // CAMBIO 2: Tipo de dato actualizado
  final Widget icon; 
  final List<String> bullets;
  final Color accentColor;
  final ValueNotifier<Offset> mousePos;
  final VoidCallback? onTapOverride;

  @override
  ConsumerState<TechCard> createState() => _TechCardState();
}

class _TechCardState extends ConsumerState<TechCard> {
  bool _isHovering = false;
  final GlobalKey _cardKey = GlobalKey();

  void _onHover(bool isHovering) {
    setState(() => _isHovering = isHovering);

    final themeNotifier = ref.read(dynamicThemeProvider.notifier);
    if (isHovering) {
      themeNotifier.setHoverTheme(widget.theme);
    } else {
      themeNotifier.clearHoverTheme();
    }
  }

 void _onClick() {
    if (widget.onTapOverride != null) {
      widget.onTapOverride!(); // Si hay una acción personalizada, úsala
    } else {
      ref.read(dynamicThemeProvider.notifier).setTheme(widget.theme); // Si no, comportamiento default
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final isDark = themeData.brightness == Brightness.dark;

    final defaultBorderColor = isDark ? Colors.white.withOpacity(0.02) : Colors.black.withOpacity(0.02);

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      cursor: SystemMouseCursors.click,
      child: ValueListenableBuilder<Offset>(
        valueListenable: widget.mousePos,
        builder: (context, mouseOffset, child) {
          Offset localLightPos = Offset.zero;
          final RenderBox? renderBox = _cardKey.currentContext?.findRenderObject() as RenderBox?;
          Size? size;

          if (renderBox != null) {
            localLightPos = renderBox.globalToLocal(mouseOffset);
            size = renderBox.size;
          }

          final borderGradient = RadialGradient(
            center: Alignment(
              (localLightPos.dx / (size?.width ?? 1)) * 2 - 1,
              (localLightPos.dy / (size?.height ?? 1)) * 2 - 1,
            ),
            radius: 1.5, 
            colors: [
              widget.accentColor, 
              defaultBorderColor, 
            ],
            stops: const [0.0, 1.0], 
          );

          final surfaceColor = themeData.colorScheme.surface;
          final hoverColor = Color.alphaBlend(
            widget.accentColor.withOpacity(0.25),
            surfaceColor, 
          );

          return AnimatedContainer(
            key: _cardKey,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            transform: _isHovering ? (Matrix4.identity()..scale(1.02)) : Matrix4.identity(),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: borderGradient, 
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.15),
                  blurRadius: 15,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            padding: const EdgeInsets.all(2.5), 
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: _isHovering ? hoverColor : surfaceColor,
                borderRadius: BorderRadius.circular(13.5), 
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _onClick,
                  borderRadius: BorderRadius.circular(13.5),
                  child: Padding(
                    padding: const EdgeInsets.all(26.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FadeIn(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                widget.title,
                                style: themeData.textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: widget.accentColor,
                                ),
                              ),
                              // Contenedor circular para el icono/imagen
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: widget.accentColor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                // CAMBIO 3: Renderizamos el widget que nos pasan directamente
                                child: widget.icon, 
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Divider(color: widget.accentColor.withOpacity(0.2)),
                        const SizedBox(height: 20),
                        ...widget.bullets.map((text) => FadeInUp(
                              delay: Duration(milliseconds: widget.bullets.indexOf(text) * 100 + 300),
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(Icons.check_circle_rounded, size: 20, color: widget.accentColor),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        text,
                                        style: themeData.textTheme.bodyLarge?.copyWith(
                                          height: 1.5,
                                          color: themeData.colorScheme.onSurface.withOpacity(0.85),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}