import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_density.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_grouped_card.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_main_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_panels.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_plate.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_segmented_control.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_selection_card.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/motion.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/state_sheet_host.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_device.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/predictive_alert.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/diagnostics_ui_formatters.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/hub/diagnostics_alerts_tab.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/hub/diagnostics_devices_tab.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/hub/diagnostics_hub_sheets.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/hub/diagnostics_hub_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/hub/diagnostics_hub_view_model.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:atelier_mobile_crossplatform/navigation/app_navigator.dart';
import 'package:flutter/material.dart';

/// Hub de diagnóstico OBD-II: Escáner, Dispositivos y Alertas predictivas (EP04). Raíz de la pestaña
/// OBD-II o pantalla con Atrás cuando se llega desde otro módulo.
class DiagnosticsHubScreen extends StatefulWidget {
  final String? initialVehicleId;

  const DiagnosticsHubScreen({super.key, this.initialVehicleId});

  @override
  State<DiagnosticsHubScreen> createState() => _DiagnosticsHubScreenState();
}

class _DiagnosticsHubScreenState extends State<DiagnosticsHubScreen> {
  late final DiagnosticsHubViewModel viewModel = getIt<DiagnosticsHubViewModel>(
    param1: widget.initialVehicleId,
  );
  final ValueNotifier<String?> _deviceMenuId = ValueNotifier(null);
  late final Listenable _menuAndState = Listenable.merge([viewModel, _deviceMenuId]);
  final AtelierHaptics _haptics = rememberAtelierHaptics();
  Object? _lastNotice;
  Object? _lastError;

  @override
  void initState() {
    super.initState();
    viewModel.addListener(_feedback);
  }

  void _feedback() {
    final state = viewModel.state;
    if (state.notice != null && !identical(state.notice, _lastNotice)) _haptics.confirm();
    if (state.error != null && !identical(state.error, _lastError)) _haptics.reject();
    _lastNotice = state.notice;
    _lastError = state.error;
  }

  @override
  void dispose() {
    viewModel.removeListener(_feedback);
    _deviceMenuId.dispose();
    viewModel.dispose();
    super.dispose();
  }

  void _open(AppRoute route, [Object? args]) => AppNavigator.push(context, route, args);

  ObdDevice? _menuDevice() {
    final id = _deviceMenuId.value;
    if (id == null) return null;
    for (final device in viewModel.state.devices) {
      if (device.id == id) return device;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final showBack = FloatingBarInset.of(context) == 0 && Navigator.of(context).canPop();
    final vm = viewModel;
    return _SheetHosts(
      viewModel: vm,
      menuListenable: _menuAndState,
      menuDevice: _menuDevice,
      onCloseMenu: () => _deviceMenuId.value = null,
      onConfirmFeedback: _haptics.confirm,
      child: ListenableBuilder(
        listenable: _menuAndState,
        builder: (context, _) => DiagnosticsHubContent(
          state: vm.state,
          sheetOpen: _anySheetOpen(vm.state),
          onBack: showBack ? () => Navigator.of(context).maybePop() : null,
          actions: DiagnosticsHubActions(
            onSelectTab: vm.selectTab,
            onOpenVehiclePicker: vm.openVehiclePicker,
            onOpenInstallForVehicle: vm.openInstallForSelectedVehicle,
            onUninstallFromVehicle: vm.uninstallFromSelectedVehicle,
            onRequestBluetoothPermission: vm.requestBluetooth,
            onRefreshAdapters: vm.loadPairedAdapters,
            onSelectAdapter: vm.selectAdapter,
            onConnectAdapter: () {
              _haptics.toggle();
              vm.connectSelectedAdapter();
            },
            onDisconnectAdapter: () {
              _haptics.toggle();
              vm.disconnectAdapter();
            },
            onOpenVehicleFaults: (vehicleId, plate) =>
                _open(AppRoute.vehicleFaults, VehicleArgs(vehicleId: vehicleId, plate: plate)),
            onOpenAiHealthReport: (vehicleId, plate) =>
                _open(AppRoute.aiHealthReport, VehicleArgs(vehicleId: vehicleId, plate: plate)),
            onReportFinding: (workOrderId) => _open(AppRoute.reportFinding, workOrderId),
            onFilterDevices: vm.filterDevices,
            onOpenRegisterDevice: vm.onOpenRegisterDevice,
            onSelectDevice: (device) => _deviceMenuId.value = device.id,
            onSetAlertsScope: vm.setAlertsScope,
            onRefreshAlerts: vm.refreshAlerts,
            onAcknowledgeAlert: (alertId) {
              _haptics.confirm();
              vm.acknowledgeAlert(alertId);
            },
            onOpenConvertAlert: vm.openConvertAlertSheet,
            onOpenNotifications: () => _open(AppRoute.notifications),
            onOpenSyncQueue: () => _open(AppRoute.pendingOperations),
            onOpenProfile: () => _open(AppRoute.profile),
          ),
        ),
      ),
    );
  }

  bool _anySheetOpen(DiagnosticsHubUiState state) {
    return state.vehiclePickerOpen ||
        state.installForVehicleSheetOpen ||
        state.registerForm != null ||
        state.editingStatusDevice != null ||
        state.installingDevice != null ||
        state.uninstallingDevice != null ||
        state.convertingAlert != null ||
        _menuDevice() != null;
  }
}

/// Las hojas del hub, dirigidas por el estado del ViewModel (cada una se abre mientras su valor no sea `null`).
class _SheetHosts extends StatelessWidget {
  final DiagnosticsHubViewModel viewModel;
  final Listenable menuListenable;
  final ObdDevice? Function() menuDevice;
  final VoidCallback onCloseMenu;
  final VoidCallback onConfirmFeedback;
  final Widget child;

