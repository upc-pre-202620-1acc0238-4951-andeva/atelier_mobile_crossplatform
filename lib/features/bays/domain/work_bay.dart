/// `BayStatus` de docs/api/README.md §8.
enum BayStatus {
  available('AVAILABLE'),
  occupied('OCCUPIED'),
  maintenance('MAINTENANCE');

  final String value;
  const BayStatus(this.value);

  static BayStatus? fromString(String? raw) {
    for (final status in values) {
      if (status.value == raw) return status;
    }
    return null;
  }
}

/// `BayType` de docs/api/README.md §8. Solo se muestra: la API no dice qué servicios admite (H25).
enum BayType {
  lift('LIFT'),
  paintBooth('PAINT_BOOTH'),
  washing('WASHING'),
  alignment('ALIGNMENT'),
  mechanicalLift('MECHANICAL_LIFT'),
  washBay('WASH_BAY'),
  diagnosticPit('DIAGNOSTIC_PIT'),
  alignmentStation('ALIGNMENT_STATION');

  final String value;
  const BayType(this.value);

  static BayType? fromString(String? raw) {
    for (final type in values) {
      if (type.value == raw) return type;
    }
    return null;
  }
}

/// Bahía de la sede (`WorkBayResource`, caché `bays`). Un tipo o estado desconocido llega en `null`.
class WorkBay {
  final String id;
  final String branchId;
  final String name;
  final BayType? type;
  final BayStatus? status;
  final String? currentWorkOrderId;

  const WorkBay({
    required this.id,
    required this.branchId,
    required this.name,
    this.type,
    this.status,
    this.currentWorkOrderId,
  });

  /// Solo una bahía libre recibe una orden (US40 E2). El tipo no se filtra (H25).
  bool get canReceive => status == BayStatus.available;
}
