import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_banner.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_button.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_chip.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_list_row.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_live_beacon.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_sheet.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_states.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_surface.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/component/atelier_top_bar.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_shapes.dart';
import 'package:atelier_mobile_crossplatform/core/designsystem/theme/atelier_theme.dart';
import 'package:atelier_mobile_crossplatform/core/di/dependency_injection.dart';
import 'package:atelier_mobile_crossplatform/core/presentation/lima_time_format.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation.dart';
import 'package:atelier_mobile_crossplatform/features/main/domain/pending_operation_status.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/sync/pending_operations_ui_state.dart';
import 'package:atelier_mobile_crossplatform/features/main/presentation/sync/pending_operations_view_model.dart';
import 'package:atelier_mobile_crossplatform/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

/// Cola de sincronización: lo que se guardó en el teléfono y aún no llegó al servidor (asistencia, fotos, tareas,
/// propuestas y telemetría/fallas OBD-II, docs/06-offline-sync.md). Tocar una fila abre su detalle con reintentar o descartar.
class PendingOperationsScreen extends StatefulWidget {
  const PendingOperationsScreen({super.key});

  @override
  State<PendingOperationsScreen> createState() => _PendingOperationsScreenState();
}

class _PendingOperationsScreenState extends State<PendingOperationsScreen> {
  late final PendingOperationsViewModel viewModel = getIt<PendingOperationsViewModel>();

  @override
  void dispose() {
    viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) => PendingOperationsContent(
        state: viewModel.state,
        onBack: () => Navigator.of(context).maybePop(),
        onSyncNow: viewModel.onSyncNow,
        onRetry: viewModel.onRetry,
        onDiscard: viewModel.onDiscard,
      ),
    );
  }
}

class PendingOperationsContent extends StatelessWidget {
  final PendingOperationsUiState state;
  final VoidCallback onBack;
  final VoidCallback onSyncNow;
  final ValueChanged<String> onRetry;
  final ValueChanged<String> onDiscard;

  const PendingOperationsContent({
    super.key,
    required this.state,
    required this.onBack,
    required this.onSyncNow,
    required this.onRetry,
    required this.onDiscard,
  });

