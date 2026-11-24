import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/register_company_customer_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/register_individual_customer_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/register_vehicle_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/invalid_reception_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_validation.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/reception_errors.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/register/register_customer_ui_state.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/foundation.dart';

/// Alta presencial de cliente y vehículo (US11 E2, US44 E2). En línea: sin red falla y no se encola.
class RegisterCustomerViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final RegisterIndividualCustomerUseCase registerIndividual;
  final RegisterCompanyCustomerUseCase registerCompany;
  final RegisterVehicleUseCase registerVehicle;
  final ConnectivityObserver? connectivity;

  RegisterCustomerViewModel({
    required this.observeSession,
    required this.registerIndividual,
    required this.registerCompany,
    required this.registerVehicle,
    RegisterCustomerArgs? args,
    this.connectivity,
  }) {
    _state = RegisterCustomerUiState(
      email: args?.email ?? '',
      plate: args?.plate ?? '',
      registeredCustomerId: args?.customerId,
      presetCustomerName: args?.customerName,
    );
    final online = connectivity;
    if (online != null) {
      _state = _state.copyWith(isOnline: online.isOnline);
      online.addListener(_onConnectivity);
    }
    _subscription = observeSession.execute().listen((session) {
      final onlyVehicle = _state.registeredCustomerId != null;
      final allowed = onlyVehicle
          ? session?.has(Permission.vehiclesCreate) == true
          : session?.has(Permission.customersCreate) == true && session?.has(Permission.vehiclesCreate) == true;
      _update(_state.copyWith(canRegister: allowed));
    });
  }

  late RegisterCustomerUiState _state;
  RegisterCustomerUiState get state => _state;

  StreamSubscription<Object?>? _subscription;
  bool _disposed = false;

  void _onConnectivity() => _update(_state.copyWith(isOnline: connectivity?.isOnline ?? true));

  /// Edita un campo mientras no se esté guardando; limpia el error anterior.
  void _edit(RegisterCustomerUiState Function(RegisterCustomerUiState state) change) {
    if (_state.isSaving) return;
    _update(change(_state).copyWith(clearError: true, clearInvalidField: true));
  }

  /// El tipo de cliente no cambia una vez creado el cliente.
  void onKindChange(CustomerType kind) => _edit((s) => s.customerLocked ? s : s.copyWith(kind: kind));

  void onFirstNameChange(String value) => _edit((s) => s.customerLocked ? s : s.copyWith(firstName: value));
  void onLastNameChange(String value) => _edit((s) => s.customerLocked ? s : s.copyWith(lastName: value));
  void onCompanyNameChange(String value) => _edit((s) => s.customerLocked ? s : s.copyWith(companyName: value));
  void onTaxIdChange(String value) => _edit((s) => s.customerLocked ? s : s.copyWith(taxId: value));
  void onEmailChange(String value) => _edit((s) => s.customerLocked ? s : s.copyWith(email: value));
  void onPhoneChange(String value) => _edit((s) => s.customerLocked ? s : s.copyWith(phone: value));
  void onPlateChange(String value) => _edit((s) => s.copyWith(plate: value));
  void onBrandChange(String value) => _edit((s) => s.copyWith(brand: value));
  void onModelChange(String value) => _edit((s) => s.copyWith(model: value));
  void onEngineTypeChange(EngineType value) => _edit((s) => s.copyWith(engineType: value));
  void onVinChange(String value) => _edit((s) => s.copyWith(vin: value));
  void onYearChange(String value) => _edit((s) => s.copyWith(year: value.replaceAll(RegExp(r'[^0-9]'), '')));

  Future<void> onSubmit() async {
    final state = _state;
    if (!state.canSubmit) return;
    // Se valida antes de crear al cliente: un año inválido no debe dejarlo guardado sin vehículo.
    final year = int.tryParse(state.year);
    if (state.year.trim().isNotEmpty && !ReceptionValidation.isOptionalYear(year)) {
      _fail(const InvalidReceptionInputException('year'));
      return;
    }
    _update(_state.copyWith(isSaving: true, clearError: true, clearInvalidField: true));
    try {
      final customerId = state.registeredCustomerId ?? await _createCustomer(state);
      if (customerId == null) return;
      final vin = state.vin.trim();
      final vehicle = await registerVehicle.execute(
        NewVehicle(
          plate: state.plate,
          brand: state.brand.trim(),
          model: state.model.trim(),
          engineType: state.engineType,
          customerId: customerId,
          vin: vin.isEmpty ? null : vin,
          year: year,
        ),
      );
      _update(_state.copyWith(isSaving: false, registeredVehicleId: vehicle.id, done: true));
    } on Object catch (e) {
      _fail(e);
    }
  }

  /// Crea al cliente y lo recuerda en el estado; `null` si falló (el error ya quedó en pantalla).
  Future<String?> _createCustomer(RegisterCustomerUiState state) async {
    final email = state.email.trim();
    final phone = state.phone.trim();
    try {
      final Customer customer = switch (state.kind) {
        CustomerType.individual => await registerIndividual.execute(
          NewIndividualCustomer(
            firstName: state.firstName.trim(),
            lastName: state.lastName.trim(),
            taxId: state.taxId.trim(),
            email: email.isEmpty ? null : email,
            phone: phone.isEmpty ? null : phone,
          ),
        ),
        CustomerType.company => await registerCompany.execute(
          NewCompanyCustomer(
            companyName: state.companyName.trim(),
            taxId: state.taxId.trim(),
            email: email.isEmpty ? null : email,
            phone: phone.isEmpty ? null : phone,
          ),
        ),
      };
      _update(_state.copyWith(registeredCustomerId: customer.id));
      return customer.id;
    } on Object catch (e) {
      _fail(e);
      return null;
    }
  }

  void _fail(Object error) {
    final field = invalidReceptionField(error);
    _update(
      _state.copyWith(
        isSaving: false,
        error: toReceptionUiText(error),
        invalidField: field,
        clearInvalidField: field == null,
      ),
    );
  }

  void _update(RegisterCustomerUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    connectivity?.removeListener(_onConnectivity);
    _subscription?.cancel();
    super.dispose();
  }
}
