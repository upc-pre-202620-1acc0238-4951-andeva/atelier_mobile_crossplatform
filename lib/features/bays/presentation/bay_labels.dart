import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/features/bays/domain/work_bay.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';

/// Tipos que se ofrecen al registrar. El backend admite además `WASHING` y `ALIGNMENT_STATION`, que se muestran
/// con el rótulo de su equivalente.
const creatableBayTypes = [
  BayType.lift,
  BayType.mechanicalLift,
  BayType.diagnosticPit,
  BayType.washBay,
  BayType.alignment,
  BayType.paintBooth,
];

/// `null` si el backend envió un tipo que esta versión no conoce.
String? bayTypeLabel(AppLocalizations strings, BayType? type) => switch (type) {
  BayType.lift => strings.bayTypeLift,
  BayType.mechanicalLift => strings.bayTypeMechanicalLift,
  BayType.diagnosticPit => strings.bayTypeDiagnosticPit,
  BayType.washBay || BayType.washing => strings.bayTypeWashBay,
  BayType.alignment || BayType.alignmentStation => strings.bayTypeAlignment,
  BayType.paintBooth => strings.bayTypePaintBooth,
  null => null,
};

String? bayStatusLabel(AppLocalizations strings, BayStatus? status) => switch (status) {
  BayStatus.available => strings.bayStatusAvailable,
  BayStatus.occupied => strings.bayStatusOccupied,
  BayStatus.maintenance => strings.bayStatusMaintenance,
  null => null,
};

ChipKind bayStatusChipKind(BayStatus? status) => switch (status) {
  BayStatus.available => ChipKind.ok,
  BayStatus.occupied => ChipKind.info,
  BayStatus.maintenance => ChipKind.wait,
  null => ChipKind.idle,
};

/// `01:20`: horas y minutos de mano de obra.
String formatLaborElapsed(Duration elapsed) {
  final total = elapsed.isNegative ? 0 : elapsed.inMinutes;
  String two(int value) => value.toString().padLeft(2, '0');
  return '${two(total ~/ 60)}:${two(total % 60)}';
}