  const _SheetHosts({
    required this.viewModel,
    required this.menuListenable,
    required this.menuDevice,
    required this.onCloseMenu,
    required this.onConfirmFeedback,
    required this.child,
  });

  DiagnosticsHubUiState get _state => viewModel.state;

  @override
  Widget build(BuildContext context) {
    final vm = viewModel;
    Widget content = child;

    content = StateSheetHost<bool>(
      listenable: vm,
      value: () => _state.vehiclePickerOpen ? true : null,
      onDismiss: vm.dismissVehiclePicker,
      sheetBuilder: (context, _) => VehiclePickerSheet(
        query: _state.vehicleSearchQuery,
        vehicles: _state.filteredVehicles,
        selectedVehicleId: _state.selectedVehicleId,
        onQueryChange: vm.onVehicleSearchQueryChange,
        onSelectVehicle: vm.selectVehicle,
      ),
      child: content,
    );

    content = StateSheetHost<bool>(
      listenable: vm,
      value: () => _state.installForVehicleSheetOpen ? true : null,
      onDismiss: vm.dismissInstallForSelectedVehicle,
      sheetBuilder: (context, _) => InstallOnVehicleSheet(
        state: _state,
        onOdometerChange: vm.onInstallOdometerChange,
        onSelectDevice: (device) {
          onConfirmFeedback();
          vm.confirmInstallOnSelectedVehicle(device);
        },
      ),
      child: content,
    );

    content = StateSheetHost<ObdDevice>(
      listenable: menuListenable,
      value: menuDevice,
      onDismiss: onCloseMenu,
      sheetBuilder: (context, device) => DeviceActionsSheet(
        device: device,
        installation: _state.deviceInstallations[device.id],
        canInstall: _state.canManageInstallations,
        canChangeStatus: _state.canRegisterDevices,
        isOnline: _state.isOnline,
        onChangeStatus: () {
          onCloseMenu();
          vm.onOpenStatusSheet(device);
        },
        onInstall: () {
          onCloseMenu();
          vm.onOpenInstallDevice(device);
        },
        onUninstall: () {
          onCloseMenu();
          vm.onOpenUninstallDevice(device);
        },
      ),
      child: content,
    );

    content = StateSheetHost<RegisterObdDeviceForm>(
      listenable: vm,
      value: () => _state.registerForm,
      onDismiss: vm.onDismissRegisterDevice,
      sheetBuilder: (context, form) => RegisterDeviceSheet(
        form: form,
        isOnline: _state.isOnline,
        isSaving: _state.isSavingDeviceAction,
        error: _state.error,
        onIdentifierChange: vm.onIdentifierChange,
        onConnectionTypeChange: vm.onConnectionTypeChange,
        onHardwareModelChange: vm.onHardwareModelChange,
        onFirmwareVersionChange: vm.onFirmwareVersionChange,
        onConfirm: () {
          onConfirmFeedback();
          vm.onConfirmRegisterDevice();
        },
      ),
      child: content,
    );

    content = StateSheetHost<ObdDevice>(
      listenable: vm,
      value: () => _state.editingStatusDevice,
      onDismiss: vm.onDismissStatusSheet,
      sheetBuilder: (context, device) => DeviceStatusSheet(
        state: _state,
        device: device,
        onUpdateStatus: (status) {
          onConfirmFeedback();
          vm.onUpdateDeviceStatus(status);
        },
      ),
      child: content,
    );

    content = StateSheetHost<ObdDevice>(
      listenable: vm,
      value: () => _state.installingDevice,
      onDismiss: vm.onDismissInstallDevice,
      sheetBuilder: (context, _) => InstallDeviceSheet(
        state: _state,
        onConfirmInstall: (vehicle) {
          onConfirmFeedback();
          vm.onConfirmInstallDevice(vehicle);
        },
      ),
      child: content,
    );

    content = StateSheetHost<ObdDevice>(
      listenable: vm,
      value: () => _state.uninstallingDevice,
      onDismiss: vm.onDismissUninstallDevice,
      sheetBuilder: (context, device) => UninstallDeviceSheet(
        state: _state,
        device: device,
        onConfirm: () {
          onConfirmFeedback();
          vm.onConfirmUninstallDevice();
        },
        onCancel: vm.onDismissUninstallDevice,
      ),
      child: content,
    );

    content = StateSheetHost<PredictiveAlert>(
      listenable: vm,
      value: () => _state.convertingAlert,
      onDismiss: vm.dismissConvertAlertSheet,
      sheetBuilder: (context, alert) => ConvertAlertSheet(
        state: _state,
        alert: alert,
        onQuickDate: vm.onConvertAlertQuickDate,
        onDateChange: vm.onConvertAlertDateChange,
        onTimeChange: vm.onConvertAlertTimeChange,
        onDurationChange: vm.onConvertAlertDurationChange,
        onReasonChange: vm.onConvertAlertReasonChange,
        onConfirm: () {
          onConfirmFeedback();
          vm.confirmConvertAlertToAppointment();
        },
        onCancel: vm.dismissConvertAlertSheet,
      ),
      child: content,
    );

    return content;
  }
}

/// Acciones del hub; la pantalla las cablea al ViewModel y las pruebas pasan [DiagnosticsHubActions.none].
class DiagnosticsHubActions {
  final ValueChanged<DiagnosticsHubTab> onSelectTab;
  final VoidCallback onOpenVehiclePicker;
  final VoidCallback onOpenInstallForVehicle;
  final VoidCallback onUninstallFromVehicle;
  final VoidCallback onRequestBluetoothPermission;
  final VoidCallback onRefreshAdapters;
  final ValueChanged<String> onSelectAdapter;
  final VoidCallback onConnectAdapter;
  final VoidCallback onDisconnectAdapter;
  final void Function(String vehicleId, String? plate) onOpenVehicleFaults;
  final void Function(String vehicleId, String? plate) onOpenAiHealthReport;
  final ValueChanged<String> onReportFinding;
  final Future<void> Function(DeviceStatus? filter) onFilterDevices;
  final VoidCallback onOpenRegisterDevice;
  final ValueChanged<ObdDevice> onSelectDevice;
  final ValueChanged<AlertsScope> onSetAlertsScope;
  final Future<void> Function() onRefreshAlerts;
  final ValueChanged<String> onAcknowledgeAlert;
  final ValueChanged<PredictiveAlert> onOpenConvertAlert;
  final VoidCallback onOpenNotifications;
  final VoidCallback onOpenSyncQueue;
  final VoidCallback onOpenProfile;

