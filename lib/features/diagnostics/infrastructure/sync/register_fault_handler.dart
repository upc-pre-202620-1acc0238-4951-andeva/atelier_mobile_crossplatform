import 'dart:convert';

import 'package:atelier_mobile_crossplatform/core/data/local/app_database.dart';
import 'package:atelier_mobile_crossplatform/core/data/sync/operation_handler.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/vehicle_fault.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/diagnostics_mappers.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/local/vehicle_fault_dao.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/remote/iot_api.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/infrastructure/remote/iot_dtos.dart';
import 'package:drift/drift.dart';

/// `REGISTER_FAULT` (06 §3 y §6): si el vehículo ya tiene ese DTC activo el backend devuelve esa falla (R3). Al
/// aplicarse, la fila `local-{id de la operación}` pasa a tener el id real; si se borró en el auto mientras se
/// enviaba, conserva la marca de resuelta para que su `RESOLVE_FAULT` la cierre.
class RegisterFaultHandler implements OperationHandler {
  static const type = 'REGISTER_FAULT';

  final IotApi api;
  final VehicleFaultDao dao;
  final DateTime Function() now;

  const RegisterFaultHandler({
    required this.api,
    required this.dao,
    this.now = DateTime.now,
  });

  @override
  Future<OperationResult> send(PendingOperationEntity operation) {
    final body = RegisterFaultRequestDto.fromJson(
      jsonDecode(operation.payload) as Map<String, dynamic>,
    );
    return OperationResult.from(() async {
      final dto = await api.registerFault(body);
      final localId = '${VehicleFault.localPrefix}${operation.id}';
      final local = await dao.findById(localId);
      final saved = dto.toEntity(
        body.vehicleId,
        now().millisecondsSinceEpoch,
      );
      await dao.replaceLocal(
        localId,
        local?.isResolved == true
            ? saved.copyWith(
                isResolved: true,
                resolvedAt: Value(local?.resolvedAt),
              )
            : saved,
      );
    });
  }
}
