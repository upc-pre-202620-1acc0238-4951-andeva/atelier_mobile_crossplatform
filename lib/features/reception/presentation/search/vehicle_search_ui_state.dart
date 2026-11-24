import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';

/// Qué se escribe en la barra: la placa del vehículo o el documento (DNI/RUC) del cliente.
enum SearchMode { plate, document }

/// Secciones del módulo de Recepción y CRM (EP03).
enum ReceptionSection { searchAndToday, customers, vehicles }

/// Rango visible de la agenda de citas.
enum AppointmentRange {
  today(0),
  week(6),
  month(29);

  final int spanDays;
  const AppointmentRange(this.spanDays);

  /// Último día del rango (`yyyy-MM-dd`, Lima) contado desde [from].
  String endDate(String from) => BusinessTime.addDays(from, spanDays);
}

/// Formulario de la hoja inferior para agendar una cita (`POST /appointments`).
class CreateAppointmentForm {
  final String customerQuery;
  final Customer? selectedCustomer;
  final List<Vehicle> vehicles;
  final bool isLoadingVehicles;
  final String? selectedVehicleId;
  final String dateText;
  final String timeText;
  final String durationText;
  final String reason;
  final bool isSaving;
  final String? invalidField;

  const CreateAppointmentForm({
    this.customerQuery = '',
    this.selectedCustomer,
    this.vehicles = const [],
    this.isLoadingVehicles = false,
    this.selectedVehicleId,
    this.dateText = '',
    this.timeText = '10:00',
    this.durationText = '60',
    this.reason = '',
    this.isSaving = false,
    this.invalidField,
  });

  CreateAppointmentForm copyWith({
    String? customerQuery,
    Customer? selectedCustomer,
    bool clearSelectedCustomer = false,
    List<Vehicle>? vehicles,
    bool? isLoadingVehicles,
    String? selectedVehicleId,
    bool clearSelectedVehicleId = false,
    String? dateText,
    String? timeText,
    String? durationText,
    String? reason,
    bool? isSaving,
    String? invalidField,
    bool clearInvalidField = false,
  }) {
    return CreateAppointmentForm(
      customerQuery: customerQuery ?? this.customerQuery,
      selectedCustomer: clearSelectedCustomer ? null : selectedCustomer ?? this.selectedCustomer,
      vehicles: vehicles ?? this.vehicles,
      isLoadingVehicles: isLoadingVehicles ?? this.isLoadingVehicles,
      selectedVehicleId: clearSelectedVehicleId ? null : selectedVehicleId ?? this.selectedVehicleId,
      dateText: dateText ?? this.dateText,
      timeText: timeText ?? this.timeText,
      durationText: durationText ?? this.durationText,
      reason: reason ?? this.reason,
      isSaving: isSaving ?? this.isSaving,
      invalidField: clearInvalidField ? null : invalidField ?? this.invalidField,
    );
  }
}

/// Formulario de la hoja inferior para editar el contacto de un cliente (`PUT /customers/{id}/contact`).
class EditContactForm {
  final String customerId;
  final String customerName;
  final String email;
  final String phone;
  final bool isSaving;
  final String? invalidField;

  const EditContactForm({
    required this.customerId,
    required this.customerName,
    this.email = '',
    this.phone = '',
    this.isSaving = false,
    this.invalidField,
  });

  EditContactForm copyWith({
    String? email,
    String? phone,
    bool? isSaving,
    String? invalidField,
    bool clearInvalidField = false,
  }) {
    return EditContactForm(
      customerId: customerId,
      customerName: customerName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isSaving: isSaving ?? this.isSaving,
      invalidField: clearInvalidField ? null : invalidField ?? this.invalidField,
    );
  }
}

class VehicleSearchUiState {
  final ReceptionSection section;
  final SearchMode mode;
  final String query;
  final bool isSearching;

  /// Ya se buscó con el texto actual: distingue "sin resultados" de "aún no se busca".
  final bool searched;
  final VehicleWithOwner? vehicleResult;
  final List<Customer> customers;
  final Customer? selectedCustomer;
  final List<Vehicle> customerVehicles;
  final bool isLoadingVehicles;
  final List<Customer> portfolioCustomers;
  final String customerFilterQuery;
  final CustomerType? customerFilterType;
  final bool isRefreshingCustomers;
  final List<VehicleWithOwner> workshopVehicles;
  final String vehicleFilterQuery;
  final List<Appointment> appointments;
  final AppointmentRange appointmentRange;
  final bool isRefreshingAppointments;