  const DiagnosticsHubActions({
    required this.onSelectTab,
    required this.onOpenVehiclePicker,
    required this.onOpenInstallForVehicle,
    required this.onUninstallFromVehicle,
    required this.onRequestBluetoothPermission,
    required this.onRefreshAdapters,
    required this.onSelectAdapter,
    required this.onConnectAdapter,
    required this.onDisconnectAdapter,
    required this.onOpenVehicleFaults,
    required this.onOpenAiHealthReport,
    required this.onReportFinding,
    required this.onFilterDevices,
    required this.onOpenRegisterDevice,
    required this.onSelectDevice,
    required this.onSetAlertsScope,
    required this.onRefreshAlerts,
    required this.onAcknowledgeAlert,
    required this.onOpenConvertAlert,
    required this.onOpenNotifications,
    required this.onOpenSyncQueue,
    required this.onOpenProfile,
  });

  /// Sin efectos: para previsualizar o probar la pantalla.
  factory DiagnosticsHubActions.none() {
    return DiagnosticsHubActions(
      onSelectTab: (_) {},
      onOpenVehiclePicker: () {},
      onOpenInstallForVehicle: () {},
      onUninstallFromVehicle: () {},
      onRequestBluetoothPermission: () {},
      onRefreshAdapters: () {},
      onSelectAdapter: (_) {},
      onConnectAdapter: () {},
      onDisconnectAdapter: () {},
      onOpenVehicleFaults: (_, _) {},
      onOpenAiHealthReport: (_, _) {},
      onReportFinding: (_) {},
      onFilterDevices: (_) async {},
      onOpenRegisterDevice: () {},
      onSelectDevice: (_) {},
      onSetAlertsScope: (_) {},
      onRefreshAlerts: () async {},
      onAcknowledgeAlert: (_) {},
      onOpenConvertAlert: (_) {},
      onOpenNotifications: () {},
      onOpenSyncQueue: () {},
      onOpenProfile: () {},
    );
  }
}

class DiagnosticsHubContent extends StatelessWidget {
  final DiagnosticsHubUiState state;
  final DiagnosticsHubActions actions;
  final VoidCallback? onBack;

