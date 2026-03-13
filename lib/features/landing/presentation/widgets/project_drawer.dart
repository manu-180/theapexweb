// lib/features/landing/presentation/widgets/project_drawer.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

// ─── PUBLIC API ──────────────────────────────────────────────────────────────

void showProjectDrawer(BuildContext context, {required Widget content}) {
  showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'Cerrar',
    barrierColor: Colors.black.withValues(alpha: 0.52),
    transitionDuration: const Duration(milliseconds: 380),
    pageBuilder: (ctx, _, __) => Align(
      alignment: Alignment.centerRight,
      child: _DrawerShell(content: content),
    ),
    transitionBuilder: (ctx, anim, _, child) {
      final curved = CurvedAnimation(parent: anim, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1, 0),
          end: Offset.zero,
        ).animate(curved),
        child: child,
      );
    },
  );
}

// ─── SHELL ───────────────────────────────────────────────────────────────────

class _DrawerShell extends StatelessWidget {
  const _DrawerShell({required this.content});
  final Widget content;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isMobile = size.width < 700;
    final drawerWidth = isMobile
        ? size.width
        : (size.width * 0.76).clamp(560.0, 960.0);
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: Colors.transparent,
      child: Container(
        width: drawerWidth,
        height: double.infinity,
        decoration: BoxDecoration(
          color: cs.surface,
          border: Border(
            left: BorderSide(color: cs.outline.withValues(alpha: 0.10)),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 56,
              offset: const Offset(-6, 0),
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(24, 12, 16, 12),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: cs.outline.withValues(alpha: 0.08),
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      'PROYECTO',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        letterSpacing: 1.6,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    InkWell(
                      onTap: () => Navigator.of(context).pop(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: cs.outline.withValues(alpha: 0.18),
                          ),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          size: 16,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // ── Scrollable content ────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: content,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── CONTACT ENGINE ──────────────────────────────────────────────────────────

class ContactEngineDrawerContent extends StatelessWidget {
  const ContactEngineDrawerContent({super.key});
  static const _accent = Color(0xFF6B7280);

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // HERO
        _Hero(
          accent: _accent,
          isDark: isDark,
          icon: const Icon(
            FontAwesomeIcons.crosshairs,
            size: 26,
            color: _accent,
          ),
          title: 'Contact Engine',
          tagline:
              'Encuentra clientes y convierte conversaciones en ventas, de forma automática.',
          statusLabel: 'Sistema Activo',
          statusColor: _accent,
        ),
        // IMPACT
        _ImpactRow(
          accent: _accent,
          chips: const [
            _ChipData(
              icon: Icons.schedule_rounded,
              label: '24 / 7',
              sub: 'Activo',
            ),
            _ChipData(
              icon: Icons.manage_search_rounded,
              label: 'Google',
              sub: 'Fuente',
            ),
            _ChipData(
              icon: Icons.people_alt_rounded,
              label: 'Multi\nUsuario',
              sub: '',
            ),
          ],
        ),
        const _DrawerDivider(),
        // OBJETIVOS
        FadeInUp(
          delay: const Duration(milliseconds: 60),
          child: _Section(
            icon: Icons.flag_rounded,
            title: 'Lo que logra en tu negocio',
            accent: _accent,
            child: const Column(
              children: [
                _Feature(
                  icon: Icons.manage_search_rounded,
                  title: 'Encuentra clientes todos los días',
                  desc:
                      'Busca en Google Maps por rubro y ciudad y extrae datos de empresas reales sin que hagas nada.',
                ),
                _Feature(
                  icon: FontAwesomeIcons.whatsapp,
                  title: 'Alcanzá por email y WhatsApp',
                  desc:
                      'Combina ambos canales para asegurar que el mensaje llegue y genere respuesta.',
                ),
                _Feature(
                  icon: Icons.track_changes_rounded,
                  title: 'Seguimiento sin esfuerzo',
                  desc:
                      'Cada contacto queda registrado. No se pierde ninguna oportunidad.',
                ),
                _Feature(
                  icon: Icons.trending_up_rounded,
                  title: 'Escalá sin agrandar el equipo',
                  desc:
                      'La arquitectura multi-tenant permite crecer sin contratar más personas.',
                ),
              ],
            ),
          ),
        ),
        const _DrawerDivider(),
        // FLUJO
        FadeInUp(
          delay: const Duration(milliseconds: 80),
          child: _Section(
            icon: Icons.hub_rounded,
            title: 'Cómo funciona',
            accent: _accent,
            child: const Column(
              children: [
                _FlowStep(
                  step: '01',
                  icon: Icons.manage_search_rounded,
                  title: 'Finder',
                  desc:
                      'Busca en Google Maps y extrae contactos por rubro y ciudad.',
                ),
                _FlowStep(
                  step: '02',
                  icon: Icons.email_outlined,
                  title: 'Hunter',
                  desc:
                      'Raspa datos, arma emails personalizados y los envía automáticamente.',
                ),
                _FlowStep(
                  step: '03',
                  icon: FontAwesomeIcons.paperPlane,
                  title: 'Sender',
                  desc:
                      'Gestiona la cola de WhatsApp y mantiene las conversaciones activas.',
                ),
                _FlowStep(
                  step: '04',
                  icon: Icons.dashboard_rounded,
                  title: 'Panel',
                  desc:
                      'Dashboard en tiempo real para controlar y optimizar todo el flujo.',
                  isLast: false,
                ),
                _FlowStep(
                  step: '05',
                  icon: Icons.assignment_rounded,
                  title: 'Seeder',
                  desc:
                      'Completá formularios para publicar tu proyecto y así ganar visibilidad.',
                  isLast: true,
                ),
              ],
            ),
          ),
        ),
        const _DrawerDivider(),
        FadeInUp(
          delay: const Duration(milliseconds: 100),
          child: const _CTA(
            question: '¿Querés este nivel de captación en tu negocio?',
          ),
        ),
      ],
    );
  }
}

// ─── BOTLODE ─────────────────────────────────────────────────────────────────

class BotLodeDrawerContent extends StatelessWidget {
  const BotLodeDrawerContent({super.key});
  static const _accent = Color(0xFFFFC000);
  static const _urlBotlode = 'https://botlode.com';
  static const _urlBotrive = 'https://botrive.com';

  Future<void> _launch(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Hero(
          accent: _accent,
          isDark: isDark,
          icon: Image.asset(
            'assets/icons/logo_botlode.png',
            height: 28,
            width: 28,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) =>
                const Icon(FontAwesomeIcons.robot, size: 26, color: _accent),
          ),
          title: 'BotLode',
          tagline:
              'Crea, lanza y monetizá bots de IA sin escribir una línea de código.',
          statusLabel: 'Producto Comercial',
          statusColor: _accent,
        ),
        _ImpactRow(
          accent: _accent,
          chips: const [
            _ChipData(
              icon: FontAwesomeIcons.robot,
              label: '6 Modos',
              sub: 'de bot',
            ),
            _ChipData(
              icon: Icons.schedule_rounded,
              label: '24 / 7',
              sub: 'Operativo',
            ),
            _ChipData(
              icon: Icons.code_off_rounded,
              label: 'Sin\nCódigo',
              sub: '',
            ),
          ],
        ),
        const _DrawerDivider(),
        FadeInUp(
          delay: const Duration(milliseconds: 60),
          child: _Section(
            icon: Icons.factory_rounded,
            title: 'BotLode Factory',
            accent: _accent,
            child: const Column(
              children: [
                _Feature(
                  icon: Icons.add_circle_outline_rounded,
                  title: 'Creación instantánea',
                  desc:
                      'Desplegá un bot con personalidad propia en minutos, sin tocar código.',
                ),
                _Feature(
                  icon: Icons.storefront_rounded,
                  title: 'Listo para comercializar',
                  desc:
                      'Cada bot puede ser un producto que vendés a terceros. Ingresos desde el día uno.',
                ),
              ],
            ),
          ),
        ),
        const _DrawerDivider(),
        FadeInUp(
          delay: const Duration(milliseconds: 80),
          child: _Section(
            icon: FontAwesomeIcons.robot,
            title: 'Cat Bot Player',
            accent: _accent,
            child: const Column(
              children: [
                _Feature(
                  icon: Icons.mood_rounded,
                  title: '6 personalidades',
                  desc:
                      'Feliz, Enojado, Técnico, Confundido, Neutro y Vendedor. El bot se adapta al contexto.',
                ),
                _Feature(
                  icon: Icons.analytics_outlined,
                  title: 'Modo vendedor',
                  desc:
                      'Captura emails, teléfonos y necesidades. Todos los datos van al Command Center.',
                ),
                _Feature(
                  icon: Icons.auto_awesome_rounded,
                  title: 'Experiencia inmersiva',
                  desc:
                      'Detección de mouse, WiFi e IA conversacional. Un bot que parece vivo.',
                ),
              ],
            ),
          ),
        ),
        const _DrawerDivider(),
        FadeInUp(
          delay: const Duration(milliseconds: 100),
          child: _Section(
            icon: Icons.analytics_rounded,
            title: 'Command Center History',
            accent: _accent,
            child: const Column(
              children: [
                _Feature(
                  icon: Icons.leaderboard_rounded,
                  title: 'Dashboard de leads',
                  desc:
                      'Cada conversación, cada lead. Scoring neuronal de 0–100 por intención de compra.',
                ),
                _Feature(
                  icon: Icons.notifications_active_rounded,
                  title: 'Alertas por email',
                  desc:
                      'Cuando el lead es caliente, recibís un email con datos y preview de la conversación.',
                ),
                _Feature(
                  icon: Icons.calendar_month_rounded,
                  title: 'Calendario de reuniones',
                  desc:
                      'Agendado directo desde el historial en el calendario del bot.',
                ),
              ],
            ),
          ),
        ),
        const _DrawerDivider(),
        // External links
        FadeInUp(
          delay: const Duration(milliseconds: 120),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _LinkBtn(
                  label: 'botlode.com',
                  accent: _accent,
                  onTap: () => _launch(_urlBotlode),
                ),
                _LinkBtn(
                  label: 'botrive.com',
                  accent: _accent,
                  onTap: () => _launch(_urlBotrive),
                ),
              ],
            ),
          ),
        ),
        const _DrawerDivider(),
        FadeInUp(
          delay: const Duration(milliseconds: 140),
          child: const _CTA(
            question: '¿Querés un ecosistema de bots para tu marca?',
          ),
        ),
      ],
    );
  }
}

