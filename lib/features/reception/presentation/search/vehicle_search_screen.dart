import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_plate.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_plate_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_segmented_control.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/lima_time_format.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/state_sheet_host.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/appointment.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/customer.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/search/vehicle_search_sheets.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/search/vehicle_search_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/reception/presentation/search/vehicle_search_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _months = ['ene', 'feb', 'mar', 'abr', 'may', 'jun', 'jul', 'ago', 'set', 'oct', 'nov', 'dic'];

/// `dd MMM · HH:mm` en es-PE (hora de Lima): `27 oct · 10:00`.
String _dateTimeLabel(DateTime instant) {
  final lima = instant.toUtc().add(const Duration(hours: -5));
  final day = lima.day.toString().padLeft(2, '0');
  return '$day ${_months[lima.month - 1]} · ${formatLimaTime(instant)}';
}

/// Recibir vehículo (US11): la placa es el gesto. Debajo del campo, la ficha del vehículo con sus acciones;
/// más abajo, las citas de hoy con gestión completa y creación de citas.
class VehicleSearchScreen extends StatefulWidget {
  /// Solo para pruebas: si no se pasa, la pantalla crea el suyo con `get_it` y lo libera.
  final VehicleSearchViewModel? viewModel;

  const VehicleSearchScreen({super.key, this.viewModel});

  @override
  State<VehicleSearchScreen> createState() => _VehicleSearchScreenState();
}

class _VehicleSearchScreenState extends State<VehicleSearchScreen> {
  late final VehicleSearchViewModel _viewModel = widget.viewModel ?? getIt<VehicleSearchViewModel>();
  Object? _lastNotice;
  Object? _lastArrival;
  Object? _lastError;

  @override
  void initState() {
    super.initState();
    _viewModel.addListener(_haptics);
  }

  void _haptics() {
    final state = _viewModel.state;
    final haptics = rememberAtelierHaptics();
    if ((state.notice != null && !identical(state.notice, _lastNotice)) ||
        (state.arrival != null && !identical(state.arrival, _lastArrival))) {
      haptics.confirm();
    }
    if (state.error != null && !identical(state.error, _lastError)) haptics.reject();
    _lastNotice = state.notice;
    _lastArrival = state.arrival;
    _lastError = state.error;
  }

