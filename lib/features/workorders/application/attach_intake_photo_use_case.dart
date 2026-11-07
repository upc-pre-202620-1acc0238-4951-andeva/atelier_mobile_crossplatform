import 'package:atelier_mobile_crossplatform/features/workorders/domain/invalid_work_order_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_id.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_validation.dart';

import 'dart:io';

/// Foto de un panel en la inspección de recepción con la descripción del daño (US13 E1). Funciona sin
/// red: se encola y aparece en `ObservePendingIntakePhotosUseCase` hasta registrarse.
class AttachIntakePhotoUseCase {
  final WorkOrderRepository repository;

  const AttachIntakePhotoUseCase({required this.repository});

  Future<void> execute(
    WorkOrderId id,
    File photo, {
    String? description,
  }) async {
    if (!WorkOrderValidation.isOptionalText(
      description,
      WorkOrderValidation.photoDescriptionMax,
    )) {
      throw const InvalidWorkOrderInputException('description');
    }
    return repository.attachIntakePhoto(id, photo, description: description);
  }
}
