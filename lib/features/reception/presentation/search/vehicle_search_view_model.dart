import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/core/domain/network_exception.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/cancel_appointment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/confirm_appointment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/create_appointment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/find_vehicle_by_plate_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/get_customer_vehicles_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/mark_appointment_arrived_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_appointments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_customers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/observe_workshop_vehicles_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/refresh_appointments_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/refresh_customers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/reschedule_appointment_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/search_customers_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/application/update_customer_contact_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/invalid_reception_input_exception.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/reception_validation.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/reception_errors.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/search/vehicle_search_ui_state.dart';
import 'package:flutter/foundation.dart';

/// US11: buscar la unidad por placa o el cliente por documento, atender/agendar citas del día y editar contacto.
class VehicleSearchViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final FindVehicleByPlateUseCase findVehicleByPlate;
  final SearchCustomersUseCase searchCustomers;
  final GetCustomerVehiclesUseCase getCustomerVehicles;
  final RefreshAppointmentsUseCase refreshAppointments;
  final ObserveAppointmentsUseCase observeAppointments;
  final MarkAppointmentArrivedUseCase markArrived;
  final RefreshCustomersUseCase? refreshCustomers;
  final ObserveCustomersUseCase? observeCustomers;
  final ObserveWorkshopVehiclesUseCase? observeWorkshopVehicles;
  final ConnectivityObserver? connectivity;
  final CreateAppointmentUseCase? createAppointment;
  final ConfirmAppointmentUseCase? confirmAppointment;
  final RescheduleAppointmentUseCase? rescheduleAppointment;
  final CancelAppointmentUseCase? cancelAppointment;
  final UpdateCustomerContactUseCase? updateCustomerContact;
  final BusinessTime time;

  VehicleSearchViewModel({
    required this.observeSession,
    required this.findVehicleByPlate,
    required this.searchCustomers,
    required this.getCustomerVehicles,
    required this.refreshAppointments,
    required this.observeAppointments,
    required this.markArrived,
    this.refreshCustomers,
    this.observeCustomers,
    this.observeWorkshopVehicles,
    this.connectivity,
    this.createAppointment,
    this.confirmAppointment,
    this.rescheduleAppointment,
    this.cancelAppointment,
    this.updateCustomerContact,
    this.time = const BusinessTime(),
  }) {
    _today = time.today();
    final online = connectivity;
    if (online != null) {
      _state = _state.copyWith(isOnline: online.isOnline);
      online.addListener(_onConnectivity);
    }
    _subscriptions.add(observeSession.execute().listen(_onSession));
    _watchAppointments(AppointmentRange.today);
    final customersSource = observeCustomers;
    if (customersSource != null) {
      _subscriptions.add(
        customersSource.execute().listen((list) {
          final selected = _state.selectedCustomer;
          Customer? refreshedSelected;
          if (selected != null) {
            refreshedSelected = list.where((c) => c.id == selected.id).firstOrNull ?? selected;
          }
          _update(_state.copyWith(portfolioCustomers: list, selectedCustomer: refreshedSelected));
        }),
      );
    }
    final vehiclesSource = observeWorkshopVehicles;
    if (vehiclesSource != null) {
      _subscriptions.add(vehiclesSource.execute().listen(_onWorkshopVehicles));
    }
  }

  late final String _today;
  VehicleSearchUiState _state = const VehicleSearchUiState();
  VehicleSearchUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  StreamSubscription<Object?>? _appointmentsSubscription;
  String? _lastAgendaBranchId = '__none__';
  bool _portfolioRequested = false;
  bool _disposed = false;

  void _onConnectivity() => _update(_state.copyWith(isOnline: connectivity?.isOnline ?? true));

  void _onSession(Session? session) {
    final canViewAppointments = session?.has(Permission.appointmentsRead) == true;
    final canReadCustomers = session?.has(Permission.customersRead) == true;
    final canCreateVehicles = session?.has(Permission.vehiclesCreate) == true;
    final String branchKey = session?.branchId ?? '';
    _update(
      _state.copyWith(
        canSearch: session?.has(Permission.vehiclesRead) == true && canReadCustomers,
        canReadCustomers: canReadCustomers,
        canUpdateCustomer: session?.has(Permission.customersUpdate) == true,
        canViewAppointments: canViewAppointments,
        canCreateAppointments: session?.has(Permission.appointmentsCreate) == true,
        canMarkArrival: session?.has(Permission.appointmentsUpdate) == true,
        canRegister: session?.has(Permission.customersCreate) == true && canCreateVehicles,
        canCreateVehicles: canCreateVehicles,
        canOpenWorkOrder: session?.has(Permission.workOrdersCreate) == true,
      ),
    );
    if (canViewAppointments && _lastAgendaBranchId != branchKey) {
      _lastAgendaBranchId = branchKey;
      refresh();
    }
    if (canReadCustomers && !_portfolioRequested) {
      _portfolioRequested = true;
      refreshCustomerPortfolio(force: false);
    }
  }

  void _onWorkshopVehicles(List<VehicleWithOwner> vehicles) {
    final state = _state;
    VehicleWithOwner? autoMatched;
    if (state.searched &&
        state.mode == SearchMode.plate &&
        state.vehicleResult == null &&
        state.query.trim().isNotEmpty) {
      String? normalized;
      try {
        normalized = ReceptionValidation.normalizePlate(state.query);
      } on Object {
        normalized = null;
      }
      autoMatched = vehicles
          .where((item) => normalized != null && item.vehicle.plate.toLowerCase() == normalized.toLowerCase())
          .firstOrNull;
    } else {
      final current = state.vehicleResult;
      if (current != null) {
        autoMatched = vehicles.where((item) => item.vehicle.id == current.vehicle.id).firstOrNull ?? current;
      }
    }
    var updatedCustomerVehicles = state.customerVehicles;
    final selected = state.selectedCustomer;
    if (selected != null) {
      final fromCache = vehicles
          .where((item) => item.vehicle.currentOwnerId == selected.id)
          .map((item) => item.vehicle)
          .toList();
      if (fromCache.length > state.customerVehicles.length) updatedCustomerVehicles = fromCache;
    }
    _update(
      _state.copyWith(
        workshopVehicles: vehicles,
        vehicleResult: autoMatched,
        customerVehicles: updatedCustomerVehicles,
      ),
    );
  }

  /// Observa la agenda del rango activo; al cambiar de rango cancela la observación anterior (`flatMapLatest`).
  void _watchAppointments(AppointmentRange range) {
    _appointmentsSubscription?.cancel();
    final stream = range == AppointmentRange.today
        ? observeAppointments.execute(_today)
        : observeAppointments.execute(_today, to: range.endDate(_today));
    _appointmentsSubscription = stream.listen((list) => _update(_state.copyWith(appointments: list)));
  }

  void onSectionChange(ReceptionSection section) {
    _update(_state.copyWith(section: section, clearError: true, clearNotice: true));
    if (section == ReceptionSection.customers && _state.portfolioCustomers.isEmpty) {
      refreshCustomerPortfolio(force: true);
    }
  }

  void onCustomerFilterQueryChange(String query) => _update(_state.copyWith(customerFilterQuery: query));

  void onCustomerFilterTypeChange(CustomerType? type) {
    _update(
      _state.customerFilterType == type
          ? _state.copyWith(clearCustomerFilterType: true)
          : _state.copyWith(customerFilterType: type),
    );
  }

  void onVehicleFilterQueryChange(String query) {
    _update(_state.copyWith(vehicleFilterQuery: query, clearError: true));
  }

  void onDirectoryFilterChange(String query) {
    if (_state.section == ReceptionSection.vehicles) {
      onVehicleFilterQueryChange(query);
    } else {
      onCustomerFilterQueryChange(query);
    }
  }

  Future<void> refreshPortfolio() => refreshCustomerPortfolio(force: true);

  /// Busca una placa desde la pestaña de Vehículos si aún no estaba en la caché local.
  Future<void> onLookupVehicleFromFilter() async {
    final rawPlate = _state.vehicleFilterQuery.trim();
    if (rawPlate.isEmpty || _state.isSearching) return;
    _update(_state.copyWith(isSearching: true, clearError: true));
    try {
      final found = await findVehicleByPlate.execute(rawPlate);
      _update(_state.copyWith(isSearching: false, vehicleResult: found));
    } on Object catch (e) {
      _failSearch(e);
    }
  }

  /// Recarga la cartera de clientes del taller (`GET /api/v1/customers`).
  Future<void> refreshCustomerPortfolio({bool force = true}) async {
    final useCase = refreshCustomers;
    if (useCase == null) return;
    if (!_state.canReadCustomers || _state.isRefreshingCustomers) return;
    _update(_state.copyWith(isRefreshingCustomers: true, clearError: true));
    Object? failure;
    try {
      await useCase.execute(force: force);
    } on NetworkException {
      failure = null;
    } on Object catch (e) {
      failure = e;
    }
    _update(
      _state.copyWith(
        isRefreshingCustomers: false,
        error: failure == null ? null : toReceptionUiText(failure),
      ),
    );
  }

  /// Cambia el horizonte de la agenda (Hoy / 7 días / 30 días) y recarga desde el backend.
  Future<void> onAppointmentRangeChange(AppointmentRange range) async {
    if (_state.appointmentRange == range) return;
    _update(_state.copyWith(appointmentRange: range, clearError: true));
    _watchAppointments(range);
    await _refreshRange(force: true);
  }

  /// Recarga la agenda para el rango activo. Sin red se sigue con la caché; sin permiso de lectura no se llama.
  Future<void> refresh() => _refreshRange(force: false);

  Future<void> _refreshRange({required bool force}) async {
    final state = _state;
    if (!state.canViewAppointments || (!force && state.isRefreshingAppointments)) return;
    final range = state.appointmentRange;
    _update(_state.copyWith(isRefreshingAppointments: true));
    Object? failure;
    try {
      if (range == AppointmentRange.today) {
        await refreshAppointments.execute(_today);
      } else {
        await refreshAppointments.execute(_today, to: range.endDate(_today));
      }
    } on NetworkException {
      failure = null;
    } on Object catch (e) {
      failure = e;
    }
    _update(
      _state.copyWith(
        isRefreshingAppointments: false,
        error: failure == null ? null : toReceptionUiText(failure),
      ),
    );
  }

  void onModeChange(SearchMode mode) {
    if (_state.isSearching || _state.mode == mode) return;
    _update(_clearedSearch(_state).copyWith(mode: mode, query: ''));
  }

  void onQueryChange(String value) {
    if (_state.isSearching) return;
    _update(_clearedSearch(_state).copyWith(query: value));
  }

  VehicleSearchUiState _clearedSearch(VehicleSearchUiState state) => state.copyWith(
    searched: false,
    clearVehicleResult: true,
    customers: const [],
    clearSelectedCustomer: true,
    customerVehicles: const [],
    clearError: true,
    clearNotice: true,
  );

  Future<void> onSearch() async {
    final state = _state;
    if (!state.canSubmitSearch) return;
    _update(_clearedSearch(_state).copyWith(isSearching: true, clearArrival: true));
    try {
      switch (state.mode) {
        case SearchMode.plate:
          final found = await findVehicleByPlate.execute(state.query);
          _update(_state.copyWith(isSearching: false, searched: true, vehicleResult: found));
        case SearchMode.document:
          final list = await searchCustomers.execute(state.query.trim());
          _update(_state.copyWith(isSearching: false, searched: true, customers: list));
          if (list.length == 1) onSelectCustomer(list.first);
      }
    } on Object catch (e) {
      _failSearch(e);
    }
  }

  void _failSearch(Object error) {
    _update(_state.copyWith(isSearching: false, error: toReceptionUiText(error)));
  }

  /// Búsqueda por documento o selección en cartera: carga los vehículos del cliente elegido.
  Future<void> onSelectCustomer(Customer customer) async {
    if (_state.isLoadingVehicles) return;
    final cachedVehicles = _state.workshopVehicles
        .where((item) => item.vehicle.currentOwnerId == customer.id)
        .map((item) => item.vehicle)
        .toList();
    _update(
      _state.copyWith(
        selectedCustomer: customer,
        customerVehicles: cachedVehicles,
        isLoadingVehicles: true,
        clearError: true,
        clearNotice: true,
      ),
    );
    try {
      final vehicles = await getCustomerVehicles.execute(customer.id);
      _update(_state.copyWith(isLoadingVehicles: false, customerVehicles: vehicles));
    } on Object catch (e) {
      _update(_state.copyWith(isLoadingVehicles: false, error: toReceptionUiText(e)));
    }
  }

  // --- Hoja de acciones de cita: Confirmar, Llegada (H10), Reprogramar y Cancelar ---

  void onOpenAppointmentActions(String appointmentId) {
    _update(_state.copyWith(actionAppointmentId: appointmentId, clearError: true, clearNotice: true));
  }

  void onDismissAppointmentActions() {
    final state = _state;
    if (state.arrivingId != null || state.updatingAppointmentId != null) return;
    if (state.actionAppointmentId == null) return;
    _update(_state.copyWith(clearActionAppointmentId: true, clearError: true));
  }

  /// `POST /appointments/{id}/arrive` (US11 E1). En línea. La orden en borrador puede tardar (H10).
  Future<void> onMarkArrived(String appointmentId) async {
    final state = _state;
    if (!state.canMarkArrival || state.arrivingId != null || state.updatingAppointmentId != null) return;
    _update(
      _state.copyWith(arrivingId: appointmentId, clearArrival: true, clearError: true, clearNotice: true),
    );
    try {
      final result = await markArrived.execute(appointmentId);
      _update(_state.copyWith(clearArrivingId: true, clearActionAppointmentId: true, arrival: result));
    } on Object catch (e) {
      _update(_state.copyWith(clearArrivingId: true, error: toReceptionUiText(e)));
    }
  }

  /// `POST /appointments/{id}/confirm`. En línea.
  Future<void> onConfirmAppointment(String appointmentId) async {
    final confirm = confirmAppointment;
    if (confirm == null) return;
    final state = _state;
    if (!state.canMarkArrival || !state.isOnline || state.updatingAppointmentId != null) return;
    _update(_state.copyWith(updatingAppointmentId: appointmentId, clearError: true, clearNotice: true));
    try {
      await confirm.execute(appointmentId);
      _update(
        _state.copyWith(
          clearUpdatingAppointmentId: true,
          clearActionAppointmentId: true,
          notice: UiText.resource((s) => s.receptionAppointmentConfirmedNotice),
        ),
      );
    } on Object catch (e) {
      _update(_state.copyWith(clearUpdatingAppointmentId: true, error: toReceptionUiText(e)));
    }
  }

  /// `POST /appointments/{id}/reschedule`. En línea.
  Future<void> onRescheduleAppointment(String appointmentId, String dateText, String timeText) async {
    final reschedule = rescheduleAppointment;
    if (reschedule == null) return;
    final state = _state;
    if (!state.canMarkArrival || !state.isOnline || state.updatingAppointmentId != null) return;
    final newInstant = parseLimaDateTime(dateText, timeText);
    if (newInstant == null) {
      _update(_state.copyWith(error: UiText.resource((s) => s.receptionAppointmentInvalidDatetime)));
      return;
    }
    _update(_state.copyWith(updatingAppointmentId: appointmentId, clearError: true, clearNotice: true));
    try {
      await reschedule.execute(appointmentId, newInstant);
      unawaited(refresh());
      _update(
        _state.copyWith(
          clearUpdatingAppointmentId: true,
          clearActionAppointmentId: true,
          notice: UiText.resource((s) => s.receptionAppointmentRescheduledNotice),
        ),
      );
    } on Object catch (e) {
      _update(_state.copyWith(clearUpdatingAppointmentId: true, error: toReceptionUiText(e)));
    }
  }

  /// `POST /appointments/{id}/cancel`. En línea.
  Future<void> onCancelAppointment(String appointmentId, String reason) async {
    final cancel = cancelAppointment;
    if (cancel == null) return;
    final state = _state;
    if (!state.canMarkArrival || !state.isOnline || state.updatingAppointmentId != null) return;
    _update(_state.copyWith(updatingAppointmentId: appointmentId, clearError: true, clearNotice: true));
    try {
      await cancel.execute(appointmentId, reason);
      _update(
        _state.copyWith(
          clearUpdatingAppointmentId: true,
          clearActionAppointmentId: true,
          notice: UiText.resource((s) => s.receptionAppointmentCanceledNotice),
        ),
      );
    } on Object catch (e) {
      final message = e is InvalidReceptionInputException
          ? UiText.resource((s) => s.receptionAppointmentInvalidCancelReason)
          : toReceptionUiText(e);
      _update(_state.copyWith(clearUpdatingAppointmentId: true, error: message));
    }
  }

  // --- Nueva cita (`POST /appointments`, `APPOINTMENTS_CREATE`) ---

  void onOpenCreateAppointment() {
    final state = _state;
    if (!state.canCreateAppointments || !state.isOnline) return;
    final preselectedCustomer = state.selectedCustomer ?? state.vehicleResult?.owner;
    final preselectedVehicle = state.vehicleResult?.vehicle;
    final List<Vehicle> initialVehicles;
    if (preselectedCustomer != null &&
        preselectedCustomer.id == state.selectedCustomer?.id &&
        state.customerVehicles.isNotEmpty) {
      initialVehicles = state.customerVehicles;
    } else if (preselectedVehicle != null) {
      initialVehicles = [preselectedVehicle];
    } else {
      initialVehicles = const [];
    }
    _update(
      _state.copyWith(
        createAppointmentForm: CreateAppointmentForm(
          selectedCustomer: preselectedCustomer,
          vehicles: initialVehicles,
          selectedVehicleId: preselectedVehicle?.id ?? initialVehicles.firstOrNull?.id,
          dateText: _today,
        ),
        clearError: true,
        clearNotice: true,
      ),
    );
    if (preselectedCustomer != null && initialVehicles.isEmpty) {
      _loadVehiclesForAppointmentCustomer(preselectedCustomer.id);
    }
    if (state.portfolioCustomers.isEmpty && state.canReadCustomers) {
      refreshCustomerPortfolio(force: false);
    }
  }

  void onDismissCreateAppointment() {
    final form = _state.createAppointmentForm;
    if (form == null || form.isSaving) return;
    _update(_state.copyWith(clearCreateAppointmentForm: true, clearError: true));
  }

  void onAppointmentCustomerQueryChange(String query) => _editAppointmentForm((f) => f.copyWith(customerQuery: query));

  void onClearAppointmentCustomer() {
    _editAppointmentForm(
      (f) => f.copyWith(
        clearSelectedCustomer: true,
        vehicles: const [],
        clearSelectedVehicleId: true,
        clearInvalidField: true,
      ),
    );
  }

  void onSelectAppointmentCustomer(Customer customer) {
    _editAppointmentForm(
      (f) => f.copyWith(
        selectedCustomer: customer,
        vehicles: const [],
        isLoadingVehicles: true,
        clearSelectedVehicleId: true,
        clearInvalidField: true,
      ),
    );
    _loadVehiclesForAppointmentCustomer(customer.id);
  }

  Future<void> _loadVehiclesForAppointmentCustomer(String customerId) async {
    try {
      final list = await getCustomerVehicles.execute(customerId);
      final form = _state.createAppointmentForm;
      if (form == null || form.selectedCustomer?.id != customerId) return;
      _update(
        _state.copyWith(
          createAppointmentForm: form.copyWith(
            vehicles: list,
            isLoadingVehicles: false,
            selectedVehicleId: form.selectedVehicleId ?? list.firstOrNull?.id,
          ),
        ),
      );
    } on Object catch (e) {
      final form = _state.createAppointmentForm;
      if (form == null) return;
      _update(
        _state.copyWith(
          createAppointmentForm: form.copyWith(isLoadingVehicles: false),
          error: toReceptionUiText(e),
        ),
      );
    }
  }

  void onSelectAppointmentVehicle(String vehicleId) {
    _editAppointmentForm((f) => f.copyWith(selectedVehicleId: vehicleId, clearInvalidField: true));
  }

  void onAppointmentDateChange(String dateText) {
    _editAppointmentForm((f) => f.copyWith(dateText: dateText, clearInvalidField: true));
  }

  void onAppointmentTimeChange(String timeText) {
    _editAppointmentForm((f) => f.copyWith(timeText: timeText, clearInvalidField: true));
  }

  void onAppointmentDurationChange(String durationText) {
    _editAppointmentForm(
      (f) => f.copyWith(durationText: durationText.replaceAll(RegExp(r'[^0-9]'), ''), clearInvalidField: true),
    );
  }

  void onAppointmentReasonChange(String reason) {
    _editAppointmentForm((f) => f.copyWith(reason: reason, clearInvalidField: true));
  }

  void onSelectAppointmentQuickDate(int daysFromToday) {
    _editAppointmentForm(
      (f) => f.copyWith(dateText: BusinessTime.addDays(_today, daysFromToday), clearInvalidField: true),
    );
  }

  void _editAppointmentForm(CreateAppointmentForm Function(CreateAppointmentForm form) change) {
    final form = _state.createAppointmentForm;
    if (form == null || form.isSaving) return;
    _update(_state.copyWith(createAppointmentForm: change(form), clearError: true));
  }

  Future<void> onConfirmCreateAppointment() async {
    final create = createAppointment;
    if (create == null) return;
    final state = _state;
    final form = state.createAppointmentForm;
    if (form == null) return;
    if (!state.canCreateAppointments || !state.isOnline || form.isSaving) return;

    final customerId = form.selectedCustomer?.id;
    final vehicleId = form.selectedVehicleId;
    if (customerId == null || customerId.trim().isEmpty) {
      _update(_state.copyWith(createAppointmentForm: form.copyWith(invalidField: 'customerId')));
      return;
    }
    if (vehicleId == null || vehicleId.trim().isEmpty) {
      _update(_state.copyWith(createAppointmentForm: form.copyWith(invalidField: 'vehicleId')));
      return;
    }
    final scheduledAt = parseLimaDateTime(form.dateText, form.timeText);
    if (scheduledAt == null) {
      _update(
        _state.copyWith(
          createAppointmentForm: form.copyWith(invalidField: 'scheduledAt'),
          error: UiText.resource((s) => s.receptionAppointmentInvalidDatetime),
        ),
      );
      return;
    }
    final durationRaw = form.durationText.trim();
    final duration = durationRaw.isEmpty ? null : int.tryParse(durationRaw);
    if (form.durationText.trim().isNotEmpty && duration == null) {
      _update(
        _state.copyWith(
          createAppointmentForm: form.copyWith(invalidField: 'estimatedDurationMinutes'),
          error: UiText.resource((s) => s.receptionAppointmentInvalidDuration),
        ),
      );
      return;
    }

    _update(
      _state.copyWith(
        createAppointmentForm: form.copyWith(isSaving: true, clearInvalidField: true),
        clearError: true,
      ),
    );
    try {
      final reason = form.reason.trim();
      await create.execute(
        customerId: customerId,
        vehicleId: vehicleId,
        scheduledAt: scheduledAt,
        estimatedDurationMinutes: duration,
        reason: reason.isEmpty ? null : reason,
      );
      unawaited(refresh());
      _update(
        _state.copyWith(
          clearCreateAppointmentForm: true,
          notice: UiText.resource((s) => s.receptionAppointmentScheduledNotice),
        ),
      );
    } on Object catch (e) {
      final field = invalidReceptionField(e);
      final errorMsg = field == 'estimatedDurationMinutes'
          ? UiText.resource((s) => s.receptionAppointmentInvalidDuration)
          : toReceptionUiText(e);
      final current = _state.createAppointmentForm;
      _update(
        _state.copyWith(
          createAppointmentForm: current?.copyWith(
            isSaving: false,
            invalidField: field,
            clearInvalidField: field == null,
          ),
          error: errorMsg,
        ),
      );
    }
  }

  // --- Editar contacto del cliente (`PUT /customers/{id}/contact`, `CUSTOMERS_UPDATE`) ---

  void onOpenEditContact(Customer customer) {
    final state = _state;
    if (!state.canUpdateCustomer || !state.isOnline) return;
    _update(
      _state.copyWith(
        editContactForm: EditContactForm(
          customerId: customer.id,
          customerName: customer.displayName,
          email: customer.email ?? '',
          phone: customer.phone ?? '',
        ),
        clearError: true,
        clearNotice: true,
      ),
    );
  }

  void onDismissEditContact() {
    final form = _state.editContactForm;
    if (form == null || form.isSaving) return;
    _update(_state.copyWith(clearEditContactForm: true, clearError: true));
  }

  void onEditContactEmailChange(String email) {
    final form = _state.editContactForm;
    if (form == null || form.isSaving) return;
    _update(_state.copyWith(editContactForm: form.copyWith(email: email, clearInvalidField: true), clearError: true));
  }

  void onEditContactPhoneChange(String phone) {
    final form = _state.editContactForm;
    if (form == null || form.isSaving) return;
    _update(_state.copyWith(editContactForm: form.copyWith(phone: phone, clearInvalidField: true), clearError: true));
  }

  Future<void> onConfirmEditContact() async {
    final updateContact = updateCustomerContact;
    if (updateContact == null) return;
    final state = _state;
    final form = state.editContactForm;
    if (form == null) return;
    if (!state.canUpdateCustomer || !state.isOnline || form.isSaving) return;

    _update(
      _state.copyWith(editContactForm: form.copyWith(isSaving: true, clearInvalidField: true), clearError: true),
    );
    try {
      final email = form.email.trim();
      final phone = form.phone.trim();
      final updated = await updateContact.execute(
        form.customerId,
        email: email.isEmpty ? null : email,
        phone: phone.isEmpty ? null : phone,
      );
      final current = _state;
      final result = current.vehicleResult;
      _update(
        current.copyWith(
          clearEditContactForm: true,
          selectedCustomer: current.selectedCustomer?.id == updated.id ? updated : current.selectedCustomer,
          customers: [for (final c in current.customers) c.id == updated.id ? updated : c],
          vehicleResult: result != null && result.owner?.id == updated.id
              ? VehicleWithOwner(vehicle: result.vehicle, owner: updated)
              : result,
          notice: UiText.resource((s) => s.receptionEditContactNotice),
        ),
      );
    } on Object catch (e) {
      final current = _state.editContactForm;
      final field = invalidReceptionField(e);
      _update(
        _state.copyWith(
          editContactForm: current?.copyWith(isSaving: false, invalidField: field, clearInvalidField: field == null),
          error: toReceptionUiText(e),
        ),
      );
    }
  }

  /// Fecha `yyyy-MM-dd` y hora `HH:mm` de Lima como instante UTC; `null` si no son válidas.
  @visibleForTesting
  static DateTime? parseLimaDateTime(String dateText, String timeText) {
    final date = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(dateText.trim());
    final time = RegExp(r'^(\d{2}):(\d{2})(?::(\d{2}))?$').firstMatch(timeText.trim());
    if (date == null || time == null) return null;
    final year = int.parse(date.group(1)!);
    final month = int.parse(date.group(2)!);
    final day = int.parse(date.group(3)!);
    final hour = int.parse(time.group(1)!);
    final minute = int.parse(time.group(2)!);
    final second = int.parse(time.group(3) ?? '0');
    if (hour > 23 || minute > 59 || second > 59) return null;
    final lima = DateTime.utc(year, month, day, hour, minute, second);
    if (lima.year != year || lima.month != month || lima.day != day) return null;
    return lima.subtract(BusinessTime.limaOffset);
  }

  void _update(VehicleSearchUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    connectivity?.removeListener(_onConnectivity);
    _appointmentsSubscription?.cancel();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}