  @override
  void dispose() {
    _viewModel.removeListener(_haptics);
    if (widget.viewModel == null) _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = _viewModel;
    final actions = VehicleSearchActions(
      onBack: () => Navigator.of(context).maybePop(),
      onModeChange: vm.onModeChange,
      onQueryChange: vm.onQueryChange,
      onSearch: vm.onSearch,
      onSelectCustomer: vm.onSelectCustomer,
      onAppointmentRangeChange: vm.onAppointmentRangeChange,
      onOpenAppointmentActions: vm.onOpenAppointmentActions,
      onDismissAppointmentActions: vm.onDismissAppointmentActions,
      onConfirmAppointment: vm.onConfirmAppointment,
      onMarkArrived: vm.onMarkArrived,
      onRescheduleAppointment: vm.onRescheduleAppointment,
      onCancelAppointment: vm.onCancelAppointment,
      onOpenCreateAppointment: vm.onOpenCreateAppointment,
      onDismissCreateAppointment: vm.onDismissCreateAppointment,
      onAppointmentCustomerQueryChange: vm.onAppointmentCustomerQueryChange,
      onSelectAppointmentCustomer: vm.onSelectAppointmentCustomer,
      onClearAppointmentCustomer: vm.onClearAppointmentCustomer,
      onSelectAppointmentVehicle: vm.onSelectAppointmentVehicle,
      onAppointmentQuickDate: vm.onSelectAppointmentQuickDate,
      onAppointmentDateChange: vm.onAppointmentDateChange,
      onAppointmentTimeChange: vm.onAppointmentTimeChange,
      onAppointmentDurationChange: vm.onAppointmentDurationChange,
      onAppointmentReasonChange: vm.onAppointmentReasonChange,
      onConfirmCreateAppointment: vm.onConfirmCreateAppointment,
      onOpenEditContact: vm.onOpenEditContact,
      onDismissEditContact: vm.onDismissEditContact,
      onEditContactEmailChange: vm.onEditContactEmailChange,
      onEditContactPhoneChange: vm.onEditContactPhoneChange,
      onConfirmEditContact: vm.onConfirmEditContact,
      onRefresh: vm.refresh,
      onRegisterNew: (plate) => AppNavigator.push(
        context,
        AppRoute.registerCustomer,
        RegisterCustomerArgs(plate: plate != null && plate.trim().isNotEmpty ? plate : null),
      ),
      onAddVehicleForCustomer: (customer) => AppNavigator.push(
        context,
        AppRoute.registerCustomer,
        RegisterCustomerArgs(customerId: customer.id, customerName: customer.displayName),
      ),
      onAffiliate: () => AppNavigator.push(context, AppRoute.affiliation),
      onOpenWorkOrder: (vehicleId, customerId, workOrderId) => AppNavigator.push(
        context,
        AppRoute.openWorkOrder,
        OpenWorkOrderArgs(vehicleId: vehicleId, customerId: customerId, workOrderId: workOrderId),
      ),
    );
    return StateSheetHost<Appointment>(
      listenable: vm,
      value: () {
        final id = vm.state.actionAppointmentId;
        return vm.state.appointments.where((a) => a.id == id).firstOrNull;
      },
      onDismiss: vm.onDismissAppointmentActions,
      sheetBuilder: (context, appointment) => AppointmentActionsSheet(
        appointment: appointment,
        state: vm.state,
        onConfirmAppointment: () => vm.onConfirmAppointment(appointment.id),
        onMarkArrived: () => vm.onMarkArrived(appointment.id),
        onReschedule: (date, time) => vm.onRescheduleAppointment(appointment.id, date, time),
        onCancelAppointment: (reason) => vm.onCancelAppointment(appointment.id, reason),
        onDismiss: vm.onDismissAppointmentActions,
      ),
      child: StateSheetHost<CreateAppointmentForm>(
        listenable: vm,
        value: () => vm.state.createAppointmentForm,
        onDismiss: vm.onDismissCreateAppointment,
        sheetBuilder: (context, form) => CreateAppointmentSheet(
          form: form,
          customers: vm.state.portfolioCustomers,
          isOnline: vm.state.isOnline,
          error: vm.state.error,
          onCustomerQueryChange: vm.onAppointmentCustomerQueryChange,
          onSelectCustomer: vm.onSelectAppointmentCustomer,
          onClearCustomer: vm.onClearAppointmentCustomer,
          onSelectVehicle: vm.onSelectAppointmentVehicle,
          onQuickDate: vm.onSelectAppointmentQuickDate,
          onDateChange: vm.onAppointmentDateChange,
          onTimeChange: vm.onAppointmentTimeChange,
          onDurationChange: vm.onAppointmentDurationChange,
          onReasonChange: vm.onAppointmentReasonChange,
          onConfirm: vm.onConfirmCreateAppointment,
          onDismiss: vm.onDismissCreateAppointment,
        ),
        child: StateSheetHost<EditContactForm>(
          listenable: vm,
          value: () => vm.state.editContactForm,
          onDismiss: vm.onDismissEditContact,
          sheetBuilder: (context, form) => EditCustomerContactSheet(
            form: form,
            isOnline: vm.state.isOnline,
            error: vm.state.error,
            onEmailChange: vm.onEditContactEmailChange,
            onPhoneChange: vm.onEditContactPhoneChange,
            onConfirm: vm.onConfirmEditContact,
            onDismiss: vm.onDismissEditContact,
          ),
          child: ListenableBuilder(
            listenable: vm,
            builder: (context, _) => VehicleSearchContent(state: vm.state, actions: actions),
          ),
        ),
      ),
    );
  }
}

