import 'package:atelier_mobile_crossplatform/features/cashier/domain/cashier_errors.dart';
import 'package:atelier_mobile_crossplatform/features/cashier/domain/voucher_draft.dart';
import 'package:atelier_mobile_crossplatform/features/inventory/domain/inventory_repository.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_repository.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// US37, US39: borrador del comprobante de una orden `COMPLETED` (H26, H27). El cajero lo corrige
/// antes de emitir. El catálogo de servicios es opcional (no todos los roles lo leen) y los nombres
/// de repuestos salen solo de la caché de inventario.
class PrepareVoucherUseCase {
  final WorkOrderRepository workOrders;
  final ReceptionRepository reception;
  final InventoryRepository inventory;

  const PrepareVoucherUseCase({
    required this.workOrders,
    required this.reception,
    required this.inventory,
  });

  Future<VoucherDraft> execute(WorkOrderId workOrderId) async {
    final detail = await workOrders.getDetail(workOrderId);
    if (detail.workOrder.status != WorkOrderStatus.completed) {
      throw const InvalidCashierInputException('status');
    }
    final serviceNames = <String, String>{};
    try {
      for (final service in await workOrders.getServiceCatalog()) {
        serviceNames[service.id] = service.name;
      }
    } catch (_) {
      // Sin catálogo se usa la descripción de la tarea.
    }
    final partNames = <String, String>{};
    final productIds = {
      for (final task in detail.tasks)
        for (final product in task.products) product.productId,
    };
    for (final id in productIds) {
      final part = await inventory.observePart(id).first;
      if (part != null) partNames[id] = part.name;
    }
    final (lines, currency) = VoucherDrafts.linesOf(
      detail,
      serviceNames: serviceNames,
      partNames: partNames,
    );
    final customer = await reception.getCustomer(detail.workOrder.customerId);
    final (type, info) = VoucherDrafts.suggestFiscalInfo(customer);
    return VoucherDraft(
      workOrderId: workOrderId.value,
      customerId: customer.id,
      type: type,
      customerInfo: info,
      currency: currency,
      lines: lines,
    );
  }
}
