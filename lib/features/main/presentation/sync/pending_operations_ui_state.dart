import 'package:atelier_mobile_crossplatform/core/designsystem/text/ui_text.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation_status.dart';

class PendingOperationsUiState {
  final List<PendingOperation> operations;
  final bool isOnline;
  final bool isSyncingNow;

  /// Drift ya respondió: antes de eso la lista se ve como esqueleto, no como "todo sincronizado".
  final bool hasLoaded;
  final UiText? notice;

  const PendingOperationsUiState({
    this.operations = const [],
    this.isOnline = true,
    this.isSyncingNow = false,
    this.hasLoaded = false,
    this.notice,
  });

  int get pendingCount =>
      operations.where((o) => o.status == PendingOperationStatus.pending).length;
  int get syncingCount =>
      operations.where((o) => o.status == PendingOperationStatus.syncing).length;
  int get failedCount =>
      operations.where((o) => o.status == PendingOperationStatus.failed).length;

  PendingOperationsUiState copyWith({
    List<PendingOperation>? operations,
    bool? isOnline,
    bool? isSyncingNow,
    bool? hasLoaded,
    UiText? notice,
  }) {
    return PendingOperationsUiState(
      operations: operations ?? this.operations,
      isOnline: isOnline ?? this.isOnline,
      isSyncingNow: isSyncingNow ?? this.isSyncingNow,
      hasLoaded: hasLoaded ?? this.hasLoaded,
      notice: notice ?? this.notice,
    );
  }
}
