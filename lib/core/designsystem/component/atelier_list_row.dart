import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_plate.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:flutter/material.dart';

/// Fila de lista con divisor (se prefiere a la pila de tarjetas). Orden fijo: [plate] o [leading] primero,
/// título y segunda línea al centro, la marca de estado en [trailing] al extremo derecho.
/// 64 dp con una línea, 72 dp con dos; crece en alto con la fuente del sistema en vez de truncar la placa.
/// Con fuente grande la marca de estado baja bajo el texto: a la derecha le quitaría el ancho al título.
class AtelierListRow extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? plate;
  final bool loading;
  final bool showDivider;
  final VoidCallback? onClick;
  final Widget? leading;
  final Widget? trailing;

  const AtelierListRow({
    super.key,
    required this.title,
    this.subtitle,
    this.plate,
    this.loading = false,
    this.showDivider = true,
    this.onClick,
    this.leading,
    this.trailing,
  });

  @override
  State<AtelierListRow> createState() => _AtelierListRowState();
}

class _AtelierListRowState extends State<AtelierListRow> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final scheme = context.scheme;
    final text = context.text;
    final loading = widget.loading;
    final plate = widget.plate;
    final leading = widget.leading;
    final subtitle = widget.subtitle;
    final trailing = widget.trailing;
    final stacked = trailing != null && MediaQuery.textScalerOf(context).scale(1) >= 1.15;

    Widget row = ConstrainedBox(
      constraints: BoxConstraints(minHeight: subtitle != null ? 72 : 64),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          spacing: 12,
          children: [
            if (plate != null)
              Bone(loading: loading, child: AtelierPlate(plate: plate))
            else
              ?leading,
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Bone(
                    loading: loading,
                    widthFraction: 0.7,
                    child: Text(
                      widget.title,
                      style: text.titleMedium?.copyWith(color: scheme.onSurface),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (subtitle != null)
                    Bone(
                      loading: loading,
                      widthFraction: 0.5,
                      child: Text(
                        subtitle,
                        style: text.bodyMedium?.copyWith(color: colors.inkSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (stacked && !loading) Padding(padding: const EdgeInsets.only(top: 4), child: trailing),
                ],
              ),
            ),
            if (!stacked && !loading && trailing != null) trailing,
          ],
        ),
      ),
    );

    final onClick = widget.onClick;
    if (onClick != null && !loading) {
      row = SpringPressScale(
        isPressed: _pressed,
        pressed: 0.985,
        child: Semantics(
          button: true,
          child: InkWell(
            onTap: onClick,
            onHighlightChanged: (value) => setState(() => _pressed = value),
            child: row,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        row,
        if (widget.showDivider)
          Divider(height: 1, thickness: 1, color: colors.outlineSoft.withValues(alpha: 0.45)),
      ],
    );
  }
}
