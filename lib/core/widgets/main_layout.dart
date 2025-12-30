import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:apex/features/presence/presentation/widgets/presence_badge.dart';
import 'package:apex/core/config/theme/app_theme.dart';
import 'package:apex/core/config/theme/app_theme_providers.dart';
import 'package:apex/core/config/theme/brightness_provider.dart';
import 'package:apex/features/auth/presentation/providers/auth_providers.dart';
import 'package:apex/widgets/contactanos.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({required this.child, super.key});
  final Widget child;

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> _navItems = [
    {'label': 'Home', 'path': '/', 'name': 'home'},
    {'label': 'Servicios', 'path': '/services', 'name': 'services'},
    {'label': 'Sobre Mí', 'path': '/about', 'name': 'about'},
    {'label': 'Contacto', 'path': '/contact', 'name': 'contact'},
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMobile = MediaQuery.of(context).size.width < 900;
    final currentPath = GoRouterState.of(context).uri.path;

    int activeIndex = _navItems.indexWhere((item) {
      if (item['path'] == '/') return currentPath == '/';
      return currentPath.startsWith(item['path']);
    });
    if (activeIndex == -1) activeIndex = 0;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: isMobile ? _MobileDrawer(navItems: _navItems) : null,
      appBar: AppBar(
        title: const _BrandLogo(),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          if (!isMobile) ...[
            // NAV BAR 100% DINÁMICA
            _DynamicSlidingNavBar(
              items: _navItems,
              selectedIndex: activeIndex,
              onTap: (index) => context.goNamed(_navItems[index]['name']),
            ),
            
            const SizedBox(width: 24),
            
            const PresenceBadge(),
            const SizedBox(width: 12),
            _ThemeToggleButton(),
            const SizedBox(width: 8),
            const _AuthButton(),
            const SizedBox(width: 24),
          ] else ...[
            const PresenceBadge(),
            IconButton(
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
              icon: const Icon(Icons.menu_rounded, size: 28),
              color: theme.colorScheme.primary,
              tooltip: 'Menú',
            ),
            const SizedBox(width: 16),
          ],
        ],
      ),
      floatingActionButton: const Contactanos(),
      body: widget.child,
    );
  }
}

