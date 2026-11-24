import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_page_transitions.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_colors.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_typography.dart';
import 'package:flutter/cupertino.dart' show CupertinoPageTransitionsBuilder;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Oscuro: planos calibrados («Precisión Automotriz») del pozo hundido (#1C1D20) al plano flotante (#33363C).
const _darkScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: atelierBlue,
  onPrimary: Colors.white,
  primaryContainer: Color(0xFF1D3A5F),
  onPrimaryContainer: atelierBlueSoft,
  secondary: atelierBlueSoft,
  onSecondary: atelierBlueDark,
  secondaryContainer: Color(0xFF1D3A5F),
  onSecondaryContainer: atelierBlueSoft,
  tertiary: atelierAccent,
  onTertiary: atelierInk,
  error: Color(0xFFFF6B76),
  onError: atelierInk,
  errorContainer: Color(0xFF4A1A20),
  onErrorContainer: Colors.white,
  surface: atelierCardDark,
  onSurface: Colors.white,
  surfaceContainerLowest: Color(0xFF1C1D20),
  surfaceContainerLow: atelierCardDark,
  surfaceContainer: Color(0xFF2F3136),
  surfaceContainerHigh: Color(0xFF33363C),
  surfaceContainerHighest: Color(0xFF3B3E45),
  onSurfaceVariant: atelierBorderLight,
  outline: Color(0x66EBEBEB),
  outlineVariant: Color(0x1FEBEBEB),
  scrim: Color(0x99000000),
);

const _lightScheme = ColorScheme(
  brightness: Brightness.light,
  primary: atelierBlue,
  onPrimary: Colors.white,
  primaryContainer: Color(0xFFD8E8FF),
  onPrimaryContainer: atelierBlueDark,
  secondary: Color(0xFF005DC2),
  onSecondary: Colors.white,
  secondaryContainer: Color(0xFFD8E8FF),
  onSecondaryContainer: atelierBlueDark,
  tertiary: Color(0xFF9A5300),
  onTertiary: Colors.white,
  error: Color(0xFFB3101D),
  onError: Colors.white,
  errorContainer: Color(0xFFFDE3E5),
  onErrorContainer: atelierInk,
  surface: atelierCardLight,
  onSurface: atelierInk,
  surfaceContainerLowest: atelierCardLight,
  surfaceContainerLow: atelierSurfaceLight,
  surfaceContainer: Color(0xFFF2F4F8),
  surfaceContainerHigh: Color(0xFFECEFF4),
  surfaceContainerHighest: Color(0xFFE4E8EF),
  onSurfaceVariant: Color(0xFF454B55),
  outline: atelierBorderLight,
  outlineVariant: Color(0xFFE5E8EE),
  scrim: Color(0x73141416),
);

/// Cuántos paneles o barras azules tocan la barra de estado ahora mismo. Un contador y no un
/// booleano: al navegar, la pantalla nueva entra antes de que la anterior salga.
final ValueNotifier<int> bluePanelsOnScreen = ValueNotifier<int>(0);

/// Mientras está montado, los íconos de la barra de estado van en claro (hay azul debajo).
class PanelStatusBarEffect extends StatefulWidget {
  const PanelStatusBarEffect({super.key});

  @override
  State<PanelStatusBarEffect> createState() => _PanelStatusBarEffectState();
}

class _PanelStatusBarEffectState extends State<PanelStatusBarEffect> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => bluePanelsOnScreen.value++);
  }

  @override
  void dispose() {
    // El decremento va fuera de la fase de build.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (bluePanelsOnScreen.value > 0) bluePanelsOnScreen.value--;
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

/// Envuelve la app: íconos de la barra de estado según tema y paneles azules.
class AtelierSystemUiScope extends StatelessWidget {
  final Widget child;

  const AtelierSystemUiScope({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return ValueListenableBuilder<int>(
      valueListenable: bluePanelsOnScreen,
      builder: (context, panels, _) {
        final lightIcons = dark || panels > 0;
        return AnnotatedRegion<SystemUiOverlayStyle>(
          value: SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarIconBrightness: lightIcons ? Brightness.light : Brightness.dark,
            statusBarBrightness: lightIcons ? Brightness.dark : Brightness.light,
            systemNavigationBarColor: Colors.transparent,
            systemNavigationBarIconBrightness: dark ? Brightness.light : Brightness.dark,
          ),
          child: child,
        );
      },
    );
  }
}

/// Tema de Atelier. Sin color dinámico a propósito: la paleta de marca es fija.
/// Oscuro y claro son esquemas completos, no una inversión.
abstract final class AtelierTheme {
  static ThemeData get light => _build(_lightScheme, lightAtelierColors, atelierSurfaceLight);
  static ThemeData get dark => _build(_darkScheme, darkAtelierColors, atelierSurfaceDark);

  static ThemeData _build(ColorScheme scheme, AtelierColors colors, Color background) {
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: background,
      canvasColor: background,
      fontFamily: satoshiFamily,
      textTheme: atelierTextTheme.apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface),
      extensions: [colors],
      splashFactory: InkRipple.splashFactory,
      dividerColor: scheme.outlineVariant,
      dividerTheme: DividerThemeData(color: scheme.outlineVariant, thickness: 1, space: 1),
      cardTheme: CardThemeData(
        color: colors.card,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: cardRadius),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surfaceFloating,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(28))),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surfaceFloating,
        shape: sheetTopShape,
        showDragHandle: false,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: controlRadius),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: AtelierPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}

extension AtelierThemeContext on BuildContext {
  /// Roles propios: `context.atelier.ok`, `context.atelier.muted`…
  AtelierColors get atelier => Theme.of(this).extension<AtelierColors>()!;
  ColorScheme get scheme => Theme.of(this).colorScheme;
  TextTheme get text => Theme.of(this).textTheme;
}
