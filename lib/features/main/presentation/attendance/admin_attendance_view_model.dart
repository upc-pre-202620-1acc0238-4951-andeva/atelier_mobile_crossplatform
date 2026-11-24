import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/data/remote/connectivity_observer.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/core/domain/business_time.dart';
import 'package:atelier_mobile_crossplatform/core/domain/permission.dart';
import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/get_selectable_branches_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/attendance/admin_attendance_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/approve_justification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/get_branch_daily_attendance_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/get_pending_justifications_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/application/reject_justification_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/team/domain/team_attendance.dart';
import 'package:flutter/foundation.dart';

class AdminAttendanceViewModel extends ChangeNotifier {
  /// Cuánto se queda a la vista el resultado de una decisión antes de retirarse de la lista.
  static const resolvedLinger = Duration(milliseconds: 1600);

  final ObserveSessionUseCase observeSession;
  final GetSelectableBranchesUseCase getBranches;
  final GetBranchDailyAttendanceUseCase getBranchDaily;
  final GetPendingJustificationsUseCase getPendingJustifications;
  final ApproveJustificationUseCase approveJustification;
  final RejectJustificationUseCase rejectJustification;
  final ConnectivityObserver connectivity;
  final BusinessTime time;
  final Duration linger;

  AdminAttendanceViewModel({
    required this.observeSession,
    required this.getBranches,
    required this.getBranchDaily,
    required this.getPendingJustifications,
    required this.approveJustification,
    required this.rejectJustification,
    required this.connectivity,
    this.time = const BusinessTime(),
    this.linger = resolvedLinger,
  }) {
    _state = AdminAttendanceUiState(today: time.today(), isOnline: connectivity.isOnline);
    _subscription = observeSession.execute().listen(_onSession);
    connectivity.addListener(_onConnectivity);
    refresh();
  }

  late AdminAttendanceUiState _state;
  AdminAttendanceUiState get state => _state;

  late final StreamSubscription<Session?> _subscription;
  Session? _session;
  String? _lastBranchId;
  bool _disposed = false;

  void _onConnectivity() => _update(_state.copyWith(isOnline: connectivity.isOnline));

  void _onSession(Session? session) {
    final branchChanged = _lastBranchId != null && session?.branchId != _lastBranchId;
    _lastBranchId = session?.branchId;
    _session = session;
    final audit = session?.has(Permission.attendanceAuditAll) ?? false;
    _update(
      _state.copyWith(
        session: session,
        canAuditAll: audit,
        canClockIn: session?.has(Permission.attendanceClockIn) ?? false,
        canApproveJustifications: session?.has(Permission.justificationsApprove) ?? false,
        // Sin permiso de auditar, lo único que queda es la asistencia propia.
        tab: audit ? _state.tab : TeamTab.mine,
      ),
    );
    if (branchChanged) refresh();
  }

  void onTabChange(TeamTab tab) => _update(_state.copyWith(tab: tab));

  Future<void> refresh() async {
    if (_state.isRefreshing) return;
    _update(_state.copyWith(isRefreshing: true, clearError: true));
    final session = _session ?? await observeSession.execute().first;
    if (!(session?.has(Permission.attendanceAuditAll) ?? false)) {
      _update(_state.copyWith(isRefreshing: false, hasLoaded: true));
      return;
    }
    Object? failure;
    if (session!.has(Permission.branchesRead)) {
      try {
        final branches = await getBranches.execute();
        final name = branches.where((b) => b.id == session.branchId).firstOrNull?.name;
        _update(_state.copyWith(branchName: name));
      } on Object {
        // Sin red se conserva el nombre previo.
      }
    }
    try {
      final records = await getBranchDaily.execute(_state.today);
      _update(_state.copyWith(records: records));
    } on Object catch (e) {
      failure = e;
    }
    try {
      final pending = await getPendingJustifications.execute();
      _update(
        _state.copyWith(
          justifications: pending.items.where((item) => item.awaitsReview).toList(),
          failedJustificationDays: pending.failedDates.length,
          resolved: const {},
        ),
      );
    } on Object {
      // Sin consulta no hay decisiones nuevas.
    }
    _update(
      _state.copyWith(
        isRefreshing: false,
        hasLoaded: true,
        error: failure == null ? null : toUiText(failure),
      ),
    );
  }

  void onOpenJustification(TeamAttendance item) {
    if (_state.resolved.containsKey(item.id)) return;
    _update(_state.copyWith(reviewing: item, clearReviewError: true));
  }

  void onDismissJustification() {
    if (_state.isSubmittingReview) return;
    _update(_state.copyWith(clearReviewing: true, clearReviewError: true));
  }

  Future<void> onReviewJustification(bool approve) async {
    final item = _state.reviewing;
    if (item == null ||
        !_state.canApproveJustifications ||
        _state.isSubmittingReview ||
        !_state.isOnline) {
      return;
    }
    _update(_state.copyWith(isSubmittingReview: true, clearReviewError: true));
    try {
      if (approve) {
        await approveJustification.execute(item.id);
      } else {
        await rejectJustification.execute(item.id);
      }
    } on Object catch (e) {
      _update(_state.copyWith(isSubmittingReview: false, reviewError: toUiText(e)));
      return;
    }
    _update(
      _state.copyWith(
        isSubmittingReview: false,
        clearReviewing: true,
        resolved: {..._state.resolved, item.id: approve},
      ),
    );
    await Future<void>.delayed(linger);
    final remaining = {..._state.resolved}..remove(item.id);
    _update(
      _state.copyWith(
        justifications: _state.justifications.where((j) => j.id != item.id).toList(),
        resolved: remaining,
      ),
    );
  }

  void _update(AdminAttendanceUiState state) {
    if (_disposed) return;
    _state = state;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    connectivity.removeListener(_onConnectivity);
    _subscription.cancel();
    super.dispose();
  }
}