// --- WIDGET PRO: Sliding Nav Bar con Medición Real ---
class _DynamicSlidingNavBar extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final int selectedIndex;
  final Function(int) onTap;

  const _DynamicSlidingNavBar({
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  State<_DynamicSlidingNavBar> createState() => _DynamicSlidingNavBarState();
}

class _DynamicSlidingNavBarState extends State<_DynamicSlidingNavBar> {
  // Lista de Keys para medir cada texto individualmente
  late List<GlobalKey> _keys;
  
  // Estado de la barra deslizante
  double _indicatorLeft = 0;
  double _indicatorWidth = 0;

  @override
  void initState() {
    super.initState();
    _keys = List.generate(widget.items.length, (_) => GlobalKey());
    
    // Esperamos al primer frame para medir
    SchedulerBinding.instance.addPostFrameCallback((_) => _updateIndicator());
  }

  @override
  void didUpdateWidget(covariant _DynamicSlidingNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si cambia la selección, recalculamos posición
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _updateIndicator();
    }
  }

  void _updateIndicator() {
    if (!mounted) return;
    
    // Obtenemos el contexto del item seleccionado actual
    final key = _keys[widget.selectedIndex];
    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
      // Buscamos la posición relativa al padre (el Stack de la NavBar)
      // Esto requiere encontrar el RenderBox del widget padre.
      // Simplificación: Asumimos que los items están en una Row al inicio (0,0) del Stack.
      // Calculamos el offset X sumando anchos previos + paddings es complejo.
      // MEJOR ESTRATEGIA: Usar `localToGlobal` y convertir.
      
      // Pero como estamos dentro de un Stack > Row, la posición X relativa al Stack
      // es exactamente lo que necesitamos.
      
      // Truco: Medimos la posición global del Item y la del Stack padre, y restamos.
      final parentRenderBox = context.findRenderObject() as RenderBox?;
      if (parentRenderBox != null) {
        final itemOffset = renderBox.localToGlobal(Offset.zero);
        final parentOffset = parentRenderBox.localToGlobal(Offset.zero);
        
        final relativeX = itemOffset.dx - parentOffset.dx;
        
        setState(() {
          _indicatorLeft = relativeX;
          _indicatorWidth = renderBox.size.width;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;

    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // 1. LOS BOTONES (Con Keys para medir)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == widget.selectedIndex;

              return Padding(
                // Espaciado dinámico real entre items
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: InkWell(
                  onTap: () => widget.onTap(index),
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Center(
                    child: Container(
                      // Ponemos la Key aquí para medir ESTE contenedor exacto (el texto)
                      key: _keys[index],
                      padding: const EdgeInsets.symmetric(vertical: 8), // Area de click vertical
                      child: _HoverText(
                        text: item['label'],
                        isSelected: isSelected,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),

          // 2. LA BARRA DESLIZANTE (Se mueve a donde le digamos)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.fastOutSlowIn,
            left: _indicatorLeft,
            width: _indicatorWidth, // Ancho dinámico igual al texto
            bottom: 10, // Altura ajustada
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: BorderRadius.circular(2),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverText extends StatefulWidget {
  final String text;
  final bool isSelected;
  const _HoverText({required this.text, required this.isSelected});

  @override
  State<_HoverText> createState() => _HoverTextState();
}

class _HoverTextState extends State<_HoverText> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = (widget.isSelected || _isHovering) 
        ? theme.colorScheme.primary 
        : theme.colorScheme.onSurface;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 200),
        style: theme.textTheme.titleSmall!.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: color,
        ),
        child: Text(widget.text),
      ),
    );
  }
}

class _BrandLogo extends ConsumerWidget {
  const _BrandLogo();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeConfig = ref.watch(currentAppThemeConfigProvider);
    final bool isNeutral = themeConfig.theme == AppTheme.neutral;

    final Widget apexIcon = Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..scale(0.7, 1.1),
      child: Icon(FontAwesomeIcons.chevronUp, color: theme.colorScheme.primary, size: 22),
    );

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.goNamed('home'),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (isNeutral)
              apexIcon
            else if (themeConfig.logoAsset != null)
              Image.asset(
                themeConfig.logoAsset!,
                height: 28,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => apexIcon,
              )
            else
              Icon(themeConfig.logoIcon ?? FontAwesomeIcons.chevronUp, color: theme.colorScheme.primary, size: 22),

            const SizedBox(width: 12),
            
            Flexible(
              child: Text(
                'Manuel Navarro',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  height: 1.0,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MobileDrawer extends ConsumerWidget {
  final List<Map<String, dynamic>> navItems;
  const _MobileDrawer({required this.navItems});
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final themeConfig = ref.watch(currentAppThemeConfigProvider);
    final isNeutral = themeConfig.theme == AppTheme.neutral;

    final Widget apexIcon = Transform(
      alignment: Alignment.center,
      transform: Matrix4.identity()..scale(0.7, 1.1),
      child: Icon(FontAwesomeIcons.chevronUp, color: colorScheme.primary, size: 26),
    );

    final Widget logoWidget;
    if (isNeutral) {
      logoWidget = apexIcon;
    } else if (themeConfig.logoAsset != null) {
      logoWidget = Image.asset(
        themeConfig.logoAsset!,
        height: 32, 
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => apexIcon,
      );
    } else {
      logoWidget = Icon(
        themeConfig.logoIcon ?? FontAwesomeIcons.chevronUp, 
        color: colorScheme.primary, 
        size: 26
      );
    }

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85, 
      backgroundColor: colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(topLeft: Radius.circular(20), bottomLeft: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
              border: Border(bottom: BorderSide(color: colorScheme.outline.withOpacity(0.1))),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                 Row(
                   mainAxisSize: MainAxisSize.min,
                   children: [
                     logoWidget,
                     const SizedBox(width: 12),
                     Text(
                       'APEX',
                       style: theme.textTheme.headlineSmall?.copyWith(
                         fontWeight: FontWeight.w900,
                         letterSpacing: 3.0,
                         color: colorScheme.primary,
                         height: 1.0,
                       ),
                     ),
                   ],
                 ),
                 IconButton(
                   icon: const Icon(Icons.close), 
                   color: colorScheme.primary, 
                   onPressed: () => Navigator.pop(context)
                 ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              children: navItems.map((item) {
                final bool isActive = GoRouterState.of(context).uri.path == item['path'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: isActive ? colorScheme.primary.withOpacity(0.1) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(item['label'], style: TextStyle(fontWeight: isActive ? FontWeight.bold : FontWeight.w500, color: isActive ? colorScheme.primary : colorScheme.onSurface)),
                    leading: Icon(_getIconForLabel(item['label']), color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant),
                    onTap: () { Navigator.pop(context); context.goNamed(item['name']); },
                  ),
                );
              }).toList(),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surface,
              border: Border(top: BorderSide(color: colorScheme.outline.withOpacity(0.1))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0, left: 4),
                  child: Text(
                    "PREFERENCIAS",
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => ref.read(brightnessModeProvider.notifier).toggleMode(),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          side: BorderSide(color: colorScheme.outline.withOpacity(0.3)),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: Icon(
                          theme.brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode,
                          size: 18,
                        ),
                        label: Text(
                          theme.brightness == Brightness.dark ? "Claro" : "Oscuro",
                          style: const TextStyle(fontSize: 14),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: () => ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.neutral),
                      tooltip: "Restaurar Tema",
                      style: IconButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.all(12),
                      ),
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: const _AuthButton(fullWidth: true),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    if (label == 'Home') return Icons.home_rounded;
    if (label == 'Servicios') return FontAwesomeIcons.layerGroup;
    if (label == 'Sobre Mí') return Icons.person_rounded;
    return Icons.mail_rounded;
  }
}

class _ThemeToggleButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          onPressed: () => ref.read(brightnessModeProvider.notifier).toggleMode(),
          icon: Icon(theme.brightness == Brightness.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
          color: theme.colorScheme.primary,
        ),
        IconButton(
          onPressed: () => ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.neutral),
          icon: const Icon(Icons.refresh_rounded, size: 20),
          color: theme.colorScheme.primary,
        ),
      ],
    );
  }
}

