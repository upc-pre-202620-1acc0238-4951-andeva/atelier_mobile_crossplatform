import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_repository.dart';

/// Colaboradores activos de la sede. Sin `iam:members:read`, lista vacía y la tarea se crea sin
/// mecánico (H11). En línea.
class GetBranchMechanicsUseCase {
  final WorkOrderRepository repository;

  const GetBranchMechanicsUseCase({required this.repository});

  Future<List<MechanicOption>> execute() {
    return repository.getBranchMechanics();
  }
}
