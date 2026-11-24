import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_live_beacon.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_colors.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:flutter/material.dart';

/// Nivel semántico de una lectura telemétrica OBD-II (DESIGN.md → La Regla del Código Vial).
enum PidSeverity { normal, warning, critical }

/// Ficha calibrada de lectura OBD-II sobre [SurfaceTier.card]: cifra tabular en Satoshi Black,
/// unidad, estado con ícono y texto cuando sale de rango, y barra métrica calibrada opcional ([level]).
class AtelierPidTile extends StatelessWidget {
  final String label;
  final String value;
  final String unit;
  final PidSeverity severity;
  final String? statusText;
  final bool loading;

  /// Entre 0 y 1; `null` no dibuja la barra.
  final double? level;

  const AtelierPidTile({
    super.key,
    required this.label,
    required this.value,
    required this.unit,
    this.severity = PidSeverity.normal,
    this.statusText,
    this.loading = false,
    this.level,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.atelier;
    final scheme = context.scheme;
    final borderColor = switch (severity) {
      PidSeverity.normal => scheme.outlineVariant,
      PidSeverity.warning => colors.warnMark,
      PidSeverity.critical => colors.badMark,
    };
    final valueColor = switch (severity) {
      PidSeverity.normal => scheme.onSurface,
      PidSeverity.warning => colors.warn,
      PidSeverity.critical => colors.bad,
    };
    final barColor = switch (severity) {
      PidSeverity.normal => atelierBlue,
      PidSeverity.warning => colors.warnMark,
      PidSeverity.critical => colors.badMark,
    };
    final statusIcon = switch (severity) {
      PidSeverity.normal => Icons.check_circle_outlined,
      PidSeverity.warning => Icons.warning_amber_outlined,
      PidSeverity.critical => Icons.error_outline,
    };
    final overlayAlpha = colors.isDark ? 0.55 : 0.72;
    final overlay = switch (severity) {
      PidSeverity.normal => null,
      PidSeverity.warning => ShapeDecoration(
        color: colors.warnContainer.withValues(alpha: overlayAlpha),
        shape: RoundedRectangleBorder(
          borderRadius: cardLargeRadius,
          side: BorderSide(color: borderColor, width: 1.5),
        ),
      ),
      PidSeverity.critical => ShapeDecoration(
        color: colors.badContainer.withValues(alpha: overlayAlpha),
        shape: RoundedRectangleBorder(
          borderRadius: cardLargeRadius,
          side: BorderSide(color: borderColor, width: 1.5),
        ),
      ),
    };
    final status = statusText;
    final textTheme = context.text;

    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 104),
      child: AtelierSurface(
        tier: SurfaceTier.card,
        shape: cardLargeShape,
        child: Semantics(
          container: true,
          child: DecoratedBox(
            decoration: overlay ?? const BoxDecoration(),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  spacing: 4,
                  children: [
                    Text(
                      label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelLarge?.copyWith(
                        color: colors.inkSecondary,
                      ),
                    ),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      spacing: 4,
                      children: [
                        Flexible(
                          child: Bone(
                            loading: loading,
                            widthFraction: 0.55,
                            child: Text(
                              value,
                              maxLines: 1,
                              style: textTheme.headlineMedium?.copyWith(
                                color: valueColor,
                              ),
                            ),
                          ),
                        ),
                        if (unit.trim().isNotEmpty && !loading)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: Text(
                              unit,
                              style: textTheme.labelLarge?.copyWith(
                                color: colors.inkSecondary,
                              ),
                            ),
                          ),
                      ],
                    ),
                    if (status != null && status.trim().isNotEmpty && !loading)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        spacing: 4,
                        children: [
                          Icon(statusIcon, size: 16, color: valueColor),
                          Flexible(
                            child: Text(
                              status,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: textTheme.labelMedium?.copyWith(
                                color: valueColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                    if (level != null && !loading)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: AtelierMetricBar(
                          progress: level!,
                          color: barColor,
                          height: 5,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
