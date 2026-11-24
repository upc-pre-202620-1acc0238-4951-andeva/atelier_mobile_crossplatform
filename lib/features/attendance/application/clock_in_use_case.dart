import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_errors.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_repository.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_validation.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/geofence.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/location_provider.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/submit_outcome.dart';

/// Marcar ingreso (US06). Sin sede, sin turno, sin fix, con mala precisión, con ubicación simulada, sin la
/// geocerca de la sede en caché o fuera de ella no se marca ni se encola. El backend repite la validación; la
/// caché permite aplicar el bloqueo también sin conexión.
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
    if (location.isMock) throw const MockLocationException();

    final branch = await repository.findBranch(branchId);
    if (branch == null) throw const BranchGeofenceUnavailableException();
    final geofence = Geofence.check(branch, location);
    if (!geofence.isInside) {
      throw LocationOutsideGeofenceException(
        geofence.distanceMeters,
        branch.geofenceRadiusMeters,
      );
    }

    final outcome = await repository.clockIn(branchId, shiftId, location);
    return ClockInResult(outcome: outcome, geofence: geofence);
  }
}