// ─── ASSISTIFY ───────────────────────────────────────────────────────────────

class AssistifyDrawerContent extends StatelessWidget {
  const AssistifyDrawerContent({super.key});
  static const _accent = Color(0xFF00A8E8);

  Future<void> _launchStore(String url) async {
    try {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Hero(
          accent: _accent,
          isDark: isDark,
          icon: Image.asset(
            'assets/icons/logo_assistify.png',
            height: 28,
            width: 28,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) => const Icon(
              FontAwesomeIcons.mobileScreen,
              size: 26,
              color: _accent,
            ),
          ),
          title: 'Assistify',
          tagline:
              'La agenda inteligente que libera a los profesores de la carga operativa.',
          statusLabel: 'En Producción · iOS & Android',
          statusColor: const Color(0xFF22C55E),
        ),
        _ImpactRow(
          accent: _accent,
          chips: const [
            _ChipData(
              icon: FontAwesomeIcons.googlePlay,
              label: 'Play\nStore',
              sub: 'Activo',
            ),
            _ChipData(
              icon: FontAwesomeIcons.appStoreIos,
              label: 'App\nStore',
              sub: 'Activo',
            ),
            _ChipData(
              icon: Icons.group_rounded,
              label: '100%\nAuto',
              sub: 'Gestión',
            ),
          ],
        ),
        const _DrawerDivider(),
        FadeInUp(
          delay: const Duration(milliseconds: 60),
          child: _Section(
            icon: Icons.warning_amber_rounded,
            title: 'El problema que resuelve',
            accent: _accent,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Coordinar cambios de horario por WhatsApp consume horas no remuneradas. '
                'Cuando un alumno cancela sobre la hora, ese hueco queda vacío: dinero que no vuelve.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.65,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        const _DrawerDivider(),
        FadeInUp(
          delay: const Duration(milliseconds: 80),
          child: _Section(
            icon: Icons.lightbulb_outline_rounded,
            title: 'La solución',
            accent: _accent,
            child: const Column(
              children: [
                _Feature(
                  icon: Icons.phone_iphone_rounded,
                  title: 'Autogestión total',
                  desc:
                      'El alumno cancela y busca su recuperación desde la app. Cero carga para el profesor.',
                ),
                _Feature(
                  icon: Icons.shield_rounded,
                  title: 'Ingresos blindados',
                  desc:
                      'Créditos + Listas de Espera rellenan huecos automáticamente. Agenda siempre llena.',
                ),
                _Feature(
                  icon: FontAwesomeIcons.whatsapp,
                  title: 'Cero fricción (WhatsApp)',
                  desc:
                      'Assistify avisa por WhatsApp ante cualquier cambio, sin necesidad de abrir la app.',
                ),
                _Feature(
                  icon: Icons.settings_rounded,
                  title: 'Control operativo total',
                  desc:
                      'Crea clases, ajusta cupos en tiempo real y administra el padrón de alumnos.',
                ),
              ],
            ),
          ),
        ),
        const _DrawerDivider(),
        FadeInUp(
          delay: const Duration(milliseconds: 100),
          child: _Section(
            icon: Icons.trending_up_rounded,
            title: 'Resultados',
            accent: _accent,
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Elimina el 90% de la carga administrativa y mejora la relación con los alumnos '
                'al ofrecerles flexibilidad inmediata. Disponible hoy mismo en iOS y Android.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.65,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ),
        ),
        const _DrawerDivider(),
        FadeInUp(
          delay: const Duration(milliseconds: 120),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 4),
            child: Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                _StoreBtn(
                  icon: FontAwesomeIcons.googlePlay,
                  label: 'Google Play',
                  color: const Color(0xFF01875F),
                  onTap: () => _launchStore(
                    'https://play.google.com/store/apps/details?id=com.manuelnavarro.tallerdeceramica',
                  ),
                ),
                _StoreBtn(
                  icon: FontAwesomeIcons.appStoreIos,
                  label: 'App Store',
                  color: const Color(0xFF0D96F6),
                  onTap: () => _launchStore(
                    'https://apps.apple.com/app/assistify/id6745438721',
                  ),
                ),
              ],
            ),
          ),
        ),
        const _DrawerDivider(),
        FadeInUp(
          delay: const Duration(milliseconds: 140),
          child: const _CTA(question: '¿Querés algo similar para tu negocio?'),
        ),
      ],
    );
  }
}