class _AuthButton extends ConsumerWidget {
  final bool fullWidth;
  const _AuthButton({this.fullWidth = false});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateStreamProvider);
    return authState.when(
      loading: () => const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
      error: (_, __) => const Icon(Icons.error),
      data: (user) {
        if (user == null) {
          return FilledButton.icon(
            onPressed: () => ref.read(authRepositoryProvider).signInWithGoogle(),
            icon: const Icon(FontAwesomeIcons.google, size: 14),
            label: const Text('Login'),
          );
        }
        if (fullWidth) {
          return OutlinedButton.icon(
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
            icon: const Icon(Icons.logout),
            label: const Text("Cerrar Sesión"),
            style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
          );
        }
        return PopupMenuButton<String>(
          onSelected: (v) => ref.read(authRepositoryProvider).signOut(),
          itemBuilder: (context) => [const PopupMenuItem(value: 'logout', child: Text('Cerrar Sesión'))],
          child: CircleAvatar(
            radius: 18,
            backgroundImage: user.userMetadata?['avatar_url'] != null ? NetworkImage(user.userMetadata!['avatar_url']) : null,
            child: user.userMetadata?['avatar_url'] == null ? Text(user.email?[0].toUpperCase() ?? 'U') : null,
          ),
        );
      },
    );
  }
}