  /// Con una hoja abierta los avisos se muestran dentro de ella y no sobre las pestañas.
  final bool sheetOpen;

  const DiagnosticsHubContent({
    super.key,
    required this.state,
    required this.actions,
    this.onBack,
    this.sheetOpen = false,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final back = onBack;
    final tabs = state.availableTabs;
    final notice = state.notice;
    final error = state.error;
    final Widget body;
    if (!state.planIncludesTelemetry && !state.planIncludesAi) {
      body = _padded(AtelierPlanLockedState(text: strings.diagHubPlanLocked));
    } else if (tabs.isEmpty && !state.planIncludesTelemetry) {
      body = _padded(AtelierPlanLockedState(text: strings.diagHubPlanLocked));
    } else if (tabs.isEmpty) {
      body = _padded(AtelierNoPermissionState(text: strings.diagHubNoPermission));
    } else {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (tabs.length > 1) _HubTabs(tabs: tabs, selected: state.selectedTab, onSelect: actions.onSelectTab),
          if (!sheetOpen && notice != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: AtelierBanner(
                message: notice.asString(strings),
                icon: Icons.check_circle_outline,
                kind: BannerKind.ok,
              ),
            ),
          if (!sheetOpen && error != null)
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, top: 16),
              child: AtelierBanner(message: error.asString(strings), icon: Icons.error_outline),
            ),
          Expanded(
            child: switch (state.selectedTab) {
              DiagnosticsHubTab.scanner => _ScannerTabContent(state: state, actions: actions),
              DiagnosticsHubTab.devices => DevicesTabContent(
                state: state,
                onFilterDevices: actions.onFilterDevices,
                onSelectDevice: actions.onSelectDevice,
              ),
              DiagnosticsHubTab.alerts => AlertsTabContent(
                state: state,
                onSetAlertsScope: actions.onSetAlertsScope,
                onRefreshAlerts: actions.onRefreshAlerts,
                onAcknowledgeAlert: actions.onAcknowledgeAlert,
                onOpenConvertAlert: actions.onOpenConvertAlert,
              ),
            },
          ),
        ],
      );
    }
    final showFab =
        state.selectedTab == DiagnosticsHubTab.devices &&
        state.planIncludesTelemetry &&
        state.canRegisterDevices &&
        state.isOnline;
    // Piso y fosa: objetivos táctiles de 56 dp para manos con grasa o guantes.
    return AtelierMinTouchTarget(
      value: AtelierMinTouchTarget.floor,
      child: Scaffold(
        floatingActionButton: showFab
            ? Padding(
                padding: EdgeInsets.only(bottom: FloatingBarInset.of(context)),
                child: AtelierFab(
                  text: strings.obdRegisterBtn,
                  icon: Icons.add,
                  onClick: actions.onOpenRegisterDevice,
                ),
              )
            : null,
        body: Column(
          children: [
            if (back != null)
              AtelierTopBar(title: strings.diagHubTitle, onBack: back)
            else
              AtelierMainTopBar(
                title: strings.diagHubTitle,
                onOpenNotifications: actions.onOpenNotifications,
                unreadNotificationsCount: state.unreadNotificationsCount,
                onOpenSync: actions.onOpenSyncQueue,
                pendingSyncCount: state.pendingSyncCount,
                onOpenProfile: actions.onOpenProfile,
              ),
            Expanded(child: body),
          ],
        ),
      ),
    );
  }

  Widget _padded(Widget child) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: child);
}