// ─── COMPONENTES INTERNOS ────────────────────────────────────────────────────

class _Hero extends StatelessWidget {
  const _Hero({
    required this.accent,
    required this.isDark,
    required this.icon,
    required this.title,
    required this.tagline,
    required this.statusLabel,
    required this.statusColor,
  });

  final Color accent;
  final bool isDark;
  final Widget icon;
  final String title;
  final String tagline;
  final String statusLabel;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            accent.withValues(alpha: isDark ? 0.18 : 0.11),
            accent.withValues(alpha: isDark ? 0.08 : 0.05),
            Colors.transparent,
          ],
          stops: const [0.0, 0.45, 1.0],
        ),
        border: Border(
          bottom: BorderSide(
            color: accent.withValues(alpha: isDark ? 0.14 : 0.09),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon container
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: isDark ? 0.14 : 0.10),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: accent.withValues(alpha: 0.28)),
                ),
                child: Center(child: icon),
              ),
              const Spacer(),
              // Status pill
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: isDark ? 0.16 : 0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.30),
                  ),
                ),
                child: Text(
                  statusLabel,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            title,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: cs.onSurface,
              height: 1.1,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            tagline,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Impact row ────────────────────────────────────────────────────────────────

class _ChipData {
  const _ChipData({required this.icon, required this.label, required this.sub});
  final IconData icon;
  final String label;
  final String sub;
}

class _ImpactRow extends StatelessWidget {
  const _ImpactRow({required this.accent, required this.chips});
  final Color accent;
  final List<_ChipData> chips;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
      child: Row(
        children: chips.map((c) {
          final isLast = c == chips.last;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 8,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: isDark ? 0.08 : 0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: accent.withValues(alpha: isDark ? 0.22 : 0.18),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(c.icon, size: 18, color: accent),
                        const SizedBox(height: 8),
                        Text(
                          c.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                            color: theme.colorScheme.onSurface,
                          ),
                        ),
                        if (c.sub.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            c.sub,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                if (!isLast) const SizedBox(width: 10),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ── Section ───────────────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.accent,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Color accent;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, size: 14, color: accent),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: accent,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ── Feature row ───────────────────────────────────────────────────────────────

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.title, required this.desc});

  final IconData icon;
  final String title;
  final String desc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 16, color: accent),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Flow step (timeline) ──────────────────────────────────────────────────────

class _FlowStep extends StatelessWidget {
  const _FlowStep({
    required this.step,
    required this.icon,
    required this.title,
    required this.desc,
    this.isLast = false,
  });

  final String step;
  final IconData icon;
  final String title;
  final String desc;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Step indicator + connector
        SizedBox(
          width: 32,
          child: Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                  border: Border.all(color: accent.withValues(alpha: 0.28)),
                ),
                child: Center(
                  child: Text(
                    step,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: accent,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Container(
                  width: 1,
                  height: 44,
                  color: accent.withValues(alpha: 0.18),
                ),
            ],
          ),
        ),
        const SizedBox(width: 14),
        // Content
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: isLast ? 0 : 8, top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 13, color: accent),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                ),
                SizedBox(height: isLast ? 0 : 16),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Link button ───────────────────────────────────────────────────────────────

