import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/invalid_work_order_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_validation.dart';
import 'package:decimal/decimal.dart';

/// Registra un servicio estándar en el catálogo del taller (`operations:services:manage`). En línea.
class CreateServiceUseCase {
  final WorkOrderRepository repository;

  const CreateServiceUseCase({required this.repository});

  Future<ServiceOption> execute({
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
    return repository.createService(
      name: trimmed,
      basePrice: basePrice,
      estimatedMinutes: estimatedMinutes,
      currency: currency,
    );
  }
}
