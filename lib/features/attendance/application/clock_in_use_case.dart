import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_errors.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_repository.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_validation.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/geofence.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/location_provider.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/submit_outcome.dart';

/// Marcar ingreso (US06). Sin sede, sin turno, sin fix o con mala precisión no se marca. Geocerca y
/// ubicación simulada solo avisan: decide el backend, y sin red no se decide (06, regla de oro).
class ClockInUseCase {
  final AttendanceRepository repository;
  final LocationProvider locationProvider;

  const ClockInUseCase({
    required this.repository,
    required this.locationProvider,
  });

  Future<ClockInResult> execute(String? branchId, String? shiftId) async {
    if (branchId == null ||
        branchId.trim().isEmpty ||
        shiftId == null ||
        shiftId.trim().isEmpty) {
      throw const MissingAssignmentException();
    }

    final location = await locationProvider.currentLocation();
    if (!AttendanceValidation.isAccurate(location)) {
      throw LocationTooInaccurateException(location.accuracyMeters);
    }

    final branch = await repository.findBranch(branchId);
    final outcome = await repository.clockIn(branchId, shiftId, location);
    return ClockInResult(
      outcome: outcome,
      geofence: branch == null ? null : Geofence.check(branch, location),
      isMockLocation: location.isMock,
    );
  }
}
