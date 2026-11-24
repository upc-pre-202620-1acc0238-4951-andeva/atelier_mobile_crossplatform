import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_plate.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_selection_card.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_text_field.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_device.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/predictive_alert.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/diagnostics_ui_formatters.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/hub/diagnostics_hub_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/reception/domain/vehicle.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

String _vehicleModelOf(VehicleWithOwner item) => '${item.vehicle.brand} ${item.vehicle.model}'.trim();

/// Detalle de un escáner (tipo de conexión, modelo y firmware) para la fila de la lista y la hoja de acciones.
String diagnosticsDeviceDetails(AppLocalizations strings, ObdDevice device) {
  final firmware = device.firmwareVersion;
  return [
    ?device.connectionType,
    ?device.hardwareModel,
    if (firmware != null) strings.obdFirmwareFormat(firmware),
  ].join(' · ');
}

Widget _errorBanner(UiText error, AppLocalizations strings) {
  return AtelierBanner(message: error.asString(strings), icon: Icons.error_outline);
}

class VehiclePickerSheet extends StatelessWidget {
  final String query;
  final List<VehicleWithOwner> vehicles;
  final String? selectedVehicleId;
  final ValueChanged<String> onQueryChange;
  final ValueChanged<String> onSelectVehicle;

  const VehiclePickerSheet({
    super.key,
    required this.query,
    required this.vehicles,
    required this.selectedVehicleId,
    required this.onQueryChange,
    required this.onSelectVehicle,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AtelierBottomSheet(
      title: strings.diagVehicleSheetTitle,
      content: [
        AtelierTextField(
          label: strings.diagVehicleSearchLabel,
          value: query,
          onValueChange: onQueryChange,
          leadingIcon: Icons.search,
          placeholder: strings.diagVehicleSearchHint,
          textInputAction: TextInputAction.search,
        ),
        if (vehicles.isEmpty)
          AtelierEmptyState(text: strings.diagVehicleEmptySearch)
        else
          for (final item in vehicles)
            AtelierListRow(
              title: _vehicleModelOf(item),
              subtitle: item.owner?.displayName,
              plate: item.vehicle.plate,
              onClick: () => onSelectVehicle(item.vehicle.id),
              trailing: item.vehicle.id == selectedVehicleId
                  ? AtelierChip(text: strings.obdStatusActive, kind: ChipKind.ok)
                  : null,
            ),
      ],
    );
  }
}

class InstallOnVehicleSheet extends StatelessWidget {
  final DiagnosticsHubUiState state;
  final ValueChanged<String> onOdometerChange;
  final ValueChanged<ObdDevice> onSelectDevice;

