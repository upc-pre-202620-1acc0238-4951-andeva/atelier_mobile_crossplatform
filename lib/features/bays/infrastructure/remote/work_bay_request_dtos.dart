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