/// Callbacks de la pantalla: la vista no conoce al ViewModel (así las pruebas pasan solo lo que usan).
class VehicleSearchActions {
  final VoidCallback onBack;
  final ValueChanged<SearchMode> onModeChange;
  final ValueChanged<String> onQueryChange;
  final VoidCallback onSearch;
  final ValueChanged<Customer> onSelectCustomer;
  final ValueChanged<AppointmentRange> onAppointmentRangeChange;
  final ValueChanged<String> onOpenAppointmentActions;
  final VoidCallback onDismissAppointmentActions;
  final ValueChanged<String> onConfirmAppointment;
  final ValueChanged<String> onMarkArrived;
  final void Function(String id, String date, String time) onRescheduleAppointment;
  final void Function(String id, String reason) onCancelAppointment;
  final VoidCallback onOpenCreateAppointment;
  final VoidCallback onDismissCreateAppointment;
  final ValueChanged<String> onAppointmentCustomerQueryChange;
  final ValueChanged<Customer> onSelectAppointmentCustomer;
  final VoidCallback onClearAppointmentCustomer;
  final ValueChanged<String> onSelectAppointmentVehicle;
  final ValueChanged<int> onAppointmentQuickDate;
  final ValueChanged<String> onAppointmentDateChange;
  final ValueChanged<String> onAppointmentTimeChange;
  final ValueChanged<String> onAppointmentDurationChange;
  final ValueChanged<String> onAppointmentReasonChange;
  final VoidCallback onConfirmCreateAppointment;
  final ValueChanged<Customer> onOpenEditContact;
  final VoidCallback onDismissEditContact;
  final ValueChanged<String> onEditContactEmailChange;
  final ValueChanged<String> onEditContactPhoneChange;
  final VoidCallback onConfirmEditContact;
  final Future<void> Function() onRefresh;
  final ValueChanged<String?> onRegisterNew;
  final ValueChanged<Customer> onAddVehicleForCustomer;
  final VoidCallback onAffiliate;
  final void Function(String vehicleId, String customerId, String? workOrderId) onOpenWorkOrder;

  static void _noop() {}
  static void _noop1(Object? _) {}
  static Future<void> _noopRefresh() async {}

  const VehicleSearchActions({
    this.onBack = _noop,
    this.onModeChange = _noop1,
    this.onQueryChange = _noop1,
    this.onSearch = _noop,
    this.onSelectCustomer = _noop1,
    this.onAppointmentRangeChange = _noop1,
    this.onOpenAppointmentActions = _noop1,
    this.onDismissAppointmentActions = _noop,
    this.onConfirmAppointment = _noop1,
    this.onMarkArrived = _noop1,
    this.onRescheduleAppointment = _noop3,
    this.onCancelAppointment = _noop2,
    this.onOpenCreateAppointment = _noop,
    this.onDismissCreateAppointment = _noop,
    this.onAppointmentCustomerQueryChange = _noop1,
    this.onSelectAppointmentCustomer = _noop1,
    this.onClearAppointmentCustomer = _noop,
    this.onSelectAppointmentVehicle = _noop1,
    this.onAppointmentQuickDate = _noop1,
    this.onAppointmentDateChange = _noop1,
    this.onAppointmentTimeChange = _noop1,
    this.onAppointmentDurationChange = _noop1,
    this.onAppointmentReasonChange = _noop1,
    this.onConfirmCreateAppointment = _noop,
    this.onOpenEditContact = _noop1,
    this.onDismissEditContact = _noop,
    this.onEditContactEmailChange = _noop1,
    this.onEditContactPhoneChange = _noop1,
    this.onConfirmEditContact = _noop,
    this.onRefresh = _noopRefresh,
    this.onRegisterNew = _noop1,
    this.onAddVehicleForCustomer = _noop1,
    this.onAffiliate = _noop,
    this.onOpenWorkOrder = _noop3,
  });

  static void _noop2(Object? a, Object? b) {}
  static void _noop3(Object? a, Object? b, [Object? c]) {}
}

class VehicleSearchContent extends StatelessWidget {
  final VehicleSearchUiState state;
  final VehicleSearchActions actions;

