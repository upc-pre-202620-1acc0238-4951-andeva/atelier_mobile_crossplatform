import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/workorders/domain/work_order_references.dart';

/// Nivel de combustible al recibir el vehículo. El backend no tiene un campo para él (docs/api/operations.md):
/// se guarda al inicio del diagnóstico con [summaryLabel] (hueco registrado en docs/03-traceability.md).
enum FuelLevel {
  reserve('Reserva'),
  quarter('1/4'),
  half('1/2'),
  threeQuarters('3/4'),
  full('Lleno');

  final String summaryLabel;
  const FuelLevel(this.summaryLabel);
}

class OpenWorkOrderUiState {
  final String mileage;
  final FuelLevel? fuel;
  final String reason;
  final List<ServiceOption> services;
  final List<MechanicOption> mechanics;
  final bool isLoadingCatalog;
  final Set<String> selectedServiceIds;
  final String? selectedMechanicId;

  /// Orden en borrador que se completa (llegó por una cita) o la que se acaba de abrir aquí.
  final String? workOrderId;

  /// La orden ya quedó guardada: al reintentar solo se agregan las faenas que faltan.
  final bool orderSaved;
  final Set<String> addedServiceIds;
  final bool isSaving;
  final UiText? error;

  /// Campo que no pasó la validación local (`mileageIn`, `diagnosticSummary`, `description`).
  final String? invalidField;

  /// Id de la orden lista, para seguir con las fotos de recepción.
  final String? doneWorkOrderId;
  final bool canCreate;
  final bool canUpdate;
  final bool isOnline;

  const OpenWorkOrderUiState({
    this.mileage = '',
    this.fuel,
    this.reason = '',
    this.services = const [],
    this.mechanics = const [],
    this.isLoadingCatalog = true,
    this.selectedServiceIds = const {},
    this.selectedMechanicId,
    this.workOrderId,
    this.orderSaved = false,
    this.addedServiceIds = const {},
    this.isSaving = false,
    this.error,
    this.invalidField,
    this.doneWorkOrderId,
    this.canCreate = false,
    this.canUpdate = false,
    this.isOnline = true,
  });

  /// Completar un borrador existente es una actualización; abrir una nueva es un alta.
  bool get isCompletingDraft => workOrderId != null && !orderSaved;
  bool get formLocked => isSaving || orderSaved;
  bool get hasPermission => canCreate && (!isCompletingDraft || canUpdate);
  bool get canSubmit =>
      hasPermission &&
      isOnline &&
      !isSaving &&
      doneWorkOrderId == null &&
      !isLoadingCatalog &&
      mileage.trim().isNotEmpty &&
      fuel != null &&
      reason.trim().isNotEmpty;
  List<ServiceOption> get pendingServices => [
    for (final service in services)
      if (selectedServiceIds.contains(service.id) && !addedServiceIds.contains(service.id)) service,
  ];

  OpenWorkOrderUiState copyWith({
    String? mileage,
    FuelLevel? fuel,
    String? reason,
    List<ServiceOption>? services,
    List<MechanicOption>? mechanics,
    bool? isLoadingCatalog,
    Set<String>? selectedServiceIds,
    String? selectedMechanicId,
    bool clearSelectedMechanic = false,
    String? workOrderId,
    bool? orderSaved,
    Set<String>? addedServiceIds,
    bool? isSaving,
    UiText? error,
    bool clearError = false,
    String? invalidField,
    bool clearInvalidField = false,
    String? doneWorkOrderId,
    bool? canCreate,
    bool? canUpdate,
    bool? isOnline,
  }) {
    return OpenWorkOrderUiState(
      mileage: mileage ?? this.mileage,
      fuel: fuel ?? this.fuel,
      reason: reason ?? this.reason,
      services: services ?? this.services,
      mechanics: mechanics ?? this.mechanics,
      isLoadingCatalog: isLoadingCatalog ?? this.isLoadingCatalog,
      selectedServiceIds: selectedServiceIds ?? this.selectedServiceIds,
      selectedMechanicId: clearSelectedMechanic ? null : selectedMechanicId ?? this.selectedMechanicId,
      workOrderId: workOrderId ?? this.workOrderId,
      orderSaved: orderSaved ?? this.orderSaved,
      addedServiceIds: addedServiceIds ?? this.addedServiceIds,
      isSaving: isSaving ?? this.isSaving,
      error: clearError ? null : error ?? this.error,
      invalidField: clearInvalidField ? null : invalidField ?? this.invalidField,
      doneWorkOrderId: doneWorkOrderId ?? this.doneWorkOrderId,
      canCreate: canCreate ?? this.canCreate,
      canUpdate: canUpdate ?? this.canUpdate,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
