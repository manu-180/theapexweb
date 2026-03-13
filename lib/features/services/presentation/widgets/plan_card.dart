// Archivo: lib/features/services/presentation/widgets/plan_card.dart
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:apex/core/analytics/analytics_events.dart';
import 'package:apex/core/analytics/analytics_service.dart';
import 'package:apex/features/services/domain/models/plan_model.dart';
import 'package:apex/features/services/presentation/widgets/case_studies_modal.dart';
import 'package:apex/features/services/presentation/widgets/contact_modal.dart';

class PlanCard extends ConsumerStatefulWidget {
  const PlanCard({super.key, required this.plan, required this.mousePos});

  final ServicePlan plan;
  final ValueNotifier<Offset> mousePos;

  @override
  ConsumerState<PlanCard> createState() => _PlanCardState();
}

class _PlanCardState extends ConsumerState<PlanCard> {
  bool _isHovering = false;

  void _onBuyPressed(BuildContext context) {
    ref.read(analyticsServiceProvider).trackEvent(
      AnalyticsEvents.planCardCtaClicked,
      {'plan_name': widget.plan.name, 'is_custom': widget.plan.isCustom},
    );
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Cerrar',
      barrierColor: Colors.black.withValues(alpha: 0.52),
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (ctx, _, __) => ContactModal(plan: widget.plan),
      transitionBuilder: (ctx, anim, __, child) => Transform.scale(
        scale: Curves.easeOutBack.transform(anim.value),
        child: Opacity(opacity: anim.value, child: child),
      ),
    );
  }

  void _showCaseStudies() {
    if (widget.plan.caseStudies == null || widget.plan.caseStudies!.isEmpty) {
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CaseStudiesModal(
        caseStudies: widget.plan.caseStudies!,
        planName: widget.plan.name,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final plan = widget.plan;
    final accent = cs.primary;
    final featured = plan.isFeatured;
    final hasCases = plan.caseStudies != null && plan.caseStudies!.isNotEmpty;

    // Colores de fondo adaptados por modo
    final cardBg = isDark
        ? (featured ? cs.surfaceContainerLow : cs.surface)
        : (featured
              ? Color.alphaBlend(
                  accent.withValues(alpha: 0.04),
                  const Color(0xFFFAFBFC),
                )
              : const Color(0xFFFAFBFC));

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: hasCases ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: hasCases ? _showCaseStudies : null,
        child: AnimatedScale(
          scale: _isHovering ? 1.015 : 1.0,
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isHovering || featured
                    ? accent.withValues(alpha: featured ? 0.50 : 0.32)
                    : cs.outline.withValues(alpha: isDark ? 0.12 : 0.20),
                width: featured ? 1.5 : 1.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Accent strip ────────────────────────────────────────────
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    height: featured ? 4 : 3,
                    color: _isHovering || featured
                        ? accent
                        : accent.withValues(alpha: isDark ? 0.35 : 0.50),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 22, 24, 26),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Badge + ejemplos row ─────────────────────────────
                        Row(
                          children: [
                            if (plan.badge.isNotEmpty)
                              _BadgePill(
                                label: plan.badge,
                                accent: accent,
                                filled: featured,
                              ),
                            const Spacer(),
                            if (hasCases)
                              GestureDetector(
                                onTap: _showCaseStudies,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: cs.outline.withValues(alpha: 0.16),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.visibility_outlined,
                                        size: 12,
                                        color: cs.onSurfaceVariant,
                                      ),
                                      const SizedBox(width: 5),
                                      Text(
                                        'Ejemplos',
                                        style: theme.textTheme.labelSmall
                                            ?.copyWith(
                                              color: cs.onSurfaceVariant,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // ── Plan name ────────────────────────────────────────
                        Text(
                          plan.name,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                            color: cs.onSurface,
                            letterSpacing: -0.4,
                            height: 1.1,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // ── Tagline ──────────────────────────────────────────
                        Text(
                          plan.description,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),

                        const SizedBox(height: 20),

                        // ── Price ────────────────────────────────────────────
                        if (!plan.isCustom) ...[
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                'ARS',
                                style: theme.textTheme.labelMedium?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _formatPrice(plan.price),
                                style: theme.textTheme.displaySmall?.copyWith(
                                  fontWeight: FontWeight.w900,
                                  color: cs.onSurface,
                                  letterSpacing: -1.5,
                                  height: 1,
                                ),
                              ),
                            ],
                          ),
                          if (plan.originalPrice != null &&
                              plan.originalPrice! > plan.price) ...[
                            const SizedBox(height: 5),
                            Row(
                              children: [
                                Text(
                                  'ARS ${_formatPrice(plan.originalPrice!)}',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF22C55E,
                                    ).withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '-${plan.discountPercentage}%',
                                    style: theme.textTheme.labelSmall?.copyWith(
                                      color: const Color(0xFF22C55E),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ] else ...[
                          Text(
                            'Precio a medida',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w900,
                              color: cs.onSurface,
                              letterSpacing: -0.5,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Según alcance y funcionalidades',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],

                        const SizedBox(height: 14),

                        // ── 3 cuotas sin interés ───────────────────────────────
                        Row(
                          children: [
                            Icon(
                              Icons.credit_score_rounded,
                              size: 16,
                              color: accent.withValues(alpha: 0.85),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              plan.isCustom
                                  ? '3 cuotas sin interés (consultar valor)'
                                  : '3 cuotas sin interés de ARS ${_formatPrice(plan.price ~/ 3)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 18),

                        // ── CTA button ───────────────────────────────────────
                        _CtaButton(
                          featured: featured,
                          accent: accent,
                          onPressed: () => _onBuyPressed(context),
                        ),

                        const SizedBox(height: 24),

                        // ── "Incluye" divider ────────────────────────────────
                        Row(
                          children: [
                            Expanded(
                              child: Divider(
                                color: cs.outline.withValues(alpha: 0.12),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                              child: Text(
                                'INCLUYE',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  letterSpacing: 1.4,
                                  fontSize: 10,
                                ),
                              ),
                            ),
                            Expanded(
                              child: Divider(
                                color: cs.outline.withValues(alpha: 0.12),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ── Feature list ─────────────────────────────────────
                        for (final feature in plan.features)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 11),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 18,
                                  height: 18,
                                  margin: const EdgeInsets.only(top: 1),
                                  decoration: BoxDecoration(
                                    color: accent.withValues(
                                      alpha: isDark ? 0.12 : 0.10,
                                    ),
                                    shape: BoxShape.circle,
                                    border: isDark
                                        ? null
                                        : Border.all(
                                            color: accent.withValues(
                                              alpha: 0.30,
                                            ),
                                            width: 0.8,
                                          ),
                                  ),
                                  child: Icon(
                                    Icons.check_rounded,
                                    size: 11,
                                    color: accent,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    feature,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      height: 1.45,
                                      color: cs.onSurface,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        // ── Ideal para ───────────────────────────────────────
                        if (plan.idealFor.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.all(13),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? cs.surfaceContainerHighest.withValues(
                                      alpha: 0.45,
                                    )
                                  : cs.surfaceContainerLow,
                              borderRadius: BorderRadius.circular(11),
                              border: Border.all(
                                color: cs.outline.withValues(
                                  alpha: isDark ? 0.08 : 0.16,
                                ),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.person_outline_rounded,
                                  size: 14,
                                  color: accent,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    plan.idealFor,
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      height: 1.5,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Badge pill ────────────────────────────────────────────────────────────────

class _BadgePill extends StatelessWidget {
  const _BadgePill({
    required this.label,
    required this.accent,
    required this.filled,
  });

  final String label;
  final Color accent;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return _FeaturedBadge(label: label, accent: accent, isDark: isDark);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.26)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: accent,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ── Featured badge — HUD tech ─────────────────────────────────────────────────

class _FeaturedBadge extends StatefulWidget {
  const _FeaturedBadge({
    required this.label,
    required this.accent,
    required this.isDark,
  });
  final String label;
  final Color accent;
  final bool isDark;

  @override
  State<_FeaturedBadge> createState() => _FeaturedBadgeState();
}

class _FeaturedBadgeState extends State<_FeaturedBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2800),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = widget.accent;

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final pulse = (math.sin(_ctrl.value * 2 * math.pi) + 1) / 2;

        return CustomPaint(
          painter: _HudBorderPainter(progress: _ctrl.value, accent: accent),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Dot pulsante en el color del tema
                SizedBox(
                  width: 10,
                  height: 10,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 10 * (0.6 + pulse * 0.4),
                        height: 10 * (0.6 + pulse * 0.4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent.withValues(alpha: 0.25 * pulse),
                        ),
                      ),
                      Container(
                        width: 5,
                        height: 5,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: accent,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  widget.label.toUpperCase(),
                  style: TextStyle(
                    color: accent,
                    fontWeight: FontWeight.w800,
                    fontSize: 10.5,
                    letterSpacing: 1.4,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Painter HUD: borde tenue + destello que recorre el perímetro.
class _HudBorderPainter extends CustomPainter {
  const _HudBorderPainter({required this.progress, required this.accent});

  final double progress;
  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    final r = size.height / 2;
    final rect = Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5);
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(r));

    // 1 — Fondo muy sutil (igual que los badges normales)
    canvas.drawRRect(rrect, Paint()..color = accent.withValues(alpha: 0.10));

    // 2 — Borde base tenue
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = accent.withValues(alpha: 0.28),
    );

    // 3 — Destello que recorre el borde (sweep gradient rotativo)
    final angle = progress * 2 * math.pi;
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..shader = SweepGradient(
          startAngle: angle,
          endAngle: angle + 2 * math.pi,
          colors: [
            accent.withValues(alpha: 0.0),
            accent.withValues(alpha: 0.0),
            accent,
            accent.withValues(alpha: 0.0),
            accent.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.38, 0.50, 0.62, 1.0],
        ).createShader(rect),
    );

    // 4 — Glow exterior mínimo
    canvas.drawRRect(
      rrect,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5
        ..color = accent.withValues(alpha: 0.18)
        ..maskFilter = const MaskFilter.blur(BlurStyle.outer, 5),
    );
  }

  @override
  bool shouldRepaint(covariant _HudBorderPainter old) =>
      old.progress != progress || old.accent != accent;
}

// ── CTA button — igual en las 3 cards ────────────────────────────────────────

class _CtaButton extends StatelessWidget {
  const _CtaButton({
    required this.featured,
    required this.accent,
    required this.onPressed,
  });

  final bool featured;
  final Color accent;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent.withValues(alpha: 0.5), width: 1.5),
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.draw_outlined, size: 17, color: accent),
            const SizedBox(width: 8),
            Text(
              'Quiero un boceto gratis',
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: accent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Price formatter ───────────────────────────────────────────────────────────

String _formatPrice(int price) {
  final str = price.toString();
  final buffer = StringBuffer();
  int count = 0;
  for (int i = str.length - 1; i >= 0; i--) {
    if (count > 0 && count % 3 == 0) buffer.write('.');
    buffer.write(str[i]);
    count++;
  }
  return buffer.toString().split('').reversed.join();
}
