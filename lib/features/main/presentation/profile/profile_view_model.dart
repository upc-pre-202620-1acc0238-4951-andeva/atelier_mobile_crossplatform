import 'dart:async';

import 'package:atelier_mobile_crossplatform/core/domain/session.dart';
import 'package:atelier_mobile_crossplatform/features/auth/application/get_selectable_branches_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_pending_operation_count_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_push_history_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/application/observe_session_use_case.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/profile/profile_ui_state.dart';
import 'package:flutter/foundation.dart';

/// Perfil de la cuenta. Sin "Cerrar sesión" (US04): no es parte de esta versión.
class ProfileViewModel extends ChangeNotifier {
  final ObserveSessionUseCase observeSession;
  final ObservePendingOperationCountUseCase observePendingCount;
  final ObservePushHistoryUseCase observePushHistory;
  final GetSelectableBranchesUseCase getBranches;

  /// Versión de la app, de `PackageInfo`; detrás de una función para que el ViewModel no dependa del plugin.
  final Future<String> Function() loadVersion;

  ProfileViewModel({
    required this.observeSession,
    required this.observePendingCount,
    required this.observePushHistory,
    required this.getBranches,
    required this.loadVersion,
  }) {
    _subscriptions.add(observeSession.execute().listen(_onSession));
    _subscriptions.add(
      observePendingCount.execute().listen(
        (count) => _update(_state.copyWith(pendingCount: count)),
      ),
    );
    _subscriptions.add(
      observePushHistory.execute().listen(
        (records) => _update(
          _state.copyWith(unreadNotificationsCount: records.where((r) => !r.read).length),
        ),
      ),
    );
    unawaited(_readVersion());
  }

  ProfileUiState _state = const ProfileUiState();
  ProfileUiState get state => _state;

  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _disposed = false;

  Future<void> _readVersion() async {
    try {
      _update(_state.copyWith(version: await loadVersion()));
    } on Object {
      // Sin versión no se muestra la línea.
    }
  }

  void _onSession(Session? session) {
    if (session == null) return;
    final plan = session.plan;
    final tier = plan?.tier.toLowerCase() ?? '';
    _update(
      _state.copyWith(
        fullName: session.fullName,
        email: session.email,
        tenantName: session.tenantName,
        branchId: session.branchId,
        planTier: tier.isEmpty ? '' : '${tier[0].toUpperCase()}${tier.substring(1)}',
        iotTelemetryEnabled: plan?.iotTelemetryEnabled ?? false,
        aiDiagnosticsEnabled: plan?.aiDiagnosticsEnabled ?? false,
      ),
    );
    unawaited(_resolveBranch(session.branchId, session.canSwitchBranch()));
  }

  /// Sin red conserva el estado previo: el nombre de la sede no está en la sesión.
  Future<void> _resolveBranch(String? branchId, bool allowSwitch) async {
    if (branchId == null || branchId.trim().isEmpty) return;
    try {
      final branches = await getBranches.execute();
      final name = branches.where((b) => b.id == branchId).firstOrNull?.name;
      _update(
        _state.copyWith(
          branchName: name ?? _state.branchName,
          canChangeBranch: allowSwitch && branches.length > 1,
        ),
      );
    } on Object {
      // Se conserva lo último que se supo.
    }
  }

  void _update(ProfileUiState state) {
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
