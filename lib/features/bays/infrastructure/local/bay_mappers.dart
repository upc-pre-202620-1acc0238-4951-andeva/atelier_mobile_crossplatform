import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/work_bay.dart';
import 'package:atelier_mobile_crossplatform/features/bays/infrastructure/remote/work_bay_dto.dart';
import 'package:drift/drift.dart';

/// Alcance de `cache_metadata` del tablero, compartido con `tasks` (06 §4).
String bayCacheScope(String branchId) => 'bays:$branchId';

extension WorkBayDtoMapper on WorkBayDto {
  /// [fallbackBranchId] es la sede consultada, por si el backend no la envía.
  BaysCompanion toCompanion(String fallbackBranchId, int syncedAt) {
    return BaysCompanion(
      id: Value(id),
      branchId: Value(branchId ?? fallbackBranchId),
      name: Value(name ?? ''),
      bayType: Value(bayType ?? ''),
      status: Value(status ?? ''),
      currentWorkOrderId: Value(currentWorkOrderId),
      syncedAt: Value(syncedAt),
    );
  }
}

extension BayEntityMapper on BayEntity {
  WorkBay toDomain() {
    return WorkBay(
      id: id,
      branchId: branchId,
      name: name,
      type: BayType.fromString(bayType),
      status: BayStatus.fromString(status),
      currentWorkOrderId: currentWorkOrderId,
    );
  }
}
