// Archivo: lib/features/landing/presentation/widgets/tech_card.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/core/config/theme/app_theme.dart';
import 'package:apex/core/config/theme/app_theme_providers.dart';

class TechCard extends ConsumerStatefulWidget {
  const TechCard({
    super.key,
    required this.theme,
    required this.title,
    required this.icon,
    required this.bullets,
    required this.accentColor,
    required this.mousePos,
    this.onTapOverride,
  });

  final AppTheme theme;
  final String title;
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
  static const double _topBarInset = 10;
  AppTheme? _themeBeforePreview;
  bool _previewApplied = false;

  void _onHover(bool isHovering) {
    if (isHovering) {
      if (!_isHovering) {
        final currentTheme = ref.read(dynamicThemeProvider).theme;
        _themeBeforePreview = currentTheme;
        if (currentTheme != widget.theme) {
          ref
              .read(dynamicThemeProvider.notifier)
              .setTheme(widget.theme, persist: false);
          _previewApplied = true;
        }
      }
    } else {
      if (_previewApplied && _themeBeforePreview != null) {
        ref
            .read(dynamicThemeProvider.notifier)
            .setTheme(_themeBeforePreview!, persist: false);
      }
      _previewApplied = false;
      _themeBeforePreview = null;
    }
    setState(() => _isHovering = isHovering);
  }

  void _onClick() {
    if (widget.onTapOverride != null) {
      widget.onTapOverride!();
    } else {
      _previewApplied = false;
      _themeBeforePreview = null;
      ref.read(dynamicThemeProvider.notifier).setTheme(widget.theme);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);
    final colorScheme = themeData.colorScheme;
    final isDark = themeData.brightness == Brightness.dark;

    final baseBorderColor = colorScheme.outline.withValues(
      alpha: isDark ? 0.20 : 0.24,
    );
    final hoverBorderColor = widget.accentColor.withValues(
      alpha: isDark ? 0.45 : 0.35,
    );
    final surfaceColor = colorScheme.surface;
    // En modo claro usamos una superficie mas solida para separar mejor la card del fondo.
    final glassBase = surfaceColor.withValues(alpha: isDark ? 0.62 : 0.96);
    final glassCold = Color.alphaBlend(
      (isDark ? const Color(0xFFB8C8E0) : const Color(0xFFE2EAF5)).withValues(
        alpha: isDark ? 0.06 : 0.08,
      ),
      glassBase,
    );
    final hoverGlass = Color.alphaBlend(
      (isDark ? const Color(0xFFB8C8E0) : const Color(0xFFE2EAF5)).withValues(
        alpha: isDark ? 0.10 : 0.12,
      ),
      colorScheme.surfaceContainerHigh.withValues(alpha: isDark ? 0.75 : 0.96),
    );
    final cardShadow = isDark
        ? <BoxShadow>[]
        : [
            BoxShadow(
              color: Colors.black.withValues(alpha: _isHovering ? 0.10 : 0.07),
              blurRadius: _isHovering ? 30 : 22,
              offset: Offset(0, _isHovering ? 10 : 7),
            ),
          ];

    return MouseRegion(
      onEnter: (_) => _onHover(true),
      onExit: (_) => _onHover(false),
      cursor: SystemMouseCursors.click,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        offset: Offset(0, _isHovering ? -0.012 : 0),
        child: AnimatedScale(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          scale: _isHovering ? 1.008 : 1.0,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(18)),
            child: Material(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(18),
              child: InkWell(
                onTap: _onClick,
                borderRadius: BorderRadius.circular(18),
                splashColor: widget.accentColor.withValues(alpha: 0.10),
                highlightColor: widget.accentColor.withValues(alpha: 0.06),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: _isHovering ? hoverGlass : glassCold,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: cardShadow,
                        border: Border.all(
                          color: _isHovering
                              ? hoverBorderColor
                              : baseBorderColor,
                          width: _isHovering ? 1.35 : 1.0,
                        ),
                      ),
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 260),
                            curve: Curves.easeOutCubic,
                            top: 0,
                            left: _topBarInset,
                            right: _isHovering
                                ? _topBarInset
                                : 120 + _topBarInset,
                            child: Container(
                              height: 3,
                              decoration: BoxDecoration(
                                color: widget.accentColor.withValues(
                                  alpha: _isHovering ? 0.95 : 0.55,
                                ),
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(18),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(26),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: AnimatedDefaultTextStyle(
                                        duration: const Duration(
                                          milliseconds: 220,
                                        ),
                                        curve: Curves.easeOutCubic,
                                        style: themeData
                                            .textTheme
                                            .headlineSmall!
                                            .copyWith(
                                              fontWeight: FontWeight.w900,
                                              color: _isHovering
                                                  ? widget.accentColor
                                                  : widget.accentColor
                                                        .withValues(
                                                          alpha: 0.92,
                                                        ),
                                              letterSpacing: _isHovering
                                                  ? -0.2
                                                  : 0,
                                            ),
                                        child: Text(widget.title),
                                      ),
                                    ),
                                    AnimatedContainer(
                                      duration: const Duration(
                                        milliseconds: 220,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      padding: const EdgeInsets.all(11),
                                      decoration: BoxDecoration(
                                        color: widget.accentColor.withValues(
                                          alpha: _isHovering ? 0.18 : 0.10,
                                        ),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: widget.accentColor.withValues(
                                            alpha: _isHovering ? 0.42 : 0.24,
                                          ),
                                        ),
                                      ),
                                      child: widget.icon,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Divider(
                                  color: widget.accentColor.withValues(
                                    alpha: _isHovering ? 0.34 : 0.20,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                for (final text in widget.bullets)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          Icons.check_rounded,
                                          size: 18,
                                          color: widget.accentColor.withValues(
                                            alpha: _isHovering ? 1 : 0.86,
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            text,
                                            style: themeData.textTheme.bodyLarge
                                                ?.copyWith(
                                                  height: 1.5,
                                                  color: colorScheme.onSurface
                                                      .withValues(
                                                        alpha: isDark
                                                            ? 0.86
                                                            : 0.93,
                                                      ),
                                                ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
