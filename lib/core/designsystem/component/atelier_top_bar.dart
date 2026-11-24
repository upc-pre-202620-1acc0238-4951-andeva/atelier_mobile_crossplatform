import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_colors.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Pinta [color] detrás del componente, lo sangra hacia arriba por debajo de la barra de estado y reserva
/// ese alto dentro del panel, así el contenido nunca queda bajo el reloj. Si la pantalla ya aplicó el inset
/// superior, no se duplica.
class PanelBleed extends StatelessWidget {
  final Color color;
  final Widget child;

  const PanelBleed({super.key, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    final media = MediaQuery.of(context);
    // `viewPadding` no lo consume ningún SafeArea: es el alto real de la barra de estado.
    final bleed = media.viewPadding.top;
    // `padding` sí se consume: si la pantalla ya lo aplicó, aquí vale 0 y no se duplica.
    final inset = media.padding.top;
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(left: 0, right: 0, top: -bleed, bottom: 0, child: ColoredBox(color: color)),
        Padding(
          padding: EdgeInsets.only(top: inset),
          child: MediaQuery.removePadding(context: context, removeTop: true, child: child),
        ),
      ],
    );
  }
}

/// Equivalente a `Modifier.panelBleed(color)`: `child.panelBleed(color)`.
extension PanelBleedWidget on Widget {
  Widget panelBleed(Color color) => PanelBleed(color: color, child: this);
}

/// Medallón circular elevado (40 dp dentro de un objetivo táctil de 48 dp) para acciones de cabecera
/// sobre lienzo limpio.
class AtelierCircularIconButton extends StatefulWidget {
  final IconData icon;
  final String contentDescription;
  final VoidCallback onClick;
  final int badgeCount;
  final Color badgeColor;

  const AtelierCircularIconButton({
    super.key,
    required this.icon,
    required this.contentDescription,
    required this.onClick,
    this.badgeCount = 0,
    this.badgeColor = atelierError,
  });

  @override
  State<AtelierCircularIconButton> createState() => _AtelierCircularIconButtonState();
}

class _AtelierCircularIconButtonState extends State<AtelierCircularIconButton> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final count = widget.badgeCount;
    return Semantics(
      button: true,
      label: widget.contentDescription,
      excludeSemantics: true,
      onTap: widget.onClick,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Material(
          type: MaterialType.transparency,
          child: InkResponse(
            onTap: widget.onClick,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            radius: 24,
            containedInkWell: false,
            child: Center(
              child: Badge(
                isLabelVisible: count > 0,
                backgroundColor: widget.badgeColor,
                textColor: Colors.white,
                label: Text((count > 99 ? 99 : count).toString()),
                child: SpringPressScale(
                  isPressed: _pressed,
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: AtelierSurface(
                      shape: const CircleBorder(),
                      child: Center(child: Icon(widget.icon, size: 20, color: scheme.onSurface)),
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

/// Barra superior limpia para formularios y listas largas: lienzo del tema, botón Atrás en medallón circular
/// elevado, título en Satoshi Black y divisor inferior sutil.
class AtelierTopBar extends StatelessWidget {
  final String title;
  final VoidCallback onBack;
  final List<Widget> actions;

  const AtelierTopBar({super.key, required this.title, required this.onBack, this.actions = const []});

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final scheme = context.scheme;
    final strings = AppLocalizations.of(context);
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        left: false,
        right: false,
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 64,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Row(
                  spacing: 8,
                  children: [
                    AtelierCircularIconButton(
                      icon: Icons.arrow_back_outlined,
                      contentDescription: strings.commonBack,
                      onClick: onBack,
                    ),
                    Expanded(
                      child: Semantics(
                        header: true,
                        child: Text(
                          title,
                          style: context.text.titleLarge?.copyWith(color: scheme.onSurface),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ),
                    IconTheme.merge(
                      data: IconThemeData(color: scheme.onSurface),
                      child: DefaultTextStyle.merge(
                        style: TextStyle(color: scheme.onSurface),
                        child: Row(mainAxisSize: MainAxisSize.min, children: actions),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Divider(height: 1, thickness: 1, color: colors.outlineSoft.withValues(alpha: 0.50)),
          ],
        ),
      ),
    );
  }
}
