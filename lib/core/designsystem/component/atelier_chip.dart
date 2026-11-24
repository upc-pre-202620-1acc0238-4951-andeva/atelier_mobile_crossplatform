import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_live_beacon.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_colors.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:flutter/material.dart';

/// Vocabulario fijo (DESIGN.md → Chips y marcas de estado): [info] en curso · [ok] listo, aprobada,
/// sincronizado · [wait] espera decisión · [bad] rechazada, falló · [warn] tardanza, stock mínimo,
/// suspendida · [idle] pendiente de sincronizar, sin permiso.
enum ChipKind { ok, info, wait, bad, idle, warn }

/// Marca de estado calibrada: fondo semántico translúcido, borde fino del mismo tono al 28 % y señal
/// acompañada de ícono o [AtelierLiveBeacon] cuando [live] está activo. Nunca solo color.
class AtelierChip extends StatelessWidget {
  final String text;
  final ChipKind kind;
  final IconData? icon;
  final bool live;

  const AtelierChip({super.key, required this.text, this.kind = ChipKind.idle, this.icon, this.live = false});

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final (container, content) = switch (kind) {
      ChipKind.ok => (colors.okContainer, colors.ok),
      ChipKind.info => (colors.infoContainer, colors.info),
      ChipKind.wait => (colors.waitContainer, colors.wait),
      ChipKind.bad => (colors.badContainer, colors.bad),
      ChipKind.idle => (colors.idleContainer, colors.idle),
      ChipKind.warn => (colors.warnContainer, colors.warn),
    };
    final beaconColor = switch (kind) {
      ChipKind.ok => colors.okMark,
      ChipKind.info => atelierBlue,
      ChipKind.wait => colors.decision,
      ChipKind.bad => colors.badMark,
      ChipKind.warn => colors.warnMark,
      ChipKind.idle => colors.idle,
    };
    final mark = icon ??
        switch (kind) {
          ChipKind.ok => Icons.check_circle_outline,
          ChipKind.info => Icons.play_circle_outline,
          ChipKind.wait => Icons.hourglass_empty_outlined,
          ChipKind.bad => Icons.error_outline,
          ChipKind.idle => Icons.more_horiz_outlined,
          ChipKind.warn => Icons.warning_amber_outlined,
        };

    return DecoratedBox(
      decoration: ShapeDecoration(
        color: container,
        shape: RoundedRectangleBorder(
          borderRadius: chipRadius,
          side: BorderSide(color: content.withValues(alpha: 0.28), width: 0.75),
        ),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 28),
        child: Align(
          widthFactor: 1,
          heightFactor: 1,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 5,
              children: [
                if (live)
                  AtelierLiveBeacon(color: beaconColor, size: 7, pulsing: true)
                else
                  Icon(mark, size: 16, color: content),
                Text(
                  text,
                  style: context.text.labelLarge!.copyWith(color: content),
                  maxLines: 1,
                  softWrap: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