  /// Cita cuya llegada se está registrando.
  final String? arrivingId;

  /// Cita abierta en la hoja de acciones (`AppointmentActionsSheet`).
  final String? actionAppointmentId;

  /// Cita que está ejecutando confirmación, reprogramación o cancelación.
  final String? updatingAppointmentId;
  final CreateAppointmentForm? createAppointmentForm;
  final EditContactForm? editContactForm;
  final ArrivalResult? arrival;
  final UiText? notice;
  final UiText? error;
  final bool isOnline;
  final bool canSearch;
  final bool canReadCustomers;
  final bool canUpdateCustomer;
  final bool canViewAppointments;
  final bool canCreateAppointments;
  final bool canMarkArrival;
  final bool canRegister;
  final bool canCreateVehicles;
  final bool canOpenWorkOrder;

  const VehicleSearchUiState({
    this.section = ReceptionSection.searchAndToday,
    this.mode = SearchMode.plate,
    this.query = '',
    this.isSearching = false,
    this.searched = false,
    this.vehicleResult,
    this.customers = const [],
    this.selectedCustomer,
    this.customerVehicles = const [],
    this.isLoadingVehicles = false,
    this.portfolioCustomers = const [],
    this.customerFilterQuery = '',
    this.customerFilterType,
    this.isRefreshingCustomers = false,
    this.workshopVehicles = const [],
    this.vehicleFilterQuery = '',
    this.appointments = const [],
    this.appointmentRange = AppointmentRange.today,
    this.isRefreshingAppointments = false,
    this.arrivingId,
    this.actionAppointmentId,
    this.updatingAppointmentId,
    this.createAppointmentForm,
    this.editContactForm,
    this.arrival,
    this.notice,
    this.error,
    this.isOnline = true,
    this.canSearch = false,
    this.canReadCustomers = false,
    this.canUpdateCustomer = false,
    this.canViewAppointments = false,
    this.canCreateAppointments = false,
    this.canMarkArrival = false,
    this.canRegister = false,
    this.canCreateVehicles = false,
    this.canOpenWorkOrder = false,
  });

  bool get canSubmitSearch => canSearch && query.trim().isNotEmpty && !isSearching;
  bool get vehicleNotFound => searched && mode == SearchMode.plate && vehicleResult == null;
  bool get customersNotFound => searched && mode == SearchMode.document && customers.isEmpty;

  String? get initialPlateCandidate {
    final trimmed = query.trim();
    return mode == SearchMode.plate && trimmed.isNotEmpty ? trimmed : null;
  }

  List<Customer> get filteredPortfolioCustomers {
    final q = customerFilterQuery.trim().toLowerCase();
    return portfolioCustomers.where((customer) {
      final matchesType = customerFilterType == null || customer.type == customerFilterType;
      final matchesQuery =
          q.isEmpty ||
          customer.displayName.toLowerCase().contains(q) ||
          (customer.taxId?.toLowerCase().contains(q) ?? false) ||
          (customer.email?.toLowerCase().contains(q) ?? false) ||
          (customer.phone?.toLowerCase().contains(q) ?? false);
      return matchesType && matchesQuery;
    }).toList();
  }

  List<VehicleWithOwner> get filteredWorkshopVehicles {
    final q = vehicleFilterQuery.trim().toLowerCase();
    if (q.isEmpty) return workshopVehicles;
    final normalizedQuery = q.replaceAll('-', '').replaceAll(' ', '');
    return workshopVehicles.where((item) {
      return item.vehicle.plate.toLowerCase().contains(normalizedQuery) ||
          item.vehicle.brand.toLowerCase().contains(q) ||
          item.vehicle.model.toLowerCase().contains(q) ||
          (item.owner?.displayName.toLowerCase().contains(q) ?? false) ||
          (item.owner?.taxId?.toLowerCase().contains(q) ?? false);
    }).toList();
  }