  const InstallOnVehicleSheet({
    super.key,
    required this.state,
    required this.onOdometerChange,
    required this.onSelectDevice,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final activeDevices = state.devices.where((d) => d.status == DeviceStatus.active).toList();
    return AtelierBottomSheet(
      title: strings.obdInstallDialogTitle,
      content: [
        if (!state.isOnline) const AtelierRequiresConnection(),
        AtelierTextField(
          label: strings.diagInstallationOdometerLabel,
          value: state.installOdometerInput,
          onValueChange: onOdometerChange,
          placeholder: strings.diagInstallationOdometerHint,
          isError: state.installOdometerInvalid,
          errorText: state.installOdometerInvalid ? strings.diagInstallationOdometerInvalid : null,
          enabled: !state.isSavingDeviceAction,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        Text(
          strings.diagInstallationChooseDevice,
          style: context.text.titleSmall?.copyWith(color: context.atelier.inkSecondary),
        ),
        if (state.error != null) _errorBanner(state.error!, strings),
        if (activeDevices.isEmpty)
          AtelierEmptyState(text: strings.diagInstallationNoActiveDevices)
        else
          for (final device in activeDevices)
            Builder(
              builder: (context) {
                final selected = state.selectedAdapterAddress;
                final matches = selected != null && device.matches(selected);
                final subtitle = [
                  ?device.hardwareModel,
                  if (matches) strings.diagBtMatchedWorkshop,
                ].join(' · ');
                return AtelierListRow(
                  title: device.deviceIdentifier,
                  subtitle: subtitle.isEmpty ? null : subtitle,
                  onClick: state.isOnline && !state.isSavingDeviceAction ? () => onSelectDevice(device) : null,
                );
              },
            ),
      ],
    );
  }
}

class DeviceActionsSheet extends StatelessWidget {
  final ObdDevice device;
  final DeviceInstallationSummary? installation;
  final bool canInstall;
  final bool canChangeStatus;
  final bool isOnline;
  final VoidCallback onChangeStatus;
  final VoidCallback onInstall;
  final VoidCallback onUninstall;

  const DeviceActionsSheet({
    super.key,
    required this.device,
    required this.installation,
    required this.canInstall,
    required this.canChangeStatus,
    required this.isOnline,
    required this.onChangeStatus,
    required this.onInstall,
    required this.onUninstall,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final status = device.status;
    final details = diagnosticsDeviceDetails(strings, device);
    final install = installation;
    final vehicleModel = install?.vehicleModel;
    return AtelierBottomSheet(
      title: device.deviceIdentifier,
      actions: [
        if (!isOnline) const AtelierRequiresConnection(),
        if (canInstall)
          if (install != null)
            AtelierButton(
              text: strings.obdUninstallBtn,
              onClick: onUninstall,
              style: AtelierButtonStyle.destructive,
              enabled: isOnline,
              icon: Icons.link_off,
            )
          else
            AtelierButton(
              text: strings.obdInstallBtn,
              onClick: onInstall,
              enabled: isOnline,
              icon: Icons.link,
            ),
        if (canChangeStatus)
          AtelierButton(
            text: strings.obdChangeStatusBtn,
            onClick: onChangeStatus,
            style: AtelierButtonStyle.outlined,
            enabled: isOnline,
          ),
      ],
      content: [
        if (status != null) AtelierChip(text: deviceStatusLabel(strings, status), kind: deviceStatusChipKind(status)),
        if (details.trim().isNotEmpty)
          Text(details, style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary)),
        Text(
          install == null
              ? strings.obdNotConnected
              : [install.plate, if (vehicleModel != null && vehicleModel.isNotEmpty) vehicleModel].join(' · '),
          style: context.text.bodyLarge?.copyWith(color: context.scheme.onSurface),
        ),
      ],
    );
  }
}

class RegisterDeviceSheet extends StatelessWidget {
  final RegisterObdDeviceForm form;
  final bool isOnline;
  final bool isSaving;
  final UiText? error;
  final ValueChanged<String> onIdentifierChange;
  final ValueChanged<String> onConnectionTypeChange;
  final ValueChanged<String> onHardwareModelChange;
  final ValueChanged<String> onFirmwareVersionChange;
  final VoidCallback onConfirm;

  const RegisterDeviceSheet({
    super.key,
    required this.form,
    required this.isOnline,
    required this.isSaving,
    required this.error,
    required this.onIdentifierChange,
    required this.onConnectionTypeChange,
    required this.onHardwareModelChange,
    required this.onFirmwareVersionChange,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final types = [
      ('BLUETOOTH_BLE', strings.obdConnBluetoothBle),
      ('BLUETOOTH', strings.obdConnBluetooth),
      ('WIFI', strings.obdConnWifi),
      ('USB', strings.obdConnUsb),
    ];
    return AtelierBottomSheet(
      title: strings.obdRegisterDialogTitle,
      actions: [
        if (!isOnline) const AtelierRequiresConnection(),
        AtelierButton(
          text: strings.obdRegisterConfirm,
          onClick: onConfirm,
          enabled: form.canSubmit && isOnline && !isSaving,
          loading: isSaving,
        ),
      ],
      content: [
        AtelierTextField(
          label: strings.obdFieldIdentifier,
          value: form.deviceIdentifier,
          onValueChange: onIdentifierChange,
          placeholder: strings.obdHintIdentifier,
          enabled: !isSaving,
        ),
        Text(
          strings.obdFieldConnectionType,
          style: context.text.titleSmall?.copyWith(color: context.scheme.onSurface),
        ),
        for (final (key, label) in types)
          AtelierSelectionCard(
            title: label,
            selected: form.connectionType == key,
            enabled: !isSaving,
            onClick: () => onConnectionTypeChange(key),
          ),
        AtelierTextField(
          label: strings.obdFieldModel,
          value: form.hardwareModel,
          onValueChange: onHardwareModelChange,
          placeholder: strings.obdHintModel,
          enabled: !isSaving,
        ),
        AtelierTextField(
          label: strings.obdFieldFirmware,
          value: form.firmwareVersion,
          onValueChange: onFirmwareVersionChange,
          placeholder: strings.obdHintFirmware,
          enabled: !isSaving,
        ),
        if (error != null) _errorBanner(error!, strings),
      ],
    );
  }
}

/// Cambio de estado operativo de un escáner (`editingStatusDevice`).
class DeviceStatusSheet extends StatelessWidget {
  final DiagnosticsHubUiState state;
  final ObdDevice device;
  final ValueChanged<DeviceStatus> onUpdateStatus;

  const DeviceStatusSheet({
    super.key,
    required this.state,
    required this.device,
    required this.onUpdateStatus,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AtelierBottomSheet(
      title: device.deviceIdentifier,
      content: [
        Text(
          strings.obdChangeStatusPrompt,
          style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
        ),
        if (!state.isOnline) const AtelierRequiresConnection(),
        if (state.error != null) _errorBanner(state.error!, strings),
        for (final status in DeviceStatus.values)
          AtelierSelectionCard(
            title: deviceStatusLabel(strings, status),
            selected: device.status == status,
            enabled: state.isOnline && !state.isSavingDeviceAction,
            onClick: () => onUpdateStatus(status),
          ),
      ],
    );
  }
}

/// Elegir el vehículo donde se vincula un escáner desde la pestaña Dispositivos (`installingDevice`).
class InstallDeviceSheet extends StatelessWidget {
  final DiagnosticsHubUiState state;
  final ValueChanged<VehicleWithOwner> onConfirmInstall;

  const InstallDeviceSheet({super.key, required this.state, required this.onConfirmInstall});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return AtelierBottomSheet(
      title: strings.obdInstallDialogTitle,
      content: [
        Text(
          strings.obdInstallSelectPrompt,
          style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
        ),
        if (!state.isOnline) const AtelierRequiresConnection(),
        if (state.error != null) _errorBanner(state.error!, strings),
        if (state.workshopVehicles.isEmpty)
          AtelierEmptyState(text: strings.obdNoVehicles)
        else
          for (final item in state.workshopVehicles.take(8))
            Builder(
              builder: (context) {
                final alreadyInstalled = state.deviceInstallations.values.any((i) => i.vehicleId == item.vehicle.id);
                return AtelierListRow(
                  title: _vehicleModelOf(item),
                  subtitle: alreadyInstalled ? strings.obdVehicleHasScanner : item.owner?.displayName,
                  plate: item.vehicle.plate,
                  onClick: alreadyInstalled || !state.isOnline || state.isSavingDeviceAction
                      ? null
                      : () => onConfirmInstall(item),
                );
              },
            ),
      ],
    );
  }
}

/// Confirmación de desvincular un escáner (`uninstallingDevice`).
class UninstallDeviceSheet extends StatelessWidget {
  final DiagnosticsHubUiState state;
  final ObdDevice device;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const UninstallDeviceSheet({
    super.key,
    required this.state,
    required this.device,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final installInfo = state.deviceInstallations[device.id];
    return AtelierBottomSheet(
      title: strings.obdUninstallConfirmTitle,
      actions: [
        if (!state.isOnline) const AtelierRequiresConnection(),
        AtelierButton(
          text: strings.obdUninstallBtn,
          onClick: onConfirm,
          style: AtelierButtonStyle.destructiveFilled,
          enabled: state.isOnline && !state.isSavingDeviceAction,
          loading: state.isSavingDeviceAction,
        ),
        AtelierButton(
          text: strings.commonCancel,
          onClick: onCancel,
          style: AtelierButtonStyle.text,
          enabled: !state.isSavingDeviceAction,
        ),
      ],
      content: [
        Text(
          strings.obdUninstallConfirmPrompt(installInfo?.plate ?? device.deviceIdentifier),
          style: context.text.bodyLarge?.copyWith(color: context.scheme.onSurface),
        ),
        if (state.error != null) _errorBanner(state.error!, strings),
      ],
    );
  }
}

/// Agendar una cita preventiva a partir de una alerta (`convertingAlert`).
class ConvertAlertSheet extends StatelessWidget {
  final DiagnosticsHubUiState state;
  final PredictiveAlert alert;
  final ValueChanged<int> onQuickDate;
  final ValueChanged<String> onDateChange;
  final ValueChanged<String> onTimeChange;
  final ValueChanged<String> onDurationChange;
  final ValueChanged<String> onReasonChange;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  const ConvertAlertSheet({
    super.key,
    required this.state,
    required this.alert,
    required this.onQuickDate,
    required this.onDateChange,
    required this.onTimeChange,
    required this.onDurationChange,
    required this.onReasonChange,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final busy = state.isActingOnAlert;
    String? plate;
    for (final item in state.workshopVehicles) {
      if (item.vehicle.id == alert.vehicleId) plate = item.vehicle.plate;
    }
    final quickDates = [
      (0, strings.diagAlertsConvertToday),
      (1, strings.diagAlertsConvertTomorrow),
      (2, strings.diagAlertsConvertIn2Days),
    ];
    return AtelierBottomSheet(
      title: strings.diagAlertsConvertTitle,
      actions: [
        if (!state.isOnline) const AtelierRequiresConnection(),
        AtelierButton(
          text: strings.diagAlertsConvertConfirm,
          onClick: onConfirm,
          enabled: state.isOnline && !busy,
          loading: busy,
          icon: Icons.event_available_outlined,
        ),
        AtelierButton(
          text: strings.commonCancel,
          onClick: onCancel,
          style: AtelierButtonStyle.text,
          enabled: !busy,
        ),
      ],
      content: [
        if (plate != null && plate.trim().isNotEmpty) Align(
          alignment: Alignment.centerLeft,
          child: AtelierPlate(plate: plate, size: PlateSize.l),
        ),
        Text(
          predictiveAlertTypeLabel(strings, alert.alertType),
          style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
        ),
        Text(
          strings.diagAlertsConvertBody,
          style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
        ),
        Wrap(
          spacing: 4,
          children: [
            for (final (days, label) in quickDates)
              FilterChip(
                selected: false,
                onSelected: busy ? null : (_) => onQuickDate(days),
                label: Text(label),
              ),
          ],
        ),
        Row(
          spacing: 8,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AtelierTextField(
                label: strings.diagAlertsConvertDateLabel,
                value: state.convertAlertDateText,
                onValueChange: onDateChange,
                enabled: !busy,
                keyboardType: TextInputType.visiblePassword,
                autocorrect: false,
              ),
            ),
            Expanded(
              child: AtelierTextField(
                label: strings.diagAlertsConvertTimeLabel,
                value: state.convertAlertTimeText,
                onValueChange: onTimeChange,
                enabled: !busy,
                keyboardType: TextInputType.visiblePassword,
                autocorrect: false,
              ),
            ),
          ],
        ),
        Wrap(
          spacing: 4,
          children: [
            for (final slot in const ['09:00', '11:00', '15:00'])
              FilterChip(
                selected: state.convertAlertTimeText == slot,
                onSelected: busy ? null : (_) => onTimeChange(slot),
                label: Text(slot),
              ),
          ],
        ),
        AtelierTextField(
          label: strings.diagAlertsConvertDurationLabel,
          value: state.convertAlertDurationText,
          onValueChange: onDurationChange,
          enabled: !busy,
          keyboardType: TextInputType.number,
        ),
        AtelierTextField(
          label: strings.diagAlertsConvertReasonLabel,
          value: state.convertAlertReason,
          onValueChange: onReasonChange,
          enabled: !busy,
        ),
        if (state.error != null) _errorBanner(state.error!, strings),
      ],
    );
  }
}
