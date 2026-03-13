// Archivo: lib/features/landing/presentation/widgets/tech_card.dart
import 'dart:async';
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
    this.themeNoticeLabel,
    this.themeNoticeDuration,
  });

  final AppTheme theme;
  final String title;
  final Widget icon;
  final List<String> bullets;
  final Color accentColor;
  final ValueNotifier<Offset> mousePos;
  final VoidCallback? onTapOverride;
  final String? themeNoticeLabel;
  /// Si no se pasa, por defecto 3400 ms. Para las cards de abajo (Assistify, BotLode, Contact Engine) usar ~2000 ms.
  final Duration? themeNoticeDuration;

  @override
  ConsumerState<TechCard> createState() => _TechCardState();
}

class _TechCardState extends ConsumerState<TechCard> {
  static OverlayEntry? _activeThemeToastEntry;
  static Timer? _activeThemeToastTimer;

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
      if ((widget.themeNoticeLabel ?? '').isNotEmpty) {
        _showThemeAppliedBanner(widget.themeNoticeLabel!);
      }
    } else {
      _previewApplied = false;
      _themeBeforePreview = null;
      ref.read(dynamicThemeProvider.notifier).setTheme(widget.theme);
      if ((widget.themeNoticeLabel ?? '').isNotEmpty) {
        _showThemeAppliedBanner(widget.themeNoticeLabel!);
      }
    }
  }

  void _showThemeAppliedBanner(String themeName) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) return;
    final colorScheme = Theme.of(context).colorScheme;
    final topInset = MediaQuery.paddingOf(context).top + kToolbarHeight + 10;
    _activeThemeToastTimer?.cancel();
    _activeThemeToastEntry?.remove();
    _activeThemeToastEntry = null;

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _ThemeToastOverlay(
        title: 'Tema global actualizado',
        subtitle: 'Paleta activa: $themeName',
        accentColor: widget.accentColor,
        surfaceColor: colorScheme.surface,
        outlineColor: colorScheme.outline,
        textColor: colorScheme.onSurface,
        topInset: topInset,
      ),
    );

    _activeThemeToastEntry = entry;
    overlay.insert(entry);

    final duration = widget.themeNoticeDuration ?? const Duration(milliseconds: 3400);
    _activeThemeToastTimer = Timer(duration, () {
      entry.remove();
      if (identical(_activeThemeToastEntry, entry)) {
        _activeThemeToastEntry = null;
      }
    });
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

class _ThemeToastOverlay extends StatefulWidget {
  const _ThemeToastOverlay({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.surfaceColor,
    required this.outlineColor,
    required this.textColor,
    required this.topInset,
  });

  final String title;
  final String subtitle;
  final Color accentColor;
  final Color surfaceColor;
  final Color outlineColor;
  final Color textColor;
  final double topInset;

  @override
  State<_ThemeToastOverlay> createState() => _ThemeToastOverlayState();
}

class _ThemeToastOverlayState extends State<_ThemeToastOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 360),
    )..forward();

    _slide = Tween<Offset>(
      begin: const Offset(0, -0.22),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bool isDark = theme.brightness == Brightness.dark;

    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, widget.topInset, 16, 0),
          child: SlideTransition(
            position: _slide,
            child: FadeTransition(
              opacity: _fade,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: widget.surfaceColor.withValues(
                      alpha: isDark ? 0.92 : 0.96,
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: widget.outlineColor.withValues(
                        alpha: isDark ? 0.28 : 0.18,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: isDark ? 0.28 : 0.10,
                        ),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(14),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: BoxDecoration(
                                color: widget.accentColor.withValues(
                                  alpha: isDark ? 0.26 : 0.14,
                                ),
                                borderRadius: BorderRadius.circular(9),
                              ),
                              child: Icon(
                                Icons.palette_outlined,
                                size: 16,
                                color: widget.accentColor,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    widget.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: widget.textColor,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.15,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    widget.subtitle,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: widget.textColor.withValues(
                                        alpha: 0.78,
                                      ),
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              Icons.check_circle_rounded,
                              size: 17,
                              color: widget.accentColor.withValues(
                                alpha: isDark ? 0.92 : 0.86,
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
      ),
    );
  }
}
