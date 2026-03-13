// Archivo: lib/features/about_me/presentation/views/about_me_view.dart
import 'package:animate_do/animate_do.dart';
import 'package:apex/core/widgets/inspector_gadget.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:apex/core/config/theme/app_theme.dart';
import 'package:apex/core/config/theme/app_theme_providers.dart';
import 'package:apex/core/config/theme/brightness_provider.dart';
import 'package:apex/core/widgets/cursor_glow_frame.dart';
import 'package:apex/features/shared/widgets/footer.dart';
import 'package:video_player/video_player.dart';

class AboutMeView extends ConsumerStatefulWidget {
  const AboutMeView({super.key});

  @override
  ConsumerState<AboutMeView> createState() => _AboutMeViewState();
}

class _AboutMeViewState extends ConsumerState<AboutMeView> {
  final ValueNotifier<Offset> _mousePos = ValueNotifier(Offset.zero);

  @override
  void initState() {
    super.initState();
    // ESTRATEGIA DE PRE-CACHING:
    // Apenas carga la vista, le decimos a Flutter que vaya leyendo TODAS las imágenes
    // en segundo plano. Cuando el usuario cambie de tema, la imagen ya estará en RAM.
    WidgetsBinding.instance.addPostFrameCallback((_) => _precacheAllAssets());
  }

  bool _precacheDone = false;

  /// Solo precacheamos el fallback si existe; los placeholders por tema pueden no estar.
  Future<void> _precacheAllAssets() async {
    if (_precacheDone || !mounted) return;
    _precacheDone = true;

    const fallback = 'assets/images/placeholder_fallback.png';
    try {
      await precacheImage(AssetImage(fallback), context);
    } catch (_) {
      // Sin placeholder_fallback.png no hay precache; Image.asset usará errorBuilder.
    }
  }

  @override
  void dispose() {
    _mousePos.dispose();
    super.dispose();
  }

