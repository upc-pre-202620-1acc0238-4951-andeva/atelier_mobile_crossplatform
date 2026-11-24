import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_navigation_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_segmented_control.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_skeleton.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_device.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/diagnostics_ui_formatters.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/hub/diagnostics_hub_sheets.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/presentation/hub/diagnostics_hub_ui_state.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Pestaña "Dispositivos": inventario de escáneres OBD-II del taller con filtro por estado.
class DevicesTabContent extends StatelessWidget {
  final DiagnosticsHubUiState state;
  final Future<void> Function(DeviceStatus? filter) onFilterDevices;
  final ValueChanged<ObdDevice> onSelectDevice;

  const DevicesTabContent({
    super.key,
    required this.state,
    required this.onFilterDevices,
    required this.onSelectDevice,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final canManage = state.canManageInstallations || state.canRegisterDevices;
    return DelayedLoading(
      loading: state.isLoadingDevices && state.devices.isEmpty,
      builder: (context, showSkeleton) {
        final children = <Widget>[
          if (showSkeleton)
            for (var i = 0; i < 4; i++)
              const AtelierListRow(
                title: 'AA:BB:CC:11:22:33',
                subtitle: 'BLUETOOTH_BLE · ELM327',
                plate: 'BKL482',
                loading: true,
              )
          else if (state.devices.isEmpty && state.error != null && !state.isOnline)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AtelierOfflineState(onRetry: () => onFilterDevices(state.deviceStatusFilter)),
            )
          else if (state.devices.isEmpty && state.error != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AtelierErrorState(
                message: state.error!.asString(strings),
                onRetry: () => onFilterDevices(state.deviceStatusFilter),
              ),
            )
          else if (state.devices.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: AtelierEmptyState(text: strings.obdEmptyList),
            )
          else
            for (final device in state.devices) _deviceRow(strings, device, canManage),
        ];
        return Column(
          children: [
            _DeviceFilterRow(selected: state.deviceStatusFilter, onFilterChange: onFilterDevices),
            AtelierRefreshBar(visible: state.isLoadingDevices && state.devices.isNotEmpty),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () => onFilterDevices(state.deviceStatusFilter),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.only(bottom: 96 + FloatingBarInset.of(context)),
                  children: children,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _deviceRow(AppLocalizations strings, ObdDevice device, bool canManage) {
    final install = state.deviceInstallations[device.id];
    final details = diagnosticsDeviceDetails(strings, device);
    final String vehicleLabel;
    if (install != null) {
      vehicleLabel = [if (install.vehicleModel.isNotEmpty) install.vehicleModel, ?install.ownerName].join(' · ');
    } else {
      vehicleLabel = strings.obdNotConnected;
    }
    final status = device.status;
    return AtelierListRow(
      title: device.deviceIdentifier,
      subtitle: [vehicleLabel, details].where((part) => part.trim().isNotEmpty).join(' · '),
      plate: install?.plate,
      onClick: canManage ? () => onSelectDevice(device) : null,
      trailing: status == null
          ? null
          : AtelierChip(text: deviceStatusLabel(strings, status), kind: deviceStatusChipKind(status)),
    );
  }
}

class _DeviceFilterRow extends StatelessWidget {
  final DeviceStatus? selected;
  final Future<void> Function(DeviceStatus? filter) onFilterChange;

  const _DeviceFilterRow({required this.selected, required this.onFilterChange});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final labels = {
      null: strings.obdFilterAll,
      DeviceStatus.active: strings.obdFilterActive,
      DeviceStatus.inactive: strings.obdFilterInactive,
    };
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: AtelierSegmentedControl<DeviceStatus?>(
        options: const [null, DeviceStatus.active, DeviceStatus.inactive],
        selected: selected,
        onSelect: onFilterChange,
        label: (option) => labels[option] ?? '',
      ),
    );
  }
}
