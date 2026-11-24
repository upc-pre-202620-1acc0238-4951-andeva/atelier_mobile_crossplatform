import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_grouped_card.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/money_format.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_product.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Repuestos imputados a la tarea (US33 E1). Con permiso de edición cada uno ofrece corregir la cantidad o
/// devolverlo al inventario; el precio queda fijo al imputar y no se recalcula aquí (US35 E3).
class TaskPartsSection extends StatelessWidget {
  final List<TaskProduct> products;
  final bool available;
  final bool canCharge;
  final bool canEdit;
  final bool isOnline;
  final bool isBusy;
  final VoidCallback onCharge;
  final ValueChanged<TaskProduct> onEdit;
  final ValueChanged<TaskProduct> onReturn;

  const TaskPartsSection({
    super.key,
    required this.products,
    required this.available,
    required this.canCharge,
    required this.canEdit,
    required this.isOnline,
    required this.isBusy,
    required this.onCharge,
    required this.onEdit,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 12,
      children: [
        AtelierSectionHeader(title: strings.taskPartsTitle, count: available ? products.length : null),
        if (!available)
          // D3: sin el detalle en línea no se sabe qué repuestos hay; no se dice que no hay ninguno.
          Text(
            strings.taskPartsOnlineOnly,
            style: context.text.bodyLarge?.copyWith(color: context.atelier.inkSecondary),
          )
        else if (products.isEmpty)
          AtelierEmptyState(text: strings.taskPartsEmpty)
        else
          for (final product in products)
            _ProductCard(
              product: product,
              canEdit: canEdit,
              isOnline: isOnline,
              isBusy: isBusy,
              onEdit: () => onEdit(product),
              onReturn: () => onReturn(product),
            ),
        if (canCharge) ...[
          AtelierButton(
            text: strings.taskPartsCharge,
            onClick: onCharge,
            style: AtelierButtonStyle.tonal,
            minHeight: 48,
            enabled: isOnline && !isBusy,
            icon: Icons.add_outlined,
          ),
          if (!isOnline) const AtelierRequiresConnection(),
        ],
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final TaskProduct product;
  final bool canEdit;
  final bool isOnline;
  final bool isBusy;
  final VoidCallback onEdit;
  final VoidCallback onReturn;

  const _ProductCard({
    required this.product,
    required this.canEdit,
    required this.isOnline,
    required this.isBusy,
    required this.onEdit,
    required this.onReturn,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final unitPrice = product.unitPrice;
    final total = product.totalAmount;
    return AtelierGroupedCard(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              Text(
                product.productName ?? strings.taskPartUnnamed,
                style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
              ),
              Row(
                spacing: 16,
                children: [
                  Text(
                    strings.taskPartQuantity(product.quantity.formatQuantity()),
                    style: context.text.bodyLarge?.copyWith(color: context.scheme.onSurface),
                  ),
                  if (unitPrice != null)
                    Flexible(
                      child: Text(
                        strings.taskPartUnitPrice(unitPrice.format()),
                        style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
                      ),
                    ),
                ],
              ),
              if (total != null)
                Text(
                  strings.taskPartTotal(total.format()),
                  style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
                ),
              if (canEdit)
                Row(
                  spacing: 8,
                  children: [
                    Expanded(
                      child: AtelierButton(
                        text: strings.taskPartEdit,
                        onClick: onEdit,
                        style: AtelierButtonStyle.outlined,
                        enabled: isOnline && !isBusy,
                      ),
                    ),
                    Expanded(
                      child: AtelierButton(
                        text: strings.taskPartReturn,
                        onClick: onReturn,
                        style: AtelierButtonStyle.text,
                        enabled: isOnline && !isBusy,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}