class _HubTabs extends StatelessWidget {
  final List<DiagnosticsHubTab> tabs;
  final DiagnosticsHubTab selected;
  final ValueChanged<DiagnosticsHubTab> onSelect;

  const _HubTabs({required this.tabs, required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AtelierSegmentedControl<DiagnosticsHubTab>(
        options: tabs,
        selected: selected,
        onSelect: onSelect,
        label: (tab) => switch (tab) {
          DiagnosticsHubTab.scanner => strings.diagTabScanner,
          DiagnosticsHubTab.devices => strings.diagTabDevices,
          DiagnosticsHubTab.alerts => strings.diagTabAlerts,
        },
      ),
    );
  }
}

// region Pestaña 1: Escáner

class _ScannerTabContent extends StatelessWidget {
  final DiagnosticsHubUiState state;
  final DiagnosticsHubActions actions;

  const _ScannerTabContent({required this.state, required this.actions});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final selectedVehicle = state.selectedVehicle;
    return DelayedLoading(
      loading: state.vehiclesLoading && state.workshopVehicles.isEmpty,
      builder: (context, showSkeleton) {
        final items = <Widget>[
          _vehicleSection(context, strings, selectedVehicle, showSkeleton),
          if (state.canConnectBluetooth || state.isBluetoothConnected)
            _BluetoothSection(state: state, actions: actions),
          if (selectedVehicle != null) _toolsSection(strings, selectedVehicle),
        ];
        return ListView.separated(
          padding: EdgeInsets.fromLTRB(16, 16, 16, 24 + FloatingBarInset.of(context)),
          itemCount: items.length,
          separatorBuilder: (_, _) => const SizedBox(height: 16),
          itemBuilder: (_, index) => items[index],
        );
      },
    );
  }

  Widget _vehicleSection(
    BuildContext context,
    AppLocalizations strings,
    VehicleWithOwner? selectedVehicle,
    bool showSkeleton,
  ) {
    final Widget content;
    if (showSkeleton) {
      content = const AtelierListRow(
        title: 'Toyota Hilux',
        subtitle: 'Rosa Quispe Mamani',
        plate: 'BKL482',
        loading: true,
      );
    } else if (selectedVehicle == null) {
      content = AtelierEmptyState(
        text: strings.diagVehicleNone,
        actionLabel: state.workshopVehicles.isNotEmpty ? strings.diagVehiclePick : null,
        onAction: state.workshopVehicles.isNotEmpty ? actions.onOpenVehiclePicker : null,
      );
    } else {
      final owner = selectedVehicle.owner?.displayName;
      content = AtelierSurface(
        shape: cardLargeShape,
        contentPadding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 8,
          children: [
            Row(
              spacing: 12,
              children: [
                AtelierPlate(plate: selectedVehicle.vehicle.plate, size: PlateSize.l),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${selectedVehicle.vehicle.brand} ${selectedVehicle.vehicle.model}'.trim(),
                        style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
                      ),
                      if (owner != null)
                        Text(
                          owner,
                          style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            if (state.planIncludesTelemetry && (state.canReadDevices || state.canManageInstallations)) ...[
              Divider(color: context.scheme.outlineVariant, height: 1),
              _InstallationStatusRow(
                state: state,
                onInstall: actions.onOpenInstallForVehicle,
                onUninstall: actions.onUninstallFromVehicle,
              ),
            ],
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AtelierSectionHeader(
          title: strings.diagVehicleSection,
          action: state.workshopVehicles.isNotEmpty
              ? AtelierButton(
                  text: selectedVehicle == null ? strings.diagVehiclePick : strings.diagVehicleChange,
                  onClick: actions.onOpenVehiclePicker,
                  style: AtelierButtonStyle.text,
                )
              : null,
        ),
        content,
      ],
    );
  }

  Widget _toolsSection(AppLocalizations strings, VehicleWithOwner selectedVehicle) {
    final vehicleId = selectedVehicle.vehicle.id;
    final plate = selectedVehicle.vehicle.plate;
    final workOrderId = state.selectedVehicleWorkOrderId;
    final showFinding = state.canReportFinding && workOrderId != null;
    final showFaults = state.planIncludesTelemetry && (state.canReadFaults || state.canUseTelemetry || state.canResolveFaults);
    final showAi = state.canUseAiDiagnostics || state.canReadAiReports || !state.planIncludesAi;
    return AtelierGroupedCard(
      title: strings.diagActionsSection,
      children: [
        if (showFaults)
          AtelierGroupedRow(
            title: strings.diagActionFaultsTitle,
            subtitle: strings.diagActionFaultsSub,
            icon: Icons.build_outlined,
            showDivider: showAi || showFinding,
            onClick: () => actions.onOpenVehicleFaults(vehicleId, plate),
          ),
        if (showAi)
          AtelierGroupedRow(
            title: strings.diagActionAiTitle,
            subtitle: state.planIncludesAi ? strings.diagActionAiSub : strings.diagActionAiLockedSub,
            icon: Icons.auto_awesome_outlined,
            showDivider: showFinding,
            onClick: () => actions.onOpenAiHealthReport(vehicleId, plate),
          ),
        if (showFinding)
          AtelierGroupedRow(
            title: strings.diagActionFindingTitle,
            subtitle: strings.diagActionFindingSub,
            icon: Icons.report_problem_outlined,
            showDivider: false,
            onClick: () => actions.onReportFinding(workOrderId),
          )
        else if (!showFaults && !showAi)
          Padding(
            padding: const EdgeInsets.all(16),
            child: AtelierNoPermissionState(text: strings.diagHubNoPermission),
          ),
      ],
    );
  }
}

class _InstallationStatusRow extends StatelessWidget {
  final DiagnosticsHubUiState state;
  final VoidCallback onInstall;
  final VoidCallback onUninstall;

  const _InstallationStatusRow({required this.state, required this.onInstall, required this.onUninstall});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final active = state.activeInstallation;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        Row(
          spacing: 8,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    active != null ? strings.diagInstallationActive : strings.diagInstallationNone,
                    style: context.text.labelLarge?.copyWith(color: context.scheme.onSurface),
                  ),
                  Text(
                    active != null ? strings.diagInstallationActiveSub : strings.diagInstallationNoneSub,
                    style: context.text.bodySmall?.copyWith(color: context.atelier.inkSecondary),
                  ),
                ],
              ),
            ),
            AtelierChip(
              text: active != null ? strings.obdStatusActive : strings.diagBtStatusDisconnected,
              kind: active != null ? ChipKind.ok : ChipKind.idle,
            ),
          ],
        ),
        if (!state.isOnline)
          AtelierBanner(
            message: strings.diagInstallationOffline,
            icon: Icons.info_outline,
            kind: BannerKind.info,
          )
        else if (state.canManageInstallations)
          if (active == null)
            AtelierButton(
              text: strings.diagInstallationInstallCta,
              onClick: onInstall,
              style: AtelierButtonStyle.outlined,
              enabled: !state.isLoadingInstallation && !state.isSavingDeviceAction,
              loading: state.isLoadingInstallation,
              icon: Icons.link,
            )
          else
            AtelierButton(
              text: strings.diagInstallationUninstallCta,
              onClick: onUninstall,
              style: AtelierButtonStyle.destructive,
              enabled: !state.isSavingDeviceAction,
              loading: state.isSavingDeviceAction,
              icon: Icons.link_off,
            ),
      ],
    );
  }
}

