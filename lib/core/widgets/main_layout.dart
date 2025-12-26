// Archivo: lib/core/widgets/main_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:prueba_de_riverpod/core/config/theme/app_theme.dart'; 
import 'package:prueba_de_riverpod/core/config/theme/app_theme_providers.dart';
import 'package:prueba_de_riverpod/core/config/theme/brightness_provider.dart';
import 'package:prueba_de_riverpod/features/auth/presentation/providers/auth_providers.dart';
import 'package:prueba_de_riverpod/widgets/contactanos.dart';

class MainLayout extends ConsumerStatefulWidget {
  const MainLayout({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  ConsumerState<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends ConsumerState<MainLayout> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final List<Map<String, dynamic>> _navItems = [
    {'label': 'Home', 'path': '/', 'name': 'home'},
    {'label': 'Servicios', 'path': '/services', 'name': 'services'},
    {'label': 'Sobre Mí', 'path': '/about', 'name': 'about'},
    {'label': 'Contacto', 'path': '/contact', 'name': 'contact'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _navItems.length, 
      vsync: this,
      // Reducimos la duración base para que los clics manuales sean instantáneos
      animationDuration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _syncTabWithRoute() {
    if (!mounted) return;
    final String location = GoRouterState.of(context).uri.path;
    int index = _navItems.indexWhere((item) => item['path'] == location);
    
    if (index == -1) {
        if (location.startsWith('/services')) index = 1;
        else index = 0;
    }

    if (_tabController.index != index) {
      // VELOCIDAD OPTIMIZADA: 200ms con curva easeOutExpo para máxima fluidez
      _tabController.animateTo(
        index,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutExpo,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncTabWithRoute());

    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Breakpoint a 1050px para evitar colisiones entre el logo y el menú
    final isMobile = screenWidth < 800; 

    final String location = GoRouterState.of(context).uri.path;
    int currentIndex = _navItems.indexWhere((item) => item['path'] == location);
    if (currentIndex == -1 && location.startsWith('/services')) currentIndex = 1;
    if (currentIndex == -1) currentIndex = 0;

    return Scaffold(
      key: _scaffoldKey,
      endDrawer: isMobile ? _MobileDrawer(navItems: _navItems) : null,
      body: Column(
        children: [
          Container(
            height: 4,
            width: double.infinity,
            color: theme.colorScheme.primary, 
          ),
          Expanded(
            child: Scaffold(
              appBar: AppBar(
                titleSpacing: 10,
                title: GestureDetector(
                  onTap: () => context.goNamed('home'),
                  child: const _BrandLogo(),
                ),
                centerTitle: false,
                automaticallyImplyLeading: false, 
                actions: [
                  if (!isMobile) ...[
                    IntrinsicWidth(
                      child: TabBar(
                        controller: _tabController,
                        isScrollable: true,
                        indicatorColor: theme.colorScheme.primary,
                        indicatorWeight: 3,
                        indicatorSize: TabBarIndicatorSize.label,
                        indicatorPadding: const EdgeInsets.only(bottom: 12), 
                        dividerColor: Colors.transparent,
                        overlayColor: WidgetStateProperty.all(Colors.transparent),
                        labelColor: Colors.transparent, 
                        unselectedLabelColor: Colors.transparent, 
                        padding: EdgeInsets.zero,
                        labelPadding: const EdgeInsets.symmetric(horizontal: 12), 
                        onTap: (index) => context.goNamed(_navItems[index]['name']),
                        tabs: _navItems.asMap().entries.map((entry) {
                          return Tab(
                            height: 60, 
                            child: _HoverableTab(
                              text: entry.value['label'],
                              isSelected: entry.key == currentIndex,
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(width: 5),
                    _ThemeToggleButton(),
                    const SizedBox(width: 5),
                    _AuthButton(),
                    const SizedBox(width: 15),
                  ] else ...[
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
            ),
          ),
        ],
      ),
    );
  }
}

class _HoverableTab extends StatefulWidget {
  final String text;
  final bool isSelected;
  const _HoverableTab({required this.text, required this.isSelected});

  @override
  State<_HoverableTab> createState() => _HoverableTabState();
}

class _HoverableTabState extends State<_HoverableTab> {
  bool _isHovering = false;
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final Color textColor = (widget.isSelected || _isHovering)
        ? theme.colorScheme.primary
        : theme.colorScheme.onSurface;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: AnimatedDefaultTextStyle(
        duration: const Duration(milliseconds: 150),
        style: theme.textTheme.titleSmall!.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: textColor,
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
    final screenWidth = MediaQuery.of(context).size.width;

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (isNeutral) 
          Transform(
            alignment: Alignment.center,
            transform: Matrix4.identity()..scale(0.7, 1.1), 
            child: Icon(FontAwesomeIcons.chevronUp, color: theme.colorScheme.primary, size: 22),
          )
        else if (themeConfig.logoAsset != null)
          Image.asset(themeConfig.logoAsset!, height: 28, fit: BoxFit.contain)
        else if (themeConfig.logoIcon != null)
          Icon(themeConfig.logoIcon!, color: theme.colorScheme.primary, size: 24),

        const SizedBox(width: 12),
        
        Flexible(
          child: Text(
           'Manuel Navarro',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
              height: 1.0, 
            ),
            overflow: TextOverflow.clip,
            softWrap: false,
          ),
        ),
      ],
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
                 const _BrandLogo(),
                 IconButton(icon: const Icon(Icons.close), color: colorScheme.primary, onPressed: () => Navigator.pop(context)),
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
            decoration: BoxDecoration(border: Border(top: BorderSide(color: colorScheme.outline.withOpacity(0.1)))),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => ref.read(brightnessModeProvider.notifier).toggleMode(),
                        icon: Icon(theme.brightness == Brightness.dark ? Icons.light_mode : Icons.dark_mode),
                        label: Text(theme.brightness == Brightness.dark ? "Modo Claro" : "Modo Oscuro"),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filledTonal(
                      onPressed: () => ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.neutral),
                      icon: const Icon(Icons.refresh),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _AuthButton(fullWidth: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
  IconData _getIconForLabel(String label) {
    if (label == 'Home') return Icons.home_rounded;
    if (label == 'Servicios') return Icons.work_rounded;
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
    final theme = Theme.of(context);
    return authState.when(
      loading: () => const CircularProgressIndicator(),
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