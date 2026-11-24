import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/part.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/presentation/inventory_labels.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// US31 E1: una chip por cada una de las 9 `ItemCategory`; tocar la activa la quita.
class CategoryFilterChips extends StatelessWidget {
  final ItemCategory? selected;
  final ValueChanged<ItemCategory> onClick;

  const CategoryFilterChips({super.key, required this.selected, required this.onClick});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        spacing: 8,
        children: [
          for (final category in ItemCategory.values)
            FilterChip(
              selected: category == selected,
              onSelected: (_) => onClick(category),
              label: Text(category.label(strings)),
              shape: controlShape,
            ),
        ],
      ),
    );
  }
}