  bool get _isAppleEcosystem {
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  Widget build(BuildContext context) {
    // Escucha activa de cambios de tema
    final themeMode = ref.watch(brightnessModeProvider);
    final themeConfig = ref.watch(currentAppThemeConfigProvider);

    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;

    final bool useStaticFallback = _isAppleEcosystem;

    return MouseRegion(
      onHover: (event) => _mousePos.value = event.position,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isMobile ? 24 : 60,
                vertical: 40,
              ),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    children: [
                      FadeInDown(
                        // Key única combinada para animar cambios drásticos si es necesario
                        key: ValueKey(
                          'hero-${themeConfig.theme.name}-$themeMode',
                        ),
                        child: useStaticFallback
                            ? _StaticHeroImage(themeConfig: themeConfig)
                            : _DynamicHeroImage(themeConfig: themeConfig),
                      ),

                      FadeInUp(
                        child: InspectorGadget(
                          // <--- AQUI ENVOLVEMOS LA CARD
                          name: "Diseño de Cristal (Glassmorphism)",
                          techSpecs:
                              "Capas visuales. Combino opacidad, blur y gradientes para crear profundidad, asegurando que el texto sea legible sobre cualquier fondo dinámico.",
                          icon: FontAwesomeIcons.bookOpen,
                          child: _AboutMeCard(mousePos: _mousePos),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
              child: FadeInUp(
                duration: const Duration(milliseconds: 480),
                child: _AboutCtaCard(mousePos: _mousePos),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }
}

/// En Mac/iOS no se muestran los videos (WebM); se usa fallback estático.
/// No mostramos icono circular para mantener la vista limpia — solo espacio.
class _StaticHeroImage extends StatelessWidget {
  final AppThemeConfig themeConfig;
  const _StaticHeroImage({required this.themeConfig});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(height: 80);
  }
}

/// Ruta única de placeholder cuando no existen las imágenes por tema.
const _kPlaceholderFallback = 'assets/images/placeholder_fallback.png';

class _DynamicHeroImage extends StatelessWidget {
  final AppThemeConfig themeConfig;
  const _DynamicHeroImage({required this.themeConfig});

  @override
  Widget build(BuildContext context) {
    // Placeholder único; si no existe placeholder_fallback.png, Image usa errorBuilder (icono).
    final (String videoPath, String imagePath) = switch (themeConfig.theme) {
      AppTheme.flutter => (
        'assets/videos/yoflutter.webm',
        _kPlaceholderFallback,
      ),
      AppTheme.supabase => (
        'assets/videos/yosupabase.webm',
        _kPlaceholderFallback,
      ),
      AppTheme.riverpod => (
        'assets/videos/yoriverpod.webm',
        _kPlaceholderFallback,
      ),
      AppTheme.botlode => ('assets/videos/yoapex.webm', _kPlaceholderFallback),
      AppTheme.assistify => (
        'assets/videos/yoassistify.webm',
        _kPlaceholderFallback,
      ),
      AppTheme.contactEngine => (
        'assets/videos/yoapex.webm',
        _kPlaceholderFallback,
      ),
      AppTheme.neutral => ('assets/videos/yoapex.webm', _kPlaceholderFallback),
    };

    return SizedBox(
      height: 250,
      width: double.infinity,
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, 45),
          child: Transform.scale(
            scale: 1.8,
            child: InspectorGadget(
              name: "Video Alpha Channel",
              techSpecs:
                  "Optimización gráfica. Uso formato WebM con canal alfa (transparencia) y lo precargo en RAM. El resultado: un video que parece flotar sobre la web sin bordes rectangulares.",
              icon: FontAwesomeIcons.video,
              child: _TransparentVideoPlayer(
                key: ValueKey(videoPath),
                assetPath: videoPath,
                placeholderPath: imagePath,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AboutMeCard extends StatelessWidget {
  final ValueNotifier<Offset> mousePos;
  const _AboutMeCard({required this.mousePos});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final brandColor = theme.colorScheme.primary;
    final isMobile = MediaQuery.of(context).size.width < 800;

    return CursorGlowFrame(
      mousePos: mousePos,
      borderRadius: 24,
      glowThickness: 2.5,
      intensity: 1.25,
      enableHoverLift: true,
      hoverScale: 1.01,
      lightModeShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 14,
          offset: const Offset(0, 8),
          spreadRadius: -6,
        ),
      ],
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 24 : 45),
        child: Column(
          crossAxisAlignment: isMobile
              ? CrossAxisAlignment.start
              : CrossAxisAlignment.center,
          children: [
            Text(
              'Manuel Navarro',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: brandColor,
                fontSize: isMobile ? 32 : null,
              ),
              textAlign: isMobile ? TextAlign.left : TextAlign.center,
            ),
            const SizedBox(height: 12),

            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  FontAwesomeIcons.boltLightning,
                  size: 16,
                  color: brandColor,
                ),
                const SizedBox(width: 10),
                Text(
                  '3 años de experiencia',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 40),

            Text(
              "Programar es mucho más que tirar líneas de código, para mí es una disciplina de constancia diaria. Llevo tres años dedicándole cada día a entender cómo construir soluciones que realmente funcionen. Estoy convencido de que hoy no existen límites técnicos: cualquier idea se puede materializar si se tiene el compromiso de entender el problema y la destreza para construir la solución que el usuario realmente necesita.",
              textAlign: isMobile ? TextAlign.left : TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                height: 1.7,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: brandColor.withOpacity(0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: brandColor.withOpacity(0.2)),
              ),
              child: Text(
                "Considero que la verdadera brecha entre un programador junior y un arquitecto de software de alto nivel radica en la capacidad de resolución de problemas bajo cualquier circunstancia. Mi filosofía es clara: no existe desafío técnico que no tenga solución. He perfeccionado mi capacidad para desglosar problemas complejos mediante el uso estratégico de herramientas de vanguardia, transformando obstáculos críticos en procesos lógicos y ejecutables.",
                textAlign: isMobile ? TextAlign.left : TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  height: 1.7,
                  fontSize: 16,
                ),
              ),
            ),

            const SizedBox(height: 40),

            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: isMobile ? WrapAlignment.start : WrapAlignment.center,
              children: [
                _buildSkillTag(
                  theme,
                  FontAwesomeIcons.puzzlePiece,
                  'Resolución de Problemas',
                ),
                _buildSkillTag(
                  theme,
                  FontAwesomeIcons.layerGroup,
                  'Arquitectura Limpia',
                ),
                _buildSkillTag(
                  theme,
                  FontAwesomeIcons.calendarCheck,
                  'Constancia Diaria',
                ),
                _buildSkillTag(
                  theme,
                  FontAwesomeIcons.brain,
                  'Pensamiento Lógico',
                ),
                _buildSkillTag(
                  theme,
                  FontAwesomeIcons.bullseye,
                  'Enfoque en Resultados',
                ),
                _buildSkillTag(
                  theme,
                  FontAwesomeIcons.sliders,
                  'Adaptabilidad',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillTag(ThemeData theme, IconData icon, String label) {
    final brandColor = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: brandColor.withOpacity(0.1),
        border: Border.all(color: brandColor.withOpacity(0.3)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: brandColor),
          const SizedBox(width: 10),
          Text(
            label,
            style: TextStyle(
              color: brandColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _AboutCtaCard extends StatefulWidget {
  const _AboutCtaCard({required this.mousePos});
  final ValueNotifier<Offset> mousePos;

  @override
  State<_AboutCtaCard> createState() => _AboutCtaCardState();
}

class _AboutCtaCardState extends State<_AboutCtaCard> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isMobile = MediaQuery.of(context).size.width < 700;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: CursorGlowFrame(
          mousePos: widget.mousePos,
          borderRadius: 24,
          glowThickness: 2.5,
          intensity: 1.25,
          enableHoverLift: true,
          hoverScale: 1.01,
          lightModeShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 8),
              spreadRadius: -6,
            ),
          ],
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: isMobile ? 22 : 30,
              vertical: isMobile ? 20 : 26,
            ),
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: cs.outline.withValues(alpha: 0.14)),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.surface,
                  Color.alphaBlend(
                    cs.primary.withValues(alpha: 0.045),
                    cs.surface,
                  ),
                ],
              ),
            ),
            child: Column(
              children: [
                Text(
                  "¿Listo para llevar tu proyecto al siguiente nivel?",
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  "Agenda una reunión gratuita y validamos tu idea con foco en resultados.",
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.35,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: FilledButton(
                    onPressed: () => GoRouter.of(context).goNamed('contact'),
                    style: FilledButton.styleFrom(
                      elevation: 0,
                      minimumSize: Size(isMobile ? 230 : 290, 48),
                      backgroundColor: cs.primary,
                      foregroundColor: cs.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                        side: BorderSide(
                          color: cs.primary.withValues(alpha: 0.65),
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.calendar_month_rounded,
                          size: 18,
                          color: cs.onPrimary,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "Agendar consulta gratis",
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: cs.onPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(Icons.east_rounded, size: 18, color: cs.onPrimary),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TransparentVideoPlayer extends StatefulWidget {
  final String assetPath;
  final String placeholderPath;

  const _TransparentVideoPlayer({
    super.key,
    required this.assetPath,
    required this.placeholderPath,
  });

  @override
  State<_TransparentVideoPlayer> createState() =>
      _TransparentVideoPlayerState();
}

class _TransparentVideoPlayerState extends State<_TransparentVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _showPlaceholder = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  Future<void> _initializePlayer() async {
    _controller = VideoPlayerController.asset(widget.assetPath);
    try {
      await _controller!.initialize().timeout(const Duration(seconds: 5));

      if (mounted) {
        _controller!.setLooping(true);
        _controller!.setVolume(0.0);
        await _controller!.play();

        setState(() {
          _isInitialized = true;
        });

        Future.delayed(const Duration(milliseconds: 150), () {
          if (mounted) setState(() => _showPlaceholder = false);
        });
      }
    } catch (e) {
      debugPrint(
        "Advertencia: No se pudo cargar el video ${widget.assetPath}: $e",
      );
    }
  }

  @override
  void dispose() {
    _controller?.pause();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // IMAGEN OPTIMIZADA: Gapless + FrameBuilder para evitar parpadeos blancos
    final placeholderImage = Image.asset(
      widget.placeholderPath,
      fit: BoxFit.contain,
      width: double.infinity,
      height: double.infinity,
      gaplessPlayback:
          true, // CLAVE: Mantiene la imagen vieja hasta que la nueva carga
      errorBuilder: (context, error, stackTrace) {
        debugPrint(
          '[AboutMe] Image error for ${widget.placeholderPath}: $error',
        );
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Center(
            child: Icon(
              Icons.person_rounded,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
        );
      },
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        if (wasSynchronouslyLoaded || frame != null) return child;
        return Container(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
            ),
          ),
        );
      },
    );

    if (!_isInitialized || _controller == null) {
      return placeholderImage;
    }

    return AspectRatio(
      aspectRatio: _controller!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          IgnorePointer(child: VideoPlayer(_controller!)),

          IgnorePointer(
            child: AnimatedOpacity(
              opacity: _showPlaceholder ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              child: placeholderImage,
            ),
          ),

          Positioned.fill(child: Container(color: Colors.transparent)),
        ],
      ),
    );
  }
}
