import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:flutter/material.dart';

/// Chip de elección de los formularios de órdenes: la elección lleva una marca y no depende solo del color.
class WorkOrderChoiceChip extends StatelessWidget {
  final String label;
  final bool selected;
  final bool enabled;
  final VoidCallback onClick;

  const WorkOrderChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.onClick,
  });

  @override
  Widget build(BuildContext context) {
    return FilterChip(
      selected: selected,
      onSelected: enabled ? (_) => onClick() : null,
      label: Text(label, style: Theme.of(context).textTheme.labelLarge),
      shape: const RoundedRectangleBorder(borderRadius: chipRadius),
      showCheckmark: false,
      avatar: selected ? const Icon(Icons.check_outlined) : null,
    );
  }
}
