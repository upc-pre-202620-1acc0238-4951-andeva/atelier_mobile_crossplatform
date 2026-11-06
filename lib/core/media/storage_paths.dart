import 'package:uuid/uuid.dart';

/// Rutas en el bucket (docs/04-mobile-integration.md §3). El UUID se genera al capturar la foto:
/// dos fotos nunca comparten URL y el reintento de la misma siempre la repite (06 §7).
class StoragePaths {
  static String newId() => const Uuid().v4();

  static String intake(String tenantId, String workOrderId, String photoId) {
    return '$tenantId/work-orders/$workOrderId/intake/$photoId.jpg';
  }

  static String taskEvidence(
    String tenantId,
    String workOrderId,
    String taskId,
    String photoId,
  ) {
    return '$tenantId/work-orders/$workOrderId/tasks/$taskId/$photoId.jpg';
  }

  static String proposal(String tenantId, String workOrderId, String photoId) {
    return '$tenantId/work-orders/$workOrderId/proposals/$photoId.jpg';
  }

  /// Comprobante de una compra recibida (US34 E2): se sube en línea, no por la cola.
  static String purchaseReceipt(
    String tenantId,
    String purchaseOrderId,
    String photoId,
  ) {
    return '$tenantId/purchase-orders/$purchaseOrderId/receipt/$photoId.jpg';
  }
}
