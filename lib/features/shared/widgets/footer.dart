// Archivo: lib/features/shared/widgets/footer.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:prueba_de_riverpod/core/config/theme/app_theme.dart';
import 'package:prueba_de_riverpod/core/config/theme/app_theme_providers.dart';
import 'package:prueba_de_riverpod/core/widgets/responsive_builder.dart';

class Footer extends ConsumerWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      padding: const EdgeInsets.only(top: 60.0, bottom: 40.0, left: 30.0, right: 30.0),
      child: Column(
        children: [
          // --- CONTENIDO PRINCIPAL ---
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1200),
            child: ResponsiveBuilder(
              desktop: (context) => Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(child: _buildBrandColumn(context, ref)),
                  Expanded(child: _buildServicesColumn(context)),
                  Expanded(child: _buildTechStackColumn(context, ref)),
                ],
              ),
              mobile: (context) => Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildBrandColumn(context, ref),
                  const SizedBox(height: 50),
                  _buildServicesColumn(context),
                  const SizedBox(height: 50),
                  _buildTechStackColumn(context, ref),
                ],
              ),
            ),
          ),

          const SizedBox(height: 80),
          Divider(color: colorScheme.outline.withOpacity(0.1)),
          const SizedBox(height: 24),

          // --- COPYRIGHT ---
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.code, size: 16, color: colorScheme.onSurfaceVariant),
              const SizedBox(width: 10),
              Text(
                '© ${DateTime.now().year} APEX Development. Todos los derechos reservados.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- COLUMNA 1: MARCA (APEX) ---
  Widget _buildBrandColumn(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 800;
    final alignment = isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        // LOGO APEX
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center, // Alineación vertical centrada
          children: [
            // EL PICO (A sin palo) - TRANSFORMADO
            // Usamos Transform para "apretarlo" horizontalmente y hacerlo más empinado.
            Transform(
              alignment: Alignment.center,
              // Escala X al 0.7 (70% de ancho) -> Lo hace más angosto y puntiagudo
              // Escala Y al 1.1 (110% de alto) -> Lo estira un poco hacia arriba
              transform: Matrix4.identity()..scale(0.7, 1.1), 
              child: Icon(
                FontAwesomeIcons.chevronUp, 
                size: 26, // Ajusté ligeramente el tamaño para compensar la transformación
                color: theme.colorScheme.primary,
                // Le damos un poco de "peso" visual extra si es necesario
                shadows: [
                  Shadow(
                    color: theme.colorScheme.primary.withOpacity(0.4),
                    blurRadius: 8,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            // Texto APEX
            Text(
              "APEX",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: 3.0,
                color: theme.colorScheme.primary,
                height: 1.0, // Altura de línea compacta para alinear con el icono
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        _FooterLink(text: "Inicio", onTap: () => context.goNamed('home')),
        _FooterLink(text: "Sobre Mí", onTap: () => context.goNamed('about')),
        _FooterLink(text: "Contacto", onTap: () => context.goNamed('contact')),
      ],
    );
  }

  // --- COLUMNA 2: SERVICIOS ---
  Widget _buildServicesColumn(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 800;
    final alignment = isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          "SERVICIOS",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        _FooterLink(
          text: "Desarrollo Web", 
          onTap: () => context.goNamed('services', extra: 0),
        ),
        _FooterLink(
          text: "Aplicaciones Móviles", 
          onTap: () => context.goNamed('services', extra: 1),
        ),
      ],
    );
  }

  // --- COLUMNA 3: TECH STACK ---
  Widget _buildTechStackColumn(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 800;
    final alignment = isMobile ? CrossAxisAlignment.center : CrossAxisAlignment.start;

    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          "POWERED BY",
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurfaceVariant,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: isMobile ? WrapAlignment.center : WrapAlignment.start,
          children: const [
            _TechBadge(
              name: "Flutter",
              icon: FontAwesomeIcons.flutter,
              targetTheme: AppTheme.flutter,
              color: Color(0xFF0175C2),
            ),
            _TechBadge(
              name: "Supabase",
              icon: FontAwesomeIcons.bolt,
              targetTheme: AppTheme.supabase,
              color: Color(0xFF3ECF8E),
            ),
            _TechBadge(
              name: "Riverpod",
              icon: FontAwesomeIcons.water,
              targetTheme: AppTheme.riverpod,
              color: Color(0xFF6E56F8),
            ),
          ],
        ),
      ],
    );
  }
}

// --- WIDGET AUXILIAR: LINK CON BARRA ANIMADA ---
class _FooterLink extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _FooterLink({required this.text, required this.onTap});

  @override
  State<_FooterLink> createState() => _FooterLinkState();
}

class _FooterLinkState extends State<_FooterLink> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeColor = theme.colorScheme.primary;
    final inactiveColor = theme.colorScheme.onSurfaceVariant;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        child: Stack(
          alignment: Alignment.centerLeft,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 6.0, top: 2.0),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 100),
                style: theme.textTheme.bodyLarge!.copyWith( 
                  color: _isHovering ? activeColor : inactiveColor,
                  fontWeight: _isHovering ? FontWeight.w600 : FontWeight.normal,
                  fontSize: 16,
                ),
                child: Text(widget.text),
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: 2,
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 500), 
                curve: Curves.easeOutExpo,
                tween: Tween(begin: 0.0, end: _isHovering ? 1.0 : 0.0),
                builder: (context, value, child) {
                  return FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: activeColor,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- WIDGET BADGE DE TECNOLOGÍA ---
class _TechBadge extends ConsumerStatefulWidget {
  final String name;
  final IconData icon;
  final AppTheme targetTheme;
  final Color color;

  const _TechBadge({
    required this.name,
    required this.icon,
    required this.targetTheme,
    required this.color,
  });

  @override
  ConsumerState<_TechBadge> createState() => _TechBadgeState();
}

class _TechBadgeState extends ConsumerState<_TechBadge> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = _isHovering;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          ref.read(dynamicThemeProvider.notifier).setTheme(widget.targetTheme);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? widget.color.withOpacity(0.08) : theme.colorScheme.surface,
            border: Border.all(
              color: isActive ? widget.color : theme.colorScheme.outline.withOpacity(0.3),
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive 
                ? [
                    BoxShadow(
                      color: widget.color.withOpacity(0.15),
                      blurRadius: 4, 
                      offset: const Offset(0, 3),
                    )
                  ] 
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                widget.icon,
                size: 16,
                color: isActive ? widget.color : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Text(
                widget.name,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isActive ? widget.color : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}