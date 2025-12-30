// Archivo: lib/features/about_me/presentation/views/about_me_view.dart
import 'package:animate_do/animate_do.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:apex/core/config/theme/app_theme.dart';
import 'package:apex/core/config/theme/app_theme_providers.dart';
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
  void dispose() {
    _mousePos.dispose();
    super.dispose();
  }

  // CORRECCIÓN DE COMPATIBILIDAD:
  // Safari (WebKit) tiene soporte limitado para WebM con canal Alfa (Transparencia).
  // Esto afecta tanto a iOS como a macOS. Detectamos ambos para evitar
  // mostrar un reproductor roto a usuarios de Mac.
  bool get _isAppleEcosystem {
    return defaultTargetPlatform == TargetPlatform.iOS || 
           defaultTargetPlatform == TargetPlatform.macOS;
  }

  @override
  Widget build(BuildContext context) {
    final themeConfig = ref.watch(currentAppThemeConfigProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 800;
    
    // Si estamos en el ecosistema Apple, ocultamos el video para evitar errores visuales
    final bool hideVisuals = _isAppleEcosystem;

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
                      // Solo mostramos el video si NO estamos en Apple
                      if (!hideVisuals)
                        FadeInDown(
                          child: _DynamicHeroImage(themeConfig: themeConfig)
                        )
                      else
                        // Espaciador para mantener armonía visual sin el video
                        const SizedBox(height: 20),
                        
                      FadeInUp(child: _AboutMeCard(mousePos: _mousePos)),
                    ],
                  ),
                ),
              ),
            ),
            const Footer(),
          ],
        ),
      ),
    );
  }
}

class _DynamicHeroImage extends StatelessWidget {
  final AppThemeConfig themeConfig;
  const _DynamicHeroImage({required this.themeConfig});

  @override
  Widget build(BuildContext context) {
    final String videoPath = switch (themeConfig.theme) {
      AppTheme.flutter   => 'assets/videos/yoflutter.webm',
      AppTheme.supabase  => 'assets/videos/yosupabase.webm',
      AppTheme.riverpod  => 'assets/videos/yoriverpod.webm',
      AppTheme.assistify => 'assets/videos/yoassistify.webm',
      AppTheme.neutral   => 'assets/videos/yoapex.webm',
    };

    return SizedBox(
      height: 250, 
      width: double.infinity,
      child: Center(
        child: Transform.translate(
          offset: const Offset(0, 45),
          child: Transform.scale(
            scale: 1.8, 
            child: _TransparentVideoPlayer(
              key: ValueKey(videoPath), 
              assetPath: videoPath,
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

    return ValueListenableBuilder<Offset>(
      valueListenable: mousePos,
      builder: (context, mouseOffset, child) {
        Offset localLightPos = Offset.zero;
        final renderObject = context.findRenderObject();
        if (renderObject is RenderBox && renderObject.hasSize) {
          localLightPos = renderObject.globalToLocal(mouseOffset);
        }

        return AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: RadialGradient(
              center: Alignment(
                (localLightPos.dx / (renderObject is RenderBox ? renderObject.size.width : 1)) * 2 - 1,
                (localLightPos.dy / (renderObject is RenderBox ? renderObject.size.height : 1)) * 2 - 1,
              ),
              radius: 1.5, 
              colors: [
                brandColor.withOpacity(0.9), 
                brandColor.withOpacity(0.3), 
                Colors.transparent,
              ],
              stops: const [0.0, 0.4, 1.0],
            ),
          ),
          padding: const EdgeInsets.all(2.5),
          child: Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(22),
            ),
            padding: EdgeInsets.all(isMobile ? 24 : 45),
            child: Column(
              crossAxisAlignment: isMobile ? CrossAxisAlignment.start : CrossAxisAlignment.center,
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
                    Icon(FontAwesomeIcons.boltLightning, size: 16, color: brandColor),
                    const SizedBox(width: 10),
                    Text(
                      '3 años de experiencia',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant, 
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 40),

                Text(
                  "Programar es mucho más que tirar líneas de código, para mí es una disciplina de constancia diaria. Llevo tres años dedicándole cada día a entender cómo construir soluciones que realmente funcionen. Estoy convencido de que hoy no existen límites técnicos: cualquier idea se puede materializar si se tiene el compromiso de entender el problema y la destreza para construir la solución que el usuario realmente necesita.",
                  textAlign: isMobile ? TextAlign.left : TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.7, fontSize: 18),
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
                    style: theme.textTheme.bodyMedium?.copyWith(height: 1.7, fontSize: 16),
                  ),
                ),

                const SizedBox(height: 40),

                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  alignment: isMobile ? WrapAlignment.start : WrapAlignment.center,
                  children: [
                    _buildSkillTag(theme, FontAwesomeIcons.puzzlePiece, 'Resolución de Problemas'),
                    _buildSkillTag(theme, FontAwesomeIcons.layerGroup, 'Arquitectura Limpia'),
                    _buildSkillTag(theme, FontAwesomeIcons.calendarCheck, 'Constancia Diaria'),
                    _buildSkillTag(theme, FontAwesomeIcons.brain, 'Pensamiento Lógico'),
                    _buildSkillTag(theme, FontAwesomeIcons.bullseye, 'Enfoque en Resultados'),
                    _buildSkillTag(theme, FontAwesomeIcons.sliders, 'Adaptabilidad'),
                  ],
                )
              ],
            ),
          ),
        );
      },
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

class _TransparentVideoPlayer extends StatefulWidget {
  final String assetPath;

  const _TransparentVideoPlayer({
    super.key, 
    required this.assetPath
  });

  @override
  State<_TransparentVideoPlayer> createState() => _TransparentVideoPlayerState();
}

class _TransparentVideoPlayerState extends State<_TransparentVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    _controller = VideoPlayerController.asset(widget.assetPath);
    try {
      // Timeout de seguridad: Si tarda más de 5s, cortamos.
      await _controller!.initialize().timeout(const Duration(seconds: 5));
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
          _controller!.setLooping(true);
          _controller!.setVolume(0.0);
          _controller!.play();
        });
      }
    } catch (e) {
      // Fallo silencioso si el formato no es compatible
      debugPrint("Advertencia: No se pudo cargar el video ${widget.assetPath}: $e");
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
    if (!_isInitialized || _controller == null) {
      return const SizedBox.shrink(); 
    }

    return FadeIn(
      duration: const Duration(milliseconds: 500),
      child: AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: Stack(
          children: [
            IgnorePointer(
              child: VideoPlayer(_controller!),
            ),
            // Capa de seguridad para clicks
            Positioned.fill(
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}