import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/diagnostics_errors.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/dtc.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/obd_device.dart';
import 'package:atelier_mobile_crossplatform/features/diagnostics/domain/predictive_alert.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';

String _two(int value) => value.toString().padLeft(2, '0');

/// `dd/MM/yyyy HH:mm` en hora de Lima (el `DateTimeFormatter` es-PE de Android).
String formatLimaDateTime(DateTime instant) {
  final lima = instant.toUtc().add(BusinessTime.limaOffset);
  return '${_two(lima.day)}/${_two(lima.month)}/${lima.year} ${_two(lima.hour)}:${_two(lima.minute)}';
}

/// El mensaje de cada error de diagnóstico; el resto, el `message` del backend o el genérico.
UiText toDiagnosticsUiText(Object error) {
  return switch (error) {
    BluetoothPermissionDeniedException() => UiText.resource((s) => s.diagBtPermissionNeeded),
    BluetoothDisabledException() => UiText.resource((s) => s.diagBtDisabled),
    ObdAdapterUnreachableException() => UiText.resource((s) => s.diagErrAdapterUnreachable),
    ObdNoResponseException() => UiText.resource((s) => s.diagErrEcuNoResponse),
    ObdConnectionLostException() => UiText.resource((s) => s.diagErrConnectionLost),
    ObdNotConnectedException() => UiText.resource((s) => s.diagErrNotConnected),
    InsufficientTelemetryException(:final message) => UiText.resource(
      (s) => s.diagReportInsufficientTelemetry(message),
    ),
    InvalidDiagnosticsInputException(:final field) => switch (field) {
      'connectionType' => UiText.resource((s) => s.diagDeviceInvalidConnectionType),
      'deviceIdentifier' => UiText.resource((s) => s.diagDeviceIdentifierRequired),
      _ => UiText.resource((s) => s.diagInstallationOdometerInvalid),
    },
    _ => toUiText(error),
  };
}

String obdLinkStateLabel(AppLocalizations s, ObdLinkState state) {
  return switch (state) {
    ObdLinkState.disconnected => s.diagBtStatusDisconnected,
    ObdLinkState.connecting => s.diagBtStatusConnecting,
    ObdLinkState.connected => s.diagBtStatusConnected,
    ObdLinkState.streaming => s.diagBtStatusStreaming,
    ObdLinkState.reconnecting => s.diagBtStatusReconnecting,
    ObdLinkState.lost => s.diagBtStatusLost,
  };
}

ChipKind obdLinkStateChipKind(ObdLinkState state) {
  return switch (state) {
    ObdLinkState.disconnected => ChipKind.idle,
    ObdLinkState.connecting || ObdLinkState.reconnecting => ChipKind.wait,
    ObdLinkState.connected => ChipKind.ok,
    ObdLinkState.streaming => ChipKind.info,
    ObdLinkState.lost => ChipKind.bad,
  };
}

String deviceStatusLabel(AppLocalizations s, DeviceStatus status) {
  return switch (status) {
    DeviceStatus.active => s.obdStatusActive,
    DeviceStatus.inactive => s.obdStatusInactive,
    DeviceStatus.lost => s.obdStatusLost,
    DeviceStatus.broken => s.obdStatusBroken,
  };
}

ChipKind deviceStatusChipKind(DeviceStatus status) {
  return switch (status) {
    DeviceStatus.active => ChipKind.ok,
    DeviceStatus.inactive => ChipKind.idle,
    DeviceStatus.lost || DeviceStatus.broken => ChipKind.bad,
  };
}

String faultSeverityLabel(AppLocalizations s, FaultSeverity severity) {
  return switch (severity) {
    FaultSeverity.critical => s.diagFaultsSeverityCritical,
    FaultSeverity.medium => s.diagFaultsSeverityMedium,
    FaultSeverity.low => s.diagFaultsSeverityLow,
  };
}

ChipKind faultSeverityChipKind(FaultSeverity severity) {
  return switch (severity) {
    FaultSeverity.critical => ChipKind.bad,
    FaultSeverity.medium => ChipKind.warn,
    FaultSeverity.low => ChipKind.idle,
  };
}

String predictiveAlertTypeLabel(AppLocalizations s, PredictiveAlertType? type) {
  return switch (type) {
    PredictiveAlertType.engineOverheatingRisk => s.diagAlertTypeOverheating,
    PredictiveAlertType.batteryFailureRisk => s.diagAlertTypeBattery,
    PredictiveAlertType.catalyticSystemDegradation => s.diagAlertTypeCatalytic,
    PredictiveAlertType.cylinderMisfireHazard => s.diagAlertTypeMisfire,
    PredictiveAlertType.brakeWear => s.diagAlertTypeBrake,
    PredictiveAlertType.oilLifeDepletion => s.diagAlertTypeOil,
    PredictiveAlertType.emissionsFailure => s.diagAlertTypeEmissions,
    null => s.diagAlertTypeGeneric,
  };
}

String predictiveAlertStatusLabel(AppLocalizations s, PredictiveAlertStatus status) {
  return switch (status) {
    PredictiveAlertStatus.dispatched => s.diagAlertStatusDispatched,
    PredictiveAlertStatus.acknowledged => s.diagAlertStatusAcknowledged,
    PredictiveAlertStatus.resolved => s.diagAlertStatusResolved,
    PredictiveAlertStatus.dismissed => s.diagAlertStatusDismissed,
  };
}

ChipKind predictiveAlertStatusChipKind(PredictiveAlertStatus status) {
  return switch (status) {
    PredictiveAlertStatus.dispatched => ChipKind.wait,
    PredictiveAlertStatus.acknowledged || PredictiveAlertStatus.resolved => ChipKind.ok,
    PredictiveAlertStatus.dismissed => ChipKind.idle,
  };
}
