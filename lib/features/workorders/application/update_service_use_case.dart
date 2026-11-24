import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/invalid_work_order_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_validation.dart';
import 'package:decimal/decimal.dart';

/// Actualiza un servicio estándar del catálogo del taller (`operations:services:manage`). En línea.
class UpdateServiceUseCase {
  final WorkOrderRepository repository;

  const UpdateServiceUseCase({required this.repository});

  Future<ServiceOption> execute(
    String serviceId, {
    required String name,
    required Decimal basePrice,
    required int estimatedMinutes,
    String currency = Money.pen,
  }) {
    final trimmed = name.trim();
    if (!WorkOrderValidation.isRequiredText(
      trimmed,
      WorkOrderValidation.serviceNameMax,
    )) {
      throw const InvalidWorkOrderInputException('name');
    }
    if (basePrice <= Decimal.zero) {
      throw const InvalidWorkOrderInputException('basePrice');
    }
    if (estimatedMinutes <= 0) {
      throw const InvalidWorkOrderInputException('estimatedMinutes');
    }
    return repository.updateService(
      serviceId,
      name: trimmed,
      basePrice: basePrice,
      estimatedMinutes: estimatedMinutes,
      currency: currency,
    );
  }
}
