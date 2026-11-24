import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/clock_in_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/clock_out_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/get_current_location_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/is_location_permission_granted_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/observe_attendance_history_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/observe_today_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/observe_weekly_schedule_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/refresh_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/application/submit_justification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_errors.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_id.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance_validation.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/geofence.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/submit_outcome.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/presentation/attendance_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:flutter/foundation.dart';

class AttendanceViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final ObserveTodayAttendanceUseCase observeToday;
  final ObserveAttendanceHistoryUseCase observeHistory;
  final ObserveWeeklyScheduleUseCase observeSchedule;
  final RefreshAttendanceUseCase refreshAttendance;
  final ClockInUseCase clockInUseCase;
  final ClockOutUseCase clockOutUseCase;
  final SubmitJustificationUseCase submitJustificationUseCase;
  final GetCurrentLocationUseCase getCurrentLocation;
  final IsLocationPermissionGrantedUseCase isLocationPermissionGranted;

  AttendanceViewModel({
    required this.observeSession,
    required this.observeToday,
    required this.observeHistory,
    required this.observeSchedule,
    required this.refreshAttendance,
    required this.clockInUseCase,
    required this.clockOutUseCase,
    required this.submitJustificationUseCase,
    required this.getCurrentLocation,
    required this.isLocationPermissionGranted,
  }) {
    _subscriptions.add(
      observeSession.execute().listen((session) => _update(_state.copyWith(session: session))),
    );
    _subscriptions.add(
      observeToday.execute().listen((today) => _update(_state.copyWith(today: today))),
    );
    _subscriptions.add(
      observeSchedule.execute().listen(
        (schedule) => _update(_state.copyWith(schedule: schedule, clearSchedule: schedule == null)),
      ),
    );
    _subscriptions.add(
      observeHistory.execute().listen((history) => _update(_state.copyWith(history: history))),
    );
    refresh();
  }

  AttendanceUiState _state = const AttendanceUiState();
  AttendanceUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _disposed = false;

  Future<void> refresh() async {
    _update(_state.copyWith(isRefreshing: true, clearError: true, clearNotice: true));
    try {
      await refreshAttendance.execute();
    } on Object catch (e) {
      _update(_state.copyWith(error: toAttendanceUiText(e)));
    }
    _update(_state.copyWith(isRefreshing: false));
  }

  /// Si ya hay permiso de ubicación, muestra la geocerca al abrir (sin pedir nada).
  Future<void> previewLocationIfGranted() async {
    try {
      if (await isLocationPermissionGranted.execute()) await previewLocation();
    } on Object {
      // Es solo la vista previa.
    }
  }

  Future<void> clockIn() async {
    final session = _state.session;
    if (session == null) return;
    if (!session.has(Permission.attendanceClockIn)) {
      _showError(UiText.resource((s) => s.attendancePermissionClockIn));
      return;
    }
    final branchId = session.branchId;
    final shiftId = session.shiftId;
    if (branchId == null || branchId.trim().isEmpty || shiftId == null || shiftId.trim().isEmpty) {
      _showError(UiText.resource((s) => s.attendanceMissingAssignment));
      return;
    }
    _update(_state.copyWith(isSubmitting: true, clearError: true, clearNotice: true));
    try {
      final result = await clockInUseCase.execute(branchId, shiftId);
      final notice = switch (result.outcome) {
        Recorded() => UiText.resource((s) => s.attendanceClockInRecorded),
        Queued() => UiText.resource((s) => s.attendanceClockInQueued),
        AlreadyQueued() => UiText.resource((s) => s.attendanceAlreadyQueued),
      };
      final geofence = result.geofence;
      final UiText? warning;
      if (geofence != null && geofence.isMock) {
        warning = UiText.resource((s) => s.attendanceMockLocationWarning);
      } else if (geofence != null && !geofence.isInside) {
        warning = UiText.resource(
          (s) => s.attendanceOutsideGeofenceWarning(geofence.distanceMeters.toInt()),
        );
      } else {
        warning = null;
      }
      _update(
        _state.copyWith(
          notice: notice,
          locationWarning: warning,
          clearLocationWarning: warning == null,
        ),
      );
    } on Object catch (e) {
      _update(_state.copyWith(error: toAttendanceUiText(e)));
    }
    _update(_state.copyWith(isSubmitting: false));
  }

  /// Obtiene una ubicación fresca para la vista previa de la geocerca. La marcación vuelve a solicitar
  /// ubicación dentro de `ClockInUseCase`; esta vista previa nunca autoriza la marcación.
  Future<void> previewLocation() async {
    _update(_state.copyWith(isLocating: true, clearError: true, clearLocationWarning: true));
    try {
      final location = await getCurrentLocation.execute();
      final branch = _state.schedule?.branch;
      final geofence = branch == null ? null : Geofence.check(branch, location);
      final UiText? warning;
      if (location.isMock) {
        warning = UiText.resource((s) => s.attendanceMockLocationBlocked);
      } else if (!AttendanceValidation.isAccurate(location)) {
        warning = UiText.resource(
          (s) => s.attendanceLocationInaccurate(location.accuracyMeters.toInt()),
        );
      } else if (branch == null) {
        warning = UiText.resource((s) => s.attendanceBranchGeofenceUnavailable);
      } else if (geofence != null && !geofence.isInside) {
        warning = UiText.resource(
          (s) => s.attendanceOutsideGeofenceBlocked(
            geofence.distanceMeters.toInt(),
            branch.geofenceRadiusMeters.toInt(),
          ),
        );
      } else {
        warning = null;
      }
      _update(
        _state.copyWith(
          deviceLocation: location,
          locationWarning: warning,
          clearLocationWarning: warning == null,
        ),
      );
    } on Object catch (e) {
      _update(_state.copyWith(error: toAttendanceUiText(e), clearDeviceLocation: true));
    }
    _update(_state.copyWith(isLocating: false));
  }

  void onLocationPermissionDenied() =>
      _showError(UiText.resource((s) => s.attendanceLocationPermissionRequired));

  Future<void> clockOut() async {
    final session = _state.session;
    if (session == null) return;
    if (!session.has(Permission.attendanceClockOut)) {
      _showError(UiText.resource((s) => s.attendancePermissionClockOut));
      return;
    }
    _update(_state.copyWith(isSubmitting: true, clearError: true, clearNotice: true));
    try {
      final outcome = await clockOutUseCase.execute();
      final notice = switch (outcome) {
        Recorded() => UiText.resource((s) => s.attendanceClockOutRecorded),
        Queued() => UiText.resource((s) => s.attendanceClockOutQueued),
        AlreadyQueued() => UiText.resource((s) => s.attendanceAlreadyQueued),
      };
      _update(_state.copyWith(notice: notice));
    } on Object catch (e) {
      _update(_state.copyWith(error: toAttendanceUiText(e)));
    }
    _update(_state.copyWith(isSubmitting: false));
  }

  void requestJustification(Attendance attendance) {
    final session = _state.session;
    if (session == null) return;
    if (!session.has(Permission.justificationsCreate)) {
      _showError(UiText.resource((s) => s.attendancePermissionJustification));
      return;
    }
    _update(
      _state.copyWith(
        justificationFor: attendance,
        justification: '',
        clearError: true,
        clearNotice: true,
      ),
    );
  }

  void onJustificationChange(String value) {
    final text = value.length > AttendanceValidation.justificationMax
        ? value.substring(0, AttendanceValidation.justificationMax)
        : value;
    _update(_state.copyWith(justification: text, clearError: true));
  }

  void cancelJustification() {
    _update(_state.copyWith(clearJustificationFor: true, justification: ''));
  }

  Future<void> submitJustification() async {
    final attendance = _state.justificationFor;
    if (attendance == null) return;
    _update(_state.copyWith(isSubmitting: true, clearError: true, clearNotice: true));
    try {
      final outcome = await submitJustificationUseCase.execute(
        AttendanceId(attendance.id.value),
        _state.justification,
      );
      final notice = switch (outcome) {
        Recorded() => UiText.resource((s) => s.attendanceJustificationRecorded),
        Queued() => UiText.resource((s) => s.attendanceJustificationQueued),
        AlreadyQueued() => UiText.resource((s) => s.attendanceAlreadyQueued),
      };
      _update(
        _state.copyWith(notice: notice, clearJustificationFor: true, justification: ''),
      );
    } on Object catch (e) {
      _update(_state.copyWith(error: toAttendanceUiText(e)));
    }
    _update(_state.copyWith(isSubmitting: false));
  }

  void _showError(UiText error) {
    _update(_state.copyWith(error: error, clearNotice: true));
  }

  void _update(AttendanceUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}

/// El mensaje de cada error de asistencia; el resto, el `message` del backend o el genérico.
UiText toAttendanceUiText(Object error) {
  return switch (error) {
    LocationPermissionDeniedException() => UiText.resource(
      (s) => s.attendanceLocationPermissionRequired,
    ),
    LocationUnavailableException() => UiText.resource((s) => s.attendanceLocationUnavailable),
    LocationTooInaccurateException(:final accuracyMeters) => UiText.resource(
      (s) => s.attendanceLocationInaccurate(accuracyMeters.toInt()),
    ),
    MissingAssignmentException() => UiText.resource((s) => s.attendanceMissingAssignment),
    LocationOutsideGeofenceException(:final distanceMeters, :final radiusMeters) => UiText.resource(
      (s) => s.attendanceOutsideGeofenceBlocked(distanceMeters.toInt(), radiusMeters.toInt()),
    ),
    MockLocationException() => UiText.resource((s) => s.attendanceMockLocationBlocked),
    BranchGeofenceUnavailableException() => UiText.resource(
      (s) => s.attendanceBranchGeofenceUnavailable,
    ),
    InvalidJustificationException() => UiText.resource((s) => s.attendanceJustificationInvalid),
    _ => toUiText(error),
  };
}