  const VehicleSearchContent({super.key, required this.state, required this.actions});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final hasOpenSheet =
        state.actionAppointmentId != null || state.createAppointmentForm != null || state.editContactForm != null;
    final inset = FloatingBarInset.of(context);
    return Scaffold(
      body: Column(
        children: [
          AtelierTopBar(title: strings.receptionSearchTitle, onBack: actions.onBack),
          Expanded(
            child: !state.canSearch && !state.canViewAppointments
                ? Padding(
                    padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
                    child: AtelierNoPermissionState(text: strings.receptionSearchNoAccess),
                  )
                : DelayedLoading(
                    loading: state.appointments.isEmpty && state.isRefreshingAppointments,
                    builder: (context, showAppointmentsSkeleton) => DelayedLoading(
                      loading: state.isSearching,
                      builder: (context, showSearchSkeleton) => Column(
                        children: [
                          AtelierRefreshBar(visible: state.isRefreshingAppointments && state.appointments.isNotEmpty),
                          Expanded(
                            child: RefreshIndicator(
                              onRefresh: actions.onRefresh,
                              child: _body(context, strings, hasOpenSheet, showAppointmentsSkeleton, showSearchSkeleton, inset),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: state.canCreateAppointments && state.isOnline
          ? Padding(
              padding: EdgeInsets.only(bottom: inset),
              child: AtelierFab(
                text: strings.receptionNewAppointment,
                icon: Icons.add,
                onClick: actions.onOpenCreateAppointment,
              ),
            )
          : null,
    );
  }

  Widget _body(
    BuildContext context,
    AppLocalizations strings,
    bool hasOpenSheet,
    bool showAppointmentsSkeleton,
    bool showSearchSkeleton,
    double inset,
  ) {
    final notice = state.notice;
    final error = state.error;
    final children = <Widget>[
      _SearchBlock(
        state: state,
        onModeChange: actions.onModeChange,
        onQueryChange: actions.onQueryChange,
        onSearch: actions.onSearch,
      ),
      if (notice != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.xs),
          child: AtelierBanner(
            message: notice.asString(strings),
            icon: Icons.check_circle_outline,
            kind: BannerKind.ok,
          ),
        ),
      if (!hasOpenSheet && error != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: AtelierErrorState(
            message: error.asString(strings),
            onRetry: state.canSubmitSearch ? actions.onSearch : actions.onRefresh,
          ),
        ),
      if (showSearchSkeleton)
        const AtelierListRow(title: 'Buscando', subtitle: 'Consultando padrón', plate: 'ABC123', loading: true)
      else if (state.canSearch)
        ..._results(context, strings),
      if (state.canViewAppointments) ..._appointments(context, strings, showAppointmentsSkeleton),
    ];
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: inset + (state.canCreateAppointments ? 96 : Spacing.lg)),
      children: children,
    );
  }

  List<Widget> _results(BuildContext context, AppLocalizations strings) {
    final result = state.vehicleResult;
    final selected = state.selectedCustomer;
    return [
      if (result != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
          child: _VehicleFicha(
            result: result,
            canOpenWorkOrder: state.canOpenWorkOrder,
            canUpdateCustomer: state.canUpdateCustomer,
            isOnline: state.isOnline,
            onOpenWorkOrder: actions.onOpenWorkOrder,
            onEditContact: actions.onOpenEditContact,
          ),
        ),
      if (state.vehicleNotFound || state.customersNotFound)
        _NotFound(
          text: state.vehicleNotFound
              ? strings.receptionPlateNotFound(state.query.trim())
              : strings.searchCustomersEmpty,
          state: state,
          onRegisterNew: () => actions.onRegisterNew(state.initialPlateCandidate),
          onAffiliate: actions.onAffiliate,
        ),
      if (state.customers.length > 1) ...[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: AtelierSectionHeader(title: strings.searchCustomersTitle, count: state.customers.length),
        ),
        for (final customer in state.customers)
          AtelierListRow(
            title: customer.displayName,
            subtitle: _customerSubtitle(customer),
            onClick: () => actions.onSelectCustomer(customer),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.xs,
              children: [
                if (state.canUpdateCustomer && state.isOnline)
                  AtelierButton(
                    text: strings.receptionEditContactBtn,
                    onClick: () => actions.onOpenEditContact(customer),
                    style: AtelierButtonStyle.text,
                  ),
                if (customer.id == selected?.id)
                  AtelierChip(text: strings.receptionSelected, kind: ChipKind.info),
              ],
            ),
          ),
      ],
      if (selected != null) ...[
        Padding(
          padding: const EdgeInsets.only(left: Spacing.md, right: Spacing.xs),
          child: AtelierSectionHeader(
            title: strings.searchCustomerVehiclesTitle(selected.displayName),
            action: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: Spacing.xs,
              children: [
                if (state.canUpdateCustomer && state.isOnline)
                  AtelierButton(
                    text: strings.receptionEditContactBtn,
                    onClick: () => actions.onOpenEditContact(selected),
                    style: AtelierButtonStyle.text,
                    icon: Icons.edit_outlined,
                  ),
                if (state.canRegister && state.isOnline)
                  AtelierButton(
                    text: strings.receptionAddVehicle,
                    onClick: () => actions.onAddVehicleForCustomer(selected),
                    style: AtelierButtonStyle.text,
                  ),
              ],
            ),
          ),
        ),
        if (state.isLoadingVehicles && state.customerVehicles.isEmpty)
          for (var i = 0; i < 2; i++)
            const AtelierListRow(title: 'Vehículo', subtitle: 'Marca modelo', plate: 'ABC123', loading: true)
        else if (state.customerVehicles.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
            child: AtelierEmptyState(text: strings.searchCustomerVehiclesEmpty),
          )
        else
          for (final vehicle in state.customerVehicles)
            AtelierListRow(
              title: _vehicleLine(vehicle),
              plate: vehicle.plate,
              trailing: state.canOpenWorkOrder
                  ? AtelierButton(
                      text: strings.receptionOpenOrder,
                      onClick: () => actions.onOpenWorkOrder(vehicle.id, selected.id, null),
                      style: AtelierButtonStyle.text,
                      enabled: state.isOnline,
                    )
                  : null,
            ),
      ],
    ];
  }

  List<Widget> _appointments(BuildContext context, AppLocalizations strings, bool showSkeleton) {
    final arrival = state.arrival;
    final rangeLabels = {
      AppointmentRange.today: strings.receptionAppointmentsRangeToday,
      AppointmentRange.week: strings.receptionAppointmentsRangeWeek,
      AppointmentRange.month: strings.receptionAppointmentsRangeMonth,
    };
    return [
      Padding(
        padding: const EdgeInsets.only(left: Spacing.md, right: Spacing.md, top: Spacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: Spacing.sm,
          children: [
            AtelierSectionHeader(
              title: strings.receptionAppointmentsSectionTitle,
              count: state.appointments.isEmpty ? null : state.appointments.length,
            ),
            AtelierSegmentedControl<AppointmentRange>(
              options: AppointmentRange.values,
              selected: state.appointmentRange,
              onSelect: actions.onAppointmentRangeChange,
              label: (range) => rangeLabels[range]!,
            ),
          ],
        ),
      ),
      if (arrival != null)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: Spacing.sm,
            children: [
              AtelierBanner(
                message: arrival is WorkOrderReady ? strings.searchArrivalReady : strings.searchArrivalPending,
                icon: Icons.check_circle_outline,
                kind: arrival is WorkOrderReady ? BannerKind.ok : BannerKind.info,
              ),
              if (arrival is WorkOrderReady && state.canOpenWorkOrder)
                AtelierButton(
                  text: strings.searchCompleteOrder,
                  onClick: () => actions.onOpenWorkOrder(
                    arrival.appointment.vehicleId,
                    arrival.appointment.customerId,
                    arrival.workOrderId.value,
                  ),
                  enabled: state.isOnline,
                ),
            ],
          ),
        ),
      if (showSkeleton)
        for (var i = 0; i < 3; i++)
          const AtelierListRow(title: 'Cita', subtitle: 'Cliente', plate: 'ABC123', loading: true)
      else if (state.appointments.isEmpty && state.isRefreshingAppointments)
        const SizedBox.shrink()
      else if (state.appointments.isEmpty && !state.isOnline)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: AtelierOfflineState(onRetry: actions.onRefresh),
        )
      else if (state.appointments.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: Spacing.md),
          child: AtelierEmptyState(
            text: switch (state.appointmentRange) {
              AppointmentRange.today => strings.searchAppointmentsEmpty,
              AppointmentRange.week => strings.receptionAppointmentsEmptyWeek,
              AppointmentRange.month => strings.receptionAppointmentsEmptyMonth,
            },
          ),
        )
      else
        for (final appointment in state.appointments) _appointmentRow(strings, appointment),
    ];
  }

  Widget _appointmentRow(AppLocalizations strings, Appointment appointment) {
    final status = appointment.status;
    final canAct =
        state.canMarkArrival && (status == AppointmentStatus.pending || status == AppointmentStatus.confirmed);
    return AtelierListRow(
      key: ValueKey('appointment-${appointment.id}'),
      title: appointment.customerName ?? strings.receptionAppointmentNoCustomer,
      subtitle: _appointmentLine(strings, appointment, includeDate: state.appointmentRange != AppointmentRange.today),
      plate: appointment.plate,
      onClick: canAct ? () => actions.onOpenAppointmentActions(appointment.id) : null,
      trailing: status == null
          ? null
          : AtelierChip(text: _statusLabel(strings, status), kind: _statusKind(status)),
    );
  }
}

