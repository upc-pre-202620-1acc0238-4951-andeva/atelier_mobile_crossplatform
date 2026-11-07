import 'package:decimal/decimal.dart';

/// `CreateWorkOrderResource`.
class CreateWorkOrderRequestDto {
  final String vehicleId;
  final String customerId;
  final String branchId;
  final int mileageIn;
  final String? diagnosticSummary;
  final String? appointmentId;

  const CreateWorkOrderRequestDto({
    required this.vehicleId,
    required this.customerId,
    required this.branchId,
    required this.mileageIn,
    this.diagnosticSummary,
    this.appointmentId,
  });

  Map<String, dynamic> toJson() => {
    'vehicleId': vehicleId,
    'customerId': customerId,
    'branchId': branchId,
    'mileageIn': mileageIn,
    if (diagnosticSummary != null) 'diagnosticSummary': diagnosticSummary,
    if (appointmentId != null) 'appointmentId': appointmentId,
  };
}

/// `UpdateWorkOrderResource`.
class UpdateWorkOrderRequestDto {
  final int? mileageIn;
  final String? diagnosticSummary;

  const UpdateWorkOrderRequestDto({this.mileageIn, this.diagnosticSummary});

  Map<String, dynamic> toJson() => {
    if (mileageIn != null) 'mileageIn': mileageIn,
    if (diagnosticSummary != null) 'diagnosticSummary': diagnosticSummary,
  };
}

/// `CreateWorkOrderTaskResource`; `mechanicId` es el membershipId.
class CreateWorkOrderTaskRequestDto {
  final String serviceId;
  final String description;
  final String? mechanicId;
  final Decimal? price;

  const CreateWorkOrderTaskRequestDto({
    required this.serviceId,
    required this.description,
    this.mechanicId,
    this.price,
  });

  Map<String, dynamic> toJson() => {
    'serviceId': serviceId,
    'description': description,
    if (mechanicId != null) 'mechanicId': mechanicId,
    if (price != null) 'price': price!.toDouble(),
  };
}

/// `UpdateWorkOrderTaskResource`.
class UpdateWorkOrderTaskRequestDto {
  final String? description;
  final String? mechanicId;
  final Decimal? price;

  const UpdateWorkOrderTaskRequestDto({
    this.description,
    this.mechanicId,
    this.price,
  });

  Map<String, dynamic> toJson() => {
    if (description != null) 'description': description,
    if (mechanicId != null) 'mechanicId': mechanicId,
    if (price != null) 'price': price!.toDouble(),
  };
}

/// `AttachImageResource` (`ATTACH_INTAKE_IMAGE`).
class AttachImageRequestDto {
  final String imageUrl;
  final String? description;

  const AttachImageRequestDto({required this.imageUrl, this.description});

  Map<String, dynamic> toJson() => {
    'imageUrl': imageUrl,
    if (description != null) 'description': description,
  };
}

/// `SubmitTaskProposalResource` (`SUBMIT_PROPOSAL`): `severity` solo `LOW|MEDIUM|CRITICAL`.
class SubmitProposalRequestDto {
  final String mechanicId;
  final String description;
  final String severity;
  final String imageUrl;
  final String? suggestedServiceId;

  const SubmitProposalRequestDto({
    required this.mechanicId,
    required this.description,
    required this.severity,
    required this.imageUrl,
    this.suggestedServiceId,
  });

  Map<String, dynamic> toJson() => {
    'mechanicId': mechanicId,
    'description': description,
    'severity': severity,
    'imageUrl': imageUrl,
    if (suggestedServiceId != null) 'suggestedServiceId': suggestedServiceId,
  };
}

/// `ApproveTaskProposalResource`.
class ApproveProposalRequestDto {
  final String serviceId;
  final Decimal finalPrice;
  final Decimal laborHours;
  final String? mechanicId;
  final String? notes;

  const ApproveProposalRequestDto({
    required this.serviceId,
    required this.finalPrice,
    required this.laborHours,
    this.mechanicId,
    this.notes,
  });

  Map<String, dynamic> toJson() => {
    'serviceId': serviceId,
    'finalPrice': finalPrice.toDouble(),
    'laborHours': laborHours.toDouble(),
    if (mechanicId != null) 'mechanicId': mechanicId,
    if (notes != null) 'notes': notes,
  };
}

/// `RejectTaskProposalResource`.
class RejectProposalRequestDto {
  final String customerNotes;

  const RejectProposalRequestDto({required this.customerNotes});

  Map<String, dynamic> toJson() => {'customerNotes': customerNotes};
}

/// `CancelWorkOrderResource`: motivo de rechazo de la proforma y de cancelación de la orden.
class ReasonRequestDto {
  final String reason;

  const ReasonRequestDto({required this.reason});

  Map<String, dynamic> toJson() => {'reason': reason};
}