class _BluetoothSection extends StatelessWidget {
  final DiagnosticsHubUiState state;
  final DiagnosticsHubActions actions;

  const _BluetoothSection({required this.state, required this.actions});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final List<Widget> body;
    if (state.bluetoothPermissionRequired) {
      body = [
        AtelierBanner(
          message: strings.diagBtPermissionNeeded,
          icon: Icons.bluetooth,
          kind: BannerKind.wait,
        ),
        AtelierButton(
          text: strings.diagBtPermissionCta,
          onClick: actions.onRequestBluetoothPermission,
          icon: Icons.bluetooth,
        ),
      ];
    } else if (state.bluetoothDisabled) {
      body = [
        AtelierBanner(
          message: strings.diagBtDisabled,
          icon: Icons.bluetooth_disabled,
          kind: BannerKind.wait,
        ),
        AtelierButton(
          text: strings.diagBtRefresh,
          onClick: actions.onRefreshAdapters,
          style: AtelierButtonStyle.outlined,
          icon: Icons.refresh,
        ),
      ];
    } else if (state.isBluetoothConnected) {
      final protocol = state.connectionInfo?.protocol;
      final vin = state.connectionInfo?.vin;
      body = [
        AtelierSurface(
          shape: cardLargeShape,
          contentPadding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: 8,
            children: [
              if (protocol != null)
                Text(
                  strings.diagBtConnectedProtocol(protocol),
                  style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
                ),
              if (vin != null)
                Text(
                  strings.diagBtConnectedVin(vin),
                  style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
                ),
              AtelierButton(
                text: strings.diagBtDisconnect,
                onClick: actions.onDisconnectAdapter,
                style: AtelierButtonStyle.outlined,
                icon: Icons.link_off,
              ),
            ],
          ),
        ),
      ];
    } else if (state.pairedAdapters.isEmpty) {
      body = [
        AtelierEmptyState(
          text: strings.diagBtEmpty,
          actionLabel: strings.diagBtRefresh,
          onAction: actions.onRefreshAdapters,
        ),
      ];
    } else {
      body = [
        for (final adapter in state.pairedAdapters)
          AtelierSelectionCard(
            title: adapter.name.trim().isEmpty ? adapter.address : adapter.name,
            subtitle: state.devices.any((d) => d.matches(adapter.address))
                ? '${adapter.address} · ${strings.diagBtMatchedWorkshop}'
                : adapter.address,
            selected: state.selectedAdapterAddress == adapter.address,
            enabled: !state.isConnecting,
            onClick: () => actions.onSelectAdapter(adapter.address),
          ),
        Row(
          spacing: 8,
          children: [
            AtelierButton(
              text: strings.diagBtRefresh,
              onClick: actions.onRefreshAdapters,
              style: AtelierButtonStyle.outlined,
              enabled: !state.isConnecting,
              icon: Icons.refresh,
            ),
            Expanded(
              child: AtelierButton(
                text: strings.diagBtConnect,
                onClick: actions.onConnectAdapter,
                enabled: state.selectedAdapterAddress != null && !state.isConnecting,
                loading: state.isConnecting,
                icon: Icons.bluetooth_connected,
              ),
            ),
          ],
        ),
      ];
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 8,
      children: [
        AtelierSectionHeader(
          title: strings.diagBtSection,
          action: AtelierChip(
            text: obdLinkStateLabel(strings, state.linkState),
            kind: obdLinkStateChipKind(state.linkState),
            icon: state.isBluetoothConnected ? Icons.bluetooth_connected : Icons.bluetooth,
          ),
        ),
        ...body,
      ],
    );
  }
}

// endregion
