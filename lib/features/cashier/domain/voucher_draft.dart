import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_errors.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_validation.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/tasks/domain/task_status.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:decimal/decimal.dart';

/// Línea por emitir, con el precio unitario ya con IGV.
class VoucherLineDraft {
  final VoucherItemType itemType;
  final String? itemId;
  final String description;
  final Decimal quantity;
  final Decimal unitPriceWithIgv;

  const VoucherLineDraft({
    required this.itemType,
    this.itemId,
    required this.description,
    required this.quantity,
    required this.unitPriceWithIgv,
  });

  /// El cajero debe escribir la descripción antes de emitir (H26).
  bool get needsDescription =>
      CashierValidation.isPlaceholderDescription(description);

  VoucherLineDraft copyWith({String? description}) {
    return VoucherLineDraft(
      itemType: itemType,
      itemId: itemId,
      description: description ?? this.description,
      quantity: quantity,
      unitPriceWithIgv: unitPriceWithIgv,
    );
  }
}

/// Borrador que arma `PrepareVoucherUseCase` y el cajero corrige antes de emitir (H26, H27).
class VoucherDraft {
  final String workOrderId;
  final String customerId;
  final VoucherType type;
  final CustomerFiscalInfo customerInfo;
  final String currency;
  final List<VoucherLineDraft> lines;

  const VoucherDraft({
    required this.workOrderId,
    required this.customerId,
    required this.type,
    required this.customerInfo,
    required this.currency,
    required this.lines,
  });

  /// Puede diferir en céntimos del total de la orden (H26): se cobra el `pendingBalance` del
  /// comprobante emitido.
  Decimal get total => lines
      .fold(
        Decimal.zero,
        (sum, line) => sum + line.quantity * line.unitPriceWithIgv,
      )
      .round(scale: 2);

  VoucherDraft copyWith({
    VoucherType? type,
    CustomerFiscalInfo? customerInfo,
    List<VoucherLineDraft>? lines,
  }) {
    return VoucherDraft(
      workOrderId: workOrderId,
      customerId: customerId,
      type: type ?? this.type,
      customerInfo: customerInfo ?? this.customerInfo,
      currency: currency,
      lines: lines ?? this.lines,
    );
  }
}

/// No hay "facturar una orden" en el backend (H26): las líneas salen de sus tareas y repuestos.
abstract final class VoucherDrafts {
  /// Tareas no canceladas: una línea de servicio por tarea con precio y una por repuesto. Un precio
  /// nulo falla con `lines`; uno en 0 no da línea (el backend pide 0,01 como mínimo). Sin líneas falla
  /// con `lines`, antes de mirar la moneda; varias monedas fallan con `currency`.
  static (List<VoucherLineDraft>, String) linesOf(
    WorkOrderDetail detail, {
    Map<String, String> serviceNames = const {},
    Map<String, String> partNames = const {},
  }) {
    final lines = <VoucherLineDraft>[];
    final currencies = <String>{};
    for (final task in detail.tasks) {
      if (task.status == TaskStatus.cancelled) continue;
      final price = task.price;
      if (price == null) throw const InvalidCashierInputException('lines');
      if (price.amount > Decimal.zero) {
        currencies.add(price.currency);
        lines.add(
          VoucherLineDraft(
            itemType: VoucherItemType.service,
            itemId: task.serviceId,
            description: serviceNames[task.serviceId] ?? task.description,
            quantity: Decimal.one,
            unitPriceWithIgv: CashierValidation.withIgv(price.amount),
          ),
        );
      }
      for (final product in task.products) {
        final unitPrice = product.unitPrice;
        if (unitPrice == null) {
          throw const InvalidCashierInputException('lines');
        }
        if (unitPrice.amount == Decimal.zero) continue;
        currencies.add(unitPrice.currency);
        lines.add(
          VoucherLineDraft(
            itemType: VoucherItemType.product,
            itemId: product.productId,
            description:
                partNames[product.productId] ?? product.productName ?? '',
            quantity: product.quantity,
            unitPriceWithIgv: CashierValidation.withIgv(unitPrice.amount),
          ),
        );
      }
    }
    if (lines.isEmpty) throw const InvalidCashierInputException('lines');
    if (currencies.length != 1) {
      throw const InvalidCashierInputException('currency');
    }
    return (lines, currencies.single);
  }

  /// H27: el cliente no trae tipo de documento ni dirección. Empresa con RUC válido → factura;
  /// persona con DNI válido → boleta; otro caso → boleta con CE, para que el cajero lo corrija.
  static (VoucherType, CustomerFiscalInfo) suggestFiscalInfo(
    Customer customer,
  ) {
    final taxId = customer.taxId ?? '';
    final (type, document) = switch (customer.type) {
      CustomerType.company when CashierValidation.isRuc(taxId) => (
        VoucherType.factura,
        FiscalDocumentType.ruc,
      ),
      CustomerType.individual when CashierValidation.isDni(taxId) => (
        VoucherType.boleta,
        FiscalDocumentType.dni,
      ),
      _ => (VoucherType.boleta, FiscalDocumentType.ce),
    };
    return (
      type,
      CustomerFiscalInfo(
        documentType: document,
        taxId: taxId,
        legalName: customer.displayName,
      ),
    );
  }
}
