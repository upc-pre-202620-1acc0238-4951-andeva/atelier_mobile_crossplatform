/// `CreateWorkBayResource` (docs/api/operations.md).
class CreateWorkBayRequestDto {
  final String branchId;
  final String name;
  final String bayType;

  const CreateWorkBayRequestDto({required this.branchId, required this.name, required this.bayType});

  Map<String, dynamic> toJson() => {'branchId': branchId, 'name': name, 'bayType': bayType};
}

/// `MaintenanceBayResource`.
class MaintenanceBayRequestDto {
  final String reason;

  const MaintenanceBayRequestDto({required this.reason});

  Map<String, dynamic> toJson() => {'reason': reason};
}

/// `AssignWorkBayResource` (docs/api/operations.md).
class AssignWorkBayRequestDto {
  final String bayId;

  const AssignWorkBayRequestDto({required this.bayId});

  Map<String, dynamic> toJson() => {'bayId': bayId};
}

/// `AssignTaskMechanicResource`: [mechanicId] es el membershipId (H11).
class AssignTaskMechanicRequestDto {
  final String mechanicId;

  const AssignTaskMechanicRequestDto({required this.mechanicId});

  Map<String, dynamic> toJson() => {'mechanicId': mechanicId};
}
