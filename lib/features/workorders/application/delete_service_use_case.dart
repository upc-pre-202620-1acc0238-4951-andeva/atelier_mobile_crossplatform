import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// Elimina un servicio del catálogo del taller si no está asociado a tareas existentes
/// (`operations:services:manage`). En línea.
class DeleteServiceUseCase {
  final WorkOrderRepository repository;

  const DeleteServiceUseCase({required this.repository});

  Future<void> execute(String serviceId) {
    return repository.deleteService(serviceId);
  }
}