class _LinkBtn extends StatelessWidget {
  const _LinkBtn({
    required this.label,
    required this.accent,
    required this.onTap,
  });

  final String label;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: accent.withValues(alpha: 0.35)),
          color: accent.withValues(alpha: isDark ? 0.08 : 0.06),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(FontAwesomeIcons.upRightFromSquare, size: 11, color: accent),
            const SizedBox(width: 8),
            Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: accent,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Store button ──────────────────────────────────────────────────────────────

class _StoreBtn extends StatelessWidget {
  const _StoreBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 2,
      ),
      icon: Icon(icon, size: 18, color: color),
      label: Text(
        label,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
      ),
    );
  }
}

// ── CTA ───────────────────────────────────────────────────────────────────────

class _CTA extends StatelessWidget {
  const _CTA({required this.question});
  final String question;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final width = MediaQuery.sizeOf(context).width;
    final useColumn = width < 420;

    final button = FilledButton.icon(
      onPressed: () {
        Navigator.of(context).pop();
        if (context.mounted) GoRouter.of(context).goNamed('contact');
      },
      icon: const Icon(Icons.calendar_month_rounded, size: 18),
      label: const Text('Agendar consulta gratis'),
      style: FilledButton.styleFrom(
        backgroundColor: cs.primary,
        foregroundColor: cs.onPrimary,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
      child: useColumn
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  question,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                button,
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    question,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                button,
              ],
            ),
    );
  }
}

// ── Divider ───────────────────────────────────────────────────────────────────

class _DrawerDivider extends StatelessWidget {
  const _DrawerDivider();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      child: Divider(
        height: 1,
        color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.10),
      ),
    );
  }
}
