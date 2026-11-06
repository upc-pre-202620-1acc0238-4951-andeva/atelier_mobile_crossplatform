import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_errors.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_id.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_repository.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_validation.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/submit_outcome.dart';

/// Enviar descargo de una tardanza o ausencia propia (US10 E1). El dictamen llega por push
/// `JUSTIFICATION_REVIEWED`.
class SubmitJustificationUseCase {
  final AttendanceRepository repository;

  const SubmitJustificationUseCase({required this.repository});

  Future<SubmitOutcome> execute(AttendanceId id, String reason) async {
    if (!AttendanceValidation.isJustification(reason)) {
      throw const InvalidJustificationException();
    }
    return repository.submitJustification(id, reason);
  }
}
