import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/attendance.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/device_location.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/today_attendance.dart';
import 'package:atelier_mobile_crossplatform/features/attendance/domain/weekly_schedule.dart';

/// Estado único de la pantalla de asistencia; la fuente de verdad es Drift/cola/backend.
class AttendanceUiState {
  final Session? session;
  final TodayAttendance today;
  final WeeklySchedule? schedule;
  final List<Attendance> history;
  final bool isRefreshing;
  final bool isSubmitting;
  final Attendance? justificationFor;
  final String justification;
  final UiText? error;
  final UiText? notice;
  final UiText? locationWarning;
  final DeviceLocation? deviceLocation;
  final bool isLocating;

  const AttendanceUiState({
    this.session,
    this.today = const NotClockedIn(),
    this.schedule,
    this.history = const [],
    this.isRefreshing = true,
    this.isSubmitting = false,
    this.justificationFor,
    this.justification = '',
    this.error,
    this.notice,
    this.locationWarning,
    this.deviceLocation,
    this.isLocating = false,
  });

  bool get canClockIn =>
      !isSubmitting &&
      session?.branchId != null &&
      session?.shiftId != null &&
      today is NotClockedIn;

  bool get canClockOut => !isSubmitting && (today is ClockedIn || today is ClockInQueued);

  AttendanceUiState copyWith({
    Session? session,
    TodayAttendance? today,
    WeeklySchedule? schedule,
    bool clearSchedule = false,
    List<Attendance>? history,
    bool? isRefreshing,
    bool? isSubmitting,
    Attendance? justificationFor,
    bool clearJustificationFor = false,
    String? justification,
    UiText? error,
    bool clearError = false,
    UiText? notice,
    bool clearNotice = false,
    UiText? locationWarning,
    bool clearLocationWarning = false,
    DeviceLocation? deviceLocation,
    bool clearDeviceLocation = false,
    bool? isLocating,
  }) {
    return AttendanceUiState(
      session: session ?? this.session,
      today: today ?? this.today,
      schedule: clearSchedule ? null : schedule ?? this.schedule,
      history: history ?? this.history,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      justificationFor: clearJustificationFor ? null : justificationFor ?? this.justificationFor,
      justification: justification ?? this.justification,
      error: clearError ? null : error ?? this.error,
      notice: clearNotice ? null : notice ?? this.notice,
      locationWarning: clearLocationWarning ? null : locationWarning ?? this.locationWarning,
      deviceLocation: clearDeviceLocation ? null : deviceLocation ?? this.deviceLocation,
      isLocating: isLocating ?? this.isLocating,
    );
  }
}