  VehicleSearchUiState copyWith({
    ReceptionSection? section,
    SearchMode? mode,
    String? query,
    bool? isSearching,
    bool? searched,
    VehicleWithOwner? vehicleResult,
    bool clearVehicleResult = false,
    List<Customer>? customers,
    Customer? selectedCustomer,
    bool clearSelectedCustomer = false,
    List<Vehicle>? customerVehicles,
    bool? isLoadingVehicles,
    List<Customer>? portfolioCustomers,
    String? customerFilterQuery,
    CustomerType? customerFilterType,
    bool clearCustomerFilterType = false,
    bool? isRefreshingCustomers,
    List<VehicleWithOwner>? workshopVehicles,
    String? vehicleFilterQuery,
    List<Appointment>? appointments,
    AppointmentRange? appointmentRange,
    bool? isRefreshingAppointments,
    String? arrivingId,
    bool clearArrivingId = false,
    String? actionAppointmentId,
    bool clearActionAppointmentId = false,
    String? updatingAppointmentId,
    bool clearUpdatingAppointmentId = false,
    CreateAppointmentForm? createAppointmentForm,
    bool clearCreateAppointmentForm = false,
    EditContactForm? editContactForm,
    bool clearEditContactForm = false,
    ArrivalResult? arrival,
    bool clearArrival = false,
    UiText? notice,
    bool clearNotice = false,
    UiText? error,
    bool clearError = false,
    bool? isOnline,
    bool? canSearch,
    bool? canReadCustomers,
    bool? canUpdateCustomer,
    bool? canViewAppointments,
    bool? canCreateAppointments,
    bool? canMarkArrival,
    bool? canRegister,
    bool? canCreateVehicles,
    bool? canOpenWorkOrder,
  }) {
    return VehicleSearchUiState(
      section: section ?? this.section,
      mode: mode ?? this.mode,
      query: query ?? this.query,
      isSearching: isSearching ?? this.isSearching,
      searched: searched ?? this.searched,
      vehicleResult: clearVehicleResult ? null : vehicleResult ?? this.vehicleResult,
      customers: customers ?? this.customers,
      selectedCustomer: clearSelectedCustomer ? null : selectedCustomer ?? this.selectedCustomer,
      customerVehicles: customerVehicles ?? this.customerVehicles,
      isLoadingVehicles: isLoadingVehicles ?? this.isLoadingVehicles,
      portfolioCustomers: portfolioCustomers ?? this.portfolioCustomers,
      customerFilterQuery: customerFilterQuery ?? this.customerFilterQuery,
      customerFilterType: clearCustomerFilterType ? null : customerFilterType ?? this.customerFilterType,
      isRefreshingCustomers: isRefreshingCustomers ?? this.isRefreshingCustomers,
      workshopVehicles: workshopVehicles ?? this.workshopVehicles,
      vehicleFilterQuery: vehicleFilterQuery ?? this.vehicleFilterQuery,
      appointments: appointments ?? this.appointments,
      appointmentRange: appointmentRange ?? this.appointmentRange,
      isRefreshingAppointments: isRefreshingAppointments ?? this.isRefreshingAppointments,
      arrivingId: clearArrivingId ? null : arrivingId ?? this.arrivingId,
      actionAppointmentId: clearActionAppointmentId ? null : actionAppointmentId ?? this.actionAppointmentId,
      updatingAppointmentId: clearUpdatingAppointmentId
          ? null
          : updatingAppointmentId ?? this.updatingAppointmentId,
      createAppointmentForm: clearCreateAppointmentForm
          ? null
          : createAppointmentForm ?? this.createAppointmentForm,
      editContactForm: clearEditContactForm ? null : editContactForm ?? this.editContactForm,
      arrival: clearArrival ? null : arrival ?? this.arrival,
      notice: clearNotice ? null : notice ?? this.notice,
      error: clearError ? null : error ?? this.error,
      isOnline: isOnline ?? this.isOnline,
      canSearch: canSearch ?? this.canSearch,
      canReadCustomers: canReadCustomers ?? this.canReadCustomers,
      canUpdateCustomer: canUpdateCustomer ?? this.canUpdateCustomer,
      canViewAppointments: canViewAppointments ?? this.canViewAppointments,
      canCreateAppointments: canCreateAppointments ?? this.canCreateAppointments,
      canMarkArrival: canMarkArrival ?? this.canMarkArrival,
      canRegister: canRegister ?? this.canRegister,
      canCreateVehicles: canCreateVehicles ?? this.canCreateVehicles,
      canOpenWorkOrder: canOpenWorkOrder ?? this.canOpenWorkOrder,
    );
  }
}
