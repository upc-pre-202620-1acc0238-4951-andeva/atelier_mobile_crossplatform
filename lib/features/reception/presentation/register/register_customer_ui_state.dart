import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';

class RegisterCustomerUiState {
  final CustomerType kind;
  final String firstName;
  final String lastName;
  final String companyName;
  final String taxId;
  final String email;
  final String phone;
  final String plate;
  final String brand;
  final String model;
  final EngineType engineType;
  final String vin;
  final String year;
  final bool isSaving;

  /// El cliente ya se creó pero el vehículo falló, o se abrió desde un cliente existente: solo se registra el vehículo.
  final String? registeredCustomerId;
  final String? presetCustomerName;
  final String? registeredVehicleId;
  final UiText? error;
  final String? invalidField;
  final bool done;
  final bool canRegister;
  final bool isOnline;

  const RegisterCustomerUiState({
    this.kind = CustomerType.individual,
    this.firstName = '',
    this.lastName = '',
    this.companyName = '',
    this.taxId = '',
    this.email = '',
    this.phone = '',
    this.plate = '',
    this.brand = '',
    this.model = '',
    this.engineType = EngineType.gasoline,
    this.vin = '',
    this.year = '',
    this.isSaving = false,
    this.registeredCustomerId,
    this.presetCustomerName,
    this.registeredVehicleId,
    this.error,
    this.invalidField,
    this.done = false,
    this.canRegister = false,
    this.isOnline = true,
  });

  bool get customerLocked => registeredCustomerId != null;

  bool get hasCustomerData =>
      customerLocked ||
      (taxId.trim().isNotEmpty &&
          switch (kind) {
            CustomerType.individual => firstName.trim().isNotEmpty && lastName.trim().isNotEmpty,
            CustomerType.company => companyName.trim().isNotEmpty,
          });

  bool get canSubmit =>
      isOnline &&
      canRegister &&
      !isSaving &&
      !done &&
      hasCustomerData &&
      plate.trim().isNotEmpty &&
      brand.trim().isNotEmpty &&
      model.trim().isNotEmpty;

  RegisterCustomerUiState copyWith({
    CustomerType? kind,
    String? firstName,
    String? lastName,
    String? companyName,
    String? taxId,
    String? email,
    String? phone,
    String? plate,
    String? brand,
    String? model,
    EngineType? engineType,
    String? vin,
    String? year,
    bool? isSaving,
    String? registeredCustomerId,
    String? registeredVehicleId,
    UiText? error,
    bool clearError = false,
    String? invalidField,
    bool clearInvalidField = false,
    bool? done,
    bool? canRegister,
    bool? isOnline,
  }) {
    return RegisterCustomerUiState(
      kind: kind ?? this.kind,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      companyName: companyName ?? this.companyName,
      taxId: taxId ?? this.taxId,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      plate: plate ?? this.plate,
      brand: brand ?? this.brand,
      model: model ?? this.model,
      engineType: engineType ?? this.engineType,
      vin: vin ?? this.vin,
      year: year ?? this.year,
      isSaving: isSaving ?? this.isSaving,
      registeredCustomerId: registeredCustomerId ?? this.registeredCustomerId,
      presetCustomerName: presetCustomerName,
      registeredVehicleId: registeredVehicleId ?? this.registeredVehicleId,
      error: clearError ? null : error ?? this.error,
      invalidField: clearInvalidField ? null : invalidField ?? this.invalidField,
      done: done ?? this.done,
      canRegister: canRegister ?? this.canRegister,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