String? _customerSubtitle(Customer customer) {
  final parts = [
    if (customer.taxId != null) customer.taxId!,
    if (customer.phone != null) customer.phone!,
  ];
  return parts.isEmpty ? null : parts.join(' · ');
}

String _vehicleLine(Vehicle vehicle) =>
    [vehicle.brand, vehicle.model, if (vehicle.year != null) vehicle.year.toString()].join(' ');

String _appointmentLine(AppLocalizations strings, Appointment appointment, {required bool includeDate}) {
  final whenLabel = includeDate ? _dateTimeLabel(appointment.scheduledAt) : formatLimaTime(appointment.scheduledAt);
  final reason = appointment.reason;
  return reason == null ? whenLabel : strings.searchAppointmentLine(whenLabel, reason);
}

String _statusLabel(AppLocalizations strings, AppointmentStatus status) => switch (status) {
  AppointmentStatus.pending => strings.appointmentStatusPending,
  AppointmentStatus.confirmed => strings.appointmentStatusConfirmed,
  AppointmentStatus.arrived => strings.appointmentStatusArrived,
  AppointmentStatus.canceled => strings.appointmentStatusCanceled,
};

ChipKind _statusKind(AppointmentStatus status) => switch (status) {
  AppointmentStatus.pending => ChipKind.wait,
  AppointmentStatus.confirmed => ChipKind.info,
  AppointmentStatus.arrived => ChipKind.ok,
  AppointmentStatus.canceled => ChipKind.idle,
};

