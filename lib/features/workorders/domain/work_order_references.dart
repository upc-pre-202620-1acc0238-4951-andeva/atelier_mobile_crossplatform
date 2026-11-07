import 'package:atelier_mobile_crossplatform/core/domain/money.dart';
import 'package:decimal/decimal.dart';

/// Servicio del catálogo del taller (`ServiceResource`): da nombre a tareas y propuestas (H11).
class ServiceOption {
  final String id;
  final String name;
  final Money? basePrice;
  final int? estimatedMinutes;

  const ServiceOption({
    required this.id,
    required this.name,
    this.basePrice,
    this.estimatedMinutes,
  });
}

/// Colaborador de la sede para asignar una tarea (`EmployeeProfileResource`). No hay endpoint con
/// nombres (H11): se identifica por [jobTitle]. [membershipId] es el `mechanicId` del backend.
class MechanicOption {
  final String membershipId;
  final String? jobTitle;
  final String? employmentStatus;

  const MechanicOption({
    required this.membershipId,
    this.jobTitle,
    this.employmentStatus,
  });
}

/// Nueva tarea en la orden (US12 E2, US22 E1). Precio sin IGV.
class NewWorkOrderTask {
  final String serviceId;
  final String description;
  final String? mechanicId;
  final Decimal? price;

  const NewWorkOrderTask({
    required this.serviceId,
    required this.description,
    this.mechanicId,
    this.price,
  });
}

/// Cambios de una tarea (US22 E2); lo que va en `null` no cambia.
class WorkOrderTaskChanges {
  final String? description;
  final String? mechanicId;
  final Decimal? price;

  const WorkOrderTaskChanges({this.description, this.mechanicId, this.price});
}
