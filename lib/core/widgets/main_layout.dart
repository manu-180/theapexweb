// Archivo: lib/core/widgets/main_layout.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart'; 
import 'package:apex/features/presence/presentation/widgets/presence_badge.dart';
import 'package:apex/core/config/theme/app_theme.dart';
import 'package:apex/core/config/theme/app_theme_providers.dart';
import 'package:apex/core/config/theme/brightness_provider.dart';
import 'package:apex/features/auth/presentation/providers/auth_providers.dart';
import 'package:apex/core/config/app_constants.dart';
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

  Future<void> _triggerWhatsApp() async {
    const phoneNumber = AppConstants.whatsappNumber;
    const message = 'Hola, vengo desde los atajos de teclado 🚀';
    final uri = Uri.parse('https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}');
    
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw 'No se pudo abrir';
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text('No se pudo abrir WhatsApp (Error de navegador)')),
        );
      }
    }
  }

  void _showShortcutsDialog() {
    showDialog(
      context: context,
      builder: (context) => _ShortcutsHelpDialog(
        // Pasamos la lógica de WhatsApp para reutilizarla dentro del diálogo
        onWhatsApp: _triggerWhatsApp,
      ),
    );
  }

  // --- ARQUITECTURA: CENTRALIZAMOS LOS ATAJOS ---
  // Esto permite que MainLayout y el Dialog compartan la misma lógica.
  Map<ShortcutActivator, VoidCallback> _getGlobalShortcuts(BuildContext context, WidgetRef ref) {
    return {
      // NAVEGACIÓN
      const SingleActivator(LogicalKeyboardKey.keyH): () => context.goNamed('home'),
      const SingleActivator(LogicalKeyboardKey.keyA): () => context.goNamed('about'),
      const SingleActivator(LogicalKeyboardKey.keyC): () => context.goNamed('contact'),
      const SingleActivator(LogicalKeyboardKey.keyS): () => context.goNamed('services', extra: 0),
      const SingleActivator(LogicalKeyboardKey.keyM): () => context.goNamed('services', extra: 1),

      // TEMAS
      const SingleActivator(LogicalKeyboardKey.digit1): () => ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.neutral),
      const SingleActivator(LogicalKeyboardKey.digit2): () => ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.flutter),
      const SingleActivator(LogicalKeyboardKey.digit3): () => ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.supabase),
      const SingleActivator(LogicalKeyboardKey.digit4): () => ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.riverpod),
      const SingleActivator(LogicalKeyboardKey.digit5): () => ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.assistify),
      
      const SingleActivator(LogicalKeyboardKey.keyR): () => ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.neutral),
      const SingleActivator(LogicalKeyboardKey.keyT): () => ref.read(brightnessModeProvider.notifier).toggleMode(),

      // ACCIONES
      const SingleActivator(LogicalKeyboardKey.keyW): _triggerWhatsApp,
      const SingleActivator(LogicalKeyboardKey.keyL): () => ref.read(authRepositoryProvider).signInWithGoogle(),
      
      // DIÁLOGO
      const SingleActivator(LogicalKeyboardKey.keyK): _showShortcutsDialog, 
      const SingleActivator(LogicalKeyboardKey.question): _showShortcutsDialog, 
    };
  }

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

    return CallbackShortcuts(
      bindings: _getGlobalShortcuts(context, ref),
      child: Focus(
        autofocus: true, 
        child: Scaffold(
          key: _scaffoldKey,
          endDrawer: isMobile ? _MobileDrawer(navItems: _navItems, onHelpTap: _showShortcutsDialog) : null,
          appBar: AppBar(
            title: const _BrandLogo(),
            centerTitle: false,
            automaticallyImplyLeading: false,
            actions: [
              if (!isMobile) ...[
                _DynamicSlidingNavBar(
                  items: _navItems,
                  selectedIndex: activeIndex,
                  onTap: (index) => context.goNamed(_navItems[index]['name']),
                ),
                
                const SizedBox(width: 24),
                const PresenceBadge(),
                const SizedBox(width: 16),
                
                _ToolsBar(onHelpTap: _showShortcutsDialog),

                const SizedBox(width: 16),
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
        ),
      ),
    );
  }
}

class _ToolsBar extends ConsumerWidget {
  final VoidCallback onHelpTap;
  const _ToolsBar({required this.onHelpTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final color = theme.colorScheme.primary; 

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: () => ref.read(brightnessModeProvider.notifier).toggleMode(),
            icon: Icon(theme.brightness == Brightness.dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded),
            color: color,
            tooltip: "Cambiar Modo (T)",
            iconSize: 20,
          ),
          
          Container(width: 1, height: 20, color: theme.colorScheme.outline.withOpacity(0.2)),

          IconButton(
            onPressed: () => ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.neutral),
            icon: const Icon(Icons.refresh_rounded),
            color: color,
            tooltip: "Resetear Tema (R)",
            iconSize: 20,
          ),

          Container(width: 1, height: 20, color: theme.colorScheme.outline.withOpacity(0.2)),

          IconButton(
            onPressed: onHelpTap,
            icon: const Icon(Icons.keyboard_command_key_rounded),
            color: color, 
            tooltip: "Ver Atajos (K)",
            iconSize: 20,
          ),
        ],
      ),
    );
  }
}

// --- DIÁLOGO INTELIGENTE ---
// Ahora hereda ConsumerWidget para poder ejecutar acciones de Riverpod (Temas, etc)
class _ShortcutsHelpDialog extends ConsumerWidget {
  final VoidCallback onWhatsApp;
  
