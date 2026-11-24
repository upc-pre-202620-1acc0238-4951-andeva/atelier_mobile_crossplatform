import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_adaptive_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_plate.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Cifra secundaria del Parte. Con [onClick] lleva a su lista filtrada.
@immutable
class PanelFigure {
  final String value;
  final String label;
  final VoidCallback? onClick;

  const PanelFigure({required this.value, required this.label, this.onClick});
}

/// Tarjeta Hero Navy esculpida en tamaño Parte, para pantallas de supervisión: vive bajo la cabecera
/// limpia con margen lateral, degradado direccional, arco de luz, leyenda única en Display y cifras
/// secundarias en sub-cápsulas translúcidas.
///
/// Con [loading] las cifras son huesos y lo fijo (contexto, rótulos) se ve desde el primer cuadro.
class AtelierReportPanel extends StatelessWidget {
  final String context_;
  final String legend;
  final String caption;
  final List<PanelFigure> figures;
  final bool loading;
  final VoidCallback? onContextClick;
  final List<Widget> actions;

  /// [context] es el nombre Kotlin del parámetro; en Dart choca con `BuildContext context`, por eso se
  /// recibe como `context` en el constructor y se guarda en [context_].
  const AtelierReportPanel({
    super.key,
    required String context,
    required this.legend,
    required this.caption,
    this.figures = const [],
    this.loading = false,
    this.onContextClick,
    this.actions = const [],
  }) : context_ = context;

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final text = context.text;
    final onContextClick = this.onContextClick;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: AtelierSurface(
        tier: SurfaceTier.heroNavy,
        shape: heroShape,
        contentPadding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: onContextClick != null ? 48 : 28),
                    child: _PanelTap(
                      onTap: onContextClick,
                      shape: controlShape,
                      child: Row(
                        spacing: 4,
                        children: [
                          Flexible(
                            child: Text(
                              context_,
                              style: text.labelLarge?.copyWith(color: colors.onPanel.withValues(alpha: 0.85)),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (onContextClick != null)
                            Icon(Icons.expand_more_outlined, size: 20, color: colors.onPanel.withValues(alpha: 0.85)),
                        ],
                      ),
                    ),
                  ),
                ),
                ...actions,
              ],
            ),
            const SizedBox(height: 6),
            Semantics(
              header: true,
              child: Bone(
                loading: loading,
                onPanel: true,
                widthFraction: 0.6,
                child: Text(legend, style: text.displaySmall?.copyWith(color: colors.onPanel)),
              ),
            ),
            Text(
              caption,
              style: text.titleMedium?.copyWith(color: colors.onPanel.withValues(alpha: 0.90)),
            ),
            if (figures.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.only(top: 14, bottom: 12),
                child: Divider(height: 1, thickness: 1, color: Colors.white.withValues(alpha: 0.16)),
              ),
              // Wrap: a fuente 1.3 las cifras bajan a una columna en vez de recortarse.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final figure in figures) _ReportFigureCapsule(figure: figure, loading: loading),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Zona tocable sobre un panel azul: encoge con resorte, ondas blancas y recorte a [shape].
/// Sin [onTap] solo pinta [decoration] y [child].
class _PanelTap extends StatefulWidget {
  final VoidCallback? onTap;
  final ShapeBorder shape;
  final Decoration? decoration;
  final EdgeInsetsGeometry padding;
  final Widget child;

  const _PanelTap({
    required this.onTap,
    required this.shape,
    this.decoration,
    this.padding = EdgeInsets.zero,
    required this.child,
  });

  @override
  State<_PanelTap> createState() => _PanelTapState();
}

class _PanelTapState extends State<_PanelTap> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final onTap = widget.onTap;
    Widget content = Material(
      type: MaterialType.transparency,
      shape: widget.shape,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: widget.shape,
        splashColor: Colors.white.withValues(alpha: 0.24),
        highlightColor: Colors.white.withValues(alpha: 0.10),
        onTap: onTap,
        onHighlightChanged: onTap != null ? (value) => setState(() => _pressed = value) : null,
        child: Padding(padding: widget.padding, child: widget.child),
      ),
    );
    if (widget.decoration != null) content = DecoratedBox(decoration: widget.decoration!, child: content);
    if (onTap == null) return content;
    return Semantics(
      button: true,
      child: SpringPressScale(isPressed: _pressed, child: content),
    );
  }
}

class _ReportFigureCapsule extends StatelessWidget {
  final PanelFigure figure;
  final bool loading;