  void _openSheet(BuildContext context, PendingOperation operation) {
    showAtelierSheetBuilder<void>(
      context: context,
      builder: (sheetContext) => _OperationSheet(
        operation: operation,
        isOnline: state.isOnline,
        onRetry: () {
          Navigator.of(sheetContext).pop();
          onRetry(operation.id);
        },
        onDiscard: () {
          Navigator.of(sheetContext).pop();
          onDiscard(operation.id);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return Scaffold(
      body: Column(
        children: [
          AtelierTopBar(title: strings.syncQueueTitle, onBack: onBack),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                _Summary(state: state, onSyncNow: onSyncNow),
                if (!state.hasLoaded)
                  for (var i = 0; i < 3; i++)
                    const AtelierListRow(
                      title: 'Marcación de ingreso',
                      subtitle: 'Creado 16/11 08:02',
                      loading: true,
                    )
                else if (state.operations.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AtelierEmptyState(text: strings.syncEmptyLine),
                  )
                else
                  for (final operation in state.operations)
                    AtelierListRow(
                      title: operationTypeLabel(strings, operation.type),
                      subtitle: _rowSubtitle(strings, operation),
                      onClick: () => _openSheet(context, operation),
                      trailing: _OperationChip(status: operation.status),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Summary extends StatelessWidget {
  final PendingOperationsUiState state;
  final VoidCallback onSyncNow;

  const _Summary({required this.state, required this.onSyncNow});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final colors = context.atelier;
    final notice = state.notice;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: AtelierSurface(
        tier: SurfaceTier.elevated,
        shape: cardLargeShape,
        contentPadding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Row(
              spacing: 8,
              children: [
                if (state.syncingCount > 0 || state.isSyncingNow)
                  AtelierLiveBeacon(color: colors.info),
                Text(
                  strings.syncSummaryTitle,
                  style: context.text.titleMedium?.copyWith(color: context.scheme.onSurface),
                ),
              ],
            ),
            if (state.hasLoaded && state.operations.isNotEmpty)
              Text(
                strings.syncSummaryCounts(
                  state.pendingCount,
                  state.syncingCount,
                  state.failedCount,
                ),
                style: context.text.labelLarge?.copyWith(color: colors.primaryText),
              ),
            Text(
              strings.syncQueueSubtitle,
              style: context.text.bodyMedium?.copyWith(color: colors.inkSecondary),
            ),
            if (!state.isOnline)
              AtelierBanner(
                message: strings.syncStatusOffline,
                icon: Icons.info_outline,
                kind: BannerKind.wait,
              ),
            if (state.isSyncingNow && notice != null)
              AtelierBanner(
                message: notice.asString(strings),
                icon: Icons.sync_outlined,
                kind: BannerKind.info,
              ),
            if (state.operations.isNotEmpty) ...[
              AtelierButton(
                text: strings.syncNowBtn(state.operations.length),
                onClick: onSyncNow,
                enabled: state.isOnline,
                loading: state.isSyncingNow,
                icon: Icons.sync_outlined,
              ),
              if (!state.isOnline) const AtelierRequiresConnection(),
            ],
          ],
        ),
      ),
    );
  }
}

class _OperationChip extends StatelessWidget {
  final PendingOperationStatus status;

  const _OperationChip({required this.status});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    return switch (status) {
      PendingOperationStatus.pending => AtelierChip(text: strings.syncOpPending, kind: ChipKind.idle),
      PendingOperationStatus.syncing => Row(
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          AtelierLiveBeacon(color: context.atelier.info),
          AtelierChip(text: strings.syncOpSyncing, kind: ChipKind.info),
        ],
      ),
      PendingOperationStatus.failed => AtelierChip(text: strings.syncOpFailed, kind: ChipKind.bad),
    };
  }
}

/// Lo que hay que saber de un vistazo: cuándo se guardó y cuántas veces se intentó.
String _rowSubtitle(AppLocalizations strings, PendingOperation operation) =>
    strings.syncOpMeta(formatLimaStamp(operation.createdAt), operation.attempts);

/// Detalle de una operación. Reintentar solo existe si falló; descartar pierde el registro del teléfono y por
/// eso vive aquí, no en la fila. Ambas son acciones sobre la cola local: reintentar necesita red para llegar.
class _OperationSheet extends StatelessWidget {
  final PendingOperation operation;
  final bool isOnline;
  final VoidCallback onRetry;
  final VoidCallback onDiscard;

  const _OperationSheet({
    required this.operation,
    required this.isOnline,
    required this.onRetry,
    required this.onDiscard,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final error = operation.lastErrorMessage;
    final syncing = operation.status == PendingOperationStatus.syncing;
    return AtelierBottomSheet(
      title: operationTypeLabel(strings, operation.type),
      actions: [
        if (operation.status == PendingOperationStatus.failed) ...[
          if (!isOnline) const AtelierRequiresConnection(),
          AtelierButton(
            text: strings.syncRetryBtn,
            onClick: onRetry,
            enabled: isOnline,
            icon: Icons.sync_outlined,
          ),
        ],
        if (!syncing)
          AtelierButton(
            text: strings.syncDiscardBtn,
            onClick: onDiscard,
            style: AtelierButtonStyle.destructive,
          ),
      ],
      content: [
        Align(alignment: Alignment.centerLeft, child: _OperationChip(status: operation.status)),
        Text(
          _rowSubtitle(strings, operation),
          style: context.text.bodyMedium?.copyWith(color: context.atelier.inkSecondary),
        ),
        if (error != null && error.trim().isNotEmpty)
          AtelierBanner(message: error, icon: Icons.error_outline),
        if (!syncing)
          Text(
            strings.syncDiscardWarning,
            style: context.text.bodyMedium?.copyWith(color: context.scheme.onSurface),
          ),
      ],
    );
  }
}

/// Nombre legible del tipo de operación de la cola; un tipo desconocido se muestra tal cual.
String operationTypeLabel(AppLocalizations strings, String type) {
  return switch (type) {
    'CLOCK_IN' => strings.syncTypeClockIn,
    'CLOCK_OUT' => strings.syncTypeClockOut,
    'SUBMIT_JUSTIFICATION' => strings.syncTypeJustification,
    'UPLOAD_FILE' => strings.syncTypeUploadFile,
    'ATTACH_INTAKE_IMAGE' => strings.syncTypeIntakeImage,
    'ATTACH_TASK_EVIDENCE' => strings.syncTypeTaskEvidence,
    'START_TASK' => strings.syncTypeStartTask,
    'PAUSE_TASK' => strings.syncTypePauseTask,
    'RESUME_TASK' => strings.syncTypeResumeTask,
    'COMPLETE_TASK' => strings.syncTypeCompleteTask,
    'SUBMIT_PROPOSAL' => strings.syncTypeSubmitProposal,
    'TELEMETRY_BATCH' => strings.syncTypeTelemetry,
    'REGISTER_FAULT' => strings.syncTypeRegisterFault,
    'RESOLVE_FAULT' => strings.syncTypeResolveFault,
    _ => type,
  };
}