class _SearchBlock extends StatelessWidget {
  final VehicleSearchUiState state;
  final ValueChanged<SearchMode> onModeChange;
  final ValueChanged<String> onQueryChange;
  final VoidCallback onSearch;

  const _SearchBlock({
    required this.state,
    required this.onModeChange,
    required this.onQueryChange,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final modeLabels = {
      SearchMode.plate: strings.premiumSearchModePlate,
      SearchMode.document: strings.premiumSearchModeDocument,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.sm,
        children: [
          if (!state.isOnline)
            AtelierBanner(
              message: strings.receptionSearchOfflineCache,
              icon: Icons.info_outline,
              kind: BannerKind.info,
            ),
          if (!state.canSearch)
            AtelierNoPermissionState(text: strings.receptionSearchNoSearchPermission)
          else
            AtelierSurface(
              tier: SurfaceTier.elevated,
              shape: heroShape,
              contentPadding: const EdgeInsets.all(Spacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                spacing: Spacing.sm,
                children: [
                  AtelierSegmentedControl<SearchMode>(
                    options: SearchMode.values,
                    selected: state.mode,
                    onSelect: (mode) {
                      if (!state.isSearching && mode != state.mode) onModeChange(mode);
                    },
                    label: (mode) => modeLabels[mode]!,
                  ),
                  if (state.mode == SearchMode.plate)
                    AtelierPlateField(
                      label: strings.searchFieldPlate,
                      value: state.query,
                      onValueChange: onQueryChange,
                      placeholder: strings.receptionSearchPlatePlaceholder,
                      enabled: !state.isSearching,
                      imeAction: TextInputAction.search,
                      onImeAction: onSearch,
                    )
                  else
                    AtelierTextField(
                      label: strings.searchFieldDocument,
                      value: state.query,
                      onValueChange: (value) => onQueryChange(_cleanDocumentQuery(value)),
                      leadingIcon: Icons.search,
                      enabled: !state.isSearching,
                      autocorrect: false,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(11)],
                      textInputAction: TextInputAction.search,
                      onSubmitted: onSearch,
                    ),
                  AtelierButton(
                    text: strings.searchSubmit,
                    onClick: onSearch,
                    enabled: state.canSubmitSearch,
                    loading: state.isSearching,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Documento en solo dígitos (DNI de 8, RUC de 11).
String _cleanDocumentQuery(String raw) {
  final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
  return digits.length > 11 ? digits.substring(0, 11) : digits;
}

class _VehicleFicha extends StatelessWidget {
  final VehicleWithOwner result;
  final bool canOpenWorkOrder;
  final bool canUpdateCustomer;
  final bool isOnline;
  final void Function(String vehicleId, String customerId, String? workOrderId) onOpenWorkOrder;
  final ValueChanged<Customer> onEditContact;

  const _VehicleFicha({
    required this.result,
    required this.canOpenWorkOrder,
    required this.canUpdateCustomer,
    required this.isOnline,
    required this.onOpenWorkOrder,
    required this.onEditContact,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final vehicle = result.vehicle;
    final owner = result.owner;
    final customerId = owner?.id ?? vehicle.currentOwnerId;
    return AtelierSurface(
      tier: SurfaceTier.card,
      shape: cardLargeShape,
      contentPadding: const EdgeInsets.all(Spacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.sm,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: AtelierPlate(plate: vehicle.plate, size: PlateSize.l),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _vehicleLine(vehicle),
                style: context.text.titleMedium!.copyWith(color: context.scheme.onSurface),
              ),
              Text(
                owner?.displayName ?? strings.searchVehicleNoOwner,
                style: context.text.bodyMedium!.copyWith(color: context.atelier.inkSecondary),
              ),
            ],
          ),
          if (canOpenWorkOrder && customerId != null)
            AtelierButton(
              text: strings.receptionOpenOrder,
              onClick: () => onOpenWorkOrder(vehicle.id, customerId, null),
              enabled: isOnline,
            ),
          if (owner != null && canUpdateCustomer)
            AtelierButton(
              text: strings.receptionEditContactBtn,
              onClick: () => onEditContact(owner),
              style: AtelierButtonStyle.outlined,
              enabled: isOnline,
              icon: Icons.edit_outlined,
            ),
          if ((canOpenWorkOrder || canUpdateCustomer) && !isOnline) const AtelierRequiresConnection(),
        ],
      ),
    );
  }
}

class _NotFound extends StatelessWidget {
  final String text;
  final VehicleSearchUiState state;
  final VoidCallback onRegisterNew;
  final VoidCallback onAffiliate;

  const _NotFound({
    required this.text,
    required this.state,
    required this.onRegisterNew,
    required this.onAffiliate,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: Spacing.md, vertical: Spacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: Spacing.sm,
        children: [
          Text(text, style: context.text.bodyLarge!.copyWith(color: context.scheme.onSurface)),
          if (state.canRegister) ...[
            AtelierButton(text: strings.searchRegister, onClick: onRegisterNew, enabled: state.isOnline),
            AtelierButton(
              text: strings.searchAffiliate,
              onClick: onAffiliate,
              style: AtelierButtonStyle.outlined,
              enabled: state.isOnline,
            ),
            if (!state.isOnline) const AtelierRequiresConnection(),
          ],
        ],
      ),
    );
  }
}