  const _ReportFigureCapsule({required this.figure, required this.loading});

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final text = context.text;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: _PanelTap(
        onTap: figure.onClick,
        shape: controlShape,
        decoration: ShapeDecoration(
          color: Colors.white.withValues(alpha: 0.10),
          shape: RoundedRectangleBorder(
            borderRadius: controlRadius,
            side: BorderSide(color: Colors.white.withValues(alpha: 0.14)),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Bone(
              loading: loading,
              onPanel: true,
              child: Text(figure.value, style: text.headlineMedium?.copyWith(color: colors.onPanel)),
            ),
            Text(
              figure.label,
              style: text.bodyMedium?.copyWith(color: colors.onPanel.withValues(alpha: 0.85)),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cabecera de detalle en capas (Ficha): barra superior limpia sobre el lienzo (Atrás en medallón circular
/// elevado + [actions]) y debajo una tarjeta [SurfaceTier.heroNavy] con [identity], [status], [title] y [subtitle].
class AtelierFichaPanel extends StatelessWidget {
  final VoidCallback onBack;
  final String title;
  final String? subtitle;
  final Widget? identity;
  final Widget? status;
  final List<Widget> actions;

  const AtelierFichaPanel({
    super.key,
    required this.onBack,
    required this.title,
    this.subtitle,
    this.identity,
    this.status,
    this.actions = const [],
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final scheme = context.scheme;
    final text = context.text;
    final strings = AppLocalizations.of(context);
    final subtitle = this.subtitle;
    final identity = this.identity;
    final status = this.status;
    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        left: false,
        right: false,
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 56),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      AtelierCircularIconButton(
                        icon: Icons.arrow_back_outlined,
                        contentDescription: strings.commonBack,
                        onClick: onBack,
                      ),
                      const Spacer(),
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: AtelierSurface(
                  tier: SurfaceTier.heroNavy,
                  shape: heroShape,
                  contentPadding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    spacing: 8,
                    children: [
                      if (identity != null || status != null)
                        Row(
                          spacing: 12,
                          children: [
                            ?identity,
                            const Spacer(),
                            ?status,
                          ],
                        ),
                      Semantics(
                        header: true,
                        child: Text(title, style: text.titleLarge?.copyWith(color: colors.onPanel)),
                      ),
                      if (subtitle != null && subtitle.trim().isNotEmpty)
                        Text(
                          subtitle,
                          style: text.bodyMedium?.copyWith(color: colors.onPanel.withValues(alpha: 0.85)),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Título de sección. Con [count] se escribe "Esperan tu decisión · 3": el conteo siempre va.
class AtelierSectionHeader extends StatelessWidget {
  final String title;
  final int? count;
  final Widget? action;

  const AtelierSectionHeader({super.key, required this.title, this.count, this.action});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final count = this.count;
    final action = this.action;
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 48),
      child: Row(
        children: [
          Expanded(
            child: Semantics(
              header: true,
              child: Text(
                count != null ? strings.sectionWithCount(title, count) : title,
                style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
              ),
            ),
          ),
          ?action,
        ],
      ),
    );
  }
}

/// Panel de decisión refinado («Precisión Automotriz»): superficie [SurfaceTier.decisionAmber] con barra
/// acento interior redondeada, placa mecanizada y respuesta táctil con resorte. El ámbar es solo para
/// decisiones humanas pendientes.
///
/// Con [resolved] muestra un chip verde elegante con el resultado ("Aprobada", "Rechazada") antes de retirarse.
class AtelierDecisionRow extends StatelessWidget {
  final String title;
  final VoidCallback onClick;
  final String? plate;
  final String? subtitle;
  final String? amount;
  final String? resolved;
  final bool enabled;
  final Widget? leading;

  const AtelierDecisionRow({
    super.key,
    required this.title,
    required this.onClick,
    this.plate,
    this.subtitle,
    this.amount,
    this.resolved,
    this.enabled = true,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final scheme = context.scheme;
    final text = context.text;
    final plate = this.plate;
    final leading = this.leading;
    final subtitle = this.subtitle;
    final amount = this.amount;
    final resolved = this.resolved;
    return AtelierSurface(
      tier: SurfaceTier.decisionAmber,
      shape: cardLargeShape,
      onClick: resolved == null ? onClick : null,
      enabled: enabled,
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 48),
        child: SizedBox(
          width: double.infinity,
          child: AtelierAdaptiveRow(
            horizontalSpacing: 12,
            verticalSpacing: 8,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                spacing: 12,
                children: [
                  if (plate != null)
                    AtelierPlate(plate: plate, size: PlateSize.l)
                  else
                    ?leading,
                  Flexible(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 2,
                      children: [
                        Text(title, style: text.titleMedium?.copyWith(color: scheme.onSurface)),
                        if (subtitle != null && subtitle.trim().isNotEmpty)
                          Text(subtitle, style: text.bodyMedium?.copyWith(color: colors.inkSecondary)),
                      ],
                    ),
                  ),
                ],
              ),
              if (resolved != null)
                AtelierChip(text: resolved, kind: ChipKind.ok, icon: Icons.check_circle_outline)
              else if (amount != null)
                Text(
                  amount,
                  style: text.titleMedium?.copyWith(fontWeight: FontWeight.w700, color: colors.decisionAccent),
                  maxLines: 1,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
