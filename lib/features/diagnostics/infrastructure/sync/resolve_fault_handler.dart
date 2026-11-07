import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/dtc.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/vehicle_fault.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/diagnostics_mappers.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/vehicle_fault_dao.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/remote/iot_api.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/remote/iot_dtos.dart';

/// `RESOLVE_FAULT` (06 §3): resolver dos veces responde 200. Si la falla se borró mientras su `REGISTER_FAULT`
/// se enviaba, el payload trae el id `local-…` y la operación depende de ese registro: el id real se busca entre
/// las fallas activas del vehículo; si ya no está activa, no hay nada que resolver.
class ResolveFaultHandler implements OperationHandler {
  static const type = 'RESOLVE_FAULT';

  final IotApi api;
  final VehicleFaultDao dao;
  final DateTime Function() now;

  const ResolveFaultHandler({
    required this.api,
    required this.dao,
    this.now = DateTime.now,
  });

  @override
  Future<OperationResult> send(PendingOperationEntity operation) {
    final payload = ResolveFaultPayload.fromJson(
      jsonDecode(operation.payload) as Map<String, dynamic>,
    );
    return OperationResult.from(() async {
      final faultId = await _realId(payload);
      if (faultId == null) return;
      final dto = await api.resolveFault(faultId);
      await dao.upsert(
        dto.toEntity(payload.vehicleId, now().millisecondsSinceEpoch),
      );
    });
  }

  Future<String?> _realId(ResolveFaultPayload payload) async {
    if (!VehicleFault.isLocalId(payload.faultId)) return payload.faultId;
    final active = await api.getActiveFaults(payload.vehicleId);
    for (final fault in active) {
      if (Dtc.normalize(fault.dtcCode ?? '') == payload.dtcCode) return fault.id;
    }
    return null;
  }
}