  const _ShortcutsHelpDialog({required this.onWhatsApp});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Helper para navegar y cerrar el diálogo al mismo tiempo
    void navAndClose(String routeName, {Object? extra}) {
      Navigator.pop(context); // Cerramos diálogo
      context.goNamed(routeName, extra: extra); // Navegamos
    }

    return CallbackShortcuts(
      bindings: {
        // --- 1. COMANDOS DE CONTROL DE DIÁLOGO ---
        const SingleActivator(LogicalKeyboardKey.keyK): () => Navigator.pop(context),
        const SingleActivator(LogicalKeyboardKey.escape): () => Navigator.pop(context),

        // --- 2. TEMAS Y ACCIONES (Se mantienen abiertos para probar) ---
        const SingleActivator(LogicalKeyboardKey.digit1): () => ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.neutral),
        const SingleActivator(LogicalKeyboardKey.digit2): () => ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.flutter),
        const SingleActivator(LogicalKeyboardKey.digit3): () => ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.supabase),
        const SingleActivator(LogicalKeyboardKey.digit4): () => ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.riverpod),
        const SingleActivator(LogicalKeyboardKey.digit5): () => ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.assistify),
        const SingleActivator(LogicalKeyboardKey.keyR): () => ref.read(dynamicThemeProvider.notifier).setTheme(AppTheme.neutral),
        const SingleActivator(LogicalKeyboardKey.keyT): () => ref.read(brightnessModeProvider.notifier).toggleMode(),
        const SingleActivator(LogicalKeyboardKey.keyL): () => ref.read(authRepositoryProvider).signInWithGoogle(),
        const SingleActivator(LogicalKeyboardKey.keyW): onWhatsApp,

        // --- 3. NAVEGACIÓN (Cierran el diálogo) ---
        const SingleActivator(LogicalKeyboardKey.keyH): () => navAndClose('home'),
        const SingleActivator(LogicalKeyboardKey.keyA): () => navAndClose('about'),
        const SingleActivator(LogicalKeyboardKey.keyC): () => navAndClose('contact'),
        const SingleActivator(LogicalKeyboardKey.keyS): () => navAndClose('services', extra: 0),
        const SingleActivator(LogicalKeyboardKey.keyM): () => navAndClose('services', extra: 1),
      },
      child: Focus(
        autofocus: true, 
        child: Dialog(
          backgroundColor: colorScheme.surface,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.keyboard, color: colorScheme.primary),
                      const SizedBox(width: 12),
                      Text("Atajos de Teclado", style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text("ESC / K", style: TextStyle(fontSize: 10, color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close)),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Wrap(
                    spacing: 40,
                    runSpacing: 24,
                    children: [
                      _ShortcutSection(
                        title: "Navegación",
                        items: const [
                          {'key': 'H', 'desc': 'Ir al Home'},
                          {'key': 'S', 'desc': 'Servicios (Web)'},
                          {'key': 'M', 'desc': 'Servicios (Apps)'},
                          {'key': 'A', 'desc': 'Sobre Mí'},
                          {'key': 'C', 'desc': 'Contacto'},
                        ],
                      ),
                      _ShortcutSection(
                        title: "Acciones",
                        items: const [
                          {'key': 'T', 'desc': 'Modo Claro/Oscuro'},
                          {'key': '1-5', 'desc': 'Cambiar Tema'},
                          {'key': 'R', 'desc': 'Resetear Tema'},
                          {'key': 'L', 'desc': 'Login Google'},
                          {'key': 'W', 'desc': 'Abrir WhatsApp'},
                          {'key': 'K', 'desc': 'Cerrar este menú'},
                        ],
                      ),
                    ],
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

class _MobileDrawer extends ConsumerWidget {
  final List<Map<String, dynamic>> navItems;
  final VoidCallback onHelpTap; 

  const _MobileDrawer({
    required this.navItems, 
    required this.onHelpTap 
  });
  
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
                _ToolsBar(onHelpTap: onHelpTap),
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

class _ShortcutSection extends StatelessWidget {
  final String title;
  final List<Map<String, String>> items;

  const _ShortcutSection({required this.title, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        const SizedBox(height: 12),
        ...items.map((item) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                ),
                child: Text(item['key']!, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 12),
              Text(item['desc']!),
            ],
          ),
        )),
      ],
    );
  }
}

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
  late List<GlobalKey> _keys;
  double _indicatorLeft = 0;
  double _indicatorWidth = 0;

  @override
  void initState() {
    super.initState();
    _keys = List.generate(widget.items.length, (_) => GlobalKey());
    SchedulerBinding.instance.addPostFrameCallback((_) => _updateIndicator());
  }

  @override
  void didUpdateWidget(covariant _DynamicSlidingNavBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _updateIndicator();
    }
  }

  void _updateIndicator() {
    if (!mounted) return;
    final key = _keys[widget.selectedIndex];
    final RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox != null) {
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: widget.items.asMap().entries.map((entry) {
              final index = entry.key;
              final item = entry.value;
              final isSelected = index == widget.selectedIndex;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: InkWell(
                  onTap: () => widget.onTap(index),
                  hoverColor: Colors.transparent,
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  child: Center(
                    child: Container(
                      key: _keys[index],
                      padding: const EdgeInsets.symmetric(vertical: 8),
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
          AnimatedPositioned(
            duration: const Duration(milliseconds: 350),
            curve: Curves.fastOutSlowIn,
            left: _indicatorLeft,
            width: _indicatorWidth,
            bottom: 10,
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