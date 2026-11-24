import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:flutter/material.dart';

/// Fila de elección dentro de una hoja o un formulario: 56 dp mínimo, marca de elegido con ícono y no solo
/// con color (`PickRow` de Android).
class PickRow extends StatelessWidget {
  final String title;
  final bool selected;
  final bool enabled;
  final VoidCallback onClick;
  final String? subtitle;
  final Widget? leading;
  final Widget? trailing;

  const PickRow({
    super.key,
    required this.title,
    required this.selected,
    required this.enabled,
    required this.onClick,
    this.subtitle,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = context.scheme;
    final colors = context.atelier;
    final text = context.text;
    final subtitle = this.subtitle;
    final trailing = this.trailing;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          inMutuallyExclusiveGroup: true,
          selected: selected,
          enabled: enabled,
          button: true,
          child: InkWell(
            onTap: enabled ? onClick : null,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 56),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  spacing: 12,
                  children: [
                    ?leading,
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: text.titleMedium?.copyWith(
                              color: enabled ? scheme.onSurface : colors.muted,
                            ),
                          ),
                          if (subtitle != null)
                            Text(
                              subtitle,
                              style: text.bodyMedium?.copyWith(color: colors.inkSecondary),
                            ),
                        ],
                      ),
                    ),
                    ?trailing,
                    if (selected && trailing == null)
                      Icon(Icons.check_circle_outline, size: 24, color: scheme.primary),
                  ],
                ),
              ),
            ),
          ),
        ),
        Divider(height: 1, thickness: 1, color: scheme.outlineVariant),
      ],
    );
  }
}
